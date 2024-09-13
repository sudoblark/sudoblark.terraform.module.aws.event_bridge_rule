output "arn" {
  value = try(aws_cloudwatch_event_rule.event_rule_ignore_state[0].arn, aws_cloudwatch_event_rule.event_rule_update_state[0].arn)
}

output "name" {
  value = try(aws_cloudwatch_event_rule.event_rule_ignore_state[0].name, aws_cloudwatch_event_rule.event_rule_update_state[0].name)
}