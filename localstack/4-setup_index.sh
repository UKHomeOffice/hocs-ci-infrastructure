#!/bin/bash
set -euo

export AWS_ACCESS_KEY_ID=UNSET
export AWS_SECRET_ACCESS_KEY=UNSET
export AWS_DEFAULT_REGION=eu-west-2

SCRIPT_LOCATION=$(realpath "$(dirname "${BASH_SOURCE[0]}")")
echo $SCRIPT_LOCATION
ELASTIC_MAPPING_PATH="${SCRIPT_LOCATION}/elastic_mapping.json"

if ! [[ -f "${ELASTIC_MAPPING_PATH}" ]]
then
    echo "${ELASTIC_MAPPING_PATH} was not found."
    exit 1
fi

until curl localhost.localstack.cloud:4566/es/eu-west-2/decs --silent | grep -q "elasticsearch"; do
   sleep 5
   echo "Waiting for ElasticSearch to be ready..."
done

# Multiple index mode
curl -X PUT localhost.localstack.cloud:4566/es/eu-west-2/decs/local-min --silent -H "Content-Type: application/json" -d "@${ELASTIC_MAPPING_PATH}"
curl -X PUT localhost.localstack.cloud:4566/es/eu-west-2/decs/local-tro --silent -H "Content-Type: application/json" -d "@${ELASTIC_MAPPING_PATH}"
curl -X PUT localhost.localstack.cloud:4566/es/eu-west-2/decs/local-dten --silent -H "Content-Type: application/json" -d "@${ELASTIC_MAPPING_PATH}"
curl -X PUT localhost.localstack.cloud:4566/es/eu-west-2/decs/local-mpam --silent -H "Content-Type: application/json" -d "@${ELASTIC_MAPPING_PATH}"
curl -X PUT localhost.localstack.cloud:4566/es/eu-west-2/decs/local-mts --silent -H "Content-Type: application/json" -d "@${ELASTIC_MAPPING_PATH}"
curl -X PUT localhost.localstack.cloud:4566/es/eu-west-2/decs/local-smc --silent -H "Content-Type: application/json" -d "@${ELASTIC_MAPPING_PATH}"
curl -X PUT localhost.localstack.cloud:4566/es/eu-west-2/decs/local-comp2 --silent -H "Content-Type: application/json" -d "@${ELASTIC_MAPPING_PATH}"
curl -X PUT localhost.localstack.cloud:4566/es/eu-west-2/decs/local-iedet --silent -H "Content-Type: application/json" -d "@${ELASTIC_MAPPING_PATH}"
curl -X PUT localhost.localstack.cloud:4566/es/eu-west-2/decs/local-comp --silent -H "Content-Type: application/json" -d "@${ELASTIC_MAPPING_PATH}"
curl -X PUT localhost.localstack.cloud:4566/es/eu-west-2/decs/local-foi --silent -H "Content-Type: application/json" -d "@${ELASTIC_MAPPING_PATH}"
curl -X PUT localhost.localstack.cloud:4566/es/eu-west-2/decs/local-bf --silent -H "Content-Type: application/json" -d "@${ELASTIC_MAPPING_PATH}"
curl -X PUT localhost.localstack.cloud:4566/es/eu-west-2/decs/local-bf2 --silent -H "Content-Type: application/json" -d "@${ELASTIC_MAPPING_PATH}"
curl -X PUT localhost.localstack.cloud:4566/es/eu-west-2/decs/local-to --silent -H "Content-Type: application/json" -d "@${ELASTIC_MAPPING_PATH}"
curl -X PUT localhost.localstack.cloud:4566/es/eu-west-2/decs/local-pogr --silent -H "Content-Type: application/json" -d "@${ELASTIC_MAPPING_PATH}"
curl -X PUT localhost.localstack.cloud:4566/es/eu-west-2/decs/local-pogr2 --silent -H "Content-Type: application/json" -d "@${ELASTIC_MAPPING_PATH}"
curl -X PUT localhost.localstack.cloud:4566/es/eu-west-2/decs/local-wcs --silent -H "Content-Type: application/json" -d "@${ELASTIC_MAPPING_PATH}"

curl -X POST localhost.localstack.cloud:4566/es/eu-west-2/decs/_aliases --silent -H "Content-Type: application/json" -d '{
"actions":[
   {
      "add":{
         "index":"local-*",
         "alias":"local-read"
      }
   },
   {
      "add":{
         "index":"local-min",
         "alias":"local-min-read"
      }
   },
   {
      "add":{
         "index":"local-tro",
         "alias":"local-tro-read"
      }
   },
   {
      "add":{
         "index":"local-dten",
         "alias":"local-dten-read"
      }
   },
   {
      "add":{
         "index":"local-mpam",
         "alias":"local-mpam-read"
      }
   },
   {
      "add":{
         "index":"local-mts",
         "alias":"local-mts-read"
      }
   },
   {
      "add":{
         "index":"local-smc",
         "alias":"local-smc-read"
      }
   },
   {
      "add":{
         "index":"local-comp2",
         "alias":"local-comp2-read"
      }
   },
   {
      "add":{
         "index":"local-iedet",
         "alias":"local-iedet-read"
      }
   },
   {
      "add":{
         "index":"local-comp",
         "alias":"local-comp-read"
      }
   },
   {
      "add":{
         "index":"local-foi",
         "alias":"local-foi-read"
      }
   },
   {
      "add":{
         "index":"local-bf",
         "alias":"local-bf-read"
      }
   },
   {
      "add":{
         "index":"local-bf2",
         "alias":"local-bf2-read"
      }
   },
   {
      "add":{
         "index":"local-to",
         "alias":"local-to-read"
      }
   },
   {
      "add":{
         "index":"local-pogr",
         "alias":"local-pogr-read"
      }
   },
   {
      "add":{
         "index":"local-pogr2",
         "alias":"local-pogr2-read"
      }
   },
   {
      "add":{
         "index":"local-wcs",
         "alias":"local-wcs-read"
      }
   }
]}'

# Kept while SINGULAR mode is supported
curl -X PUT localhost.localstack.cloud:4566/es/eu-west-2/decs/local-case --silent -H "Content-Type: application/json" -d "@${ELASTIC_MAPPING_PATH}"
