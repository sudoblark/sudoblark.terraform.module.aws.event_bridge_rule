module "rule" {
  source   = "./modules/rule"
  for_each = { for rule in var.raw_event_bridge_rules : rule.suffix => rule }

  environment       = var.environment
  application_name  = var.application_name
  event_name_suffix = each.value["suffix"]
  event_description = each.value["description"]
  event_schedule    = each.value["schedule"]
  event_pattern     = each.value["pattern"]
  state             = each.value["state"]
  ignore_state      = each.value["ignore_state"]
}