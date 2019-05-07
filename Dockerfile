# VERSION 1.0.1
# AUTHOR: euwen
# DESCRIPTION: Basic wifidata container
# BUILD: docker build --rm -t euwen/wifidata .


FROM python:3.6-slim
LABEL maintainer="euwen"

# Never prompts the user for choices on installation/configuration of packages
ENV DEBIAN_FRONTEND noninteractive
ENV TERM linux


ARG WIFIDATA_VERSION=1.0.1
ARG WIFIDATA_HOME=/home/wifidata
ARG PYTHON_DEPS=""

# Define en_US.
ENV LANGUAGE en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LC_ALL en_US.UTF-8
ENV LC_CTYPE en_US.UTF-8
ENV LC_MESSAGES en_US.UTF-8

RUN set -ex \
    && buildDeps=' \
        freetds-dev \
        libkrb5-dev \
        libsasl2-dev \
        libssl-dev \
        libffi-dev \
        libpq-dev \
        git \
    ' \
    && apt-get update -yqq \
    && apt-get upgrade -yqq \
    && apt-get install -yqq --no-install-recommends \
        $buildDeps \
        freetds-bin \
        build-essential \
        default-libmysqlclient-dev \
        apt-utils \
        curl \
        rsync \
        netcat \
        locales \
    && sed -i 's/^# en_US.UTF-8 UTF-8$/en_US.UTF-8 UTF-8/g' /etc/locale.gen \
    && locale-gen \
    && update-locale LANG=en_US.UTF-8 LC_ALL=en_US.UTF-8 \
    && useradd -ms /bin/bash -d ${WIFIDATA_HOME} wifi \
    && ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime \
    && echo "Asia/Shanghai" > /etc/timezone \
    && dpkg-reconfigure -f noninteractive tzdata \
    && pip install -U pip setuptools wheel \
    && pip install pytz \
    && pip install pyOpenSSL \
    && pip install ndg-httpsclient \
    && pip install pyasn1 \
    && pip install pyspark \
    && pip install geohash \
    && pip install pandas \
    && pip install kazoo \
    && pip install happybase \
    && pip install ConfigParser \
    && pip install flask \
    && pip install pathos \
    && pip install pykafka \
    && pip install pymysql \
    && pip install thrift \
    && pip install arrow \
    && pip install DBUtils \
    && pip install flask_bcrypt \
    && pip install sqlalchemy \
    && pip install 'redis>=3.2.0' \
    && if [ -n "${PYTHON_DEPS}" ]; then pip install ${PYTHON_DEPS}; fi \
    && apt-get purge --auto-remove -yqq $buildDeps \
    && apt-get autoremove -yqq --purge \
    && apt-get clean \
    && rm -rf \
        /var/lib/apt/lists/* \
        /tmp/* \
        /var/tmp/* \
        /usr/share/man \
        /usr/share/doc \
        /usr/share/doc-base



RUN chown -R wifi: ${WIFIDATA_HOME}

EXPOSE 8080 5555 8793 6379 8088 8089 8090 8091 8092 8093 8094 8095 8096 8097 8098 8099

USER wifi
WORKDIR ${WIFIDATA_HOME}
