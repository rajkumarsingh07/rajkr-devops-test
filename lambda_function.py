import os
import json
import urllib.request
import urllib.error

def lambda_handler(event, context):
    # Get environment variables with a fallback value (to avoid KeyError)
    API_ENDPOINT = os.environ.get("API_ENDPOINT", "https://bc1yy8dzsg.execute-api.eu-west-1.amazonaws.com/v1/data")
    SUBNET_ID = os.environ.get("SUBNET_ID", "")
    NAME = os.environ.get("NAME", "")
    EMAIL = os.environ.get("EMAIL", "")

    # Construct the payload
    payload = {
        "subnet_id": SUBNET_ID,
        "name": NAME,
        "email": EMAIL
    }

    # Convert payload to JSON
    json_data = json.dumps(payload).encode("utf-8")

    # Headers for the API request
    headers = {
        "X-Siemens-Auth": "test",
        "Content-Type": "application/json"
    }

    try:
        # Create and send the HTTP request
        req = urllib.request.Request(API_ENDPOINT, data=json_data, headers=headers, method="POST")
        with urllib.request.urlopen(req) as f:
            res = f.read()
        return {
            "statusCode": 200,
            "body": res.decode()
        }
    except Exception as e:
        return {
            "statusCode": 500,
            "error": str(e)
        }
