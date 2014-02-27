'''
    File: groups.py
    Author: Colby Ing
    -----------------
    Handles all database work that has to do with groups
'''

import utils
from db import db_session
import models
from sqlalchemy import and_

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
    users_are_friends = db_session.query(models.Friend).filter(and_(models.Friend.left_id == user_id, models.Friend.is_user == True)).all()

    if users_are_friends:
        return get_groups_users_map(users_are_friends)
    return utils.error_json_message("You have no friends")

# Helper function for get_user_friend_groups
def get_groups_users_map(friends):
    # creating a map from groups to users
    result = dict()

    print friends

    for friend_id in friends:
        friend = db_session.query(models.User).filter(models.User.fb_id == friend_id.right_id).first()
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
    Function: in_group
    params: fb_id, the facebook id
    Given a fb_id, function returns a boolean
    whether that fb_id is contained within the
    database
'''
def in_group(fbid):
    print db_session.query(models.User).filter(models.User.first_name=='Colby').first()
    result = db_session.query(models.User).filter(models.User.first_name.in_(['Colby'])).all()
    return result

'''
    Function: change_group_id
    params: fb_id, the facebook id
            new_group, the integer of the new group_id
    return: the JSON information of the user
'''
def change_group_id(fb_id, new_group):
    result = db_session.query(models.User).filter(models.User.fb_id == fb_id).first()
    if result:
        # Changing a group_id to the same group_id will cause a server error
        if int(result.group_id) == int(new_group):
            return utils.obj_to_json('user', result, True)

        # Modifying the user's color_id
        result.group_id = new_group
        new_group = db_session.query(models.Group).filter(models.Group.id == new_group).first()
        new_group.users.append(result)
        new_color_id = (len(new_group.users) - 1) % 5

        # changing the color_id
        result.color_id = new_color_id

        temp = result
        db_session.commit()
        return utils.obj_to_json('user',temp, True)
    return utils.error_json_message()

'''
    Function: get_group_by_id
    params: group_id, the integer id of the group
    return: the JSON formatted group information
'''
def get_group_by_id(group_id):
    if group_id is not None:
        group = db_session.query(models.Group).filter(models.Group.id == int(group_id)).first()
        if group:
            return utils.obj_to_json('group', group, True)
    return utils.error_json_message('Group does not exist')
