"""
    File: db.py
    Author: Colby Ing
    ------------------
    Handles all database bitch work.
    Also handles most endpoints for anything that manipulates
    data for users table in the database
"""

import os
import sqlalchemy
from sqlalchemy import create_engine
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import sessionmaker, scoped_session
from google.appengine.api import taskqueue
from apns import APNs, Payload

import time

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

# Maximum number of messages to return
MESSAGE_LIMIT = 500
# Number of greeting message
# "Welcome to your flat!" + "Access code = xxxxxx"
NUM_GREETING_MESSAGES = 2

engine = create_engine('mysql+gaerdbms:///add20?instance=flatappapi:db0')
db_session = scoped_session(sessionmaker(autocommit=False,
                                         autoflush=False,
                                         bind=engine))
# Gateway into sending push notifications
apns = APNs(use_sandbox=True,cert_file='ck.pem', key_file='FlatKeyD.pem')
Base = declarative_base()

import groups


import models
"""
    Import all models here
"""
def db_init():
    print "created models"
    Base.metadata.create_all(engine)

'''
    function: add_user
    params: access token of the specified user
    ------------------
    Handles the connection to the database and adds a user
    along with a group
'''
def add_user(access_token, device_id):

    graph = facebook.GraphAPI(access_token)
    profile = graph.get_object("me")
    request_picture_url = "http://graph.facebook.com/" + profile['id'] + "/picture"
    picture_url = urllib2.urlopen(request_picture_url).geturl()

    new_group = models.Group(passcode=0, latitude=0.0, longitude=0.0)

    new_user = models.User(
            fb_id = profile["id"],
            color_id = 0,
            is_near_dorm = False,
            first_name = profile["first_name"],
            last_name = profile["last_name"],
            image_url = picture_url,
            email = profile["email"],
            device_id = device_id,
            last_broadcast=datetime.datetime.utcnow()
        )

    # Adds each friend to the friend table in the db
    params = dict()
    params['access_token'] = access_token
    params['id'] = profile['id']
    taskqueue.add(url='/tasks/add_friends', method='POST', params=params)

    # Assign the user to the newly created group
    new_group.users = [new_user]

    db_session.add(new_group)
    db_session.commit()

    groups.assign_passcode(profile['id'])

    return utils.obj_to_json('user', new_group.users[0], True)

'''
    This is the subprocess that adds users' friends into the database
'''
def task_add_friends(access_token, left_id):
    graph = facebook.GraphAPI(access_token)
    friends = graph.get_connections("me", "friends")
    add_friends_to_db(friends, left_id)
    # update_friend_table(left_id)
    return "Done"

'''
    Helper function
'''
def add_friends(friends, left_id):
    add_friends_to_db(friends, left_id)
    print "done with process"

'''
    Another helper function
'''
def add_friends_to_db(friends, left_id):
    for friend in friends['data']:
        # is_user = user_exists(friend['id'])
        is_user = False
        new_friend = models.Friend(
            right_id=friend['id'],
            left_id=left_id,
            is_user=is_user
        )
        db_session.add(new_friend)
    db_session.commit()

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
        # TODO: add code that will send APN to users when status changes
        result.is_near_dorm = status
        result.last_broadcast = datetime.datetime.utcnow()
        temp = result
        db_session.commit()
        return utils.obj_to_json(USER, temp, True)
    return utils.error_json_message("User does not exist")

'''
    params: access_token, the facebook access token
    return: the facebook id corresponding to the access token
'''
def get_fbid(access_token):
    graph = facebook.GraphAPI(access_token)
    profile = graph.get_object("me")
    return profile['id']

def get_name_from_fbid(fb_id):
    # Check for the event message
    if fb_id == '0':
        return 'Event'
    elif fb_id == '1':
        return 'Flat'

    user = db_session.query(models.User).filter(models.User.fb_id == fb_id).first()
    if user is not None:
        return user.first_name
    return utils.error_json_message('nooo')

'''
    Method: db_get_group
    Params: group_id, the group id
    Return: SQLAlchemy object of the group
'''
def db_get_group(group_id):
    return db_session.query(models.Group).filter(models.Group.id == int(group_id)).first()

