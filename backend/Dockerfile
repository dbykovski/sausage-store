# ---------- build stage ----------
FROM maven:3.9.3-eclipse-temurin-20-alpine as builder
ARG VERSION=${VERSION}
WORKDIR /usr/src/app

# Копируем исходники и pom
COPY ./src ./src
COPY *.xml ./

# Скачиваем сертификат Яндекс и собираем jar
RUN wget -O YandexInternalRootCA.crt https://storage.yandexcloud.net/cloud-certs/CA.pem \
    && mvn package -Dversion.application=${VERSION} -Dmaven.test.skip=true

# ---------- runtime stage ----------
FROM eclipse-temurin:17-jre-jammy
ARG VERSION=${VERSION}
WORKDIR /app

# Копируем сертификат и добавляем его в Java truststore
COPY --from=builder /usr/src/app/YandexInternalRootCA.crt .
RUN keytool -importcert -file YandexInternalRootCA.crt \
    -alias yandex -cacerts -storepass changeit -noprompt \
    && rm -f YandexInternalRootCA.crt

# Создаём непривилегированного пользователя
RUN groupadd -r jaruser && useradd -r -s /bin/false -g jaruser jaruser

# Копируем jar и назначаем владельца
COPY --chown=jaruser:jaruser \
     --from=builder /usr/src/app/target/sausage-store-${VERSION}.jar ./sausage-store.jar

EXPOSE 8080
USER jaruser

ENTRYPOINT ["java", "-jar", "-Dmyserver.bindPort=8080", "/app/sausage-store.jar"]
CMD ["--spring.profiles.active=default"]