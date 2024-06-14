terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.47.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

data "aws_region" "current" {}

data "aws_caller_identity" "current" {}

data "aws_s3_bucket" "test_bucket" {
  bucket = "test-bucket-ashvini"
}

resource "aws_iam_role" "lambda_role" {
  name = "my-test-role-ashvini"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
  lifecycle {
    ignore_changes = [
      assume_role_policy, // Ignore changes to the assume role policy
    ]
  }  
}

resource "aws_iam_role_policy_attachment" "lambda_policy" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_lambda_function" "hello_world_lambda" {
  function_name    = "lambda-code"
  s3_bucket        = data.aws_s3_bucket.test_bucket.id
  s3_key           = "lambda-code.zip"
  handler          = "index.handler"
  runtime          = "nodejs20.x"
  role             = aws_iam_role.lambda_role.arn
}

