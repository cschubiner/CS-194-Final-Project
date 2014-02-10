from flask import Response
import json

# Converts a sqlalchemy query result (list) to json
def list_to_json(response_type, obj_list):
    if obj_list:
        return to_app_json({response_type:[i.serialize for i in obj_list]})
    return to_app_json({})

# Converts a single SQLAlchemy object into a JSON object
def obj_to_json(response_type, obj):
    if obj:
        return to_app_json({response_type: obj.serialize})
    return to_app_json({})

# Helper function that converts from HTML/text to application/JSON
def to_app_json(obj):
    return Response(response=json.dumps(obj), status=200,mimetype="application/json")