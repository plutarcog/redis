FROM centos:7
MAINTAINER Plutarco Guerrero, plutarcog@gmail.com

# add our user and group first to make sure their IDs get assigned consistently, regardless of whatever dependencies get added
RUN groupadd -r -g 996 redis && useradd -r -g redis -u 996 redis

ENV GOSU_VERSION=1.12
RUN set -eux; \
  gpg --batch --keyserver hkps://keys.openpgp.org --recv-keys B42F6819007F00F88E364FD4036A9C25BF357DD4; \
  curl -o /usr/local/bin/gosu -SL "https://github.com/tianon/gosu/releases/download/${GOSU_VERSION}/gosu-amd64"; \
  curl -o /usr/local/bin/gosu.asc -SL "https://github.com/tianon/gosu/releases/download/${GOSU_VERSION}/gosu-amd64.asc"; \
  gpg --batch --verify /usr/local/bin/gosu.asc; \
  rm /usr/local/bin/gosu.asc; \
  rm -r /root/.gnupg; \
  chmod +x /usr/local/bin/gosu; \
# Verify that the binary works
  gosu nobody true

#update and install EPEL - Remi repo
RUN set -eux; \
  yum update -y; \
  yum install -y epel-release yum-utils; \
  yum install -y http://rpms.remirepo.net/enterprise/remi-release-7.rpm; \
  yum-config-manager --enable remi

#Install Redis
RUN set -eux; \
  yum install -y redis; \
  yum clean all && rm -rf /var/cache/yum; \
  redis-cli --version; \
  redis-server --version

RUN mkdir /data && chown redis:redis /data
VOLUME /data
WORKDIR /data

COPY docker-entrypoint.sh /usr/local/bin/
RUN set -eux; \
  chmod +x /usr/local/bin/docker-entrypoint.sh

ENTRYPOINT ["docker-entrypoint.sh"]

EXPOSE 6379
CMD ["redis-server"]
