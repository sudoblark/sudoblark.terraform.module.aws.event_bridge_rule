variable "application_name" {
  description = "Name of the application the rule relates to."
  type        = string
}

variable "environment" {
  description = "Which environment this is being instantiated in."
  type        = string
  validation {
    condition     = contains(["dev", "test", "prod"], var.environment)
    error_message = "Must be either dev, test or prod"
  }
}

variable "event_bus" {
  description = "The name of the event bus"
  type        = string
  default     = "default"
}

variable "event_pattern" {
  description = "The pattern for the event"
  type        = string
  default     = null
}

variable "event_description" {
  description = "The description of the event rule"
  type        = string
}

variable "state" {
  description = "Initial state of the resource"
  type        = string
  default     = "ENABLED"
  validation {
    condition = alltrue([
      contains(["ENABLED", "DISABLED", "ENABLED_WITH_ALL_CLOUDTRAIL_MANAGEMENT_EVENTS"], var.state)
    ])
    error_message = "state must be one of the following: ENABLED, DISABLED, ENABLED_WITH_ALL_CLOUDTRAIL_MANAGEMENT_EVENTS"
  }
}

variable "event_name_suffix" {
  description = "Additional suffix to for event bridge rule."
  type        = string
}

variable "resource_tags" {
  description = "Additional tags for the resource."
  default     = null
}

variable "event_schedule" {
  description = "The scheduling expression. For example, cron(0 20 * * ? *) or rate(5 minutes)."
  default     = null
}

variable "ignore_state" {
  description = "Ignore state when deploying the resource."
  default     = false
}