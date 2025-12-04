resource "aws_iam_role" "lambda-resize" {
  name               = "lambda-role-Resize-Image"
  assume_role_policy = <<POLICY
  {
    "Version": "2012-10-17",
    "Statement": [
      {
        "Action": "sts:AssumeRole",
        "Principal": {
          "Service": "lambda.amazonaws.com"
        },
        "Effect": "Allow",
        "Sid": ""
      }
    ]
  }
    POLICY
}

resource "aws_iam_role_policy_attachment" "attach_policy" {
  role       = aws_iam_role.lambda-resize.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess" #For the future, use a more restricted bucket policy
}

#Attach CloudWatch log permission
resource "aws_iam_role_policy_attachment" "cloudwatch_logs" {
  role       = aws_iam_role.lambda-resize.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchLogsFullAccess"
}


resource "aws_iam_policy" "lambda_sns_publish" {
  name        = "LambdaSNSPublishPolicy"
  description = "Allow Lambda to publish to SNS topic"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = "sns:Publish"
        Resource = aws_sns_topic.Resized-Image-SNS.arn
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "attach_sns_policy" {
  role       = aws_iam_role.lambda-resize.name
  policy_arn = aws_iam_policy.lambda_sns_publish.arn
}
