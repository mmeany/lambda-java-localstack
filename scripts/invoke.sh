#!/bin/bash

# invoke.sh - Invoke Lambda function
# Usage: ./invoke.sh <aws-profile> <json-payload-file> [function-name] [region]

set -e

# Check if required parameters are provided
if [ $# -lt 2 ]; then
    echo "Usage: $0 <aws-profile> <json-payload-file> [function-name] [region]"
    echo "Example: $0 my-profile payload.json my-lambda-function us-east-1"
    exit 1
fi

AWS_PROFILE="$1"
PAYLOAD_FILE="$2"
FUNCTION_NAME="${3:-lambda-bash-function}"
AWS_REGION="${4:-us-east-1}"

# Check if payload file exists
if [ ! -f "$PAYLOAD_FILE" ]; then
    echo "Error: Payload file '$PAYLOAD_FILE' not found"
    exit 1
fi

# Validate JSON format
if ! jq empty "$PAYLOAD_FILE" 2>/dev/null; then
    echo "Error: '$PAYLOAD_FILE' is not valid JSON"
    exit 1
fi

echo "Invoking Lambda function '$FUNCTION_NAME'..."
echo "Profile: $AWS_PROFILE"
echo "Region: $AWS_REGION"
echo "Payload file: $PAYLOAD_FILE"

# Check if function exists
if ! aws lambda get-function --function-name "$FUNCTION_NAME" --profile "$AWS_PROFILE" --region "$AWS_REGION" >/dev/null 2>&1; then
    echo "Error: Function '$FUNCTION_NAME' not found"
    echo "Please deploy the function first using deploy.sh"
    exit 1
fi


# Invoke the function
echo "Invoking function..."
RESPONSE=$(aws lambda invoke \
    --function-name "$FUNCTION_NAME" \
    --payload "file://$PAYLOAD_FILE" \
    --profile "$AWS_PROFILE" \
    --region "$AWS_REGION" \
    --cli-binary-format raw-in-base64-out \
    response.json)

# Check if invocation was successful
STATUS_CODE=$(echo "$RESPONSE" | jq -r '.StatusCode')
if [ "$STATUS_CODE" != "200" ]; then
    echo "Error: Lambda invocation failed with status code $STATUS_CODE"
    echo "Response:"
    cat response.json
    rm -f response.json
    exit 1
fi

echo "Invocation successful! Status code: $STATUS_CODE"
echo "Response:"
cat response.json | jq .

# Clean up response file
rm -f response.json
