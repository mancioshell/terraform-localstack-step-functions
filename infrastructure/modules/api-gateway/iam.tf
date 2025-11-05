##################################
## IAM Role for API Gateway     ##
##################################

data "aws_iam_policy_document" "api_gateway_assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["apigateway.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "iam_for_apigw_start_sfn" {
  name               = "iam_for_apigw_start_sfn"
  assume_role_policy = data.aws_iam_policy_document.api_gateway_assume_role.json
}

##################################
## IAM Role for CloudWatch      ##
##################################


data "aws_iam_policy_document" "cloudwatch" {
  statement {
    effect = "Allow"

    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:DescribeLogGroups",
      "logs:DescribeLogStreams",
      "logs:PutLogEvents",
      "logs:GetLogEvents",
      "logs:FilterLogEvents",
    ]

    resources = ["*"]
  }
}

resource "aws_iam_role_policy" "cloudwatch" {
  name   = "default"
  role   = aws_iam_role.iam_for_apigw_start_sfn.id
  policy = data.aws_iam_policy_document.cloudwatch.json
}