# venmo-action-automation

## Introduction
Are you annoyed with having to remember to send the same requests and payments each month for things like subscriptions, rent, etc? If so, this solution is the answer to your Venmo problems! Leverages an AWS Lambda function written in Python triggered by EventBridge Schedules; each unique recurring payment/request to be automated is handled by its own Schedule object. All resource creation is maintained via Terraform. 

Because of how lightweight the Lambda function is, this solution is practically free assuming you aren't automating 100s or 1000s of Venmo actions each month. All that is required is your own AWS account and a Venmo account.

## Getting Started
Follow these steps to set up your own recurring Venmo payments and/or requests.

#### Install Terraform
Use the [official install instructions](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli#install-terraform) to install the Terraform CLI. Verify the installation by running
```terraform -help```

#### Clone the repository
```
git clone https://github.com/slimwizard/venmo-action-automation.git
```

#### Define your recurring venmo schedules in Terraform
Navigate to the ```/terraform``` directory and open the locals.tf file in your preferred code editor. 

Update the **venmo_schedules** variable (line 12) with all recurring payment/requests you'd like to automate. For example, if I wanted to automate one payment request for a Netflix subscription to be sent on the 5th of each month at noon and one payment for rent to be sent on the 1st of each month at 9am, I would update the venmo_schedules variable like so:

```hcl
venmo_schedules = [
  {
    name            = "NetflixSubscriptionRequest"
    description     = "Schedule for monthly Netflix subscription request"
    cron_expression = "cron(0 12 5 * ? *)" # every month on the 5th at noon
    payload = jsonencode({
      amount              = 7.50
      action              = "request"
      note                = "Netflix subscription"
      recipient_user_name = "RecipientVenmoUserName"
    })
  },
  {
    name            = "RentPayment"
    description     = "Schedule for monthly rent payment"
    cron_expression = "cron(0 9 1 * ? *)" # every month on the 1st at 9am
    payload = jsonencode({
      amount              = 850
      action              = "payment"
      note                = "Rent"
      recipient_user_name = "RecipientVenmoUserName"
    })
  },
]

```

You can grab the value for **recipient_user_name** from the Venmo application. **Be careful to not misspell the username. If you do, you may end up sending money to someone you don't know...** The code will handle translating the username to the appropriate UserID, which is required by the Venmo API.

#### Add your email address for alerts
SNS and Cloudwatch Alarms are used to send alerts to the specified email in the case that the Lambda function fails to send the payment/request. This is configured via the **alarm_email** variable within the same file (/terraform/locals.tf - line 10)
```hcl
alarm_email    = "<your email address>"
```

#### Generate an API Token for your Venmo account
You will need to install the venmo-api package via pip in order to generate a token via Python
```bash
pip3 install venmo-api --upgrade
```

Use the following Python code to generate your token
```Python
from venmo_api import Client

access_token = Client.get_access_token(username='myemail@random.com',
                                        password='your password')
print(f"My token: {access_token}")
```

Save this token as you will need to pass it in to Terraform when deploying the resources. *Note that this token does not expire unless you change your Venmo password.*

#### Deploy your recurring payments to your AWS account via Terraform
Within the AWS Console, create a user with access to create resources within Lambda, IAM, EventBridge, Cloudwatch, and SNS. Assuming you are deploying this to your own AWS account, it is easiest to just grant AdminstratorAccess to your user. Create an Access Key for this user and set the corresponding Secret and ID values as environment variables within your terminal. These will be leveraged by the Terraform CLI. *These values should be treated like a password; do not share them with anyone or store them anywhere with public read access*

```
set AWS_ACCESS_KEY_ID=<your_access_key_id_here>
set AWS_SECRET_ACCESS_KEY=<your_secret_access_key_here>
```

Use the Terraform CLI to deploy your resources
```
cd terraform
terraform apply
```

Terraform will use the **venmo-action-automation/package_lambda.sh** script to package the Lambda code (handler.py) into a zip file for deployment. Note that you will likely run into issues if you are not running this from a Unix-like environment. Git-bash may work but has not been tested.

You will be prompted to provide the Venmo API token which was generated in the previous step. Paste the token into your terminal when prompted. The ```terraform apply``` command will prompt you to accept the planned changes; enter "yes" to deploy the resources.

## Acknowledgements
This project leverages the venmo-api created and maintained by [Mark Mohades](https://github.com/mmohades).
