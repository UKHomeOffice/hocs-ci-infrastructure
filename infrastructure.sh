#!/bin/bash
set -euo

if [[ $1 == "" ]]
then
  echo "No docker-compose services listed, not setting up infrastructure!"
else
  if [[ $2 == "true" ]]
  then
      docker-compose -f docker-compose.yml -f docker-compose-elastic.yml up -d "$1"
  else
      docker-compose -f docker-compose.yml up -d "$1"
  fi
  until curl 'localhost.localstack.cloud:4566/health' --silent | grep -q "\"initScripts\": \"initialized\""; do
       sleep 5
       echo "Waiting for LocalStack Initialisation scripts to have been run..."
  done
fi
