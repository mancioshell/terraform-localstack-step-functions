##################################
# Lambda Functions               #
##################################

data "archive_file" "lambda_adam" {
  type        = "zip"
  source_file = "../apps/adam/dist/lambda.js"
  output_path = "../apps/adam/lambda.zip"
}

resource "aws_lambda_function" "lambda_adam" {
  function_name    = "lambda_adam"
  role             = var.iam_role_for_lambda_arn
  filename         = data.archive_file.lambda_adam.output_path
  handler          = "lambda.handler"
  source_code_hash = data.archive_file.lambda_adam.output_base64sha256
  runtime          = "nodejs22.x"
  timeout          = 60

  environment {
    variables = {
      ENVIRONMENT = "dev"
    }
  }
}

data "archive_file" "lambda_cole" {
  type        = "zip"
  source_file = "../apps/cole/dist/lambda.js"
  output_path = "../apps/cole/lambda.zip"
}

resource "aws_lambda_function" "lambda_cole" {
  function_name    = "lambda_cole"
  role             = var.iam_role_for_lambda_arn
  filename         = data.archive_file.lambda_cole.output_path
  handler          = "lambda.handler"
  source_code_hash = data.archive_file.lambda_cole.output_base64sha256
  runtime          = "nodejs22.x"
  timeout          = 60

  environment {
    variables = {
      ENVIRONMENT = "dev"
    }
  }
}

data "archive_file" "lambda_combine" {
  type        = "zip"
  source_file = "../apps/combine/dist/lambda.js"
  output_path = "../apps/combine/lambda.zip"
}

resource "aws_lambda_function" "lambda_combine" {
  function_name    = "lambda_combine"
  role             = var.iam_role_for_lambda_arn
  filename         = data.archive_file.lambda_combine.output_path
  handler          = "lambda.handler"
  source_code_hash = data.archive_file.lambda_combine.output_base64sha256
  runtime          = "nodejs22.x"
  timeout          = 60

  environment {
    variables = {
      ENVIRONMENT = "dev"
    }
  }
}