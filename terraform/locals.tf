locals {
  lambda_function_name = "VenmoActionLambda"
  scheduler_time_zone  = "America/Denver"
  schedule_group_name  = "venmo-schedules"
  lambda_source_hash   = filesha256("${path.module}/../handler.py")

  sns_topic_name = "venmo-lambda-failure-notifications"
  metric_filter_name = "VenmoLambdaExecutionError"
  metric_namespace = "VenmoLambdaMetrics"
  alarm_email    = "myemail@gmail.com"

  venmo_schedules = [
    {
      name            = "ExampleRequest"
      description     = "Schedule for monthly request"
      cron_expression = "cron(0 13 3 * ? *)" # every month on the 3rd at 1pm
      payload = jsonencode({
        amount              = 20
        action              = "request"
        note                = "Please pay me"
        recipient_user_name = "Matthew-Rice-26"
      })
    },
    {
      name            = "ExamplePayment"
      description     = "Schedule for monthly payment"
      cron_expression = "cron(0 9 1 * ? *)" # every month on the 1st at 9am
      payload = jsonencode({
        amount              = 20
        action              = "payment"
        note                = "Here's some moneys"
        recipient_user_name = "Matthew-Rice-26"
      })
    },
  ]

  common_tags = {
    Terraform = "true"
    Project   = "venmo_automation"
  }
}