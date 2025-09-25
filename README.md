## Overview

A few examples of deploying Lambda's to Localstack that exercise different features available in the community edition
of Localstack.

This is a work in progress, it is rough round the edges and likely to change.

Modules present so far:

* `lambda-module` - A simple Lambda module that takes a JSON payload.
    * First attempt, accepts a JSON payload and logs it to stdout.
* `lambda-s3` - A Lambda that writes to an S3 bucket
    * Second attempt, writes to an S3 bucket.
    * Environment parameters added using a second AWS CLI call
    * Demonstrates how to create an S3 Client for Localstack.
* `lambda-s3-event` - A lambda that listens to S3 events
    * Third attempt, this one is triggered by S3 events.
    * Environment parameters added during deployment of Lambda.
    * Event triggering is added to existing bucket.

## Running

There are some scripts in the root of the repo for running the examples. These take care of _everything_:

* Rebuilding the project.
* Dropping and recreating the Docker stack.
* Deploying the Lambda's to Localstack.
* Running the Lambda's locally, either by direct invocation or via events.

The scripts are:

* [test_module.sh](./test_module.sh) Tests the most basic Lambda that takes a JSON payload and logs it to stdout.
* [test_s3.sh](./test_s3.sh) Tests the Lambda that writes to an S3 bucket (Create S3Client for Localstack).
* [test_s3_event.sh](./test_s3_events.sh) Tests the Lambda that listens to S3 events.

> Check the `scripts/.work` directory for script output.

> __NOTE:__ At present the attempt to display logs fails. Check the container logs directly for output.

## Todo

* Add walkthroughes for each example.
* Add an FAQ for common issues.
* Convince a colleague to add Terraform scripts for deploying the examples (local and remote using profiles only).
* Add Function URL examples.
* Add DynamoDB examples.
* Add SQS examples.
* Add SNS examples.

There is a lot more available in the community edition of Localstack, as work on this project continues, this list will
grow.