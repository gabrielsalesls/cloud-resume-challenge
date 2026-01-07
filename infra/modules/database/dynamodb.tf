module "common" {
  source = "../common"
}

resource "aws_dynamodb_table" "this" {
  name         = "teste"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "id"

  attribute {
    name = "id"
    type = "S"
  }

  attribute {
    name = "visitors"
    type = "N"
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

  item = <<ITEM
{
  "id": {"S": "visitors_count"},
  "visitors": {"N": "0"}
}
ITEM
}
