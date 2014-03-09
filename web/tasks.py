'''
    File: tasks.py
    Author: Colby Ing
    Handles shit that deals with the shared task lists
'''

import db
import models
from db import db_session
import utils
import datetime

'''
    Function: add_task
    Params: group_id, the group id
            body, the body of the task
    Return: list of all tasks with that group_id
'''
def add_task(group_id, body, due_date):

    new_task = models.Task(
        group_id=group_id,
        body=body,
        date=datetime.datetime.utcnow(),
        due_date=due_date
    )
    db_session.add(new_task)
    db_session.commit()
    query_result = db_session.query(models.Task).filter(models.Task.group_id==group_id).order_by(models.Task.date).all()
    return utils.list_to_json('tasks', query_result)

def get_tasks(group_id):
    query_result = db_session.query(models.Task).filter(models.Task.group_id==group_id).order_by(models.Task.date).all()  
    return utils.list_to_json('tasks', query_result)

def delete_task(task_id, group_id):
    print "taskid = " + task_id
    print "group_id = " + group_id
    query_result = db_session.query(models.Task).filter(models.Task.id==int(task_id)).first()
    if query_result:
        db_session.delete(query_result)
        db_session.commit()
        updated_query = db_session.query(models.Task).filter(models.Task.group_id==int(group_id)).order_by(models.Task.date).all()
        return utils.list_to_json('tasks', updated_query)
    return utils.error_json_message("invalid task id")

def edit_task(task_id, group_id, new_body, new_due_date):
    query_result = db_session.query(models.Task).filter(models.Task.id==int(task_id)).first()
    if query_result:
        query_result.body = new_body
        if new_due_date:
            query_result.due_date = new_due_date
        db_session.commit()
        updated_query = db_session.query(models.Task).filter(models.Task.group_id==int(group_id)).order_by(models.Task.date).all()
        return utils.list_to_json('tasks', updated_query)
    return utils.error_json_message("invalid task id")




