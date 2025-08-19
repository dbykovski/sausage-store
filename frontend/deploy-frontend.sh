#! /bin/bash
set -xe

sudo docker login -u ${CI_REGISTRY_USER} -p ${CI_REGISTRY_PASSWORD} ${CI_REGISTRY}
sudo docker pull ${CI_REGISTRY_IMAGE}/sausage-frontend:${VERSION}

docker --context remote compose -f docker-compose-frontend.yml up frontend -d --force-recreate