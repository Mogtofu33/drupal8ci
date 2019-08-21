#!/bin/bash
set -e

red=$'\e[1;31m'
grn=$'\e[1;32m'
end=$'\e[0m'
__error=0

printf "\\n>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>\\n"

if [ -x "$(command -v php)" ]; then
  php -v | grep built
else
  printf "%sPhp missing!%s\\n" "${red}" "${end}"
  __error=1
fi

if [ -x "$(command -v apache2)" ]; then
  apache2 -v | grep version | cut -d " " -f3-
  cat /etc/apache2/sites-available/000-default.conf | grep DocumentRoot | xargs
else
  printf "%sApache missing!%s\\n" "${red}" "${end}"
  __error=1
fi

if [ -x "$(command -v composer)" ]; then
  sudo -E -u www-data composer --version | grep version
else
  printf "%sComposer missing!%s\\n" "${red}" "${end}"
  __error=1
fi

if [ -x "$(command -v mysql)" ]; then
  mysql --version
else
  printf "%sMysql client missing!%s\\n" "${red}" "${end}"
  __error=1
fi

if [ -x "$(command -v robo)" ]; then
  sudo -E -u www-data robo --version
else
  printf "%sRobo missing!%s\\n" "${red}" "${end}"
  __error=1
fi

if [ -x "$(command -v node)" ]; then
  printf "Node "
  sudo -E -u www-data node --version
else
  printf "%sNode missing!%s\\n" "${red}" "${end}"
  __error=1
fi

if [ -x "$(command -v yarn)" ]; then
  printf "Yarn "
  sudo -E -u www-data yarn --version
else
  printf "%sYarn missing!%s\\n" "${red}" "${end}"
  __error=1
fi

if [ -x "$(command -v jq)" ]; then
  jq --version
else
  printf "%sJq missing!%s\\n" "${red}" "${end}"
  __error=1
fi

if [ -x "$(command -v sudo)" ]; then
  sudo --version | grep 'Sudo version'
else
  printf "%sSudo missing!%s\\n" "${red}" "${end}"
  __error=1
fi

if [ -x "$(command -v chromium)" ]; then
  chromium --version
else
  printf "%sChromium missing!%s\\n" "${red}" "${end}"
  __error=1
fi

if [ -f /scripts/run-tests-extra.sh ]; then
  source /scripts/run-tests-extra.sh
fi

printf "<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<"

if [ $__error = 1 ]; then
  printf "\\n\\n%s[ERROR] Tests failed!%s\\n\\n" "${red}" "${end}"
  exit 1
fi

printf "\\n\\n%s[SUCCESS] Tests passed!%s\\n\\n" "${grn}" "${end}"
exit 0