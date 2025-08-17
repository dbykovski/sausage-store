#! /bin/bash
set -xe
sudo docker login -u ${CI_REGISTRY_USER} -p ${CI_REGISTRY_PASSWORD} ${CI_REGISTRY}
sudo docker pull ${CI_REGISTRY_IMAGE}/sausage-frontend:${VERSION}
docker compose -f ~/docker-compose-frontend.yml up -d --force-recreate
timeout 10 bash -c 'until docker inspect -f {{.State.Health.Status}} sausage-backend-blue | grep healthy || docker inspect -f {{.State.Health.Status}} sausage-backend-green | grep healthy; do sleep 5; done' || exit 1