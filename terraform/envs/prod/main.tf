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
    function_name = "prod_hello_world"
    handler = "handler"
    iam_role_arn = module.iam_for_lambda.iam_role_arn
}

