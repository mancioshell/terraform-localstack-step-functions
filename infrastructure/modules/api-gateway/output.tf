output "aws_api_gateway_rest_api_id" {
  description = "The ID of the API Gateway REST API"
  value       = aws_api_gateway_rest_api.api-gw.id
}

output "api_gateway_base_url" {
  value = aws_api_gateway_stage.v1.invoke_url
}