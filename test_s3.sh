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
./deploy-s3.sh localstack json-processor > .work/deploy-lambda.log

echo "## Sleep for 5 seconds"
echo "##"
sleep 5

echo "## Setting Lambda environment"
echo "##"
./env-vars.sh localstack json-processor

echo "## Adding config for S3 bucket to trigger Lambda environment"
echo "##"
./add-s3-events.sh localstack my-bucket-local

echo "## Sleep for 5 seconds"
echo "##"
sleep 5

echo "## Invoking Lambda"
echo "##"
./invoke.sh localstack ./simple-payload.json json-processor

echo "## Listing bucket contents"
echo "##"
aws --profile localstack s3 ls "s3://my-local-bucket/" --recursive

echo "## Viewing logs"
echo "##"
./view-logs.sh localstack json-processor

popd > /dev/null
