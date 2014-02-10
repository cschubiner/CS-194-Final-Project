from sqlalchemy import Column, Integer, String, ForeignKey, Float
from sqlalchemy.orm import relationship, backref
from db import Base

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
    group = relationship("Group")

    @property
    def serialize(self):
        return {
            "fb_id": int(self.fb_id),
            "group_id": self.group_id,
            "color_id": self.color_id,
            "is_near_dorm": self.is_near_dorm, #ge this later. this will not work
            "first_name": self.first_name,
            "last_name": self.last_name,
            "image_url": self.image_url,
            "email": self.email
        }


    def __repr__(self):
        return "<User(firstname='%s', lastname='%s')>" % (self.first_name, self.last_name)

class Group(Base):
    __tablename__ = 'groups'

    id = Column(Integer, primary_key=True)
    curr_color = Column(Integer)
    latitude = Column(Float)
    longitude = Column(Float)

    users = relationship("User")

    def __repr__(self):
        return "<User(id='%s', curr_color='%s')>" % (self.id, self.curr_color)


