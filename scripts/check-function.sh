#!/bin/bash

# check-function.sh - Check if Lambda function exists and get its status
# Usage: ./check-function.sh <aws-profile> [function-name] [region]

set -e

# Check if AWS profile is provided
if [ $# -lt 1 ]; then
    echo "Usage: $0 <aws-profile> [function-name] [region]"
    echo "Example: $0 localstack lambda-bash-function us-east-1"
    exit 1
fi

AWS_PROFILE="$1"
FUNCTION_NAME="${2:-lambda-bash-function}"
AWS_REGION="${3:-us-east-1}"

echo "Checking Lambda function: $FUNCTION_NAME"
echo "Profile: $AWS_PROFILE"
echo "Region: $AWS_REGION"
echo ""

# Check if function exists
if aws lambda get-function --function-name "$FUNCTION_NAME" --profile "$AWS_PROFILE" --region "$AWS_REGION" >/dev/null 2>&1; then
    echo "✅ Function '$FUNCTION_NAME' exists!"
    
    # Get function details
    echo ""
    echo "Function Details:"
    aws lambda get-function --function-name "$FUNCTION_NAME" --profile "$AWS_PROFILE" --region "$AWS_REGION" --query 'Configuration.[FunctionName,Runtime,State,LastModified]' --output table
    
    echo ""
    echo "To view logs after invoking the function:"
    echo "./view-logs.sh $AWS_PROFILE $FUNCTION_NAME $AWS_REGION"
    
else
    echo "❌ Function '$FUNCTION_NAME' does not exist!"
    echo ""
    echo "To deploy the function:"
    echo "1. Create IAM role: ./create-role.sh $AWS_PROFILE"
    echo "2. Deploy function: ./deploy.sh $AWS_PROFILE $FUNCTION_NAME $AWS_REGION"
fi
