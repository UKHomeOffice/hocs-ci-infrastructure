#!/bin/bash
set -euo

if[[ -z $2 ]]
then
  docker-compose -f docker-compose.yml -d $1
else
  docker-compose -f docker-compose.yml -f docker-compose-elastic.yml -d $1
fi
