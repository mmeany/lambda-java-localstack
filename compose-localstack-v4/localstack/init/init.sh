#!/bin/bash
set -x

awslocal s3 mb s3://my-bucket-local
awslocal s3 mb s3://my-other-bucket-local

awslocal sqs create-queue --queue-name my-queue --region us-east-1

awslocal dynamodb create-table \
  --table-name MyTable \
  --attribute-definitions AttributeName=Id,AttributeType=S \
  --key-schema AttributeName=Id,KeyType=HASH \
  --table-class STANDARD \
  --provisioned-throughput ReadCapacityUnits=5,WriteCapacityUnits=5
