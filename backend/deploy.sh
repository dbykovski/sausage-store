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
     --env SPRING_CLOUD_VAULT_TOKEN="hvs.CAESIJRyaeMPqZPYzADF1qh1dk6TQsKx2IFzjpq3bmYET49NGh4KHGh2cy40UXE1Q05aY2lqRE9SZ2tmRTVNSm9oVW0" \
     --env SPRING_CLOUD_VAULT_SCHEME="http" \
     --env SPRING_CLOUD_VAULT_HOST="std-ext-019-01.praktikum-services.tech" \
     --env SPRING_CLOUD_VAULT_KV_ENABLED="true" \
     --env SPRING_CONFIG_IMPORT="vault://secret/sausage-store/" \
     --network=sausage_network \
     "${CI_REGISTRY_IMAGE}"/sausage-backend:${VERSION}