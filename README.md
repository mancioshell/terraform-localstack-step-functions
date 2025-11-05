# Monorepo Example: AWS Lambda and Step Functions with LocalStack and Terraform

A monorepo example using AWS Lambda and Step Functions with LocalStack and Terraform.

## Prerequisites

Install the following tools before getting started:

- [Docker](https://www.docker.com/get-started)
- [LocalStack](https://localstack.cloud/)
- [Terraform](https://www.terraform.io/downloads.html)
- [Terraform Local](https://github.com/localstack/terraform-local)
- [AWS CLI](https://aws.amazon.com/cli/)
- [AWS CLI Local](https://github.com/localstack/awscli-local)
- [Node.js](https://nodejs.org/en/download/)
- [Yarn](https://yarnpkg.com/getting-started/install)

## Setup Instructions

1. Install turbo globally if you haven't already:

   ```bash
   yarn global add turbo
   ```

2. Build lambdas and deploy infrastructure using Turbo:

   ```bash
   turbo run build
   ```

3. Start LocalStack:

   ```bash
   localstack start
   ```

4. Navigate to the `infrastructure` directory and apply the Terraform configuration:

   ```bash
   cd infrastructure
   terraform init
   terraform apply
   ```

## Testing the Application

To test the API Gateway endpoint, use the following `curl` command:

```bash
curl --request POST \
  --url http://<rest-api-id>.execute-api.localhost.localstack.cloud:4566/v1/step-functions \
  --header 'content-type: application/json' \
  --data '{
  "inputX": "Hello",
  "inputY": "World"
}'
```

Replace `<rest-api-id>` with your actual API Gateway REST API ID.
