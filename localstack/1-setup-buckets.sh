#!/bin/bash
set -euo

export AWS_ACCESS_KEY_ID=UNSET
export AWS_SECRET_ACCESS_KEY=UNSET
export AWS_DEFAULT_REGION=eu-west-2

## make sure that localstack is running in the pipeline
until curl http://localstack:4566/_localstack/health --silent | grep -Ei "\"s3\": \"(available|running)\""; do
   sleep 5
   echo "Waiting for LocalStack to be ready..."
done

awslocal s3 mb s3://untrusted-bucket
awslocal s3 mb s3://trusted-bucket
