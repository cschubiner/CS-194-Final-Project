"""
    File: main.py
    Author: Colby Ing
    -----------------------------------------
    Handles all routing endpoints for the API
"""

import os
import sys
import json
from flask import Flask, Response, request, render_template
from db import db_init, db_session
import db
import models
import utils

app = Flask(__name__.split('.')[0])

db_init()

@app.route('/')
@app.route('/<name>')
def hello(name=None):
    """ Return hello template at application root URL."""
    # return str(engine)
    return render_template('hello.html', name=name)

'''
    Function: facebook_login()
    --------------------------
    The server calls this function whenever handed a facebook access_token
    and the user logs in for the first time.
    The flow for a first time login is as follows:
    1. Assign a new group to that user (commit to db)
    2. Collect fb data
    3. Add the user into the db using that data
'''
@app.route('/user/<signup>/facebook', methods=['GET', 'POST'])
def facebook_login(signup):
    if request.method == 'POST':
        print "request.form = "
        print request.form
        if request.form:
            fb_id = db.get_fbid(request.form['token'])
            if db.get_user_by_fbid(fb_id) is not None:
                return db.get_user_by_fbid(fb_id)

            return db.add_user(request.form['token'])
        return db.add_user(request.form['token'])
    else:
        return utils.to_app_json({"Go fuck yourself"})


@app.route('/db/rollback')
def rollback():
    db.rollback()
    return "DB rolled back"

@app.route('/db/test/groupID')
def getId():
    return str(db.get_group_id())

@app.route('/test/query')
def test_query():
    return str(db.in_group("708108626"))

@app.route('/group/<group_id>/users')
def get_group_members(group_id):
    return db.get_all_users(group_id)

@app.route('/group/<group_id>', methods=['GET','POST'])
def get_location_by_group(group_id):
    data = {
        "group":
        {
            "groupID": 0,
            "latLocation": 37.419984,
            "longLocation": -122.167301
        }
    }
    resp = Response(response=json.dumps(data), status=200,mimetype="application/json")
    return resp

# Given a user id and a boolean
# records status of the user id the DB
@app.route('/user/<fbid>/indorm/', methods=['GET','POST'])
def is_in_dorm(fbid):
    # return whether or not is_in_dorm = true
    data = {
        "data":
        {
            "value": True,
        }
    }
    resp = Response(response=json.dumps(data), status=200,mimetype="application/json")
    return resp

@app.route('/user/<fb_id>/indorm/<new_status>', methods=['GET','POST'])
def update_dorm_status(fb_id, new_status):
    if request.method == 'GET':
        db.update_dorm_status(fb_id, new_status)
        return utils.obj_to_json({"Go fuck yourself"})

@app.route('/group/update_location/', methods=['GET', 'POST'])
def update_location():
    if request.method == 'POST':
        group = request.form['group']
        lat = request.form['lat']
        lon = request.form['long']
        db.update_location(group, lat, lon)
        return {}

# Given a specific facebook_id, returns the information
# about that user in JSON format
@app.route('/user/<fb_id>')
def get_user_by_fbid(fb_id):
    return db.get_user_by_fbid(fb_id)

# This function should only be used for testing/database maintainance
# purposes.
@app.route('/user/add', methods=['GET','POST'])
def add_user_by_fbid():
    if request.method == 'POST':
        db.add_user_by_fb_id(request.data)
        return "Success!"

@app.route('/user/<fb_id>/changegroupid/<new_group_id>')
def change_group_id(fb_id, new_group_id):
    return db.change_group_id(fb_id, new_group_id)

@app.route('/message/new', methods=['GET', 'POST'])
def add_new_message():
    print request
    if request.method == 'POST':
        print "============"

        body = request.form['message']
        fb_id = request.form['userID']
        print body
        print fb_id
        return db.add_new_message(body, fb_id)
    return "Hello"

@app.route('/messages/all/<userID>')
def get_messages(userID):
    return db.get_messages(userID)



