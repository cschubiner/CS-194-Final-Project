'''
    Filename: messages.py
    Author: Colby Ing 2014
    ----------------------
    Used to deal with all messaging modules and functionality
'''

from db import db_session
import models, utils, datetime
from google.appengine.api import taskqueue
import urllib2
import json, groups
AUTHORIZED_IP="128.12.253.15"
API_KEY = 'AIzaSyB1jxr6zInsnwvK9KeJV59r-5kM08tRr4M'

# Maximum number of messages to return
MESSAGE_LIMIT = 500
# Number of greeting message
# "Welcome to your flat!" + "Access code = xxxxxx"
NUM_GREETING_MESSAGES = 2

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
        group = db_session.query(models.Group).filter(models.Group.id == group_id).first()

        new_msg = models.Message(
            body = body,
            time_stamp = datetime.datetime.utcnow(),
            offset = group.offset,
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

        # Used to return the last 500, if there are more than 500 messages
        messages_to_return = []
        messages_to_return.extend(all_messages[0:NUM_GREETING_MESSAGES])
        if len(all_messages) > MESSAGE_LIMIT:
            messages_to_return.extend(all_messages[NUM_GREETING_MESSAGES:MESSAGE_LIMIT])
        else:
            messages_to_return.extend(all_messages[NUM_GREETING_MESSAGES:])
            
        return utils.list_to_json('messages', messages_to_return)
    return utils.error_json_message("hello")

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
    Returns the correct time given a timezone and a group
'''
def adjusted_time(group_id, ucttime):
    location = groups.get_location(group_id)
    url = "https://maps.googleapis.com/maps/api/timezone/json?sensor=false&location="

    if location:
        lat = str(location[0])
        lon = str(location[1])
        cur = str(datetime.datetime.utcnow().strftime('%s'))
        part1 = lat+","+lon+"+&timestamp=" + cur + "&key=" + API_KEY
        print part1
        url += part1
        part2 = "&userIp=" + AUTHORIZED_IP
        url += part2
        print url
        result = json.loads(urllib2.urlopen(url).read())
        print result
        print type(result)
        offset = result["rawOffset"]
        print offset
        delta = datetime.timedelta(seconds=int(offset))
        dst = datetime.timedelta(seconds=int(result['dstOffset']))
        print delta
        adjusted = ucttime + delta + dst
        return adjusted.isoformat()
        return ucttime + delta

def get_offset(lat, lon):
    url = "https://maps.googleapis.com/maps/api/timezone/json?sensor=false&location="
    cur = str(datetime.datetime.utcnow().strftime('%s'))
    part1 = lat+","+lon+"+&timestamp=" + cur + "&key=" + API_KEY
    print part1
    url += part1
    part2 = "&userIp=" + AUTHORIZED_IP
    url += part2
    print url
    result = json.loads(urllib2.urlopen(url).read())
    return int(result['dstOffset']) + int(result['rawOffset'])

def fast_adjusted_time(ucttime, offset):
    if offset is None:
        return None
    delta = datetime.timedelta(seconds=offset)
    result = ucttime + delta
    return result.isoformat()







