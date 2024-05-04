data "external" "lambda_zip" {
  program = ["bash", "${path.module}/../package_lambda.sh"]
}

resource "aws_lambda_function" "venmo_lambda" {
  function_name = local.lambda_function_name

  filename         = data.external.lambda_zip.result["zipfile"]
  source_code_hash = local.lambda_source_hash

  handler = "handler.handler"
  runtime = "python3.11"

  role = aws_iam_role.lambda_role.arn

  environment {
    variables = {
      VENMO_AUTH_TOKEN = var.venmo_auth_token
    }
  }
}