variable "event_rule" {
  description = "Name of the event rule"
  type        = string
}

variable "event_target" {
  description = "The resource target of the event"
  type        = string
}

variable "event_target_arn" {
  description = "The arn of the resource being targeted, for cross account use the arn of the event bus"
  type        = string
}

variable "event_bus" {
  description = "Name of the event bus. Do not use if using a cross account event bus"
  type        = string
  default     = null
}

variable "event_target_role_arn" {
  description = "The Amazon Resource Name (ARN) of the IAM role to be used for this target when the rule is triggered. Required if ecs_target is used or target in arn is EC2 instance, Kinesis data stream, Step Functions state machine, or Event Bus in different account or region."
  type        = string
  default     = null
}

variable "event_target_input" {
  description = "Valid JSON text passed to the target"
  type        = string
  default     = null
}

variable "event_target_input_path" {
  description = "The value of the JSONPath that is used for extracting part of the matched event when passing it to the target."
  type        = string
  default     = null
}

variable "event_target_input_transformer" {
  description = "Parameters used when you are providing a custom input to a target based on certain event data"
  type = object({
    input_template = string,
    input_paths    = optional(map(any), null)
  })
}