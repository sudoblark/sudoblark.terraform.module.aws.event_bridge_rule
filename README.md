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

<!-- END_TF_DOCS -->

## Data structure
<POPULATE WITH YOUR DATA STRUCTURE>

## Examples
See `examples` folder for an example setup.
