resource "aws_sns_topic" "lambda_failure_topic" {
  name = local.sns_topic_name
}

resource "aws_sns_topic_subscription" "lambda_failure_subscription" {
  topic_arn = aws_sns_topic.lambda_failure_topic.arn
  protocol  = "email"
  endpoint  = local.alarm_email
}

resource "aws_cloudwatch_log_metric_filter" "lambda_error_filter" {
  name           = local.metric_filter_name
  log_group_name = "/aws/lambda/${aws_lambda_function.venmo_lambda.function_name}"
  pattern        = "ERROR"

  metric_transformation {
    name      = "ErrorCount"
    namespace = local.metric_namespace
    value     = "1"
  }

  depends_on = [aws_cloudwatch_log_group.venmo_lambda_log_group]
}

resource "aws_cloudwatch_metric_alarm" "lambda_error_alarm" {
  alarm_name          = "VenmoLambdaFunctionError"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "ErrorCount"
  namespace           = local.metric_namespace
  period              = "60"
  statistic           = "Sum"
  threshold           = "0"
  alarm_description   = "Alarm when the ${aws_lambda_function.venmo_lambda.function_name} function fails."
  alarm_actions       = [aws_sns_topic.lambda_failure_topic.arn]
}
