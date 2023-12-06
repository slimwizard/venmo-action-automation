from venmo_api import Client
import os

access_token = os.environ["ACCESS_TOKEN"]


def handler(event, context):
    request_amount = event["request_amount"]
    request_recipient = event["request_recipient"]
    request_message = event["request_message"]

    try:
        client = Client(access_token=access_token)
        client.payment.request_money(
            amount=request_amount,
            note=request_message,
            target_user_id=request_recipient,
        )

        return {
            "statusCode": 200,
            "headers": {"Content-Type": "application/json"},
            "body": "Success!",
        }

    except Exception as e:
        return {
            "statusCode": 500,
            "headers": {"Content-Type": "application/json"},
            "body": f"An error occured :( {e}",
        }
