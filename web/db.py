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
EPS = 0.00001

engine = create_engine('mysql+gaerdbms:///add18?instance=flatappapi:db0')
db_session = scoped_session(sessionmaker(autocommit=False,
                                         autoflush=False,
                                         bind=engine))
# Gateway into sending push notifications
apns = APNs(use_sandbox=True,cert_file='ck.pem', key_file='FlatKeyD.pem')
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
def add_user(access_token, device_id):

    graph = facebook.GraphAPI(access_token)
    profile = graph.get_object("me")
    request_picture_url = "http://graph.facebook.com/" + profile['id'] + "/picture"
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

    # Updates the friends table in case the newly register user
    # was previously in the friends table
    update_friend_table(profile['id'])

    # query = db_session.query(models.User).all()
    print device_id
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

    # if result:
    #     if latitude != result.latitude and longitude != result.longitude:
    #         # Updating both
    #         result.latitude = latitude
    #         result.longitude = longitude
    #     elif latitude == result.latitude and longitude != result.longitude:
    #         # Updating longitude only
    #         result.longitude = longitude
    #     elif latitude != result.latitude and longitude == result.longitude:
    #         #updating latitude only
    #         result.latitude = latitude
    #     else:
    #         # Update none of them
    #     temp = result
    #     db_session.commit()
    #     return utils.obj_to_json('group', temp, True)

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

'''
    Function: get_messages
    param: fb_id
    return: all messages in JSON format
    -----------------------------------
    Given a fb_id, retrives all the messages in that
    user's group.
'''
def get_messages(fb_id):
    user = db_session.query(models.User).filter(models.User.fb_id == fb_id).first()
    if user:
        group_id = user.group_id
        all_messages = db_session.query(models.Message).filter(models.Message.group_id == group_id).order_by(models.Message.time_stamp).all()
        return utils.list_to_json('messages', all_messages)
    return utils.error_json_message("invalid fb_id")

'''
    Function: send_push_notification
    param: group_id, the id of the group
           fb_id, the user who sent the message
           name, name of the user who sent the message
           msg, the text body/content of the message
    return: Misc JSON #TODO: fix this
'''
def send_push_notification(group_id, fb_id, name, msg):
    apns = APNs(use_sandbox=True,cert_file='ck.pem', key_file='FlatKeyD.pem')

    recipients = db_session.query(models.User).filter(and_(models.User.group_id == group_id, models.User.fb_id != fb_id)).all()

    # PyAPNs code
    message = name + ': ' + msg + ''
    payload = Payload(alert=message, sound="default", badge=1)

    # for loop through the users that aren't the sender
    for recipient in recipients:
        if recipient.device_id != None and len(recipient.device_id) == 64:
            apns.gateway_server.send_notification(recipient.device_id, payload)

    # DUnno what this does, but the sample code had it
    for (token_hex, fail_time) in apns.feedback_server.items():
        print (token_hex, fail_time)
    return utils.error_json_message("Yo")

'''
    function: add_new_message
    params: body, the text content of the message
            fb_id, the facebook_id of the sender
    return: all messages of that user's group in JSON
'''
def add_new_message(body, fb_id):
    user = db_session.query(models.User).filter(models.User.fb_id == fb_id).first()

    if user is not None:
        group_id = user.group_id
        new_msg = models.Message(
            body = body,
            time_stamp = datetime.datetime.utcnow(),
            user_id = fb_id,
            group_id = user.group_id,
            color_id = user.color_id
        )

        db_session.add(new_msg)
        db_session.commit()

        # Setting the parameters to the task callback
        push_params = dict()
        push_params['group_id'] = user.group_id
        push_params['fb_id'] = fb_id
        push_params['name'] = user.first_name
        push_params['msg'] = body
        taskqueue.add(url='/tasks/message/push', method='POST', params=push_params)
        # TODO: this query is probably buggy
        all_messages = db_session.query(models.Message).filter(models.Message.group_id == group_id).order_by(models.Message.time_stamp).all()
        return utils.list_to_json('messages', all_messages)
    return utils.error_json_message("hello")

def get_name_from_fbid(fb_id):

    # Check for the event message
    if fb_id == '0':
        return 'Event'

    user = db_session.query(models.User).filter(models.User.fb_id == fb_id).first()
    if user is not None:
        return user.first_name
    return utils.error_json_message('nooo')

def update_calendar():
    return utils.error_json_message("Dummy endpoint")

'''
    Method: db_get_group
    Params: group_id, the group id
    Return: SQLAlchemy object of the group
'''
def db_get_group(group_id):
    return db_session.query(models.Group).filter(models.Group.id == int(group_id)).first()

