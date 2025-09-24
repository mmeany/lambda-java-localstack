#!/usr/bin/env bash
#
# S3 bucket must already exist.
#
# Lambda must already exist.
#
# This script will configure the bucket to add event generation on puts to the bucket
# that will be processed by the lambda function.

#{
#    "LambdaFunctionConfigurations": [
#        {
#            "Id": "s3eventtriggerslambda",
#            "LambdaFunctionArn": "arn:aws:lambda:ap-northeast-2:000000000000:function:my-lambda",
#            "Events": ["s3:ObjectCreated:*"]
#        }
#    ]
#}

if [ $# -lt 2 ]; then
    echo "Usage: $0 <aws-profile> <bucket_name> [region]"
    echo "Example: $0 my-profile my-local-bucket us-east-1"
    exit 1
fi

AWS_PROFILE="$1"
BUCKET="${2:-my-local-bucket}"
AWS_REGION="${3:-us-east-1}"


ARN=$(tr -d '[:space:]' < 'function-arn.txt')
BUCKET_CONFIG="{
    \"LambdaFunctionConfigurations\": [
        {
            \"Id\": \"s3eventtriggerslambda\",
            \"LambdaFunctionArn\": \"${ARN}\",
            \"Events\": [\"s3:ObjectCreated:*\"]
        }
    ]
}"


aws --profile "${AWS_PROFILE}" \
 s3api put-bucket-notification-configuration \
 --bucket "${BUCKET}" \
 --notification-configuration "${BUCKET_CONFIG}" \
 --region "${AWS_REGION}"

