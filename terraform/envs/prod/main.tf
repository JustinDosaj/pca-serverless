provider "aws" {
    region      = var.region
    profile     = var.aws-profile
}

module "iam_for_lambda" {
    source = "../../modules/iam"
    environment = "prod"
}

module "lambda" {
    source = "../../modules/lambda"
    environment = "prod"
    handler = "handler"
    iam_role_arn = module.iam_for_lambda.iam_role_arn
}

