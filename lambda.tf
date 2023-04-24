terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.64.0"
    }
  }
}
provider "aws" {
  region = "us-east-1"
}
resource "aws_iam_policy" "lambda_policy" {
  name   = "lambda_policy"
  #role   = aws_iam_role.lambda_role.id
  policy = "${file("iam/iampolicy.json")}"
}

resource "aws_iam_role" "lambda_role" {
  name               = "lambda_role"
  assume_role_policy = "${file("iam/iam_assume-policy.json")}"
}

 resource "aws_iam_role_policy_attachment" "role_policy_attachment" {
       role       = aws_iam_role.lambda_role.name
       policy_arn = aws_iam_policy.lambda_policy.arn
 }

resource "aws_lambda_function" "test_lambda" {

  filename      = local.zip_path
  function_name = "sample"
  role          = aws_iam_role.lambda_role.arn
  handler       = "sample.add"
  depends_on = [ aws_iam_role_policy_attachment.role_policy_attachment]

  source_code_hash = data.archive_file.sample.output_base64sha256

  runtime = "python3.8"
}
locals {
  zip_path = "outputs/sample.zip"
}
data "archive_file" "sample" {
  type        = "zip"
  source_file = "sample.py"
  output_path = local.zip_path
}


