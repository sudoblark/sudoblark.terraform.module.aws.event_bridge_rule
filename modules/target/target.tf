resource "aws_cloudwatch_event_target" "event_target" {
  rule           = var.event_rule
  target_id      = var.event_target
  arn            = var.event_target_arn
  event_bus_name = var.event_bus
  role_arn       = var.event_target_role_arn
  input          = var.event_target_input
  input_path     = var.event_target_input_path

  dynamic "input_transformer" {
    // i.e. only have an input_transformer block if event_target_input_transformer is not null
    for_each = var.event_target_input_transformer == null ? [] : [var.event_target_input_transformer]
    content {
      input_paths    = var.event_target_input_transformer.input_paths
      input_template = var.event_target_input_transformer.input_template
    }
  }
  lifecycle {
    precondition {
      condition = alltrue([
        (var.event_target_input != null && var.event_target_input_path == null && var.event_target_input_transformer == null) ||
        (var.event_target_input == null && var.event_target_input_path != null && var.event_target_input_transformer == null) ||
        (var.event_target_input == null && var.event_target_input_path == null && var.event_target_input_transformer != null) ||
        (var.event_target_input == null && var.event_target_input_path == null && var.event_target_input_transformer == null)
      ])
      error_message = "event_target_input, event_target_input_path and event_target_input_transformer are mutually exclusive"
    }
  }
}
