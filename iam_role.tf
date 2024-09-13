locals {
  event_bridge_roles = { for idx, policy in flatten([
    for rule in var.raw_event_bridge_rules : [
      for i, policy_statement in rule.iam_policy_statements : {
        index : rule.suffix,
        role_name_suffix   = rule.iam_role_suffix,
        assume_role_policy = data.aws_iam_policy_document.allow_event_bridge_assume.json
        policy_arn         = aws_iam_policy.invoke_policy[rule.suffix].arn

      }
    ] if length(rule.iam_policy_statements) > 0
  ]) : policy.index => policy }
}


resource "aws_iam_role" "invoke_role" {
  for_each = local.event_bridge_roles

  name_prefix        = lower("${var.environment}-${var.application_name}-${each.value["role_name_suffix"]}-role")
  assume_role_policy = each.value["assume_role_policy"]

  depends_on = [
    aws_iam_policy.invoke_policy,
    data.aws_iam_policy_document.allow_event_bridge_assume,
    data.aws_iam_policy_document.event_bridge_target_policy
  ]
}

resource "aws_iam_role_policy_attachment" "invoke_role_policy" {
  for_each = local.event_bridge_roles

  role       = aws_iam_role.invoke_role[each.key].id
  policy_arn = each.value["policy_arn"]

  depends_on = [
    aws_iam_role.invoke_role
  ]
}