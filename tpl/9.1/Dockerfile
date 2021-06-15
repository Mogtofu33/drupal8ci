# https://hub.docker.com/r/juampynr/drupal8ci/~/dockerfile/
# https://github.com/docker-library/drupal/blob/master/9.1/php8.0/apache-buster/Dockerfile
FROM drupal:${IMAGE_TAG}-apache

LABEL maintainer="dev-drupal.com"

# Install needed programs for next steps.
RUN apt-get update && apt-get install --no-install-recommends -y \
  apt-transport-https \
  ca-certificates \
  gnupg2 \
  software-properties-common \
  sudo \
  curl \
  ssh \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

#==================
# Install Nodejs, Yarn, Chrome, php extensions, needed programs.
RUN curl -sL https://deb.nodesource.com/setup_12.x | bash - \
  && curl -sL https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - \
  && echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list \
  # Google Chrome latest stable release.
  && curl -sS -o - https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add - \
  && echo "deb [arch=amd64] https://dl.google.com/linux/chrome/deb/ stable main" > /etc/apt/sources.list.d/google-chrome.list \
  && apt-get update && apt-get install --no-install-recommends -y \
  nodejs \
  yarn \
  google-chrome-stable \
  libicu-dev \
  libnss3-dev \
  libssl-dev \
  libxslt-dev \
  mariadb-client \
  jq \
  git \
  unzip \
  vim \
  # Install intl, xsl, mysqli, xdebug, bcmath.
  && docker-php-ext-install intl xsl mysqli bcmath calendar sockets pcntl opcache exif ftp \
  && pecl install xdebug \
  && docker-php-ext-enable xdebug \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

#==================
# Chromedriver latest stable release.
# http://chromedriver.chromium.org/downloads/version-selection
RUN curl -fsSL https://chromedriver.storage.googleapis.com/$(curl -s https://chromedriver.storage.googleapis.com/LATEST_RELEASE)/chromedriver_linux64.zip \
    -o /tmp/chromedriver_linux64.zip \
  && unzip /tmp/chromedriver_linux64.zip -d /opt \
  && rm -f /tmp/chromedriver_linux64.zip \
  && ln -fs /opt/chromedriver /usr/local/bin/chromedriver \
  # Add Chrome as a user
  && groupadd -r chromeuser && useradd -r -g chromeuser -G audio,video chromeuser \
  && mkdir -p /home/chromeuser && chown -R chromeuser:chromeuser /home/chromeuser

#==================
# Composer v1 is included in base image, update to v2.
# https://github.com/docker-library/drupal/blob/master/9.1/php8.0/apache-buster/Dockerfile#L60
RUN /usr/local/bin/composer selfupdate --2
COPY --chown=www-data:www-data composer.json /var/www/.composer/composer.json

RUN chmod 777 /var/www \
  && chown -R www-data:www-data /var/www

USER www-data

# Manage Composer.
WORKDIR /var/www/.composer

# Put a turbo on composer, install phpqa + tools + Robo + Coder.
# see composer.json
RUN COMPOSER_MEMORY_LIMIT=-1 composer install --no-interaction --no-ansi \
  && composer clear-cache

WORKDIR /opt/drupal

USER root

# Add dev, drush and update phpunit based on how official image use composer.
# Added phpspec, @see https://www.drupal.org/project/drupal/issues/3182653
RUN set -eux; \
  export COMPOSER_HOME="$(mktemp -d)"; \
  COMPOSER_MEMORY_LIMIT=-1 composer require "drupal/core-dev:~${IMAGE_TAG}.0" "drush/drush:^10" "phpspec/prophecy-phpunit" --working-dir="/opt/drupal" --no-interaction --no-ansi --no-suggest; \
  chown -R www-data:www-data web/profiles; \
  # delete composer cache
  rm -rf "$COMPOSER_HOME"

# Manage final tasks.
COPY --chown=www-data:www-data run-tests.sh /scripts/run-tests.sh
COPY --chown=chromeuser:chromeuser start-chromedriver.sh /scripts/start-chromedriver.sh
COPY --chown=chromeuser:chromeuser start-chrome.sh /scripts/start-chrome.sh

RUN ln -sf /opt/drupal/vendor /var/www/vendor \
  && chmod +x /scripts/*.sh \
  && ln -sf /scripts/* /usr/local/bin \
  # Symlink composer downloaded binaries.
  && ln -sf /var/www/.composer/vendor/bin/* /usr/local/bin \
  # Add security checker.
  && curl -fsSL https://github.com/fabpot/local-php-security-checker/releases/download/v1.0.0/local-php-security-checker_1.0.0_linux_amd64 -o security-checker \
  && mv security-checker /usr/local/bin \
  && chmod +x /usr/local/bin/security-checker \
  # Fix Php performances.
  && mv /usr/local/etc/php/php.ini-development /usr/local/etc/php/php.ini \
  && sed -i "s#memory_limit = 128M#memory_limit = 4G#g" /usr/local/etc/php/php.ini \
  && sed -i "s#max_execution_time = 30#max_execution_time = 90#g" /usr/local/etc/php/php.ini \
  && sed -i "s#;max_input_nesting_level = 64#max_input_nesting_level = 512#g" /usr/local/etc/php/php.ini \
  # Convenient alias for root and www-data.
  && echo "alias ls='ls --color=auto -lAh'" >> /root/.bashrc \
  && echo "alias l='ls --color=auto -lAh'" >> /root/.bashrc \
  && cp /root/.bashrc /var/www/.bashrc \
  && chown www-data:www-data /var/www/.bashrc

EXPOSE 80 4444 9515 9222
