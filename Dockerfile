FROM debian:bullseye-slim

ARG UID=1000
ARG GID=1000

ENV YARN_CACHE_FOLDER="/var/cache/yarn"

RUN apt-get update \
&&  apt-get install -y --no-install-recommends \
software-properties-common \
apt-utils \
apt-transport-https \
lsb-release \
ca-certificates \
gnupg \
gnupg1 \
gnupg2 \
git \
tini \
curl \
wget \
unzip

RUN set -eux; \
adduser -h /home/rootless -g "rootless" -D -u ${UID} rootless; \
echo "rootless:${UID}:${GID}" >> /etc/subuid; \
echo "rootless:${UID}:${GID}" >> /etc/subgid; \
echo "rootless:rootless:${UID}:${GID}:/root:/bin" >> /etc/passwd; \
echo "rootless::${GID}:rootless" >> /etc/group

RUN apt-get update \
&&  curl -sL https://deb.nodesource.com/setup_16.x | bash - \
&&  curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - \
&&  echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list

RUN apt-get update \
&& DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
nodejs \
yarn

COPY docker-entrypoint.sh /usr/bin/docker-entrypoint.sh

RUN set -eux; \
mkdir -p \
/var/cache/yarn; \
chmod 777 -R \
/var/cache; \
chmod +x \
/usr/bin/docker-*.sh

ENTRYPOINT ["docker-entrypoint.sh"]

WORKDIR /app

CMD ["yarn"]

USER rootless
