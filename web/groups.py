'''
    File: groups.py
    Author: Colby Ing
    -----------------
    Handles all database work that has to do with groups
'''

import utils
from db import db_session
import models
import db
from sqlalchemy import and_
import random
import datetime
import groups
from flask import Response
import messages

NUM_COLORS = 10
NOT_BROADCASTING = 2
EPS = 0.00001

'''
    Implements the /facebook/user/<user_id>/friendgroups endpoint
    Returns a list of groups containing information about users
    in the following format:

    { groups: [
            group: {
                users: [
                        user: {
                           firstname, last name, fb id, etc.
                           }
               latlocation,
               longlocation,
               groupID
           }
       ]
    }
'''
def get_user_friend_groups(user_id):
    # gets all the users who active and friends with the user
    users_are_friends = db_session.query(models.Friend).filter(models.Friend.right_id == user_id).all()

    if users_are_friends:
        return get_groups_users_map(users_are_friends)
    return utils.error_json_message("You have no friends")

# Helper function for get_user_friend_groups
def get_groups_users_map(friends):
    # creating a map from groups to users
    result = dict()

    print friends

    for friend_id in friends:
        friend = db_session.query(models.User).filter(models.User.fb_id == friend_id.left_id).first()
        print friend
        if friend:
            if friend.group_id in result.keys():
                result[friend.group_id].append(utils.obj_to_json(None, friend, False))
            else:
                result[friend.group_id] = [utils.obj_to_json(None, friend, False)]

    # now that we have a dictionary mapping from
    # groups -> users
    # we need the information about the groups
    group_array = []

    for group_id in result.keys():
        group = db_session.query(models.Group).filter(models.Group.id == group_id).first()
        group_array.append(group)

    print group_array

    return utils.list_to_json("groups", group_array)

'''
    Function: change_group_id
    params: fb_id, the facebook id
            new_group, the integer of the new group_id
    return: the JSON information of the user
'''
def change_group_id(fb_id, new_group, passcode):
    result = db_session.query(models.User).filter(models.User.fb_id == fb_id).first()
    new_grp = db_session.query(models.Group).filter(models.Group.id == new_group).first()
    if result and new_grp:
        print new_grp.passcode
        print passcode
        if str(new_grp.passcode) == str(passcode):
            # Changing a group_id to the same group_id will cause a server error
            if int(result.group_id) == int(new_group):
                return utils.obj_to_json('user', result, True)

            # Modifying the user's color_id
            result.group_id = new_group
            new_group = db_session.query(models.Group).filter(models.Group.id == new_group).first()
            new_group.users.append(result)

            # changing the color_id
            result.color_id = get_new_color(result.group_id)

            temp = result
            db_session.commit()
            return utils.obj_to_json('user',temp, True)
    elif result and passcode == "newgroup":
        print "entered correct code"
        # create new group
        new_g = models.Group(offset = 0, passcode=0, latitude=0.0, longitude=0.0)

        # reflect that in the user info
        result.group_id = new_g.id
        new_g.users.append(result)
        result.color_id = 0
        temp = result
        db_session.add(new_g)
        db_session.commit()
        groups.assign_passcode(result.fb_id)
        return utils.obj_to_json('user',temp, True) 
    return Response('Wrong access code', 401)


    return utils.json_message("Wrong group access token")

'''
    Given a new group_id, we want to choose another group ID
'''
def get_new_color(group_id):
    users = db_session.query(models.User).filter(models.Group.id == group_id).all()
    all_colors = set([i for i in range(NUM_COLORS)])
    used_colors = set()

    for user in users:
        used_colors.add(user.color_id)
    legal_colors = all_colors - used_colors

    for color in legal_colors:
        # Returning the first color that we see, bad style but idgaf
        return color
    return 0

'''
    Function: get_group_by_id
    params: group_id, the integer id of the group
    return: the JSON formatted group information
'''
def get_group_by_id(group_id):
    if group_id:
        group = db_session.query(models.Group).filter(models.Group.id == group_id).first()
        if group:
            return utils.obj_to_json('group', group, True)
    return utils.error_json_message('Group does not exist')


def update_location(group, lat, lon):
    result = db_session.query(models.Group).filter(models.Group.id == int(group)).first()

    latitude = float(lat)
    longitude = float(lon)

    if result:
        if latitude != result.latitude and longitude != result.longitude:
            # Updating both
            result.latitude = latitude
            result.longitude = longitude
        elif latitude == result.latitude and longitude != result.longitude:
            # Updating longitude only
            result.longitude = longitude
        elif latitude != result.latitude and longitude == result.longitude:
            #updating latitude only
            result.latitude = latitude
        else:
            # Update none of them
            # Updating each user to not broadcasting

        # Updating the time zone
        previous_offset = result.offset
        new_offset = messages.get_offset(lat, lon) 
        if previous_offset != new_offset:
            result.offset = new_offset

        update_broadcasting_status(group)
        temp = result
        db_session.commit()
        return utils.obj_to_json('group', temp, True)
    return utils.to_app_json({})

'''
    Changes all users in specified group to NOT_BROADCASTING

    This method is used when the user changes the location
    of his/her group
'''
def update_broadcasting_status(group_id):
    users = db_session.query(models.User).filter(models.User.group_id == group_id)
    if users:
        for user in users:
            user.is_near_dorm = NOT_BROADCASTING
        db_session.commit()
    return 1

'''
    Function: assign_passcode
    Params: group_id
    ----------------
    Takes in a group_id and assigns it a passcode
    Also posts messages to that group
'''
def assign_passcode(fb_id):
    user = db_session.query(models.User).filter(models.User.fb_id==fb_id).first()
    group_id = user.group_id
    group = db_session.query(models.Group).filter(models.Group.id == group_id).first()

    if group:
        new_passcode = random.randint(100000, 999999)
        group.passcode = new_passcode

        message_body = "Welcome to your Flat!"
        message_body1 = "Your Flat's access token is " + str(new_passcode)
        message_body1 += ". Send your friends this number so they can join your Flat!"

        greeting = models.Message(
            body = message_body,
            time_stamp = datetime.datetime.utcnow(),
            offset = 0,
            user_id = 1,
            group_id = group_id,
            color_id = 9
        )

        db_session.add(greeting)

        passcode_message = models.Message(
            body = message_body1,
            time_stamp = datetime.datetime.utcnow(),
            offset = 0,
            user_id = 1,
            group_id = group_id,
            color_id = 9
        )

        db_session.add(passcode_message)
        db_session.commit()
        return
    return

'''
    Returns latitude and longitude given the group_id
'''
def get_location(group_id):
    group = db_session.query(models.Group).filter(models.Group.id == group_id).first()
    if group:
        return (group.latitude, group.longitude)
    return "Eroor"

'''
    Returns the offset associated with the group
'''




