locals {
  target_permissions = { for identifier, rule in flatten([
    for rule in var.raw_event_bridge_rules : [
      for i, target in rule.targets : {
        index : format("%s/%s", rule.suffix, target.name),
        lambda_name : target.name,
        rule_arn : module.rule[rule.suffix].arn,
        event_bridge_rule_suffix : rule.suffix
      }
    ] if rule.targets != []
    ]) : rule.index => rule
  }
}

resource "aws_lambda_permission" "allow_lambda_execution_from_event_bridge" {
  for_each = { for permission in local.target_permissions : permission.index => permission if can(regex("lambda", permission.lambda_name)) }

  statement_id  = format("AllowExecutionFromEventBridgeRule-%s", each.value["event_bridge_rule_suffix"])
  action        = "lambda:InvokeFunction"
  function_name = each.value["lambda_name"]
  principal     = "events.amazonaws.com"
  source_arn    = each.value["rule_arn"]
}