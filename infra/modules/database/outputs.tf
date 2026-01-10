output "table_arn" {
  description = "O ARN da tabela DynamoDB criada"
  value       = aws_dynamodb_table.this.arn
}

output "table_name" {
  value       = aws_dynamodb_table.this.name
  description = "Nome da tabela DynamoDB"
}
