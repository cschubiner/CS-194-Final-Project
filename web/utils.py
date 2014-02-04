from flask import Response
import json

# Converts a sqlalchemy query result (list) to json
def list_to_json(response_type, obj_list):
    if obj_list:
        return Response(response=json.dumps({response_type:[i.serialize for i in obj_list]}), status=200,mimetype="application/json")
    return "{}"

# Converts a single SQLAlchemy object into a JSON object
def obj_to_json(response_type, obj):
    return Response(response=json.dumps({response_type: obj.serialize}), status=200,mimetype="application/json")
