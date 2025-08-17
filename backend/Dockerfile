FROM maven:3.9.3-eclipse-temurin-17-alpine AS builder
ARG VERSION=${VERSION}
WORKDIR /usr/src/app
COPY ./src ./src
COPY *.xml ./
RUN wget -O YandexInternalRootCA.crt https://storage.yandexcloud.net/cloud-certs/CA.pem \
    && mvn package -Dversion.application=${VERSION} -Dmaven.test.skip=true

FROM bellsoft/liberica-runtime-container:jre-17-slim-musl
ARG VERSION=${VERSION}
RUN addgroup --system jaruser \
 && adduser --system -s /bin/false -G jaruser jaruser
RUN mkdir -p /app/reports /app/logs /app \
 && chown -R jaruser:jaruser /app
VOLUME /app/reports
VOLUME /app/logs
WORKDIR /app
COPY --from=builder /usr/src/app/YandexInternalRootCA.crt /tmp/YandexInternalRootCA.crt
RUN apt-get update && apt-get install -y \
    ca-certificates \
    curl \
    && rm -rf /var/lib/apt/lists/*
RUN keytool -importcert -trustcacerts -noprompt \
    -alias yandex \
    -file /tmp/YandexInternalRootCA.crt \
    -keystore /usr/lib/jvm/liberica17-container-jre/lib/security/cacerts \
    -storepass changeit \
    && rm -f /tmp/YandexInternalRootCA.crt
COPY --chown=jaruser:jaruser \
     --from=builder /usr/src/app/target/sausage-store-${VERSION}.jar ./sausage-store.jar
HEALTHCHECK --interval=30s --timeout=3s --start-period=30s --retries=3 \
    CMD curl -fSs http://localhost:8080/actuator/health || exit 1
EXPOSE 8080
USER jaruser
ENTRYPOINT ["java", "-jar", "-Dmyserver.bindPort=8080", "/app/sausage-store.jar"]
CMD ["--spring.profiles.active=default"]