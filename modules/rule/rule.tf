resource "aws_cloudwatch_event_rule" "event_rule_ignore_state" {
  count = var.ignore_state == true ? 1 : 0

  name                = lower("aws-${var.environment}-${var.application_name}-${var.event_name_suffix}")
  event_bus_name      = var.event_bus
  event_pattern       = var.event_pattern
  description         = var.event_description
  state               = var.state
  tags                = var.resource_tags
  schedule_expression = var.event_schedule

  lifecycle {
    ignore_changes = [
      state
    ]
  }
}

resource "aws_cloudwatch_event_rule" "event_rule_update_state" {
  count = var.ignore_state == false ? 1 : 0

  name                = lower("aws-${var.environment}-${var.application_name}-${var.event_name_suffix}")
  event_bus_name      = var.event_bus
  event_pattern       = var.event_pattern
  description         = var.event_description
  state               = var.state
  tags                = var.resource_tags
  schedule_expression = var.event_schedule
}