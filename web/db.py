"""
    File: db.py
    Author: Colby Ing
    ------------------
    Handles all database bitch work.
"""

import os
# import jinja2
import sqlalchemy
from sqlalchemy import create_engine
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import sessionmaker, scoped_session

from flask import Flask
from flask import render_template
from sqlalchemy import Column, Integer, String



MAX_LENGTH = 50

engine = create_engine('mysql+gaerdbms:///users?instance=flatappapi:db0')
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


def add_user():

    new_user = User(first_name='Colby', last_name='Ing', fb_id='010101', password='helloWorld')
    db_session.add(new_user)
    # our_user = session.query(User).filter_by(first_name='Colby').first()
    # print our_user
    db_session.commit()
    return "hello"

def test():
    return "test"

def rollback():
    session.rollback()
