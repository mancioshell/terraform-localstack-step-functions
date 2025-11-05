##################################
## IAM Role for Step Functions  ##
##################################

data "aws_iam_policy_document" "step_function_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["states.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "iam_for_step_functions" {
  name               = "iam_for_step_functions"
  assume_role_policy = data.aws_iam_policy_document.step_function_assume_role.json
}

data "aws_iam_policy_document" "lambda_access_policy" {
  statement {
    actions = [
      "lambda:*"
    ]
    resources = ["*"]
  }
}

resource "aws_iam_policy" "step_functions_policy_lambda" {
  name   = "step_functions_policy_lambda_policy_all_poc_sf"
  policy = data.aws_iam_policy_document.lambda_access_policy.json
}

resource "aws_iam_role_policy_attachment" "step_functions_to_lambda" {
  role       = aws_iam_role.iam_for_step_functions.name
  policy_arn = aws_iam_policy.step_functions_policy_lambda.arn
}