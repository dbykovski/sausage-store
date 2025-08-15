#! /bin/bash
set -xe
sudo docker login -u ${CI_REGISTRY_USER} -p ${CI_REGISTRY_PASSWORD} ${CI_REGISTRY}
sudo docker network create -d bridge sausage_network || true
sudo docker rm -f sausage-backend || true
sudo docker run --rm -d --name sausage-backend \
     --env SPRING_DATASOURCE_URL="${SPRING_DATASOURCE_URL}" \
     --env SPRING_DATASOURCE_USERNAME="${SPRING_DATASOURCE_USERNAME}" \
     --env SPRING_DATASOURCE_PASSWORD="${SPRING_DATASOURCE_PASSWORD}" \
     --env SPRING_DATA_MONGODB_URI="${SPRING_DATA_MONGODB_URI}" \
     --env SPRING_CLOUD_VAULT_TOKEN="hvs.CAESIM-EdivWbuVMJ6U1IpswTthwoBGHd_mbt32_whhoeCA7Gh4KHGh2cy56WXNEcXhicTJ0dkhpbjhvT3pqb09sYkc" \
     --env SPRING_CLOUD_VAULT_SCHEME="http" \
     --env SPRING_CLOUD_VAULT_HOST="std-ext-019-01.praktikum-services.tech" \
     --env SPRING_CLOUD_VAULT_KV_ENABLED="true" \
     --env SPRING_CONFIG_IMPORT="vault://secret/sausage-store" \
     --network=sausage_network \
     "${CI_REGISTRY_IMAGE}"/sausage-backend:${VERSION}