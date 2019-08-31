# https://hub.docker.com/r/juampynr/drupal8ci/~/dockerfile/
# https://github.com/docker-library/drupal/blob/master/8.7/apache/Dockerfile
FROM drupal:8.7-apache

LABEL maintainer="dev-drupal.com"

ENV DBUS_SESSION_BUS_ADDRESS="/dev/null"
ARG CHROME_DRIVER_VERSION=76.0.3809.68

# Install needed programs for next steps.
RUN apt-get update && apt-get install --no-install-recommends -y \
  apt-transport-https \
  ca-certificates \
  gnupg2 \
  software-properties-common \
  sudo \
  curl \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

#==================
# Install Nodejs, Yarn, Chrome, php extensions, needed programs.
RUN curl -sL https://deb.nodesource.com/setup_10.x | bash - \
  && curl -sL https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - \
  && echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list \
  # Google Chrome 76+
  && curl -sS -o - https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add - \
  && echo "deb [arch=amd64] https://dl.google.com/linux/chrome/deb/ stable main" > /etc/apt/sources.list.d/google-chrome.list \
  && apt-get update && apt-get install --no-install-recommends -y \
  nodejs \
  yarn \
  google-chrome-stable \
  imagemagick \
  libmagickwand-dev \
  libnss3-dev \
  libxslt-dev \
  mariadb-client \
  jq \
  git \
  unzip \
  vim \
  # Install xsl, mysqli, xdebug, imagick.
  && docker-php-ext-install xsl mysqli \
  && pecl install imagick xdebug \
  && docker-php-ext-enable imagick xdebug \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

#==================
# Chromedriver
RUN curl -fsSL https://chromedriver.storage.googleapis.com//chromedriver_linux64.zip \
  -o /tmp/chromedriver_linux64.zip \
  && unzip /tmp/chromedriver_linux64.zip -d /opt \
  && rm -f /tmp/chromedriver_linux64.zip \
  && mv /opt/chromedriver /opt/chromedriver- \
  && chmod 755 /opt/chromedriver- \
  && ln -fs /opt/chromedriver- /usr/local/bin/chromedriver \
  # Add Chrome as a user
  && groupadd -r chromeuser && useradd -r -g chromeuser -G audio,video chromeuser \
  && mkdir -p /home/chromeuser && chown -R chromeuser:chromeuser /home/chromeuser

#==================
# Composer.
COPY --chown=www-data:www-data --from=composer:latest /usr/bin/composer /usr/local/bin/composer
COPY --chown=www-data:www-data composer.json /var/www/.composer/composer.json

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

#==================
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

COPY --chown=www-data:www-data run-tests.sh /scripts/run-tests.sh
COPY --chown=chromeuser:chromeuser start-chrome.sh /scripts/start-chrome.sh
COPY --chown=chromeuser:chromeuser start-chromedriver.sh /scripts/start-chromedriver.sh

RUN chmod +x /scripts/*.sh \
  # Symlink binaries.
  && ln -sf /var/www/html/vendor/bin/* /usr/local/bin \
  && ln -sf /var/www/.composer/vendor/bin/* /usr/local/bin \
  && ln -sf /var/www/.composer/vendor/bin/* /var/www/html/vendor/bin/ \
  # Remove Apache logs to stdout from the php image (used by Drupal image).
  && rm -f /var/log/apache2/access.log \
  # Fix Php performances.
  && mv /usr/local/etc/php/php.ini-development /usr/local/etc/php/php.ini \
  && sed -i "s#memory_limit = 128M#memory_limit = 2048M#g" /usr/local/etc/php/php.ini \
  && sed -i "s#max_execution_time = 30#max_execution_time = 90#g" /usr/local/etc/php/php.ini \
  && sed -i "s#;max_input_nesting_level = 64#max_input_nesting_level = 512#g" /usr/local/etc/php/php.ini \
  # Convenient alias.
  echo "alias ls='ls --color=auto -lAh'" >> /root/.bashrc \
  && cp /root/.bashrc /var/www/.bashrc \
  && chown www-data:www-data /var/www/.bashrc

EXPOSE 80 4444 9515 9222