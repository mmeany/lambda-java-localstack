#!/bin/bash

set -e

pushd ./compose-localstack-v4 > /dev/null

echo "##"
echo "## In directory: $(pwd)"
echo "## Stopping and restarting LocalStack"
echo "##"
docker-compose down -v
docker-compose up -d

popd > /dev/null

echo "##"
echo "## In directory: $(pwd)"
echo "## Building Lambda module"
echo "##"
./gradlew clean build

pushd ./scripts/ > /dev/null

echo "##"
echo "## In directory: $(pwd)"
echo "## Setting the stage"
echo "##"
./init.sh

echo "##"
echo "## Creating role"
./create-role.sh localstack

echo "## Deploying Lambda"
echo "##"
./deploy-s3-event.sh localstack json-processor > .work/deploy-lambda.log

echo "## Sleep for 5 seconds"
echo "##"
sleep 5

echo "## Adding config for S3 bucket to trigger Lambda environment"
echo "##"
./add-s3-events.sh localstack my-bucket-local

echo "## Sleep for 5 seconds"
echo "##"
sleep 5

echo "## Upload files to S3, should trigger Lambda (one copy to test other event type)"
echo "##"
aws --profile localstack s3 cp ".work/role-arn.txt" "s3://my-bucket-local/role-arn.txt"
aws --profile localstack s3 cp ".work/role-arn.txt" "s3://my-other-bucket-local/role-arn.txt"
aws --profile localstack s3 cp ".work/deploy-lambda.log" "s3://my-bucket-local/deploy-lambda.log"
aws --profile localstack s3 cp "s3://my-other-bucket-local/role-arn.txt" "s3://my-bucket-local/copied-stuff/role-arn.txt"

echo "## Listing bucket contents"
echo "##"
aws --profile localstack s3 ls "s3://my-bucket-local/" --recursive

echo "## Viewing logs"
echo "##"
./view-logs.sh localstack json-processor

popd > /dev/null
