

import push_notification
from db import db_session
import models
import datetime
import utils

def handle_event(body, fb_id):
	user = db_session.query(models.User).filter(models.User.fb_id == fb_id).first()

	if user is not None:
		group_id = user.group_id
        group = db_session.query(models.Group).filter(models.Group.id == group_id).first()

        new_msg = models.Message(
            body = body,
            time_stamp = datetime.datetime.utcnow(),
            offset = group.offset,
            user_id = '0',
            group_id = user.group_id,
            color_id = user.color_id
        )

        db_session.add(new_msg)
        db_session.commit()
        push_notification.push_notify_group(group_id, body)
        all_messages = db_session.query(models.Message).filter(models.Message.group_id == group_id).order_by(models.Message.time_stamp).all()
        return utils.list_to_json('messages', all_messages)
