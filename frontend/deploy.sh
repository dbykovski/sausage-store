#! /bin/bash
set -xe
sudo docker login -u ${CI_REGISTRY_USER} -p ${CI_REGISTRY_PASSWORD} ${CI_REGISTRY}
sudo docker network create -d bridge sausage_network || true
sudo docker rm -f sausage-frontend || true
sudo docker run -d --restart=on-failure:10 --name sausage-frontend \
     --network=sausage_network \
     -p 80:80 \
     "${CI_REGISTRY_IMAGE}"/sausage-frontend:${VERSION}