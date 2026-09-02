import json
import boto3

dynamodb = boto3.resource("dynamodb")
table = dynamodb.Table("CloudResumeVisitorCount")


def lambda_handler(event, context):

    response = table.update_item(
        Key={
            "id": "visitor-count"
        },
        UpdateExpression="ADD #count :inc",
        ExpressionAttributeNames={
            "#count": "count"
        },
        ExpressionAttributeValues={
            ":inc": 1
        },
        ReturnValues="UPDATED_NEW"
    )

    count = response["Attributes"]["count"]

    return {
        "statusCode": 200,
        "body": json.dumps({
            "count": int(count)
        })
    }