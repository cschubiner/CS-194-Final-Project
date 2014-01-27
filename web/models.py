from sqlalchemy import Column, Integer, String, ForeignKey
from sqlalchemy.orm import relationship, backref
from db import Base

MAX_LENGTH = 50

class User(Base):
        __tablename__ = 'fb_users'

        id = Column(Integer, primary_key=True)
        fb_id = Column(String(MAX_LENGTH))
        group_id = Column(Integer) #TODO: add foreign key
        first_name = Column(String(MAX_LENGTH))
        last_name = Column(String(MAX_LENGTH))
        img_url = Column(String(MAX_LENGTH))
        email = Column(String(MAX_LENGTH))

        def __repr__(self):
            return "<User(firstname='%s', lastname='%s')>" % (self.first_name, self.last_name)

class Group(Base):
    __tablename__ = 'group'

    id = Column(Integer, primary_key=True)
    # users = relationship("fb_users", backref="Group")

class GroupId(Base):
    __tablename__ = "group_id"

    id = Column(Integer, primary_key=True)
    counter = Column(Integer)


