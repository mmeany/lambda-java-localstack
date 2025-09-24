#!/bin/bash

# deploy.sh - Deploy Lambda function to AWS
# Usage: ./deploy.sh <aws-profile> [function-name] [region]

set -e

# Check if AWS profile is provided
if [ $# -lt 1 ]; then
    echo "Usage: $0 <aws-profile> [function-name] [region]"
    echo "Example: $0 my-profile my-lambda-function us-east-1"
    echo "Note: Make sure to run create-role.sh first to create the IAM role"
    exit 1
fi

AWS_PROFILE="$1"
FUNCTION_NAME="${2:-lambda-bash-function}"
AWS_REGION="${3:-us-east-1}"

# Read role ARN from file
if [ ! -f "role-arn.txt" ]; then
    echo "Error: role-arn.txt file not found"
    echo "Please run ./scripts/create-role.sh first to create the IAM role"
    exit 1
fi

ROLE_ARN=$(cat role-arn.txt)

# Check if Lambda JAR exists
JAR_FILE="../lambda-module/build/libs/lambda-function.jar"
if [ ! -f "$JAR_FILE" ]; then
    echo "Error: Lambda JAR file not found at $JAR_FILE"
    echo "Please run './gradlew build' first to build the Lambda function"
    exit 1
fi

echo "Deploying Lambda function '$FUNCTION_NAME' to AWS..."
echo "Profile: $AWS_PROFILE"
echo "Region: $AWS_REGION"
echo "Role: $ROLE_ARN"
echo "JAR: $JAR_FILE"

# Check if function already exists
if aws lambda get-function --function-name "$FUNCTION_NAME" --profile "$AWS_PROFILE" --region "$AWS_REGION" >/dev/null 2>&1; then
    echo "Function '$FUNCTION_NAME' already exists. Updating..."
    
    # Update function code
    aws lambda update-function-code \
        --function-name "$FUNCTION_NAME" \
        --zip-file "fileb://$JAR_FILE" \
        --profile "$AWS_PROFILE" \
        --region "$AWS_REGION"
    
    echo "Function code updated successfully!"
else
    echo "Function '$FUNCTION_NAME' does not exist. Creating..."
    
    # Create new function
    aws lambda create-function \
        --function-name "$FUNCTION_NAME" \
        --runtime java17 \
        --role "$ROLE_ARN" \
        --handler "com.example.lambda.LambdaHandler::handleRequest" \
        --zip-file "fileb://$JAR_FILE" \
        --timeout 30 \
        --memory-size 512 \
        --profile "$AWS_PROFILE" \
        --region "$AWS_REGION"
    
    echo "Function created successfully!"
fi

# Get function ARN
FUNCTION_ARN=$(aws lambda get-function --function-name "$FUNCTION_NAME" --profile "$AWS_PROFILE" --region "$AWS_REGION" --query 'Configuration.FunctionArn' --output text)

# Output function ARN to file
echo "$FUNCTION_ARN" > function-arn.txt
echo "Function ARN saved to function-arn.txt: $FUNCTION_ARN"

echo "Function ARN: $FUNCTION_ARN"
echo "Deployment completed successfully!"
