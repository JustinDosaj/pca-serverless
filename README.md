# Private Chat Project - Frontend
This repository contains the serverless backend for the private chat app, managing infrastructure-as-code with [Terraform](https://developer.hashicorp.com/terraform) and writing lambda functions using [Node.js 22](https://nodejs.org/en).

## Project Overview
The overall goal of this project is to allow a typical LLM conversation to take place, but with the option to automatically remove personal identifiable information while maintaining original message context.

### Features
- Deploy and entirely serverless backend using [Terraform](https://www.terraform.io/) Infrastructure-as-Code
- Personal Identifiable Information is removed from chat messages before sending to third-party servers (see `Project Status` section).

## Tech Stack
- **Infrastructure-as-Code**: [Terraform](https://www.terraform.io/)
- **Compute**: [AWS Lambda](https://aws.amazon.com/lambda/)
- **API Management**: [AWS API Gateway](https://aws.amazon.com/api-gateway/)
- **Database**: [AWS DynamoDB](https://aws.amazon.com/dynamodb/)
- **PII Removal**: [AWS Comprehend](https://aws.amazon.com/comprehend/)

## Environment Variables
The following environment variables are required for the app to function properly:

| Variable Name | Description |
|---------------|-------------|
| `openai_api_key` | The base URI of the backend APIs deployed by [pca-serverless](https://github.com/JustinDosaj/pca-serverless) |
| `iam_account_id` | Your IAM account ID |
| `cognito_id` | Cognito User Pool ID from AWS Amplify Auth (found in cognito console) |
| `cognito_client_id` | Cognito Client ID from AWS Amplify Auth

Create a `terraform.tfvars` inside either env folder then define the variables. The `variables.tf` file contains the information required to access the env variables from `main.tf`.  

## Installation

### Prerequisites

Before you begin, make sure you have the following installed:

- [Node.js 22](https://nodejs.org/) (LTS version recommended)
- [Terraform](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli)

### Steps to Install

1. Clone Repository
```bash
git clone https://github.com/your-username/pca-serverless.git
```

2. Navigate to Project Directory
```bash
cd terraform/<env>
```

3. Initialize Terraform build
```bash
terraform init
```

4. Deploy Servers
```bash
terraform apply
```

## Project Status
Project currently in the process of migrating from [AWS Amplify Functions](https://docs.amplify.aws/react/build-a-backend/functions/set-up-function/) to AWS Lambda behind API Gateway.

### Affected Features
| Feature Name | Description |
|---------------|-------------|
| `PII Removal` | During migrating from Amplify functions to Lambda and API Gatewayk, chat completion does not support PII removal  |