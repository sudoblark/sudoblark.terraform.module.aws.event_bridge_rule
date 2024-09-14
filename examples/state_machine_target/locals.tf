locals {
  raw_event_bridge_rules = [
    # Rule is enabled and its state is managed with Terraform
    {
      suffix       = "etl-load"
      description  = "EventBridge Schedule Rule to trigger StateMachine based on a schedule."
      state        = "ENABLED"
      ignore_state = "false"
      schedule     = "cron(0 0 * * ? *)"
      targets = [
        {
          name : "StateMachine"
          arn : "arn:aws:states:${data.aws_region.current_region.name}:${data.aws_caller_identity.current_account.account_id}:stateMachine:etl-load"
        }
      ]
      iam_role_suffix = "etl-load"
      iam_policy_statements = [
        {
          sid = "EventBridgeInvokeStateMachine",
          actions = [
            "states:StartExecution"
          ]
          resources = [
            "arn:aws:states:${data.aws_region.current_region.name}:${data.aws_caller_identity.current_account.account_id}:stateMachine:etl-load"
          ]
        }
      ]
    },
    # Rule is disabled, by state is not managed by Terraform, thus it may be enabled/disabled in the account
    # manually by individuals
    {
      suffix      = "daily-load-alert"
      description = "Tracks and monitors status in daily step function and send SNS notification for any status other than success."
      pattern = jsonencode(
        {
          "source" : ["aws.states"],
          "detail-type" : ["Step Functions Execution Status Change"],
          "detail" : {
            "status" : ["SUCCEEDED", "FAILED", "TIMED_OUT", "ABORTED"],
            "stateMachineArn" : ["arn:aws:states:${data.aws_region.current_region.name}:${data.aws_caller_identity.current_account.account_id}:stateMachine:etl-load"]
          }
        }
      )
      targets = [
        {
          name : "SNSTopic"
          arn : "arn:aws:sns:${data.aws_region.current_region.name}:${data.aws_caller_identity.current_account.account_id}:etl-alert-topic"
        }
      ]
    },
  ]
}