# sudoblark.terraform.module.aws.event_bridge_rule
Terraform module to create N event bridge rules with targets and custom IAM policies. - repo managed by sudoblark.terraform.github

## Developer documentation
The below documentation is intended to assist a developer with interacting with the Terraform module in order to add,
remove or update functionality.

### Pre-requisites
* terraform_docs

```sh
brew install terraform_docs
```

* tfenv
```sh
git clone https://github.com/tfutils/tfenv.git ~/.tfenv
echo 'export PATH="$HOME/.tfenv/bin:$PATH"' >> ~/.bash_profile
```

* Virtual environment with pre-commit installed

```sh
python3 -m venv venv
source venv/bin/activate
pip install pre-commit
```
### Pre-commit hooks
This repository utilises pre-commit in order to ensure a base level of quality on every commit. The hooks
may be installed as follows:

```sh
source venv/bin/activate
pip install pre-commit
pre-commit install
pre-commit run --all-files
```

# Module documentation
The below documentation is intended to assist users in utilising the module, the main thing to note is the
[data structure](#data-structure) section which outlines the interface by which users are expected to interact with
the module itself, and the [examples](#examples) section which has examples of how to utilise the module.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | ~> 1.5.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 4.63.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 5.67.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_rule"></a> [rule](#module\_rule) | ./modules/rule | n/a |
| <a name="module_target"></a> [target](#module\_target) | ./modules/target | n/a |

## Resources

| Name | Type |
|------|------|
| [aws_iam_policy.invoke_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_role.invoke_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy_attachment.invoke_role_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_lambda_permission.allow_lambda_execution_from_event_bridge](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_permission) | resource |
| [aws_iam_policy_document.allow_event_bridge_assume](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.event_bridge_target_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_application_name"></a> [application\_name](#input\_application\_name) | Name of the application utilising resource. | `string` | n/a | yes |
| <a name="input_environment"></a> [environment](#input\_environment) | Which environment this is being instantiated in. | `string` | n/a | yes |
| <a name="input_raw_event_bridge_rules"></a> [raw\_event\_bridge\_rules](#input\_raw\_event\_bridge\_rules) | Data structure<br>---------------<br>A list of dictionaries, where each dictionary has the following attributes:<br><br>REQUIRED<br>---------<br>- suffix                : Friendly name for the rule in Event Bridge<br>- description           : A friendly description of what the Event Bridge rule does<br>- targets               : A list of dictionaries with the following attributes, defining what target this event triggers:<br>-- name                 : A friendly name for the target, if lambda this should be the lambda name<br>-- arn                  : The ARN of the resource being targeted<br>MUTUALLY EXCLUSIVE TARGETS INPUTS:<br>-- input                : OPTIONAL JSON string of input to pass to target, defaults to null<br>-- input\_path           : OPTIONAL value of the JSONPath that is used for extracting part of the matched event when passing it to the target, defaults to null.<br>-- input\_transformer    : OPTIONAL parameters used when you are providing a custom input to a target based on certain event data, defaults to null.<br><br>One of the following, but not both:<br>- schedule              : The scheduling expression. For example, cron(0 20 * * ? *) or rate(5 minutes)<br>- pattern               : Pattern for the event to match on, should be jsonencoded dictionary<br><br>OPTIONAL<br>---------<br>By default we deploy event bridge rules as disabled, and ignore state on apply, such that<br>enabling/disabling event bridge rules is always a manual affair rather than doing via Terraform. But via the below<br>optional values this may be changed on a per-rule basis.<br><br>- state                 : By default DISABLED, can set to ENABLED or ENABLED\_WITH\_ALL\_CLOUDTRAIL\_MANAGEMENT\_EVENTS<br>- ignore\_state          : By default true, can set to false.<br><br><br>IAM role  Statement and Role Suffix to be used for this target when the rule is triggered.<br>Required if ecs\_target is used or target in arn is EC2 instance, Kinesis data stream, Step Functions state machine,<br>or Event Bus in different account or region.<br>- iam\_role\_suffix       : IAM role suffix for the event bridge Role having permission to invoke target AWS Service<br>- iam\_policy\_statements : A list of dictionaries where each dictionary is an IAM statement defining Event Bridge permissions<br>-- conditions    : An OPTIONAL list of dictionaries, which each defines:<br>--- test         : Test condition for limiting the action<br>--- variable     : Value to test<br>--- values       : A list of strings, denoting what to test for | <pre>list(<br>    object({<br>      suffix      = string,<br>      description = string,<br>      targets = optional(list(<br>        object({<br>          name       = string,<br>          arn        = string,<br>          input      = optional(string, null)<br>          input_path = optional(string, null)<br>          input_transformer = optional(object({<br>            input_template = string,<br>            input_paths    = optional(map(any), null)<br>          }), null)<br>      })), null),<br>      schedule        = optional(string, null),<br>      pattern         = optional(string, null),<br>      iam_role_suffix = optional(string, ""),<br>      iam_policy_statements = optional(list(<br>        object({<br>          sid       = string,<br>          actions   = list(string),<br>          resources = list(string),<br>          conditions = optional(list(<br>            object({<br>              test : string,<br>              variable : string,<br>              values = list(string)<br>            })<br>          ), [])<br>      })), []),<br>      state        = optional(string, "DISABLED"),<br>      ignore_state = optional(bool, true)<br>    })<br>  )</pre> | n/a | yes |

## Outputs

No outputs.
<!-- END_TF_DOCS -->

## Data structure
```
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
```

## Examples
See `examples` folder for an example setup.
