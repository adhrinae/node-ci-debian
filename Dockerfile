FROM node:14-buster

ENV AWS_CLI_VERSION 2.1.24
ENV DOCKER_COMPOSE_VERSION 1.23.2
ENV WATCHMAN_VERSION 4.9.0

RUN set -ex
RUN apt update
RUN apt install -y apt-transport-https gnupg2 software-properties-common pass \
    git openssh-client ca-certificates curl build-essential python3 python3-pip python3-dev python3-setuptools
# Upgrade pip
RUN pip3 install --no-cache-dir --upgrade pip setuptools
# Install Docker
RUN curl -fsSL https://download.docker.com/linux/debian/gpg | apt-key add -
RUN add-apt-repository \
    "deb [arch=amd64] https://download.docker.com/linux/debian \
    $(lsb_release -cs) \
    stable"
RUN apt update && apt install -y docker-ce docker-ce-cli containerd.io
# Install Docker Compose
RUN pip3 install docker-compose==${DOCKER_COMPOSE_VERSION}
# Install awscli v2
RUN curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64-${AWS_CLI_VERSION}.zip" -o "awscliv2.zip" \
    && unzip awscliv2.zip \
    && ./aws/install \
    && aws --version \
    && apt install -y amazon-ecr-credential-helper
# Install Watchman
RUN cd /tmp; curl -LO https://github.com/facebook/watchman/archive/v${WATCHMAN_VERSION}.tar.gz \
    && tar xzf v${WATCHMAN_VERSION}.tar.gz; rm v${WATCHMAN_VERSION}.tar.gz \
    && cd watchman-${WATCHMAN_VERSION} \
    && ./autogen.sh; ./configure --without-python  --without-pcre --enable-lenient; make && make install \
    && cd /tmp; rm -rf watchman-${WATCHMAN_VERSION} \
    && watchman --version
# Fix Yarn configuration
RUN npm config set scripts-prepend-node-path true \
    && yarn --version
