#!/bin/bash -e
OS_PROJECT="${1:-helloworld}"

if [ -z "${OS_PUBLIC_IP}" ]; then
  echo "Error: the public IP of the OpenShift master must be provided via the OS_PUBLIC_IP environment variable."
  exit 1
fi

oc login -u developer -p developer --insecure-skip-tls-verify
oc new-project "${OS_PROJECT}" --description="The Red Hat HelloWorld MSA (Microservice Architecture)." || true
oc project "${OS_PROJECT}"
oc policy add-role-to-user admin "system:serviceaccount:${OS_PROJECT}:turbine"

sed -i.bak "s/value: \"OS_PROJECT\"/value: \"$OS_PROJECT\"/g" "${OS_PROJECT}.yml"
sed -i.bak "s/value: \"OS_SUBDOMAIN\"/value: \"$OS_PUBLIC_IP.nip.io\"/g" "${OS_PROJECT}.yml"
oc create -f "${OS_PROJECT}.yml"
  
if [ -n "${OS_PULL_DOCKER_IMAGES}" ]; then
  sudo docker pull fabric8/turbine-server:1.0.28
  sudo docker pull fabric8/hystrix-dashboard:1.0.28
  sudo docker pull metmajer/redhatmsa-frontend
  sudo docker pull metmajer/redhatmsa-api-gateway
  sudo docker pull metmajer/redhatmsa-aloha
  sudo docker pull metmajer/redhatmsa-bonjour
  sudo docker pull metmajer/redhatmsa-hola
  sudo docker pull metmajer/redhatmsa-ola
fi
