module "common" {
  source = "../common"
}

resource "aws_dynamodb_table" "this" {
  name         = "visitors_database"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "id"

  attribute {
    name = "id"
    type = "S"
  }

  tags = merge(
    module.common.tags,
    {
      description = "Visitors Count Database"
    }
  )
}

resource "aws_dynamodb_table_item" "seed_items" {
  depends_on = [aws_dynamodb_table.this]

  table_name = aws_dynamodb_table.this.name
  hash_key   = aws_dynamodb_table.this.hash_key

  item = jsonencode({
    id       = { S = "visitors_count" }
    visits = { N = "0" }
  })
}
