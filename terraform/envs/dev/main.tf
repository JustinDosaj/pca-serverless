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
    source = "../../modules/api-gateway"
    environment = "dev"
    chat_completion_invoke_arn = module.chat_completion.chat_completion_uri
    chat_completion_arn = module.chat_completion.chat_completion_arn
}


