output "cloudfront_domain_name" {
  value = module.cloudfront.cloudfront_domain_name
}

output "cloudfront_distribution_id" {
  value = module.cloudfront.cloudfront_distribution_id
}

output "s3_bucket_name" {
  value = module.cloudfront.s3_bucket_name
}

output "aws_api_gateway_rest_api_id" {
  description = "The ID of the API Gateway REST API"
  value       = module.api-gateway.aws_api_gateway_rest_api_id
}

output "api_gateway_base_url" {
  value = module.api-gateway.api_gateway_base_url
}

output "cognito_client_id" {
  value = module.cognito.cognito_client_id
}

output "cognito_user_pool_id" {
  value = module.cognito.cognito_user_pool_id
}