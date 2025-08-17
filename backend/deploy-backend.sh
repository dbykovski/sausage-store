#! /bin/bash
set -xe

DEPLOY_COLOR=${DEPLOY_COLOR:-blue}
OPPOSITE_COLOR=$(~/bin/opposite-color.sh ${DEPLOY_COLOR})

sudo docker login -u ${CI_REGISTRY_USER} -p ${CI_REGISTRY_PASSWORD} ${CI_REGISTRY}

docker compose -f ~/docker-compose-backend.yml up -d \
  --scale sausage-backend-${OPPOSITE_COLOR}=0 \
  --scale sausage-backend-${DEPLOY_COLOR}=1

timeout 300 bash -c 'until docker inspect -f {{.State.Health.Status}} sausage-backend-${DEPLOY_COLOR} | grep healthy; do sleep 5; done'