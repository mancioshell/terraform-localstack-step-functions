#################################################################################
## Lambda Iam Role Module                                                      ##
#################################################################################

module "iam" {
  source         = "./modules/iam"
}

#################################################################################
## CloudFront Module                                                           ##
#################################################################################

module "cloudfront" {
  source         = "./modules/cloudfront"
  aws-region     = var.aws-region
}

#################################################################################
## Step Functions Module                                                       ##
#################################################################################

module "step-functions" {
  source         = "./modules/step-functions"
  aws-region     = var.aws-region
  iam_role_for_lambda_arn   = module.iam.aws_iam_role_for_lambda_arn
}

#################################################################################
## Cognito Module                                                              ##
#################################################################################

module "cognito" {
  source         = "./modules/cognito"
  aws-region     = var.aws-region
  cdn-domain-name = module.cloudfront.cloudfront_domain_name
}

#################################################################################
## API Gateway Module                                                          ##
#################################################################################

module "api-gateway" {
  source         = "./modules/api-gateway"
  aws-region     = var.aws-region
  cognito-user-pool-id = module.cognito.cognito_user_pool_id
  state_machine_arn = module.step-functions.state_machine_arn
  iam_role_for_lambda_arn = module.iam.aws_iam_role_for_lambda_arn
}