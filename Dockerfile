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
ENV NPM_VERSION 5.5.1

# Replace shell with bash so we can source files.
RUN rm /bin/sh && ln -s /bin/bash /bin/sh

# Install packages needed to run a LAMP stack.
RUN apt-get update
RUN apt-get upgrade -y
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
  vim \
  git \
  pv \
  iputils-ping

RUN apt-get install apache2 libapache2-mod-php7.0 -y
RUN apt-get install mariadb-common mariadb-server mariadb-client -y

# Install Composer.
RUN php -r "readfile('http://getcomposer.org/installer');" | php -- --install-dir=/usr/bin/ --filename=composer

# Install Drush.
RUN sudo composer global require drush/drush:8.1.2
ENV PATH="/root/.composer/vendor/bin:${PATH}"

# Install Registry Rebuild
RUN drush @none dl registry_rebuild-7.x

# Install node, npm, aquifer, and gulp.
RUN mkdir -p /tmp/node
WORKDIR /tmp/node
RUN curl -SLO "http://nodejs.org/dist/v$NODE_VERSION/node-v$NODE_VERSION-linux-x64.tar.gz" && \
  tar -xzf "node-v$NODE_VERSION-linux-x64.tar.gz" -C /usr/local --strip-components=1 && \
  rm "node-v$NODE_VERSION-linux-x64.tar.gz" && \
  npm install -g npm@"$NPM_VERSION" && \
  npm install -g aquifer gulp
WORKDIR /root

# Set up apache.
RUN sudo mkdir -p /root/marketing-aquifer/build
COPY ./config/default-apache-page.html /root/marketing-aquifer/build/index.html
COPY ./config/marketing-aquifer.conf /etc/apache2/sites-available/marketing-aquifer.conf
RUN chown -R www-data:www-data /root/marketing-aquifer/build && \
  chmod -R g+rwX /root/marketing-aquifer/build && \
  chmod +rx /root && \
  a2enmod rewrite && \
  a2ensite marketing-aquifer && \
  rm -R /root/marketing-aquifer

# Set up Mysql.
RUN sudo service mysql start && \
  mysql -e "CREATE DATABASE IF NOT EXISTS circle_test" && \
  mysql -e "CREATE USER 'ubuntu'@'localhost'" && \
  mysql -e "GRANT ALL PRIVILEGES ON circle_test.* TO 'ubuntu'@'localhost'"


COPY init.sh /usr/sbin
RUN chmod +x /usr/sbin/init.sh

VOLUME /root
VOLUME /var/log/httpd
VOLUME /var/lib/mysql
VOLUME /var/log/mysql
VOLUME /etc/apache2

EXPOSE 80
EXPOSE 8080
EXPOSE 3306

ENTRYPOINT /usr/sbin/init.sh
