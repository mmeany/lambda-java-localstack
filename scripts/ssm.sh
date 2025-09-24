#!/usr/bin/env bash
#
# #####
# ##### This script fails as well, cannot run from Git Bash
# #####
#
# An experiment to see if Parameter Store parameters can be read/written using
# AWS CLI from a bash script run from Git Bash.
#
# The reason for the experiment is because attempts to use AWS CLI v2 from
# Git Bash always fails with `Parameter name: can't be prefixed with "ssm" (case-insensitive)`

# Write parameter to Parameter Store
# Bash (Git Bash)
cmd.exe /c 'aws --profile localstack ssm put-parameter --name "/app3/param1" --value "Mark" --type String --overwrite'

VALUE=$(cmd.exe /c 'aws --profile localstack ssm get-parameter --name "/app3/param1" --query "Parameter.Value" --output text' | tr -d '\r')

echo "Parameter value: $VALUE"
if [ "$VALUE" = "Mark" ]; then
    echo "Parameter value matches expected value"
else
    echo "Parameter value does not match expected value"
fi

