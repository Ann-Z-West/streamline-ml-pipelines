resource "aws_dynamodb_table" "terraform" {
  name           = "devops-terraform"
  read_capacity  = 5
  write_capacity = 5
  hash_key       = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }
}

resource "aws_s3_bucket" "terraform" {
  bucket = "devops-tfstate"

  depends_on = [aws_dynamodb_table.terraform]
}

resource "aws_s3_bucket_public_access_block" "tf_s3_block_public_access" {
  bucket = aws_s3_bucket.terraform.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_versioning" "tf_s3_versioning" {
  bucket = aws_s3_bucket.terraform.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "tf_lifecycle_config" {
  bucket = aws_s3_bucket.terraform.id

  rule {
    id     = "Old Version Cleanup"
    status = "Enabled"

    filter {
      prefix = ""
    }

    noncurrent_version_expiration {
      noncurrent_days = 90
    }
  }
}
