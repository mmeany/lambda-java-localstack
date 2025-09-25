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
echo "## Setting the stage"
echo "##"
./init.sh

echo "##"
echo "## Creating role"
echo "##"
./create-role.sh localstack

echo "## Deploying Lambda"
echo "##"
./deploy-module.sh localstack json-processor > .work/deploy-lambda.log

echo "## Sleep for 5 seconds"
echo "##"
sleep 5

echo "## Invoking Lambda"
echo "##"
./invoke.sh localstack ./simple-payload.json json-processor

echo "## Viewing logs"
echo "##"
./view-logs.sh localstack json-processor

popd > /dev/null
