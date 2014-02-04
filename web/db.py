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

engine = create_engine('mysql+gaerdbms:///add7?instance=flatappapi:db0')
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

    new_group = models.Group(curr_color=0)

    new_group.users = [
        models.User(
            fb_id = profile["id"],
            color_id = 0,
            first_name = profile["first_name"],
            last_name = profile["last_name"],
            image_url = picture_url,
            email = profile["email"]
        )
    ]


    db_session.add(new_group)
    db_session.commit()

    query = db_session.query(models.User).all()
    return obj_to_json('user', new_group.users[0])

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


