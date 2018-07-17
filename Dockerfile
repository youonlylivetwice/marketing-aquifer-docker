# This was started from the docker file here:
# https://hub.docker.com/r/fauria/lamp/~/dockerfile/

# Set the base image.
FROM ubuntu:16.04

# Default environment variables.
ENV LOG_STDOUT **Boolean**
ENV LOG_STDERR **Boolean**
ENV LOG_LEVEL warn
ENV ALLOW_OVERRIDE All
ENV DATE_TIMEZONE UTC
ENV TERM dumb
ENV NVM_DIR /usr/local/nvm
ENV NODE_VERSION 8.0.0

# Use bash instead of shell so that files can be sourced.
RUN rm /bin/sh && ln -s /bin/bash /bin/sh

RUN apt-get update
RUN apt-get upgrade -y

# Install packages needed to run a LAMP stack.
RUN apt-get install -y \
  php7.0 \
  php7.0-bz2 \
  php7.0-cgi \
  php7.0-cli \
  php7.0-common \
  php7.0-curl \
  php7.0-dev \
  php7.0-enchant \
  php7.0-fpm \
  php7.0-gd \
  php7.0-gmp \
  php7.0-imap \
  php7.0-interbase \
  php7.0-intl \
  php7.0-json \
  php7.0-ldap \
  php7.0-mcrypt \
  php7.0-mysql \
  php7.0-odbc \
  php7.0-opcache \
  php7.0-pgsql \
  php7.0-phpdbg \
  php7.0-pspell \
  php7.0-readline \
  php7.0-recode \
  php7.0-snmp \
  php7.0-sqlite3 \
  php7.0-sybase \
  php7.0-tidy \
  php7.0-xmlrpc \
  php7.0-xsl \
  php7.0-phar \
  php7.0-mbstring \
  php7.0-zip \
  unzip \
  wget \
  curl \
  sudo \
  snmp \
  iputils-ping \
  apache2 \
  libapache2-mod-php7.0

# Install Composer.
RUN php -r "readfile('http://getcomposer.org/installer');" | php -- --install-dir=/usr/bin/ --filename=composer

# Install Drush.
RUN sudo composer global require drush/drush:8.1.2
ENV PATH="/root/.composer/vendor/bin:${PATH}"

# Install MariaDB.
RUN \
  apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 0xcbcb082a1bb943db && \
  wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | sudo apt-key add - && \
  echo "deb [arch=amd64,i386,ppc64el] http://mirror.lstn.net/mariadb/repo/10.2/ubuntu xenial main" > /etc/apt/sources.list.d/mariadb.list && \
  apt-get update && \
  DEBIAN_FRONTEND=noninteractive apt-get install -y --allow-unauthenticated mariadb-server && \
  rm -rf /var/lib/apt/lists/* && \
  sed -i 's/^\(bind-address\s.*\)/# \1/' /etc/mysql/my.cnf && \
  echo "mysqld_safe &" > /tmp/config && \
  echo "mysqladmin --silent --wait=30 ping || exit 1" >> /tmp/config && \
  bash /tmp/config && \
  rm -f /tmp/config && \
  apt-get clean all

# Install NVM, Node, and NPM.
RUN mkdir /usr/local/nvm
RUN mkdir /usr/local/nvm/bin
RUN mkdir /usr/local/nvm/versions
RUN curl https://raw.githubusercontent.com/creationix/nvm/v0.20.0/install.sh | bash
RUN source $NVM_DIR/nvm.sh \
    && nvm install $NODE_VERSION \
    && nvm alias default $NODE_VERSION \
    && nvm use default

ENV NODE_PATH $NVM_DIR/v$NODE_VERSION/lib/node_modules
ENV PATH $NVM_DIR/v$NODE_VERSION/bin:$PATH

CMD ["service", "php7-fpm", "start"]
CMD ["service", "apache2", "start"]
CMD ["mysqld_safe"]

EXPOSE 8080
EXPOSE 3306
