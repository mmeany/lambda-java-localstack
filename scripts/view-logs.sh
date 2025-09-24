#!/bin/bash

# view-logs.sh - View Lambda function logs
# Usage: ./view-logs.sh <aws-profile> [function-name] [region] [follow]

set -e

# Check if AWS profile is provided
if [ $# -lt 1 ]; then
    echo "Usage: $0 <aws-profile> [function-name] [region] [follow]"
    echo "Example: $0 my-profile lambda-bash-function us-east-1 follow"
    echo "Options:"
    echo "  follow - Follow logs in real-time (like tail -f)"
    exit 1
fi

AWS_PROFILE="$1"
FUNCTION_NAME="${2:-lambda-bash-function}"
AWS_REGION="${3:-us-east-1}"
FOLLOW="${4:-false}"

LOG_GROUP_NAME="/aws/lambda/$FUNCTION_NAME"

echo "Viewing logs for Lambda function: $FUNCTION_NAME"
echo "Profile: $AWS_PROFILE"
echo "Region: $AWS_REGION"
echo "Log Group: $LOG_GROUP_NAME"
echo ""

# Check if log group exists
if ! aws logs describe-log-groups --log-group-name-prefix "$LOG_GROUP_NAME" --profile "$AWS_PROFILE" --region "$AWS_REGION" >/dev/null 2>&1; then
    echo "Error: Log group '$LOG_GROUP_NAME' not found"
    echo "Make sure the Lambda function has been deployed and invoked at least once"
    exit 1
fi

if [ "$FOLLOW" = "follow" ]; then
    echo "Following logs in real-time (Ctrl+C to stop)..."
    aws logs tail "$LOG_GROUP_NAME" --follow --profile "$AWS_PROFILE" --region "$AWS_REGION"
else
    echo "Recent log events:"
    aws logs filter-log-events \
        --log-group-name "$LOG_GROUP_NAME" \
        --max-items 50 \
        --profile "$AWS_PROFILE" \
        # --region "$AWS_REGION" \
        # --query 'events[*].[timestamp,message]' \
        --output table
fi
