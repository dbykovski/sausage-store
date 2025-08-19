#! /bin/bash
set -xe

docker context create remote --description "remote ssh" --docker "host=ssh://${DEV_USER}@${DEV_HOST}"
sudo docker login -u ${CI_REGISTRY_USER} -p ${CI_REGISTRY_PASSWORD} ${CI_REGISTRY}
sudo docker pull ${CI_REGISTRY_IMAGE}/sausage-backend:${VERSION}

docker --context remote compose up backend -d --pull "always" --force-recreate