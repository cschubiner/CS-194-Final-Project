'''
    File: push_notification.py
    Author: Colby Ing
    -----------------
    This file takes care of all operations that have to
    do with push notifications. This module makes heavy use
    of the PyAPNs library. Here's a link to the documentation:
    https://github.com/djacobs/PyAPNs
'''
from google.appengine.api import taskqueue
from db import db_session
import db, utils, models
from apns import APNs, Payload
from sqlalchemy import and_

'''
    Function: send_push_notification
    param: group_id, the id of the group
           fb_id, the user who sent the message
           name, name of the user who sent the message
           msg, the text body/content of the message
    return: Misc JSON
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
    Called by external files, adds this task to the task
    queue.
'''
def send_to_group(group_id, body):
    push_params = dict()
    push_params['group_id'] = group_id
    push_params['body'] = body
    taskqueue.add(url='/tasks/group/push', method='POST', params=push_params)
    return utils.json_message("Added to taskQueue")

'''
    Called by the task queue to execute this task
'''
def task_send_to_group(group_id, body):
    apns = APNs(use_sandbox=True,cert_file='ck.pem', key_file='FlatKeyD.pem')

    group = db.db_get_group(group_id)

    # PyAPNs code
    payload = Payload(alert=body, sound="default", badge=1)

    # for loop through the users in group
    for recipient in group.users:
        # If a user signed up on the web and not on an iPhone
        if recipient.device_id != None and len(recipient.device_id) == 64:
            apns.gateway_server.send_notification(recipient.device_id, payload)

    # DUnno what this does, but the sample code had it
    for (token_hex, fail_time) in apns.feedback_server.items():
        print (token_hex, fail_time)
    return utils.json_message("Yo")

def push_notify_group(group_id, body):
    send_to_group(group_id, body)
