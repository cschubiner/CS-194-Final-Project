""" main.py is the top level script.

Return "Hello World" at the root URL.
"""

import sys

# import cgi
# import webapp2
# from google.appengine.ext.webapp.util import run_wsgi_app

# import MySQLdb
import os
# import jinja2

import sqlalchemy
from sqlalchemy import create_engine
from sqlalchemy.ext.declarative import declarative_base

from flask import Flask
from flask import render_template
app = Flask(__name__.split('.')[0])
engine = create_engine('mysql+gaerdbms:///users?instance=flatappapi:db0')
Base = declarative_base()

@app.route('/')
@app.route('/<name>')
def hello(name=None):
  """ Return hello template at application root URL."""
  return str(engine)
  return render_template('hello.html', name=name)


