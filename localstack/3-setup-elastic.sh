#!/bin/bash
set -euo

export AWS_ACCESS_KEY_ID=UNSET
export AWS_SECRET_ACCESS_KEY=UNSET
export AWS_DEFAULT_REGION=eu-west-2

## make sure that localstack is running in the pipeline
until curl http://localstack:4566/_localstack/health --silent | grep -q "\"opensearch\": \"available\""; do
   sleep 5
   echo "Waiting for LocalStack to be ready..."
done

awslocal opensearch create-domain --engine-version "OpenSearch_1.3" --domain-name decs
