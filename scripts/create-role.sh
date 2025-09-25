#!/bin/bash

# create-role.sh - Create IAM role for Lambda function
# Usage: ./create-role.sh <aws-profile> [role-name] [region]

set -e

# Check if AWS profile is provided
if [ $# -lt 1 ]; then
    echo "Usage: $0 <aws-profile> [role-name] [region]"
    echo "Example: $0 my-profile lambda-execution-role us-east-1"
    exit 1
fi

AWS_PROFILE="$1"
ROLE_NAME="${2:-lambda-execution-role}"
AWS_REGION="${3:-us-east-1}"

echo "Creating IAM role '$ROLE_NAME' for Lambda function..."
echo "Profile: $AWS_PROFILE"
echo "Region: $AWS_REGION"

# Create trust policy for Lambda service
TRUST_POLICY='{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}'

# Create basic execution policy
EXECUTION_POLICY='{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ],
      "Resource": "arn:aws:logs:*:*:*"
    }
  ]
}'

# Check if role already exists
if aws iam get-role --role-name "$ROLE_NAME" --profile "$AWS_PROFILE" >/dev/null 2>&1; then
    echo "Role '$ROLE_NAME' already exists. Getting ARN..."
    ROLE_ARN=$(aws iam get-role --role-name "$ROLE_NAME" --profile "$AWS_PROFILE" --query 'Role.Arn' --output text)
else
    echo "Creating new role '$ROLE_NAME'..."
    
    # Create the role
    ROLE_ARN=$(aws iam create-role \
        --role-name "$ROLE_NAME" \
        --assume-role-policy-document "$TRUST_POLICY" \
        --profile "$AWS_PROFILE" \
        --query 'Role.Arn' \
        --output text)
    
    echo "Role created successfully!"
    
    # Attach basic execution policy
    echo "Attaching basic execution policy..."
    aws iam attach-role-policy \
        --role-name "$ROLE_NAME" \
        --policy-arn "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole" \
        --profile "$AWS_PROFILE"
    
    echo "Basic execution policy attached!"
fi

# Output role ARN to file
echo "$ROLE_ARN" > .work/role-arn.txt
echo "Role ARN saved to .work/role-arn.txt: $ROLE_ARN"

# Display the role ARN
echo "Role ARN: $ROLE_ARN"
echo "Role creation completed successfully!"
