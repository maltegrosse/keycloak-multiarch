FROM debian:bullseye-slim  AS build-env
ARG KEYCLOAK_VERSION 17.0.0
ARG KEYCLOAK_DIST=https://github.com/keycloak/keycloak/releases/download/$KEYCLOAK_VERSION/keycloak-$KEYCLOAK_VERSION.tar.gz

RUN apt-get update -y && apt-get upgrade -y
RUN apt-get install -y curl ca-certificates gzip openssl tar 
ADD $KEYCLOAK_DIST /tmp/keycloak/

RUN (cd /tmp/keycloak && \
    tar -xvf /tmp/keycloak/keycloak-*.tar.gz && \
    rm /tmp/keycloak/keycloak-*.tar.gz) || true

RUN mv /tmp/keycloak/keycloak-* /opt/keycloak && mkdir -p /opt/keycloak/data

RUN chmod -R g+rwX /opt/keycloak
FROM debian:bullseye-slim
COPY --from=build-env --chown=1000:0 /opt/keycloak /opt/keycloak
 
RUN apt-get update -y && apt-get upgrade -y
RUN apt-get install -y openjdk-11-jdk-headless curl ca-certificates gzip openssl tar  && echo "keycloak:x:0:root" >> /etc/group && \
    echo "keycloak:x:1000:0:keycloak user:/opt/keycloak:/sbin/nologin" >> /etc/passwd


USER 1000

EXPOSE 8080
EXPOSE 8443

ENTRYPOINT [ "/opt/keycloak/bin/kc.sh" ]
