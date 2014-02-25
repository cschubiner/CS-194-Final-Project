from sqlalchemy import Column, Integer, String, ForeignKey, Float, DateTime, Boolean
from sqlalchemy.orm import relationship, backref
from db import Base
import db
import datetime

MAX_LENGTH = 50

class User(Base):
    __tablename__ = 'users'

    id = Column(Integer, primary_key=True)
    fb_id = Column(String(MAX_LENGTH))
    group_id = Column(Integer, ForeignKey('groups.id')) #TODO: add foreign key
    color_id = Column(Integer) #TODO: add foreign key, maybe
    is_near_dorm = Column(Integer)
    first_name = Column(String(MAX_LENGTH))
    last_name = Column(String(MAX_LENGTH))
    image_url = Column(String(MAX_LENGTH))
    email = Column(String(MAX_LENGTH))
    device_id = Column(String(64))
    group = relationship("Group")

    @property
    def serialize(self):
        return {
            "fb_id": int(self.fb_id),
            "group_id": self.group_id,
            "color_id": self.color_id,
            "is_near_dorm": self.is_near_dorm, #ge this later.
            "first_name": self.first_name,
            "last_name": self.last_name,
            "image_url": self.image_url,
            "email": self.email,
            "device_id": self.device_id
        }


    def __repr__(self):
        return "<User(firstname='%s', lastname='%s')>" % (self.first_name, self.last_name)

class Friend(Base):
    __tablename__ = 'friends'

    id = Column(Integer, primary_key=True)
    left_id = Column(String(MAX_LENGTH))
    right_id = Column(String(MAX_LENGTH))

    is_user = Column(Boolean)


class Group(Base):
    __tablename__ = 'groups'

    id = Column(Integer, primary_key=True)
    curr_color = Column(Integer)
    latitude = Column(String(MAX_LENGTH))
    longitude = Column(String(MAX_LENGTH))

    users = relationship("User")

    @property
    def serialize(self):
        return {
            "groupID": self.id,
            "latLocation": float(self.latitude),
            "longLocation": float(self.longitude),
            "users": [i.serialize for i in self.users]
        }

    def __repr__(self):
        return "<User(id='%s', curr_color='%s')>" % (self.id, self.curr_color)

class Message(Base):
    __tablename__ = 'messages'

    id = Column(Integer, primary_key=True)
    body = Column(String(260))
    time_stamp = Column(DateTime, default=datetime.datetime.utcnow)
    user_id = Column(Integer)
    group_id = Column(Integer)
    color_id = Column(Integer)

    @property
    def serialize(self):
        return {
            "body": self.body,
            "user_id": self.user_id,
            "name": db.get_name_from_fbid(self.user_id),
            "group_id": self.group_id,
            "time_stamp": str(self.time_stamp),
            "color_id": self.color_id
        }

class Event(Base):
    __tablename__ = "events"

    id = Column(Integer, primary_key=True)
    title = Column(String( MAX_LENGTH ))
    user_id = Column(Integer)
    start_date = Column(DateTime)
    end_date = Column(DateTime)

    @property
    def serialize(self):
        return {
            "title": self.title,
            "user_id": self.user_id,
            "startDate": str(self.start_date),
            "endDate": str(self.end_date)
        }




