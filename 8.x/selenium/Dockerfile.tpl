# https://hub.docker.com/r/juampynr/drupal8ci/~/dockerfile/
# https://github.com/docker-library/drupal/blob/master/8.7/apache/Dockerfile
# https://gitlab.com/mog33/drupal8ci
FROM mogtofu33/drupal8ci:8.7

LABEL maintainer="dev-drupal.com"

ENV JAVA_OPTS="-Xmx512m"
ENV SE_OPTS=""

ADD http://selenium-release.storage.googleapis.com/3.141/selenium-server-standalone-3.141.59.jar selenium-server-standalone.jar
ADD https://raw.githubusercontent.com/SeleniumHQ/docker-selenium/master/Standalone/start-selenium-standalone.sh /scripts/start-selenium-standalone.sh

RUN mkdir -p /opt/selenium \
  && mv selenium-server-standalone.jar /opt/selenium/ \
  && mkdir -p /usr/share/man/man1 \
  && apt-get update && apt-get install --no-install-recommends -y \
  openjdk-8-jdk \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

COPY run-tests-extra.sh /scripts/run-tests-extra.sh
RUN chmod +x /scripts/*.sh

EXPOSE 80 4444 9515 9222