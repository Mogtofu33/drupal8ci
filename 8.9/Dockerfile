# https://hub.docker.com/r/juampynr/drupal8ci/~/dockerfile/
# https://github.com/docker-library/drupal/blob/master/8.9/apache-buster/Dockerfile
FROM drupal:8.9-apache

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
  imagemagick \
  libmagickwand-dev \
  libnss3-dev \
  libxslt-dev \
  mariadb-client \
  jq \
  git \
  unzip \
  vim \
  # Install intl, xsl, mysqli, xdebug, imagick.
  && docker-php-ext-install intl xsl mysqli \
  && pecl install imagick xdebug \
  && docker-php-ext-enable imagick xdebug \
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
# Composer is included in base image:
# https://github.com/docker-library/drupal/blob/master/8.8/apache-buster/Dockerfile#L60
COPY --chown=www-data:www-data composer.json /var/www/.composer/composer.json

RUN chmod 777 /var/www /opt/drupal \
  && chown -R www-data:www-data /var/www /opt/drupal

USER www-data

# Manage Composer.
WORKDIR /var/www/.composer

# Put a turbo on composer, install phpqa + tools + Robo + Coder.
# see composer.json
RUN COMPOSER_MEMORY_LIMIT=-1 composer install --no-interaction --no-ansi --no-suggest \
  && composer clear-cache

WORKDIR /opt/drupal

USER root

# Add dev, drush and update phpunit based on how official image use composer.
RUN set -eux; \
  export COMPOSER_HOME="$(mktemp -d)"; \
  COMPOSER_MEMORY_LIMIT=-1 composer require "drupal/core-dev:~8.9" "drush/drush:^10" --working-dir="/opt/drupal" --no-interaction --no-ansi --no-suggest; \
  chown -R www-data:www-data web/profiles; \
  # delete composer cache
  rm -rf ""

# Manage final tasks.
COPY --chown=www-data:www-data run-tests.sh /scripts/run-tests.sh
COPY --chown=chromeuser:chromeuser start-chromedriver.sh /scripts/start-chromedriver.sh
COPY --chown=chromeuser:chromeuser start-chrome.sh /scripts/start-chrome.sh

RUN ln -sf /opt/drupal/vendor /var/www/vendor \
  && chmod +x /scripts/*.sh \
  && ln -sf /scripts/* /usr/local/bin \
  # Symlink composer downloaded binaries.
  && ln -sf /var/www/.composer/vendor/bin/* /usr/local/bin \
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
