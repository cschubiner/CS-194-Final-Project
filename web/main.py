"""
    File: main.py
    Author: Colby Ing
    -----------------------------------------
    Handles all routing endpoints for the API
"""

import os, sys, json
from flask import Flask, Response, request, render_template
from db import db_init, db_session
import db, groups, models, flat_calendar, utils, tasks, push_notification
import location_timer, messages

app = Flask(__name__.split('.')[0])

db_init()

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
        print request.data
        # for debugging purposes
        if request.data:
            params = request.data.split()
            return db.add_user(params[0], params[1])
        # else we use the normal form
        if request.form:
            fb_id = db.get_fbid(request.form['token'])
            if db.get_user_by_fbid(fb_id) is not None:
                return db.get_user_by_fbid(fb_id)

            return db.add_user(request.form['token'], request.form['device_token'])
        return db.add_user(request.form['token'], request.form['device_token'])
    else:
        return utils.to_app_json({"Error lol"})

@app.route('/group/<group_id>/users')
def get_group_members(group_id):
    return db.get_all_users(group_id)

@app.route('/group/<group_id>', methods=['GET','POST'])
def get_location_by_group(group_id):
    return groups.get_group_by_id(group_id)
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

# used to change the status of the dorm
# TODO: reset status to not broadcasting after 4 hours
@app.route('/user/<fb_id>/indorm/<new_status>', methods=['GET','POST'])
def update_dorm_status(fb_id, new_status):
    if request.method == 'GET':
        return db.update_dorm_status(fb_id, new_status)

@app.route('/group/update_location/', methods=['GET', 'POST'])
def update_location():
    if request.method == 'POST' and request.form:
        group = request.form['groupID']
        lat = request.form['lat']
        lon = request.form['long']
        return groups.update_location(group, lat, lon)
    elif request.method == 'POST' and request.data:
        args = request.data.split()
        return groups.update_location(args[0], args[1], args[2])

@app.route('/facebook/user/friendgroups', methods = ['GET', 'POST'])
def get_user_friends():
    if request.method == 'POST':
        return db.add_user(request.data)
        # return db.add_user_friends(request.data)

@app.route('/facebook/user/<user_id>/friendgroups', methods = ['GET', 'POST'])
def get_friend_groups(user_id):
    if request.method == 'GET':
        return groups.get_user_friend_groups(user_id)

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

# Get request to change user's group
# Get instead of post because lazy
@app.route('/user/<fb_id>/changegroupid/<new_group_id>/token/<passcode>')
def change_group_id(fb_id, new_group_id, passcode):
    return groups.change_group_id(fb_id, new_group_id, passcode)

@app.route('/message/new', methods=['GET', 'POST'])
def add_new_message():
    print request
    if request.method == 'POST':

        body = request.form['message']
        fb_id = request.form['userID']
        print body
        print fb_id
        return messages.add_new_message(body, fb_id)
    return "Hello"

@app.route('/messages/all/<userID>')
def get_messages(userID):
    return messages.get_messages(userID)

@app.route('/tasks/add_friends', methods=['GET', 'POST'])
def task_add_friends():
    if request.method == 'POST':
        print request.form
        print "hello"
        # return "fuck you"
        return db.task_add_friends(request.form['access_token'],request.form['id'])
    return "{}"


@app.route('/tasks/message/push', methods=['GET', 'POST'])
def task_send_message_notification():
    if request.method == 'POST':

        # for debugging purposes
        print request.data
        if request.data:
            data = request.data.split()
            return push_notification.send_push_notification(data[0], data[1], data[2], data[3])
        else:
            return push_notification.send_push_notification(request.form['group_id'], request.form['fb_id'], request.form['name'], request.form['msg'])

'''
    This function is a callback used by the Google Task Queue. 
    Sends a push notification to given group with given body
    PARAMS: group_id, the group associated with the task
            body, the body of the push push_notification
'''
@app.route('/tasks/group/push', methods=['GET', 'POST'])
def task_notify_group():
    if request.method == 'POST':
        # for debugging purposes
        print request.data
        if request.data:
            data = request.data.split()
            return push_notification.task_send_to_group(data[0], data[1])
        else:
            # It's a post request with parameters
            return push_notification.task_send_to_group(request.form['group_id'], request.form['body'])
    # TODO: handle get request

'''
    Inserts a new calendar event into the DB
    PARAMS: message, the content of the event
            userID, the userID åssociated with the event
'''
@app.route("/calendar/message/new", methods=['GET', 'POST'])
def test_push_to_group():
    if request.method == 'POST':
        # for debugging purposes
        print request.data
        if request.data:
            data = request.data.split()
            return flat_calendar.handle_event(data[0], data[1])
        else:
            body = request.form['message']
            fb_id = request.form['userID']
            return flat_calendar.handle_event(body, fb_id)

'''
    Inserts a task into the db
    PARAMS: body, the body of the task
            group_id, the group associated with the task
            due_date, the due date of the task
'''
@app.route('/tasks/add', methods=['GET', 'POST'])
def add_task():
    if request.method == 'POST':
        # For debugging
        print request.data
        if request.data:
            data = request.data.split()
            return tasks.add_task(data[0], data[1], data[2])
        else:
            body = request.form['body']
            group_id = request.form['group_id']
            due_date = request.form['due_date']
            return tasks.add_task(group_id, body, due_date)
    return utils.json_message("not supposed to happen")

'''
    Fetches the tasks for a given group_id
'''
@app.route('/tasks/<group_id>')
def get_tasks(group_id):
    return tasks.get_tasks(group_id)

'''
    Deletes a task from the db
    params: task_id, id of the task to be deleted
            group_id, the group that task deleted from
'''
@app.route('/tasks/delete', methods=['POST'])
def delete_task():
    if request.method == 'POST':
        print request.data
        if request.data:
            data = request.data.split()
            return tasks.delete_task(data[0], data[1])
        else:
            return tasks.delete_task(request.form['task_id'], request.form['group_id'])

'''
    Endpoint hit when user wants to edit a task
    PARAMS: task_id, the id of the task to be edited
            group_id, the group the task pertains to
            body, updated body
            due_date, updated due_date
'''
@app.route('/tasks/edit', methods=['GET', 'POST'])
def edit_task():
    if request.method == 'POST':
        print request.data
        if request.data:
            data = request.data.split()
            return tasks.edit_task(data[0], data[1], data[2], data[3])
        else:
            task_id = request.form['task_id']
            group_id = request.form['group_id']
            new_body = request.form['body']
            new_time = request.form['due_date']
            return tasks.edit_task(task_id, group_id, new_body, new_time)

@app.route('/cron/check_broadcast')
def check_broadcast():
    return location_timer.check_broadcast()

'''
    Gets a groupID 








