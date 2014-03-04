'''
	Filename: location_timer.py
	Author: Colby Ing
'''
from db import db_session
import datetime
from datetime import timedelta
import models

FOUR_HOURS = 14400
BROADCASTING = 1
NOT_BROADCASTING = 2

'''
	check_broadcast()
	params: none
	if the user hasn't broadcasted his or her location for 
	4 hours, this changes the user's status to not broadcasting
'''
def check_broadcast():
	all_users = db_session.query(models.User).all()
	curr_time = datetime.datetime.utcnow() 
	for user in all_users:
		last_broadcast = user.last_broadcast
		diff = curr_time - last_broadcast
		print diff.total_seconds()
		if diff.total_seconds() > FOUR_HOURS and user.is_near_dorm != NOT_BROADCASTING:
			user.is_near_dorm = NOT_BROADCASTING

	db_session.commit()
	return "OK"

