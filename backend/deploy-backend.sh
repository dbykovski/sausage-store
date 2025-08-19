#! /bin/bash
set -xe

docker context create remote --description "remote ssh" --docker
sudo docker login -u ${CI_REGISTRY_USER} -p ${CI_REGISTRY_PASSWORD} ${CI_REGISTRY}
sudo docker pull ${CI_REGISTRY_IMAGE}/sausage-backend:${VERSION}

docker --context remote compose --env-file deploy.env up backend -d --pull "always" --force-recreate