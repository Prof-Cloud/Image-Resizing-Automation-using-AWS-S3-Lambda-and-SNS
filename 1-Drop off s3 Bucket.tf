#Drop off S3 bucket
resource "aws_s3_bucket" "Prof_Cloud_Drop_off_Bucket" {
  bucket = "prof-cloud-drop-off-bucket"


  tags = {
    Name        = "Prof Cloud Drop off Bucket"
    Environment = "Dev"
  }
  #Allow terraform to delete the bucket even if files exist in the bucket
  force_destroy = true
}

#Enabling bucket or no rules automatically
resource "aws_s3_bucket_ownership_controls" "Drop_off_ownership" {
  bucket = aws_s3_bucket.Prof_Cloud_Drop_off_Bucket.id

  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

#Blocks all public access
resource "aws_s3_bucket_public_access_block" "Drop_off_block" {
  bucket                  = aws_s3_bucket.Prof_Cloud_Drop_off_Bucket.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

#Enabling versioning
resource "aws_s3_bucket_versioning" "Drop_off_versioning" {
  bucket = aws_s3_bucket.Prof_Cloud_Drop_off_Bucket.id

  versioning_configuration {
    status = "Enabled"
  }
}

#Lifecycle rules
resource "aws_s3_bucket_lifecycle_configuration" "Drop_off_bucket-config" {
  bucket = aws_s3_bucket.Prof_Cloud_Drop_off_Bucket.id

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
