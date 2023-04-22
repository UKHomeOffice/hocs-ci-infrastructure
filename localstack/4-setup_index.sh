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

until awslocal opensearch describe-domain --domain-name decs | jq ".DomainStatus.Processing" | grep -q "false"; do
   sleep 5
   echo "Waiting for ElasticSearch to be ready..."
done

# Create the indexes and aliases
types=("min" "tro" "dten" "mpam" "mts" "smc" "comp2" "iedet" "comp" "foi" "bf" "bf2" "to" "pogr" "pogr2" "wcs")
for type in "${types[@]}"
do
    echo
    echo "Creating index for ${type}"
    echo
    curl -X PUT localhost.localstack.cloud:4566/opensearch/eu-west-2/decs/local-"${type}" --silent -H "Content-Type: application/json" -d "@${ELASTIC_MAPPING_PATH}"

    echo
    echo "Creating alias for ${type}"
    echo
    curl -X POST localhost.localstack.cloud:4566/opensearch/eu-west-2/decs/_aliases --silent -H "Content-Type: application/json" -d "{\"actions\":
    [
      {\"add\": {\"index\":\"local-${type}\", \"alias\":\"local-${type}-read\"}},
      {\"add\": {\"index\":\"local-${type}\", \"alias\":\"local-${type}-write\"}}
    ]}"
done

# Create the alias for all indexes
curl -X POST localhost.localstack.cloud:4566/opensearch/eu-west-2/decs/_aliases --silent -H "Content-Type: application/json" -d '{"actions":
    [
      {"add":{"index":"local-*","alias":"local-read"}}
]}'

# Create the index for singular
curl -X PUT localhost.localstack.cloud:4566/opensearch/eu-west-2/decs/local-case --silent -H "Content-Type: application/json" -d "@${ELASTIC_MAPPING_PATH}"
