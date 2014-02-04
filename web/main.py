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
        return db.add_user(request.form['token'])
    else:
        # Request information about users
        ret = {
          "user": {
            "userID": 0,
            "groupID": 0,
            "colorID": 0,
            "firstName": "Glenna",
            "lastName": "Willis",
            "imageURL": "http://placehold.it/32x32",
            "email": "glennawillis@uncorp.com"
          }
        }
        resp = Response(response=json.dumps(ret), status=200,mimetype="application/json")
        return resp
    return db.obj_to_json({})


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

@app.route('/sandbox/users/all', methods=['GET','POST'])
def s_users_all():
    users = {
        "users": [
            {
                "userID": 0,
                "groupID": 0,
                "colorID": 0,
                "firstName": "Glenna",
                "lastName": "Willis",
                "imageURL": "http://placehold.it/32x32",
                "isNearDorm": False,
                "email": "glennawillis@uncorp.com"
            },
            {
                "userID": 1,
                "groupID": 0,
                "colorID": 1,
                "firstName": "Joy",
                "lastName": "Peters",
                "imageURL": "http://placehold.it/32x32",
                "isNearDorm": False,
                "email": "joypeters@uncorp.com"
            },
            {
                "userID": 2,
                "groupID": 0,
                "colorID": 2,
                "firstName": "Harry",
                "lastName": "Potter",
                "imageURL": "http://placehold.it/32x32",
                "isNearDorm": True,
                "email": "hpiddy@hogwarts.edu"
            },
            {
                "userID": 3,
                "groupID": 1,
                "colorID": 0,
                "firstName": "Tamika",
                "lastName": "Lynch",
                "imageURL": "http://placehold.it/32x32",
                "isNearDorm": True,
                "email": "tamikalynch@uncorp.com"
            }
        ]
    }


    resp = Response(response=json.dumps(users), status=200,mimetype="application/json")
    return resp

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
@app.route('/users/<fbid>/indorm/<bool>', methods=['GET','POST'])
def is_in_dorm(fbid, bool):
    data = {
        "data":
        {
            "value": True,
        }
    }
    resp = Response(response=json.dumps(data), status=200,mimetype="application/json")
    return resp

# Given a specific ƒacebook_id, returns the information
# about that user in JSON format
@app.route('/user/<fb_id>')
def get_user_by_fbid(fb_id):
    return db.get_user_by_fbid(fb_id)

# This function should only be used for testing/database maintainance
# purposes.
@app.route('/users/add', methods=['GET','POST'])
def add_user_by_fbid():
    if request.method == 'POST':
        db.add_user_by_fb_id(request.data)
        return "Success!"



