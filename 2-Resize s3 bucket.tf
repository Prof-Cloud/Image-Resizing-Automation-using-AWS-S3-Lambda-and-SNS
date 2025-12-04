#Drop off S3 bucket
resource "aws_s3_bucket" "Prof_Cloud_Lamba_Bucket" {
  bucket = "prof-cloud-lamba-bucket"


  tags = {
    Name        = "Prof Cloud Lamba Bucket"
    Environment = "Dev"
  }
  #Allow terraform to delete the bucket even if files exist in the bucket
  force_destroy = true
}

#Enabling bucket or no rules automatically
resource "aws_s3_bucket_ownership_controls" "Lamba_ownership" {
  bucket = aws_s3_bucket.Prof_Cloud_Lamba_Bucket.id

  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

#Blocks all public access
resource "aws_s3_bucket_public_access_block" "Lamba_block" {
  bucket                  = aws_s3_bucket.Prof_Cloud_Lamba_Bucket.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

#Enabling versioning
resource "aws_s3_bucket_versioning" "Lamba-versioning" {
  bucket = aws_s3_bucket.Prof_Cloud_Lamba_Bucket.id

  versioning_configuration {
    status = "Enabled"
  }
}

#Lifecycle rules
resource "aws_s3_bucket_lifecycle_configuration" "Lamba-bucket-config" {
  bucket = aws_s3_bucket.Prof_Cloud_Lamba_Bucket.id

  rule {
    id = "Lifecycle rules"

    expiration {
      days = 90
    }

    status = "Enabled"

    transition {
      days          = 30
      storage_class = "STANDARD_IA"
    }

    transition {
      days          = 60
      storage_class = "GLACIER"
    }
  }
}
