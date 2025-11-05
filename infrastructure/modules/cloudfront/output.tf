output "cloudfront_domain_name" {
  value = "https://${aws_cloudfront_distribution.cdn.domain_name}"
}

output "cloudfront_distribution_id" {
  value = aws_cloudfront_distribution.cdn.id
}

output "s3_bucket_name" {
  value = aws_s3_bucket.cognito_static_website.id
}