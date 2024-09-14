locals {
  raw_event_bridge_rules = [
    # Rule is enabled and its state is managed with Terraform
    {
      suffix       = "sagemaker-promotion"
      description  = "Trigger SageMaker model promotion when package state changes"
      state        = "ENABLED"
      ignore_state = "false"
      targets = [
        {
          name = "my-promotion-lambda"
          arn  = "arn:aws:lambda:${data.aws_region.current_region.name}:${data.aws_caller_identity.current_account.account_id}:function:my-promotion-lambda"
        }
      ]
      pattern = jsonencode({
        source      = ["aws.sagemaker"]
        detail-type = ["SageMaker Model Package State Change"]
        detail = {
          "ModelPackageGroupName" : [
            {
              "exists" : true
            }
          ]
        }
      })
    },
    # Rule is disabled, by state is not managed by Terraform, thus it may be enabled/disabled in the account
    # manually by individuals
    {
      suffix      = "hourly-healthcheck"
      description = "EventBridge Schedule Rule to trigger hourly healthcheck lambda"
      schedule    = "cron(0 0 * * ? *)"
      targets = [
        {
          name = "hourly-healthcheck-lambda"
          arn  = "arn:aws:lambda:${data.aws_region.current_region.name}:${data.aws_caller_identity.current_account.account_id}:function:hourly-healthcheck-lambda"
        }
      ]
      iam_role_suffix = "healthcheck"
    },
  ]
}