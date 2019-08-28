# https://hub.docker.com/r/juampynr/drupal8ci/~/dockerfile/
# https://github.com/docker-library/drupal/blob/master/$DRUPAL_TAG/apache/Dockerfile
# https://gitlab.com/mog33/drupal8ci
FROM mogtofu33/drupal8ci:$DRUPAL_TAG-selenium

LABEL maintainer="dev-drupal.com"

# Remove the vanilla Drupal project that comes with the parent image.
RUN rm -rf ..?* .[!.]* *

# Change docroot since we use Composer Drupal project.
RUN sed -ri -e 's!/var/www/html!/var/www/html/web!g' /etc/apache2/sites-available/*.conf \
  && sed -ri -e 's!/var/www!/var/www/html/web!g' /etc/apache2/apache2.conf /etc/apache2/conf-available/*.conf

# Add tests.
COPY run-tests.sh /scripts/run-tests.sh
RUN chmod +x /scripts/*.sh
