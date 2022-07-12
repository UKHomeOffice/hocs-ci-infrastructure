#!/bin/bash
set -euo

if [[ $1 == "" ]]
then
  echo "No docker-compose services listed, not setting up infrastructure!"
else
  if [[ $2 == "true" ]]
  then
      echo "Starting with elastic search"
      docker-compose -f ./ci/docker-compose.yml -f ./ci/docker-compose-elastic.yml up -d $1
  else
      echo "Starting without elastic search"
      docker-compose -f ./ci/docker-compose.yml up -d $1
  fi
  until curl 'localhost.localstack.cloud:4566/health' --silent | grep -q "\"initScripts\": \"initialized\""; do
       sleep 5
       echo "Waiting for LocalStack Initialisation scripts to have been run..."
  done
fi
