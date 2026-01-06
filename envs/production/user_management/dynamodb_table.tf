resource "aws_dynamodb_table" "users_table" {
  name             = "users"
  billing_mode     = "PAY_PER_REQUEST"
  hash_key         = "user_id"
  stream_enabled   = true
  stream_view_type = "NEW_AND_OLD_IMAGES"

  attribute {
    name = "user_id"
    type = "S"
  }

  ttl {
    attribute_name = "expires_at"
    enabled        = true
  }

}
