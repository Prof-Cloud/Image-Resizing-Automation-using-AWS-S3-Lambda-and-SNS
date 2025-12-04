#Lambda Function - Resize
resource "aws_lambda_function" "resize" {
  function_name = "s3_resize_function"
  role          = aws_iam_role.lambda-resize.arn
  runtime       = "python3.11"
  handler       = "lambda_function.lambda_handler"
  filename      = "./src/lambda_function.py.zip"
  #To inform terraform that the Lambda code changes
  source_code_hash = filebase64sha256("./src/lambda_function.py.zip")

  # Performance and reliability settings
  timeout     = 30  # 30 seconds for processing larger images
  memory_size = 512 # 512 MB - good balance for image processing
  layers      = [local.pillow_layer_arn]

  environment {
    variables = {
      DESTINATION_BUCKETNAME = aws_s3_bucket.Prof_Cloud_Lamba_Bucket.id
      SNS_TOPIC_ARN          = aws_sns_topic.Resized-Image-SNS.arn
    }
  }
  depends_on = [
    aws_iam_role_policy_attachment.attach_policy,
    aws_iam_role_policy_attachment.cloudwatch_logs
  ]
}

#S3 permission to inkoke the lambda function
resource "aws_lambda_permission" "allow_s3_invoke" {
  statement_id  = "AllowS3Invoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.resize.function_name
  principal     = "s3.amazonaws.com"
  source_arn    = aws_s3_bucket.Prof_Cloud_Drop_off_Bucket.arn
}

#S3 Bucket Notification
resource "aws_s3_bucket_notification" "resize_trigger" {
  bucket = aws_s3_bucket.Prof_Cloud_Drop_off_Bucket.id

  lambda_function {
    lambda_function_arn = aws_lambda_function.resize.arn
    events              = ["s3:ObjectCreated:*"]
    #No filter is needed, so all file types are processed
    #filter_prefix       = ""

  }

  depends_on = [aws_lambda_permission.allow_s3_invoke]
}