import boto3
import os
import json

dynamodb = boto3.resource("dynamodb")
table = dynamodb.Table(os.environ["TABLE_NAME"])

def lambda_handler(event, context):
    pk_value = "visitors_count"

    response = table.update_item(
        Key={
            "id": pk_value
        },
        UpdateExpression="ADD visits :inc",
        ExpressionAttributeValues={
            ":inc": 1
        },
        ReturnValues="UPDATED_NEW"
    )

    return {
        "statusCode": 200,
        "body": json.dumps({
            "message": "Visitor count incremented",
            "new_count": int(response["Attributes"]["visits"])
        })
    }
