provider "aws" {
    region      = var.region
    profile     = var.aws-profile
}

module "iam_for_lambda" {
    source = "../../modules/iam"
    environment = "dev"
}

module "chat_completion" {
    source = "../../modules/lambda"
    environment = "dev"
    iam_role_arn = module.iam_for_lambda.iam_role_arn
}

module "ChatCompletionAPI" {
  source                     = "../../modules/api-gateway"
  environment                = "dev"
  chat_completion_invoke_arn = module.chat_completion.chat_completion_invoke_arn
  chat_completion_arn        = module.chat_completion.chat_completion_arn
  region                     = var.region
  
  # Add these variables with values from your Amplify project
  cognito_user_pool_id       = "us-west-1_9ZbuQizvZ" # Replace with your actual Amplify-created User Pool ID
  cognito_user_pool_client_id = "30oarcfi7d6rseca2234957fm6" # Replace with your actual Amplify-created App Client ID
}


