# Input variable definitions
variable "environment" {
  description = "Which environment this is being instantiated in."
  type        = string
  validation {
    condition     = contains(["dev", "test", "prod"], var.environment)
    error_message = "Must be either dev, test or prod"
  }
}

variable "application_name" {
  description = "Name of the application utilising resource."
  type        = string
}

variable "raw_event_bridge_rules" {
  description = <<EOT

Data structure
---------------
A list of dictionaries, where each dictionary has the following attributes:

REQUIRED
---------
- suffix                : Friendly name for the rule in Event Bridge
- description           : A friendly description of what the Event Bridge rule does
- targets               : A list of dictionaries with the following attributes, defining what target this event triggers:
-- name                 : A friendly name for the target, if lambda this should be the lambda name
-- arn                  : The ARN of the resource being targeted
MUTUALLY EXCLUSIVE TARGETS INPUTS:
-- input                : OPTIONAL JSON string of input to pass to target, defaults to null
-- input_path           : OPTIONAL value of the JSONPath that is used for extracting part of the matched event when passing it to the target, defaults to null.
-- input_transformer    : OPTIONAL parameters used when you are providing a custom input to a target based on certain event data, defaults to null.

One of the following, but not both:
- schedule              : The scheduling expression. For example, cron(0 20 * * ? *) or rate(5 minutes)
- pattern               : Pattern for the event to match on, should be jsonencoded dictionary

OPTIONAL
---------
By default we deploy event bridge rules as disabled, and ignore state on apply, such that
enabling/disabling event bridge rules is always a manual affair rather than doing via Terraform. But via the below
optional values this may be changed on a per-rule basis.

- state                 : By default DISABLED, can set to ENABLED or ENABLED_WITH_ALL_CLOUDTRAIL_MANAGEMENT_EVENTS
- ignore_state          : By default true, can set to false.


IAM role  Statement and Role Suffix to be used for this target when the rule is triggered.
Required if ecs_target is used or target in arn is EC2 instance, Kinesis data stream, Step Functions state machine,
or Event Bus in different account or region.
- iam_role_suffix       : IAM role suffix for the event bridge Role having permission to invoke target AWS Service
- iam_policy_statements : A list of dictionaries where each dictionary is an IAM statement defining Event Bridge permissions
-- conditions    : An OPTIONAL list of dictionaries, which each defines:
--- test         : Test condition for limiting the action
--- variable     : Value to test
--- values       : A list of strings, denoting what to test for


EOT
  type = list(
    object({
      suffix      = string,
      description = string,
      targets = optional(list(
        object({
          name       = string,
          arn        = string,
          input      = optional(string, null)
          input_path = optional(string, null)
          input_transformer = optional(object({
            input_template = string,
            input_paths    = optional(map(any), null)
          }), null)
      })), null),
      schedule        = optional(string, null),
      pattern         = optional(string, null),
      iam_role_suffix = optional(string, ""),
      iam_policy_statements = optional(list(
        object({
          sid       = string,
          actions   = list(string),
          resources = list(string),
          conditions = optional(list(
            object({
              test : string,
              variable : string,
              values = list(string)
            })
          ), [])
      })), []),
      state        = optional(string, "DISABLED"),
      ignore_state = optional(bool, true)
    })
  )

  validation {
    condition = alltrue([
      for rule in var.raw_event_bridge_rules : !(rule.pattern == null && rule.schedule == null)
    ])
    error_message = "Each rule must define either a pattern or schedule for its trigger."
  }

  validation {
    condition = alltrue([
      for rule in var.raw_event_bridge_rules : contains(["ENABLED", "ENABLED_WITH_ALL_CLOUDTRAIL_MANAGEMENT_EVENTS", "DISABLED"], rule.state)
    ])
    error_message = "state for each one must be one of: ENABLED, ENABLED_WITH_ALL_CLOUDTRAIL_MANAGEMENT_EVENTS, DISABLED"
  }
  validation {
    condition = alltrue([
      for rule in var.raw_event_bridge_rules : alltrue([
        /*
            Negate statement, such that we fail validation if all of these
            conditions are true
          */
        for target in rule.targets : alltrue([
          !(
            can(regex("arn:aws:states", target.arn)) &&
            length(rule.iam_policy_statements) == 0 &&
            rule.iam_role_suffix == ""
          )
        ])
      ])
    ])
    error_message = "state machine targets require iam_role_suffix and iam_policy_statements to be defined."
  }
  validation {
    condition = alltrue([
      for rule in var.raw_event_bridge_rules : alltrue([
        /*
          Negate statement, such that we fail validation if all of these
          conditions are true
        */
        for target in rule.targets : alltrue([
          !(
            can(regex("arn:aws:ec2", target.arn)) &&
            length(rule.iam_policy_statements) == 0 &&
            rule.iam_role_suffix == ""
          )
        ])
      ])
    ])
    error_message = "ec2 targets require iam_role_suffix and iam_policy_statements to be defined."
  }

  validation {
    condition = alltrue([
      for rule in var.raw_event_bridge_rules : alltrue([
        /*
          Negate statement, such that we fail validation if all of these
          conditions are true
        */
        for target in rule.targets : alltrue([
          !(
            can(regex("arn:aws:kinesis:*:*:stream", target.arn)) &&
            length(rule.iam_policy_statements) == 0 &&
            rule.iam_role_suffix == ""
          )
        ])
      ])
    ])
    error_message = "Kinesis data stream targets require iam_role_suffix and iam_policy_statements to be defined."
  }

  validation {
    condition = alltrue([
      for rule in var.raw_event_bridge_rules : alltrue([
        /*
          Negate statement, such that we fail validation if all of these
          conditions are true
        */
        for target in rule.targets : alltrue([
          !(
            can(regex("arn:aws:events", target.arn)) &&
            length(rule.iam_policy_statements) == 0 &&
            rule.iam_role_suffix == ""
          )
        ])
      ])
    ])
    error_message = "Event bus targets require iam_role_suffix and iam_policy_statements to be defined."
  }

  validation {
    condition = alltrue([
      for rule in var.raw_event_bridge_rules : alltrue([

        rule.schedule == null ? true : (
          can(regex("cron", rule.schedule)) || can(regex("rate", rule.schedule))
        )
      ])

    ])
    error_message = "If schedule is used for a rule, it must define either a cron() or rate() scheduling."
  }

  validation {
    condition = alltrue([
      for rule in var.raw_event_bridge_rules : alltrue([
        for target in rule.targets : alltrue([
          (target.input != null && target.input_path == null && target.input_transformer == null) ||
          (target.input == null && target.input_path != null && target.input_transformer == null) ||
          (target.input == null && target.input_path == null && target.input_transformer != null) ||
          (target.input == null && target.input_path == null && target.input_transformer == null)
        ])
      ])
    ])
    error_message = "input, input_path and input_transformer are mutually exclusive"
  }
}