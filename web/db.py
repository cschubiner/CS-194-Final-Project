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
from sqlalchemy import Column, Integer, String
import utils
import facebook
import urllib2

MAX_LENGTH = 50

engine = create_engine('mysql+gaerdbms:///add8?instance=flatappapi:db0')
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

    new_group.users = [
        models.User(
            fb_id = profile["id"],
            color_id = 0,
            is_near_dorm = False,
            first_name = profile["first_name"],
            last_name = profile["last_name"],
            image_url = picture_url,
            email = profile["email"]
        )
    ]

    db_session.add(new_group)
    db_session.commit()

    query = db_session.query(models.User).all()
    return utils.obj_to_json('user', new_group.users[0])

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
    # Execute query, result is a SQLalchemy object, or nothing
    # TODO: Do error checking
    result = db_session.query(models.User).filter(models.User.fb_id==fb_id).first()
    return utils.obj_to_json('user', result)

'''
    @params, fb_id(integer), status(boolean)
    @return, boolean indicating success or failure
'''
def update_dorm_status(fb_id, status):
    result = db_session.query(models.User).filter(models.User.fb_id==fb_id).first()
    if result:
        result.is_near_dorm = status
        db_session.commit()
    return True

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
        if result.group_id == new_group:
            return utils.obj_to_json('user', result)

        result.group_id = new_group
        temp = result
        db_session.commit()
        return utils.obj_to_json('user',temp)
    return utils.obj_to_json({})

def update_location(group, lat, lon):
    result = db_session.query(models.Group).filter(models.Group.id == group).first()
    if result:
        result.latitude = lat
        result.longitude = lon
        temp = result
        db_session.commit()
        return utils.obj_to_json('group', temp)


