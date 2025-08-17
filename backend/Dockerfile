# Build stage
FROM maven:3.9.3-eclipse-temurin-17-alpine as builder
ARG VERSION=${VERSION}
WORKDIR /usr/src/app
COPY ./src ./src
COPY *.xml ./
RUN wget -O YandexInternalRootCA.crt https://storage.yandexcloud.net/cloud-certs/CA.pem \
    && mvn package -Dversion.application=${VERSION} -Dmaven.test.skip=true

# Release stage
FROM bellsoft/liberica-runtime-container:jre-17-slim-musl
ARG VERSION=${VERSION}

# Создаем пользователя и группы (используем busybox-совместимые команды)
RUN addgroup -S jaruser || true \
 && adduser -S -s /bin/false -G jaruser jaruser || true

# Создаем директории и настраиваем права
RUN mkdir -p /app/reports /app/logs /app \
 && chown -R jaruser:jaruser /app

VOLUME /app/reports
VOLUME /app/logs
WORKDIR /app

# Копируем сертификат из builder stage
COPY --from=builder /usr/src/app/YandexInternalRootCA.crt /tmp/YandexInternalRootCA.crt

# Устанавливаем необходимые пакеты (используем apk вместо apt-get)
RUN apk update && apk add --no-cache \
    ca-certificates \
    curl \
    && rm -rf /var/cache/apk/*

# Импортируем сертификат
RUN keytool -importcert -trustcacerts -noprompt \
    -alias yandex \
    -file /tmp/YandexInternalRootCA.crt \
    -keystore /usr/lib/jvm/liberica17-container-jre/lib/security/cacerts \
    -storepass changeit \
    && rm -f /tmp/YandexInternalRootCA.crt

# Копируем собранный JAR-файл
COPY --chown=jaruser:jaruser \
     --from=builder /usr/src/app/target/sausage-store-${VERSION}.jar ./sausage-store.jar

# Настройка healthcheck
HEALTHCHECK --interval=30s --timeout=3s --start-period=30s --retries=3 \
    CMD curl -fSs http://localhost:8080/actuator/health || exit 1

EXPOSE 8080
USER jaruser
ENTRYPOINT ["java", "-jar", "-Dmyserver.bindPort=8080", "/app/sausage-store.jar"]
CMD ["--spring.profiles.active=default"]