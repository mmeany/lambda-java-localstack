#!/bin/bash

# deploy-s3-event.sh - Deploy Lambda function to AWS
# Usage: ./deploy-module.sh <aws-profile> [function-name] [region]

set -e

echo "$0 - 1"

# Check if AWS profile is provided
if [ $# -lt 1 ]; then
    echo "Usage: $0 <aws-profile> [function-name] [region]"
    echo "Example: $0 my-profile my-lambda-function us-east-1"
    echo "Note: Make sure to run create-role.sh first to create the IAM role"
    exit 1
fi

echo "$0 - 2"

AWS_PROFILE="$1"
FUNCTION_NAME="${2:-lambda-bash-function}"
AWS_REGION="${3:-us-east-1}"

echo "$0 - 3"

# Read role ARN from file
if [ ! -f ".work/role-arn.txt" ]; then
    echo "Error: .work/role-arn.txt file not found"
    echo "Please run ./scripts/create-role.sh first to create the IAM role"
    exit 1
fi

echo "$0 - 4"

ROLE_ARN=$(cat .work/role-arn.txt)

echo "$0 - 5"

# Check if Lambda JAR exists
#ZIP_FILE="../lambda-module/build/distributions/lambda-module-1.0.0.zip"
ZIP_FILE="../lambda-s3-events/build/distributions/lambda-s3-events-1.0.0.zip"
if [ ! -f "$ZIP_FILE" ]; then
    echo "Error: Lambda ZIP file not found at $ZIP_FILE"
    echo "Please run './gradlew build' first to build the Lambda function"
    exit 1
fi

echo "$0 - 6"

echo "Deploying Lambda function '$FUNCTION_NAME' to AWS..."
echo "Profile: $AWS_PROFILE"
echo "Region: $AWS_REGION"
echo "Role: $ROLE_ARN"
echo "JAR: $ZIP_FILE"

# Check if function already exists
if aws lambda get-function --function-name "$FUNCTION_NAME" --profile "$AWS_PROFILE" --region "$AWS_REGION" >/dev/null 2>&1; then
    echo "Function '$FUNCTION_NAME' already exists. Updating..."
    
    # Update function code
    aws lambda update-function-code \
        --function-name "$FUNCTION_NAME" \
        --zip-file "fileb://$ZIP_FILE" \
        --profile "$AWS_PROFILE" \
        --region "$AWS_REGION"
    
    echo "Function code updated successfully!"
else
    echo "Function '$FUNCTION_NAME' does not exist. Creating..."

    JSON_ENV=$(
    cat << 'END_HEREDOC'
    {
      "Variables": {
        "AWS_ACCESS_KEY_ID" : "test",
        "AWS_SECRET_ACCESS_KEY" : "test",
        "AWS_REGION" : "us-east-1",
        "AWS_ENDPOINT_URL": "http://localhost.localstack.cloud:4566",
        "FORCE_PATH_STYLE": "true",
        "BUCKET" : "my-bucket-local",
        "S3_PREFIX": "mvm",
        "AUTHOR": "Mark Meany",
        "TITLE": "Developer"
      }
    }
END_HEREDOC
)

    # Create new function
    aws lambda create-function \
        --function-name "$FUNCTION_NAME" \
        --runtime java17 \
        --role "$ROLE_ARN" \
        --handler "com.example.lambda.LambdaHandler::handleRequest" \
        --zip-file "fileb://$ZIP_FILE" \
        --timeout 30 \
        --memory-size 512 \
        --environment "$JSON_ENV" \
        --profile "$AWS_PROFILE" \
        --region "$AWS_REGION"
    
    echo "Function created successfully!"
fi

# Get function ARN
FUNCTION_ARN=$(aws lambda get-function --function-name "$FUNCTION_NAME" --profile "$AWS_PROFILE" --region "$AWS_REGION" --query 'Configuration.FunctionArn' --output text)

# Output function ARN to file
echo "$FUNCTION_ARN" > .work/function-arn.txt
echo "Function ARN saved to .work/function-arn.txt: $FUNCTION_ARN"

echo "Function ARN: $FUNCTION_ARN"
echo "Deployment completed successfully!"
