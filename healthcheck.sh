#!/bin/bash
set -euo

until curl -s 'localhost.localstack.cloud:4566/_localstack/init/ready' | jq .completed | grep -q true; do
     sleep 5
     echo "Waiting for LocalStack Initialisation scripts to have been run..."
done
