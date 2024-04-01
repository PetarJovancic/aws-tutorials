import json

def lambda_handler(event, context):
    message = {
    'message': 'Hello World!'
    }
    status_code = 200
    return {
        "isBase64Encoded": False,
        "statusCode": status_code,
        "body": json.dumps(message),
        "headers": {
            "Content-Type": "application/json",
            "Access-Control-Allow-Headers": "*",
            "Access-Control-Allow-Origin": "*",
            "Access-Control-Allow-Methods": "OPTIONS,POST,GET",
        },
    }
