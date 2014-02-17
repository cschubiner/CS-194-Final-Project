"""
    File: db.py
    Author: Colby Ing
    ------------------
    Handles all database bitch work.
"""

import os
import sqlalchemy
from sqlalchemy import create_engine
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import sessionmaker, scoped_session

from flask import Flask
from flask import render_template
from sqlalchemy import Column, Integer, String, and_
import utils
import facebook
import urllib2
import datetime

MAX_LENGTH = 50
USER = "user"
USERS = "users"
GROUP = "group"
MESSAGES = "messages"
EPS = 0.00001

engine = create_engine('mysql+gaerdbms:///add12?instance=flatappapi:db0')
db_session = scoped_session(sessionmaker(autocommit=False,
                                         autoflush=False,
                                         bind=engine))
Base = declarative_base()


import models
"""
    Import all models here
"""
def db_init():
    print "created models"
    Base.metadata.create_all(engine)

"""
    Function: get_group_id
    @return incremented group counter
"""
def get_group_id():
    curr_counter = db_session.query(models.GroupId).first()
    temp = curr_counter.counter
    temp += 1
    db_session.delete(curr_counter)
    db_session.add(models.GroupId(counter=temp))
    db_session.commit()
    return temp

'''
    function: add_user
    params: access token of the specified user
    ------------------
    Handles the connection to the database and adds a user
    along with a group
'''
def add_user(access_token):

    graph = facebook.GraphAPI(access_token)
    profile = graph.get_object("me")
    friends = graph.get_connections("me", "friends")
    request_picture_url = "http://graph.facebook.com/" + profile['id']+"/picture"
    picture_url = urllib2.urlopen(request_picture_url).geturl()

    new_group = models.Group(curr_color=0, latitude=0.0, longitude=0.0)
    new_user = models.User(
            fb_id = profile["id"],
            color_id = 0,
            is_near_dorm = False,
            first_name = profile["first_name"],
            last_name = profile["last_name"],
            image_url = picture_url,
            email = profile["email"],
        )

    # Adds each friend to the friend table in the db
    add_friends_to_db(friends['data'], profile['id'])

    # Assign the user to the newly created group
    new_group.users = [new_user]

    db_session.add(new_group)
    db_session.commit()

    # Updates the friends table in case the newly register user
    # was previous in the friends table
    update_friend_table(profile['id'])

    # query = db_session.query(models.User).all()
    return utils.obj_to_json('user', new_group.users[0], True)

def add_friends_to_db(friends, left_id):
    for friend in friends:
        is_user = user_exists(left_id)
        new_friend = models.Friend(
            right_id=friend['id'],
            left_id=left_id,
            is_user=False
        )
        db_session.add(new_friend)


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
    Updates the Friends table when a new user signs up
    Specifically, it updates the is_use tuple when someone who
    isn't a member registers an account
'''
def update_friend_table(fb_id):
    result = db_session.query(models.Friend).filter(models.Friend.right_id==fb_id).all()

    for friend in result:
        friend.is_user = True
    db_session.commit()

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
    Given a group id, fetch all users in that group
    @params, group_id, the id of the group
    @return, JSON representation of the users in the group
'''
def get_all_users(g_id):

    # Execute query, result is a SQLalchemy array
    query_result = db_session.query(models.User).filter(models.User.group_id==g_id).all()

    # Return valid json
    return utils.list_to_json('users', query_result)

'''
    Given a facebook id (fb_id), fetch all the information
    about that user form the DB.
    @params: fb_id, the facebook_id
    @return: valid JSON representing that user
'''
def get_user_by_fbid(fb_id):
    # Execute query, result is a SQLAlchemy object, or nothing
    # TODO: Do error checking
    result = db_session.query(models.User).filter(models.User.fb_id==fb_id).first()
    if result is not None:
        return utils.obj_to_json('user', result, True)
    return None

def user_exists(fb_id):
    result = db_session.query(models.User).filter(models.User.fb_id==fb_id).first()
    if result:
        return True
    return False

