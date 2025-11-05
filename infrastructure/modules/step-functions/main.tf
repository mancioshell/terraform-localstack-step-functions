data "template_file" "step_functions_definition" {
  template = jsonencode(yamldecode(file("${path.module}/data/step-function-definition.yaml")))
}

resource "aws_sfn_state_machine" "step_demo" {
  name     = "step-demo"
  role_arn = aws_iam_role.iam_for_step_functions.arn

  type     = "EXPRESS"

  definition = data.template_file.step_functions_definition.rendered
}