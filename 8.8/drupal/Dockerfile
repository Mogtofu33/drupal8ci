FROM mogtofu33/drupal8ci:8.7

LABEL maintainer="dev-drupal.com"

# Install Chromium 76 on debian.

COPY 99defaultrelease /etc/apt/apt.conf.d/99defaultrelease
COPY sources.list /etc/apt/sources.list.d/sources.list

RUN mv /etc/apt/sources.list /etc/apt/sources.list.bak \
  && apt-get update && apt-get -t testing install --no-install-recommends -y \
  chromium

# Remove the vanilla Drupal project that comes with the parent image.
RUN rm -rf ..?* .[!.]* *

RUN set -eux; \
  curl -fSL "https://ftp.drupal.org/files/projects/drupal-8.8.x-dev.tar.gz" -o drupal.tar.gz; \
  tar -xz --strip-components=1 -f drupal.tar.gz; \
  rm drupal.tar.gz; \
  && mkdir -p /var/www/html/vendor/bin/ \
  && chmod 777 /var/www \
  && chown -R www-data:www-data /var/www/.composer /var/www/html
