locals {
  event_bridge_policies = { for idx, policy in flatten([
    for rule in var.raw_event_bridge_rules : [
      for i, policy_statement in rule.iam_policy_statements : {
        policy_name_suffix = rule.suffix
        policy_content     = data.aws_iam_policy_document.event_bridge_target_policy[rule.suffix].json
      }
    ] if rule.iam_policy_statements != []
  ]) : policy.policy_name_suffix => policy }
}

resource "aws_iam_policy" "invoke_policy" {
  for_each = local.event_bridge_policies
  name     = lower(lower("aws-${var.environment}-${var.application_name}-${each.value["policy_name_suffix"]}-policy"))
  policy   = each.value["policy_content"]

  depends_on = [
    data.aws_iam_policy_document.event_bridge_target_policy,
    data.aws_iam_policy_document.allow_event_bridge_assume
  ]
}