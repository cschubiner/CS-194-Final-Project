'''
    File: calendar.py
    Author: Colby Ing
    ------------------
    Handles all calendar events on the backend
'''

import json
import models
import dateutil.parser
import push_notification
import db
from db import db_session
'''
    Function: calendar_store_event
    Params: event_string, a string that needs to be decoded into a python object

    {
     "events":[
      {
       "title":"thor",
       "userid":546379114,
       "startdate":"2014-02-23t20:00:00-0800",
       "enddate":"2014-02-23t21:00:00-0800"
      },
      {
       "title":"me 421: european entrepreneurship",
       "userid":546379114,
       "startdate":"2014-02-24t16:30:00-0800",
       "enddate":"2014-02-24t17:45:00-0800"
      },
      {
       "title":"project atlas playtest",
       "userid":546379114,
       "startdate":"2014-02-24t20:00:00-0800",
       "enddate":"2014-02-24t22:00:00-0800"
      },
  '''
def calendar_store_event(event_string):
    event_obj = json.loads(event_string)

    events = event_obj['events']

    for event in events:
        #TODO: store some sort of unique identifier for each event
        # process each event individually
        new_event = models.Event(
            title = event['title'],
            user_id = event['userid'],
            start_date = dateutil.parser.parse(event['startdate']),
            end_date = dateutil.parser.parse(event['enddate'])
        )
        db_session.add(new_event)
    db_session.commit()

'''
    Function: calendar_notify_event
    Params: JSON string object (see below)
    --------------------------------------
    Given an event, sends a push notification to alert
    everyone in that group

'''
def calendar_notify_event(event_string):
    event_obj = json.loads(event_string)

    # Creating the message body
    # TODO: format date and time better, kinda shitty right now
    msg_body = event_obj['title'] + "\n"
    msg_body += event_obj['startdate'] + '-' + event_obj['enddate']

    # Get user associated with fb_id
    user = db_session.query(models.User).filter(models.User.fb_id==fb_id).first()

    new_message = models.Message(
        body=msg_body,
        timestamp=datetime.datetime.utcnow(),
        user_id=event_obj['user_id'],
        group_id=user.group_id,
        color_id=user.color_id
    )
    db_session.add(new_message)
    db_session.commit()
    calendar_push_notify_group(body, user.group_id)
    return utils.error_json_message("Done")

'''
    Method: calendar_push_notify_group
    Params: body, the message body,
            group_id, the group to send the push notifications to
    Return: Nothing
'''
def calendar_push_notify_group(body, group_id)
    group = db.db_get_group(group_id)
    push_notification.send_to_group(group_id, body)
