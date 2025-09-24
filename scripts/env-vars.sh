#!/usr/bin/env bash

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

#     "AWS_ENDPOINT_URL": "http://host.docker.internal:4566",
JSON_ENV=$(
cat << 'END_HEREDOC'
{
  "Variables": {
    "AWS_ACCESS_KEY_ID" : "test",
    "AWS_SECRET_ACCESS_KEY" : "test",
    "AWS_REGION" : "us-east-1",
    "AWS_ENDPOINT_URL": "http://localhost.localstack.cloud:4566",
    "FORCE_PATH_STYLE": "true",
    "BUCKET" : "my-local-bucket",
    "S3_PREFIX": "mvm",
    "AUTHOR": "Mark Meany",
    "TITLE": "Developer"
  }
}
END_HEREDOC
)

aws --profile "$AWS_PROFILE" lambda update-function-configuration \
  --function-name "${FUNCTION_NAME}" \
  --environment "$JSON_ENV" > function-env.txt
