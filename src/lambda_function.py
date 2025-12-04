import boto3
import os
from PIL import Image, UnidentifiedImageError
from io import BytesIO

# Initialize AWS clients
s3_client = boto3.client('s3')
sns_client = boto3.client('sns')

# Environment variables from Terraform
DEST_BUCKET = os.environ['DESTINATION_BUCKETNAME']
SNS_TOPIC_ARN = os.environ['SNS_TOPIC_ARN']

# Set desired resized dimensions
RESIZE_WIDTH = 200
RESIZE_HEIGHT = 200

def lambda_handler(event, context):
    # Log full event for debugging
    print("Received event:", event) 

    try:
        # Get the bucket and object key from the S3 event
        for record in event['Records']:
            src_bucket = record['s3']['bucket']['name']
            src_key = record['s3']['object']['key']

            print(f"Processing file: s3://{src_bucket}/{src_key}")

            # Download the image from S3 into memory
            try:
                response = s3_client.get_object(Bucket=src_bucket, Key=src_key)
                image_data = response['Body'].read()
            except Exception as e:
                print(f"Error downloading {src_key} from {src_bucket}: {e}")
                continue

            # Open the image with Pillow
            try:
                with Image.open(BytesIO(image_data)) as img:
                    # Convert image mode if needed (e.g., AVIF or other formats)
                    if img.mode not in ("RGB", "RGBA"):
                        img = img.convert("RGBA")
                    
                    # Resize image preserving aspect ratio
                    img.thumbnail((RESIZE_WIDTH, RESIZE_HEIGHT))

                    # Save resized image to memory
                    buffer = BytesIO()
                    img_format = img.format if img.format else 'JPEG'
                    img.save(buffer, img_format)
                    buffer.seek(0)

                    # Upload resized image to destination bucket
                    dest_key = f"resized-{src_key}"
                    s3_client.put_object(Bucket=DEST_BUCKET, Key=dest_key, Body=buffer)
                    print(f"Uploaded resized image to s3://{DEST_BUCKET}/{dest_key}")

                    # Send SNS notification
                    message = f"Image {src_key} has been resized and saved to {DEST_BUCKET} as {dest_key}"
                    sns_client.publish(
                        TopicArn=SNS_TOPIC_ARN,
                        Subject="Image Resized",
                        Message=message
                    )
                    print("SNS notification sent successfully.")

            except UnidentifiedImageError:
                print(f"Skipping file {src_key}: not a recognized image format.")
                continue
            except Exception as e:
                print(f"Failed to process image {src_key}: {e}")
                continue

    except Exception as e:
        print(f"Error processing images: {str(e)}")
        raise e
