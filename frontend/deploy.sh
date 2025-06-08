#! /bin/bash
#Если свалится одна из команд, рухнет и весь скрипт
set -xe
sudo rm -rf /var/www-data/*||true
#Переносим артефакт в нужную папку
curl -u ${NEXUS_REPO_USER}:${NEXUS_REPO_PASS} -o sausage-store-frontend.tar.gz ${NEXUS_REPO_URL}/repository/${NEXUS_REPO_FRONTEND_NAME}/${VERSION}/sausage-store-${VERSION}.tar.gz
sudo tar -xzf sausage-store-frontend.tar.gz --strip-components=1 -C /var/www-data/ frontend/ \ && sudo chown -R frontend:frontend /var/www-data/||true
sudo systemctl reload nginx