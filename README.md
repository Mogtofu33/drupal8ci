# Drupal 8 CI Docker image for Gitlab CI

## Details

[Drupal 8/9](https://www.drupal.org/8) ci image based on official [docker Drupal](https://github.com/docker-library/drupal)
with some Php/NodeJs tools needed for CI or Local Build/Test/Lint.

Used with project [Gitlab CI Drupal](https://gitlab.com/mog33/gitlab-ci-drupal).

* Fork from [juampynr/drupal8ci](https://hub.docker.com/r/juampynr/drupal8ci/~/dockerfile/)
* Based on [Drupal official image](https://github.com/docker-library/drupal), added
  * [Node.js 10](https://nodejs.org/en/) + [Yarn](https://yarnpkg.com)
  * [Google chrome stable](https://dl.google.com/linux/chrome/deb/)  + [Chromedriver](http://chromedriver.chromium.org)
  * [Composer prestissimo plugin](https://github.com/hirak/prestissimo)
  * [Robo CI](http://robo.li)
  * [Phpqa](https://github.com/EdgedesignCZ/phpqa) including:
    * [Phpmetrics](https://www.phpmetrics.org)
    * [Phploc](https://github.com/sebastianbergmann/phploc)
    * [Phpcs](https://github.com/squizlabs/PHP_CodeSniffer)
    * [Phpmd](https://phpmd.org)
    * [Pdepend](https://pdepend.org)
    * [Phpcpd](https://github.com/sebastianbergmann/phpcpd)
  * [Security checker](https://github.com/fabpot/local-php-security-checker)
  * [phpstan](https://github.com/phpstan/phpstan)
  * [Drupal Coder](https://www.drupal.org/project/coder)
  * Mariadb (MySQL) client
  * Php: added extensions intl, xsl, mysqli, imagick, xdebug
  * [jq](https://stedolan.github.io/jq/)

## Basic usage (local)

All images are based on official [docker Drupal](https://github.com/docker-library) images managed by Composer.

To use with a local Drupal 8/9 managed by Composer, mount your Drupal on `/opt/drupal/`

## Issues

* Force phpcpd to v5 (and `phpunit/php-timer:3.1.4`) until this [issue](https://github.com/EdgedesignCZ/phpqa/pull/209) is resolved.

## Build

CI variable `CI_DO_RELEASE`, default to `1` to push to Docker hub.

```bash
make prepare
```

## Tests

Basic version check tests with [Obvious Shell Testing (osht)](https://github.com/coryb/osht).

```bash
docker run -it --rm mogtofu33/drupal8ci:3.x-dev-9.0 /scripts/run-tests.sh report
```

----
Want some help implementing this on your project? I provide Drupal expertise as a freelance, just [contact me](https://developpeur-drupal.com/en).
