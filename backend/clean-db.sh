#! /bin/bash

PSQL_ADMIN="std-ext-019-01"
PSQL_PASSWORD="Testusr1234"
PSQL_HOST="rc1d-78co8isdqitugh45.mdb.yandexcloud.net"
PSQL_PORT="6432"
PSQL_DBNAME="std-ext-019-01"
PSQL_CONNECTION="postgresql://${PSQL_ADMIN}:${PSQL_PASSWORD}@${PSQL_HOST}:${PSQL_PORT}/${PSQL_DBNAME}"

touch init.sql

# Очистим базу
echo "DROP TABLE IF EXISTS flyway_schema_history;" >> init.sql
echo "DROP TABLE IF EXISTS product;" >> init.sql
echo "DROP TABLE IF EXISTS orders;" >> init.sql
echo "DROP TABLE IF EXISTS order_product;" >> init.sql

psql ${PSQL_CONNECTION} -f init.sql

rm -f init.sql
