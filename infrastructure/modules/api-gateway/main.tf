# API Gateway
resource "aws_api_gateway_rest_api" "api-gw" {
  name        = "api-gw"
  description = "API Gateway for Step Functions integration"

  endpoint_configuration {
    types = ["REGIONAL"]
  }
}

# API Gateway root resource
resource "aws_api_gateway_resource" "root" {
  rest_api_id = aws_api_gateway_rest_api.api-gw.id
  parent_id   = aws_api_gateway_rest_api.api-gw.root_resource_id
  path_part   = "{proxy+}"
}

# API Gateway Method and Integration for CORS

resource "aws_api_gateway_method" "options" {
  rest_api_id   = aws_api_gateway_rest_api.api-gw.id
  resource_id   = aws_api_gateway_resource.root.id
  http_method   = "OPTIONS"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "options_integration" {
  rest_api_id             = aws_api_gateway_rest_api.api-gw.id
  resource_id             = aws_api_gateway_resource.root.id
  http_method             = aws_api_gateway_method.options.http_method
  integration_http_method = "OPTIONS"
  type                    = "MOCK"

  request_templates = {
    "application/json" = "{\"statusCode\": 200}"
  }
  
  # depends_on = [aws_api_gateway_method.options]
}

resource "aws_api_gateway_method_response" "options_response" {
  rest_api_id = aws_api_gateway_rest_api.api-gw.id
  resource_id = aws_api_gateway_resource.root.id
  http_method = aws_api_gateway_method.options.http_method
  status_code = "200"

  response_models = {
    "application/json" = "Empty"
  }

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = true,
    "method.response.header.Access-Control-Allow-Methods" = true,
    "method.response.header.Access-Control-Allow-Origin"  = true,
  }
  # depends_on = [aws_api_gateway_method.options]
}

resource "aws_api_gateway_integration_response" "options_integration_response" {
  rest_api_id = aws_api_gateway_rest_api.api-gw.id
  resource_id = aws_api_gateway_resource.root.id
  http_method = aws_api_gateway_method.options.http_method
  status_code = aws_api_gateway_method_response.options_response.status_code

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = "'*'",
    "method.response.header.Access-Control-Allow-Methods" = "'POST,OPTIONS'",
    "method.response.header.Access-Control-Allow-Origin"  = "'*'"
  }

  # depends_on = [
  #   aws_api_gateway_method.options,
  #   aws_api_gateway_integration.options_integration,
  # ]
}

# API Gateway Method and Integration for Step Functions

resource "aws_api_gateway_method" "proxy" {
  rest_api_id   = aws_api_gateway_rest_api.api-gw.id
  resource_id   = aws_api_gateway_resource.root.id
  http_method   = "POST"
  authorization = "CUSTOM"
  authorizer_id = aws_api_gateway_authorizer.cognito_custom_authorizer.id
}

resource "aws_api_gateway_integration" "step_function_integration" {
  rest_api_id             = aws_api_gateway_rest_api.api-gw.id
  resource_id             = aws_api_gateway_resource.root.id
  http_method             = aws_api_gateway_method.proxy.http_method
  integration_http_method = "POST"
  type                    = "AWS"
  uri = (
    "arn:aws:apigateway:${var.aws-region}:states:action/StartSyncExecution"
  )
  credentials = aws_iam_role.iam_for_apigw_start_sfn.arn

  request_templates = {
    "application/json" = <<EOF
    #set($input = $input.json('$'))
    {
      "input": "$util.escapeJavaScript($input)",
      "stateMachineArn": "${var.state_machine_arn}"
    }
    EOF
  }
}

resource "aws_api_gateway_method_response" "proxy_response" {
  rest_api_id = aws_api_gateway_rest_api.api-gw.id
  resource_id = aws_api_gateway_resource.root.id
  http_method = aws_api_gateway_method.proxy.http_method
  status_code = "200"
}

resource "aws_api_gateway_integration_response" "step_function_integration_response" {
  rest_api_id = aws_api_gateway_rest_api.api-gw.id
  resource_id = aws_api_gateway_resource.root.id
  http_method = aws_api_gateway_method.proxy.http_method

  status_code = aws_api_gateway_method_response.proxy_response.status_code

  response_templates = {
    "application/json" = <<EOF
      #set ($bodyObj = $util.parseJson($input.body))
        
      #if ($bodyObj.status == "SUCCEEDED")
          #set ($bodyPayload = $util.parseJson($bodyObj.output))
          #set($context.responseOverride.header.Access-Control-Allow-Headers = "*")
          #set($context.responseOverride.header.Access-Control-Allow-Methods = "*")
          #set($context.responseOverride.header.Access-Control-Allow-Origin = "*")
          $bodyPayload.Payload
      #elseif ($bodyObj.status == "FAILED")
          #set($context.responseOverride.status = 500)
          {
              "cause": "$bodyObj.cause",
              "error": "$bodyObj.error"
          }
      #else
          #set($context.responseOverride.status = 500)
          $input.body
      #end
    EOF
  }

  depends_on = [
    aws_api_gateway_method.proxy,
    aws_api_gateway_integration.step_function_integration,
  ]
}

resource "aws_api_gateway_deployment" "v1" {

  depends_on = [
    aws_api_gateway_integration.step_function_integration,
  ]

  triggers = {
    redeployment = sha1(jsonencode([
      aws_api_gateway_resource.root,
      aws_api_gateway_method.proxy,
      aws_api_gateway_integration.step_function_integration,
      aws_api_gateway_integration_response.step_function_integration_response,
      aws_api_gateway_method_response.proxy_response,

      aws_api_gateway_method.options,
      aws_api_gateway_integration.options_integration,
      aws_api_gateway_integration_response.options_integration_response,
      aws_api_gateway_method_response.options_response,
    ]))
  }

  lifecycle {
    create_before_destroy = true
  }

  rest_api_id = aws_api_gateway_rest_api.api-gw.id
}


resource "aws_api_gateway_stage" "v1" {
  deployment_id = aws_api_gateway_deployment.v1.id
  rest_api_id   = aws_api_gateway_rest_api.api-gw.id
  stage_name    = "v1"

  depends_on = [
    aws_cloudwatch_log_group.api_gateway_execution_logs,
    aws_api_gateway_account.demo
  ]

  access_log_settings {
    destination_arn = aws_cloudwatch_log_group.api_gateway_execution_logs.arn
    format = jsonencode({
      requestId      = "$context.requestId"
      ip             = "$context.identity.sourceIp"
      requestTime    = "$context.requestTime"
      httpMethod     = "$context.httpMethod"
      resourcePath   = "$context.resourcePath"
      status         = "$context.status"
      responseLength = "$context.responseLength"
    })
  }
}

resource "aws_api_gateway_method_settings" "method_settings" {
  rest_api_id = aws_api_gateway_rest_api.api-gw.id
  stage_name  = aws_api_gateway_stage.v1.stage_name
  method_path = "*/*"
  settings {
    logging_level      = "INFO"
    data_trace_enabled = true
    metrics_enabled    = true
  }
}

resource "aws_api_gateway_account" "demo" {
  cloudwatch_role_arn = aws_iam_role.iam_for_apigw_start_sfn.arn
}

resource "aws_api_gateway_authorizer" "cognito_custom_authorizer" {
  name           = "cognito_custom_authorizer"
  rest_api_id    = aws_api_gateway_rest_api.api-gw.id
  authorizer_uri = aws_lambda_function.lambda_auth.invoke_arn
  #  authorizer_credentials = aws_iam_role.invocation_role.arn
  authorizer_result_ttl_in_seconds = 0
}