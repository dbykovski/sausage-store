#! /bin/bash
set -xe

# создаём remote context, если ещё не создан
if ! docker context inspect remote >/dev/null 2>&1; then
  docker context create remote \
    --description 'remote ssh' \
    --docker host=ssh://student@std-ext-019-01.praktikum-services.tech
fi

sudo docker login -u ${CI_REGISTRY_USER} -p ${CI_REGISTRY_PASSWORD} ${CI_REGISTRY}
sudo docker pull ${CI_REGISTRY_IMAGE}/sausage-backend:${VERSION}

docker --context remote run --rm -v "$PWD:/app" -w /app docker:24.0.7-cli ./blue-green.sh "${VERSION}"