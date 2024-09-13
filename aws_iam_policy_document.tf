locals {
  actual_iam_policy_documents = {
    for rule in var.raw_event_bridge_rules :
    rule.suffix => {
      statements = rule.iam_policy_statements
    } if length(rule.iam_policy_statements) > 0
  }
}

data "aws_iam_policy_document" "event_bridge_target_policy" {
  for_each = local.actual_iam_policy_documents

  dynamic "statement" {
    for_each = each.value["statements"]

    content {
      sid       = statement.value["sid"]
      actions   = statement.value["actions"]
      resources = statement.value["resources"]

      dynamic "condition" {
        for_each = statement.value["conditions"]

        content {
          test     = condition.value["test"]
          variable = condition.value["variable"]
          values   = condition.value["values"]
        }
      }
    }
  }
}

data "aws_iam_policy_document" "allow_event_bridge_assume" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["events.amazonaws.com"]
    }
  }
}