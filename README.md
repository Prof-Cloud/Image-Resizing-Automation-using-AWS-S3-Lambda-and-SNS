# Image-Resizing-Automation-using-AWS-S3-Lambda-and-SNS

In this project, I built a fully serverless, automatic image processing system that resizes images as soon as they're uploaded to an S3 bucket. As soon as the file gets dropped off, AWS Lambda takes over and shrinks the image to a preset size, uploads the resized image to a different S3 bucket and then sends an email notification through SNS. 

<img width="4298" height="2400" alt="Blank diagram" src="https://github.com/user-attachments/assets/0c4b5328-3653-405f-b797-48493074aadb" />

## What I Built 

 1. S3 Buckets
      - Drop-off Bucket - Where the original images get uploaded
      - Lambda Output Bucket - Stores the resized image, with a new prefix added

2. Lambda
     - Runs automatically when a new image is uploaded
     - Uses the pillow library to resize the image
     - Write the resized version back to the output bucket
     - Publish a message to SNS to notify the user
  
3. SNS
     - Send an email notification after the resized image is successfully still in the S3 bucket
     - Users subscribe via email, and this is a real-time notification when processing is finished

4. CloudWatch
     - All image processing actions and errors are allowed to Amazon CloudWatch
     - Helps troubleshoot issues like invalid files or permission errors
     - Makes it easier to monitor the pipeline and confirm successful executions
  
5. IAM Roles and Permissions
     - Lambda
         - Read from the drop-off bucket
         - Write to the resized image bucket
         - Publish notifications to SNS

## Automated Image Pipeline

The sequence that happens automatically:
  1. A user uploads an image to the Drop off Bucket
  2. S3 triggers the Lambda function
  3. Lambda downloads the image and resizes it
  4. Lambda uploads the resized version to the Lambda Output Bucket
  5. Lambda publishes a notification message to SNS.
  6. SNS sneeds an email confirming the resized image was created


 ## Alternatives You Could Use Instead

  1. AWS Step Functions
       - Useful for multi-stage editing 
         
  2. AWS Rekognition
      - Cam automatically tags, clasify, or detects objects in uploaded images
      - Useful for AI-powered processing

  3. AWS Batch or ECS
       - Better suited for processing massive or large images at scale

## Improvements I Can Add Later

1. Better Filename Handling for Upload
      - I ran into an issue when uploading a file with special characters or spaces. Some filenames (like those containing emojis or characters encoded as %20) require    decoding before Lambda can download them into an S3 bucket. A future improvement could be automatically decoding object keys, so all filenames are supported.  
3. More Secure IAM Permissions
4. More Image Validate
     - Adding logic to validate the file types (for exampl, ignoring non-image uploads) before processing.
5. Adjustable Image Size and Quality
     - In the future, I can allow dynamic image sizing so the lambda function adjusts dimension based on aspect ratio, helping and maintain a high-quality resizing in the output
