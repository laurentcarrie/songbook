#!/bin/bash
set -euo pipefail

# Setup script for deploying the songbook-processor Lambda
# Prerequisites: AWS CLI, SAM CLI, Docker

STACK_NAME="songbook-processor"
REGION="${AWS_REGION:-eu-west-3}"
BUCKET_NAME="zik-laurent"

echo "=== Songbook Processor Lambda Setup ==="

# Check prerequisites
command -v aws >/dev/null 2>&1 || { echo "AWS CLI is required but not installed."; exit 1; }
command -v sam >/dev/null 2>&1 || { echo "SAM CLI is required but not installed."; exit 1; }
command -v docker >/dev/null 2>&1 || { echo "Docker is required but not installed."; exit 1; }

# Get AWS account ID
AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
ECR_REPO="${AWS_ACCOUNT_ID}.dkr.ecr.${REGION}.amazonaws.com/songbook-processor"

echo "AWS Account: ${AWS_ACCOUNT_ID}"
echo "Region: ${REGION}"
echo "ECR Repository: ${ECR_REPO}"

# Create ECR repository if it doesn't exist
echo "Creating ECR repository..."
aws ecr describe-repositories --repository-names songbook-processor --region "${REGION}" 2>/dev/null || \
    aws ecr create-repository --repository-name songbook-processor --region "${REGION}"

# Login to ECR
echo "Logging into ECR..."
aws ecr get-login-password --region "${REGION}" | docker login --username AWS --password-stdin "${AWS_ACCOUNT_ID}.dkr.ecr.${REGION}.amazonaws.com"

# Build the SAM application
echo "Building SAM application..."
sam build --template template-existing-bucket.yaml

# Deploy the SAM application
echo "Deploying SAM application..."
sam deploy \
    --stack-name "${STACK_NAME}" \
    --capabilities CAPABILITY_IAM CAPABILITY_NAMED_IAM \
    --resolve-s3 \
    --region "${REGION}" \
    --image-repository "${ECR_REPO}"

# Get the Lambda ARN
LAMBDA_ARN=$(aws cloudformation describe-stacks \
    --stack-name "${STACK_NAME}" \
    --region "${REGION}" \
    --query 'Stacks[0].Outputs[?OutputKey==`SongbookProcessorFunction`].OutputValue' \
    --output text)

echo "Lambda ARN: ${LAMBDA_ARN}"

# Configure S3 bucket notification
echo "Configuring S3 bucket notification..."
cat > /tmp/notification.json << EOF
{
  "LambdaFunctionConfigurations": [
    {
      "Id": "SongbookProcessorTrigger",
      "LambdaFunctionArn": "${LAMBDA_ARN}",
      "Events": ["s3:ObjectCreated:*", "s3:ObjectRemoved:*"],
      "Filter": {
        "Key": {
          "FilterRules": [
            {
              "Name": "prefix",
              "Value": "songs/"
            }
          ]
        }
      }
    }
  ]
}
EOF

aws s3api put-bucket-notification-configuration \
    --bucket "${BUCKET_NAME}" \
    --notification-configuration file:///tmp/notification.json

echo "=== Setup Complete ==="
echo "The Lambda function will now trigger when files in s3://${BUCKET_NAME}/songs/ are modified."
