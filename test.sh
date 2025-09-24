#!/bin/bash

set -e

pushd /e/docker/localstack-v4/ > /dev/null
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
echo "## Creating role"
echo "##"
./create-role.sh localstack
echo "## Deploying Lambda"
echo "##"
./deploy-event.sh localstack json-processor > ./deploy-lambda.log
echo "## Sleep for 5 seconds"
echo "##"
sleep 5
#echo "## Setting Lambda environment"
#echo "##"
#./env-vars.sh localstack json-processor
echo "## Adding config for S3 bucket to trigger Lambda environment"
echo "##"
./add-s3-events.sh localstack my-bucket-local
echo "## Sleep for 5 seconds"
echo "##"
sleep 5
echo "## Invoking Lambda"
echo "##"
aws --profile localstack s3 cp "./role-arn.txt" "s3://my-bucket-local/role-arn.txt"
aws --profile localstack s3 cp "./role-arn.txt" "s3://my-other-bucket-local/role-arn.txt"
aws --profile localstack s3 cp "./deploy-lambda.log" "s3://my-bucket-local/deploy-lambda.log"
aws --profile localstack s3 cp "s3://my-other-bucket-local/role-arn.txt" "s3://my-bucket-local/copied-stuff/deploy-lambda.log"
echo "## Listing bucket contents"
echo "##"
aws --profile localstack s3 ls "s3://my-bucket-local/" --recursive
echo "## Viewing logs"
echo "##"
./view-logs.sh localstack json-processor
popd > /dev/null
