from venmo_api import Client
import os

AUTH_TOKEN = os.environ["VENMO_AUTH_TOKEN"]


def handler(event, context):
    amount = event["amount"]
    action = event["action"]
    note = event["note"]
    recipient_user_name = event["recipient_user_name"]

    try:
        print("Creating client")
        client = Client(access_token=AUTH_TOKEN)
        recipient_user_id = client.user.search_for_users(recipient_user_name)[0].id
        print(
            f"Sending {action} to {recipient_user_name}:{recipient_user_id}; amount: {amount}, note: {note}"
        )
        if action == "request":
            client.payment.request_money(
                amount=amount,
                note=note,
                target_user_id=recipient_user_id,
            )
        elif action == "payment":
            client.payment.send_money(
                amount=amount,
                note=note,
                target_user_id=recipient_user_id,
            )
        else:
            raise Exception(
                "Invalid action provided. Valid actions are 'payment' and 'request'"
            )

        return {
            "statusCode": 200,
            "headers": {"Content-Type": "application/json"},
            "body": f"{amount} {action} sent to {recipient_user_name}!",
        }

    except Exception as e:
        raise RuntimeError(f"An exception occured: {e}")
