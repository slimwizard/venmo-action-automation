resource "aws_scheduler_schedule_group" "venmo_schedule_group" {
  name = local.schedule_group_name
}

resource "aws_scheduler_schedule" "venmo_action_schedule" {
  for_each    = { for s in local.venmo_schedules : s.name => s }
  name        = each.key
  group_name  = aws_scheduler_schedule_group.venmo_schedule_group.id
  description = each.value.description

  flexible_time_window {
    mode                      = "FLEXIBLE"
    maximum_window_in_minutes = 15
  }

  schedule_expression          = each.value.cron_expression
  schedule_expression_timezone = local.scheduler_time_zone

  target {
    arn      = aws_lambda_function.venmo_lambda.arn
    role_arn = aws_iam_role.lambda_invocation_role.arn

    input = each.value.payload

    retry_policy {
      maximum_retry_attempts = 5
    }
  }
}