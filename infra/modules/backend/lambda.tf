module "common" {
  source = "../common"
}

# REMOVA ESTA LINHA:
# module "database" {
#   source = "../database"
# }

data "archive_file" "zip_python_code" {
  type        = "zip"
  source_dir  = "../lambda/src/"
  output_path = "../lambda/target/app.zip"
}

resource "aws_iam_role" "lambda_role" {
  name = "role_para_acessar_dynamo"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "lambda.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_policy" "dynamo_access" {
  name        = "permissao_dynamo_visitantes"
  description = "Permite ler e editar a tabela de visitantes"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = [
        "dynamodb:GetItem",
        "dynamodb:PutItem",
        "dynamodb:UpdateItem"
      ]
      Resource = var.dynamodb_table_arn  # Usa a variável
    }]
  })
}

resource "aws_iam_role_policy_attachment" "vinculo" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = aws_iam_policy.dynamo_access.arn
}

resource "aws_lambda_function" "example" {
  depends_on = [aws_iam_role_policy_attachment.vinculo]

  filename      = data.archive_file.zip_python_code.output_path
  function_name = "visit_counter_lambda_agora_vai"
  role          = aws_iam_role.lambda_role.arn
  handler       = "index.lambda_handler"
  runtime       = "python3.13"

  environment {
    variables = {
      TABLE_NAME = var.dynamodb_table_name  
    }
  }

  tags = {
    Environment = "production"
    Application = "example"
  }
}