'''
    @params, fb_id(integer), status(boolean)
    @return, boolean indicating success or failure
'''
def update_dorm_status(fb_id, status):
    result = db_session.query(models.User).filter(models.User.fb_id==fb_id).first()
    if result:
        if int(result.is_near_dorm) == int(status):
            return utils.to_app_json({"data":"cannot change user to same status"})
        result.is_near_dorm = status
        temp = result
        db_session.commit()
        return utils.obj_to_json(USER, temp, True)
    return utils.error_json_message("you suck")

'''
    params: access_token, the facebook access token
    return: the facebook id corresponding to the access token
'''
def get_fbid(access_token):
    graph = facebook.GraphAPI(access_token)
    profile = graph.get_object("me")
    return profile['id']

def change_group_id(fb_id, new_group):
    result = db_session.query(models.User).filter(models.User.fb_id == fb_id).first()
    if result:
        # Changing a group_id to the same group_id will cause a server error
        if int(result.group_id) == int(new_group):
            return utils.obj_to_json('user', result, True)

        result.group_id = new_group

        # changing the color_id
        # num = result.randint(1,3)
        # result.color_id = num
        # while result.color_id == num:
        #     result.color_id = randint(0,3)

        # result.color_id = random.randint(1,3) # Hacky shit, will re-write later
        temp = result
        db_session.commit()
        return utils.obj_to_json('user',temp, True)
    return utils.error_json_message()

def update_location(group, lat, lon):
    result = db_session.query(models.Group).filter(models.Group.id == int(group)).first()

    print "PARAMS"
    print lat
    print lon
    print "PARAMS AS FLOATS"
    print str(float(lat))
    print str(float(lon))
    print "STORED IN DB"
    print str(float(result.latitude))
    print str(float(result.longitude))
    latitude = float(lat)
    longitude = float(lon)

    if result:
        if abs(float(result.latitude) - float(lat)) < EPS and abs(float(result.longitude) - float(lon)) < EPS:
            print "UPDATING NOTHING"
            return utils.obj_to_json('group', result, True)
        elif abs(float(result.latitude) - float(lat )) < EPS and abs(float(result.longitude) - float(lon)) > EPS:
            print "UPDATING LONGITUDE ONLY"
            # update longitude only
            result.longitude = lon
        elif abs(float(result.latitude) - float(lat)) > EPS and abs(float(result.longitude) - float(lon)) < EPS:
            print "UPDATING LATITUDE ONLY"
            # update latitude only
            result.latitude = lat
        else:
            print "UPDATING BOTH"
            # update both
            result.latitude = lat
            result.longitude = lon
        temp = result
        db_session.commit()
        return utils.obj_to_json('group', temp, True)
    return utils.to_app_json({})

def get_messages(fb_id):
    user = db_session.query(models.User).filter(models.User.fb_id == fb_id).first()
    if user:
        group_id = user.group_id
        all_messages = db_session.query(models.Message).filter(models.Message.group_id == group_id).order_by(models.Message.time_stamp).all()
        return utils.list_to_json('messages', all_messages)
    return utils.error_json_message()

def add_new_message(body, fb_id):
    user = db_session.query(models.User).filter(models.User.fb_id == fb_id).first()

    if user is not None:
        group_id = user.group_id
        new_msg = models.Message(
            body = body,
            time_stamp = datetime.datetime.utcnow(),
            user_id = fb_id,
            group_id = user.group_id
        )

        db_session.add(new_msg)
        db_session.commit()
        # TODO: this query is probably buggy
        all_messages = db_session.query(models.Message).filter(models.Message.group_id == group_id).order_by(models.Message.time_stamp).all()
        return utils.list_to_json('messages', all_messages)
    return utils.error_json_message()

def get_name_from_fbid(fb_id):
    user = db_session.query(models.User).filter(models.User.fb_id == fb_id).first()
    if user is not None:
        return user.first_name
    return utils.error_json_message()

def get_group_by_id(group_id):
    group = db_session.query(models.Group).filter(models.Group.id == int(group_id)).first()
    if group:
        return utils.obj_to_json('group', group, True)
    return utils.error_json_message('Group does not exist')

def update_calendar():
    return utils.error_json_message("Dummy endpoint")
