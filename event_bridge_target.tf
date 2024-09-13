locals {
  event_bridge_targets = flatten([
    for rule in var.raw_event_bridge_rules : [
      for target in rule.targets : {
        identifier = format("%s/%s", rule.suffix, target.name),
        event_rule : module.rule[rule.suffix].name
        event_target : target.name
        event_target_arn : target.arn
        event_target_role_arn : try(aws_iam_role.invoke_role[rule.suffix].arn, null)
        event_target_input : target.input
        event_target_input_path : target.input_path
        event_target_input_transformer : target.input_transformer
      }
    ]
  ])
}

module "target" {
  source = "./modules/target"

  for_each = { for target in local.event_bridge_targets : target.identifier => target }

  event_rule                     = each.value["event_rule"]
  event_target                   = each.value["event_target"]
  event_target_arn               = each.value["event_target_arn"]
  event_target_role_arn          = each.value["event_target_role_arn"]
  event_target_input             = each.value["event_target_input"]
  event_target_input_path        = each.value["event_target_input_path"]
  event_target_input_transformer = each.value["event_target_input_transformer"]


  depends_on = [
    module.rule,
    data.aws_iam_policy_document.event_bridge_target_policy,
    data.aws_iam_policy_document.allow_event_bridge_assume
  ]
}