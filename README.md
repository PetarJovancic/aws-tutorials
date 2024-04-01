# AWS Tutorials

This repository provides several examples to demonstrate functionality of popular AWS services.

## Getting started

- An AWS account. Amazon has sufficient free-tier services for many of these tutorials unless otherwise stated. See <a href="https://aws.amazon.com/free/">Free 1 year AWS account</a>.
- The AWS CLI. See <a href="https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html">Installing AWS CLI</a>.
- The Terraform. See <a href="https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli">Installing Terraform</a>.
- Python Programming Language. See <a href="https://www.python.org/downloads/">Installing Python</a>.

### Identity Access Management (IAM)
- Create User and set Permissions. See <a href="https://us-east-1.console.aws.amazon.com/iam/home#/home">AWS IAM management console</a>.

- Run following command in terminal to configure AWS locally:
```
aws configure
```
- Create hello world lambda handler and define lambda function.
- Run following command to create terraform file:

```
touch main.tf
```


- In main.tf define an AWS Lambda function and API Gateway resource.

- To deploy lambda run following command:
```
terraform init
terraform plan
terraform apply
```