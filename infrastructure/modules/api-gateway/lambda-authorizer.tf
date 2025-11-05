# # Lambda Authorizer

data "archive_file" "lambda_auth" {
  type        = "zip"
  source_file = "../apps/auth-lambda/dist/lambda.js"
  output_path = "../apps/auth-lambda/lambda.zip"
}

resource "aws_lambda_function" "lambda_auth" {
  function_name    = "lambda_auth"
  role             = var.iam_role_for_lambda_arn
  filename         = data.archive_file.lambda_auth.output_path
  handler          = "lambda.handler"
  source_code_hash = data.archive_file.lambda_auth.output_base64sha256
  runtime          = "nodejs22.x"
  timeout          = 60

  environment {
    variables = {
      ENVIRONMENT = "dev"
      COGNITO_REGION = "us-east-1"
      COGNITO_USER_POOL_ID = var.cognito-user-pool-id
    }
  }
}