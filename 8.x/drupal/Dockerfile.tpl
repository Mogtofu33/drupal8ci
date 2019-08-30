# https://hub.docker.com/r/juampynr/drupal8ci/~/dockerfile/
# https://github.com/docker-library/drupal/blob/master/$DRUPAL_TAG/apache/Dockerfile
FROM drupal:$DRUPAL_TAG-apache

LABEL maintainer="dev-drupal.com"

# Install needed programs for next steps.
RUN apt-get update && apt-get install --no-install-recommends -y \
  apt-transport-https \
  gnupg2 \
  software-properties-common \
  sudo \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Install Nodejs, Yarn, programs for next steps and php extensions.
RUN curl -sL https://deb.nodesource.com/setup_10.x | bash - \
  && curl -sL https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - \
  && echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list \
  && apt-get update && apt-get install --no-install-recommends -y \
  nodejs \
  yarn \
  imagemagick \
  libmagickwand-dev \
  libnss3-dev \
  libxslt-dev \
  mariadb-client \
  jq \
  git \
  unzip \
  # Install xsl, mysqli, xdebug, imagick.
  && docker-php-ext-install xsl mysqli \
  && pecl install imagick xdebug \
  && docker-php-ext-enable imagick xdebug \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

## Install Chromium 76+ on debian.
COPY 99defaultrelease /etc/apt/apt.conf.d/99defaultrelease
COPY sources.list /etc/apt/sources.list.d/sources.list
RUN mv /etc/apt/sources.list /etc/apt/sources.list.bak \
  && apt-get update && apt-get -t testing install --no-install-recommends -y \
  chromium

# Install Composer.
COPY --from=composer:latest /usr/bin/composer /usr/local/bin/composer
COPY composer.json /var/www/.composer/composer.json

RUN mkdir -p /var/www/.composer /var/www/html/vendor/bin/ \
  && chmod 777 /var/www \
  && chown -R www-data:www-data /var/www/.composer /var/www/html/vendor /var/www/html/composer.*

# Manage Composer.
WORKDIR /var/www/.composer

USER www-data

# Put a turbo on composer, install phpqa + tools + Robo + Coder.
# Install Drupal dev third party and upgrade Php-unit.
RUN composer install --no-ansi -n --profile --no-suggest \
  && composer clear-cache \
  && rm -rf /var/www/.composer/cache/*

# [TEMPORARY] Drupal 8.7 only.
# Install Drupal dev and PHP 7 update for PHPunit, see
# https://github.com/drupal/drupal/blob/8.7.x/composer.json#L56

WORKDIR /var/www/html

RUN composer run-script drupal-phpunit-upgrade --no-ansi \
  && composer clear-cache \
  && rm -rf /tmp/* \
  && chown -R www-data:www-data /var/www/html/vendor

# Manage final tasks.
USER root

## Specific part for the included Drupal 8 code in this image.
COPY .env.nightwatch /var/www/html/core/.env

RUN ln -sf /var/www/html/vendor/bin/* /usr/local/bin \
  && ln -sf /var/www/.composer/vendor/bin/* /usr/local/bin \
  && ln -sf /var/www/.composer/vendor/bin/* /var/www/html/vendor/bin/

COPY run-tests.sh /scripts/run-tests.sh
COPY start-chrome.sh /scripts/start-chrome.sh
RUN chmod +x /scripts/*.sh

# Remove Apache logs to stdout from the php image (used by Drupal image).
RUN rm -f /var/log/apache2/access.log

# Fix Php performances.
RUN mv /usr/local/etc/php/php.ini-development /usr/local/etc/php/php.ini \
  && sed -i "s#memory_limit = 128M#memory_limit = 2048M#g" /usr/local/etc/php/php.ini \
  && sed -i "s#max_execution_time = 30#max_execution_time = 90#g" /usr/local/etc/php/php.ini \
  && sed -i "s#;max_input_nesting_level = 64#max_input_nesting_level = 512#g" /usr/local/etc/php/php.ini
