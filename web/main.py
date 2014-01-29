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

app = Flask(__name__.split('.')[0])

db_init()

@app.route('/')
@app.route('/<name>')
def hello(name=None):
    """ Return hello template at application root URL."""
    # return str(engine)
    return render_template('hello.html', name=name)

@app.route('/users/login')
def handle():
    pass

@app.route('/users/add/colby')
def addColby():
    db.add_user()
    return "hello"

@app.route('/user/login/facebook', methods=['GET', 'POST'])
def facebook_login():
    if request.method == 'POST':
        print "======================="
        print str(request.data)
        curr_user = dict()
        if request.data:
            # TODO: fix this, it's wrong
            access_token = request.data.token
            graph = facebook.GraphAPI(access_token)
            profile = graph.get_object("me")

            # TODO: Fix the hashes, look at FB api, might be wrong
            user = User(
                fb_id = profile["id"],
                group_id = db.get_group_id(),
                first_name = profile["first_name"],
                last_name = profile["last_name"],
                img_url = profile["picture"],
                email = profile["email"]
            )
            print user.fb_id
            print group_id
            print first_name
            print last_name
            print img_url
            print email
            # TODO: Loop through friends
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

@app.route('/db/rollback')
def rollback():
    db.rollback()
    return "DB rolled back"

@app.route('/db/test/groupID')
def getId():
    return str(db.get_group_id())

@app.route('/sandbox/users/all', methods=['GET','POST'])
def s_users_all():
    print '===================='
    print request.data
    print request.method
    users = {
        "users": [
            {
                "userID": 0,
                "groupID": 0,
                "colorID": 0,
                "firstName": "Glenna",
                "lastName": "Willis",
                "imageURL": "http://placehold.it/32x32",
                "email": "glennawillis@uncorp.com"
            },
            {
                "userID": 1,
                "groupID": 1,
                "colorID": 1,
                "firstName": "Joy",
                "lastName": "Peters",
                "imageURL": "http://placehold.it/32x32",
                "email": "joypeters@uncorp.com"
            },
            {
                "userID": 2,
                "groupID": 2,
                "colorID": 2,
                "firstName": "Tamika",
                "lastName": "Lynch",
                "imageURL": "http://placehold.it/32x32",
                "email": "tamikalynch@uncorp.com"
            }
        ]
    }

    resp = Response(response=json.dumps(users), status=200,mimetype="application/json")
    return resp


