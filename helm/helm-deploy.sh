#!/usr/bin/env bash

wget -O /cluster_ca.crt \
 https://raw.githubusercontent.com/UKHomeOffice/acp-ca/master/${KUBE_CLUSTER}.crt

kubectl config set-cluster "${KUBE_CLUSTER}" \
  --certificate-authority="/cluster_ca.crt" \
  --server="${KUBE_SERVER}"

kubectl config set-credentials helm \
  --token="${KUBE_TOKEN}"

kubectl config set-context helm \
  --cluster="${KUBE_CLUSTER}" \
  --user="helm" \

kubectl config use-context helm

helm repo add hocs-helm-charts https://ukhomeoffice.github.io/hocs-helm-charts

helm upgrade ${CHART_NAME} ./helm/${CHART_NAME} \
--dependency-update \
--install \
--reset-values \
--timeout 10m \
--history-max 2 \
--namespace ${KUBE_NAMESPACE} \
--set hocs-backend-service.version=${VERSION} \
--set hocs-generic-service.version=${VERSION} \
--set version=${VERSION} $*
