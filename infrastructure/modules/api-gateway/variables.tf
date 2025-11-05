variable "aws-region" {
  type = string
}

variable "cognito-user-pool-id" {
  type = string
}

variable "iam_role_for_lambda_arn" {
  type = string
}

variable "state_machine_arn" {
  type = string
}