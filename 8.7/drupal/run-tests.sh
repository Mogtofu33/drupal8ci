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
  apache2 -v | grep version
  a2query -s 000-default
else
  printf "%sApache missing!%s\\n" "${red}" "${end}"
  __error=1
fi

if [ -x "$(command -v composer)" ]; then
  composer --version | grep version
else
  printf "%sComposer missing!%s\\n" "${red}" "${end}"
  __error=1
fi

if [ -x "$(command -v mysql)" ]; then
  mysql -V
else
  printf "%sMysql client missing!%s\\n" "${red}" "${end}"
  __error=1
fi

if [ -x "$(command -v robo)" ]; then
  robo -V
else
  printf "%srobo missing!%s\\n" "${red}" "${end}"
  __error=1
fi

if [ -x "$(command -v node)" ]; then
  printf "Node "
  node --version
else
  printf "%sNode missing!%s\\n" "${red}" "${end}"
  __error=1
fi

if [ -x "$(command -v yarn)" ]; then
  yarn versions | grep 'versions'
else
  printf "%sYarn missing!%s\\n" "${red}" "${end}"
  __error=1
fi

if [ -x "$(command -v phpqa)" ]; then
  phpqa tools
else
  printf "%sPhpqa missing!%s\\n" "${red}" "${end}"
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

if [ -x "$(command -v phpunit)" ]; then
  phpunit --version | grep 'PHPUnit'
else
  printf "%sPhpunit missing!%s\\n" "${red}" "${end}"
  __error=1
fi

if [ -x "$(command -v google-chrome)" ]; then
  google-chrome --version
else
  printf "%sGoogle Chrome missing!%s\\n" "${red}" "${end}"
  __error=1
fi

if [ -x "$(command -v chromedriver)" ]; then
  chromedriver --version
else
  printf "%sChromedriver missing!%s\\n" "${red}" "${end}"
  __error=1
fi

if [ -f /scripts/run-tests-extra.sh ]; then
  source /scripts/run-tests-extra.sh
fi

printf "<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<"

if [ $__error = 1 ]; then
  printf "\\n\\n%s[ERROR] Tests failed!%s\\n\\n" "${red}" "${end}"
  exit 1
fi

printf "\\n\\n%s[SUCCESS] Tests passed!%s\\n\\n" "${grn}" "${end}"
exit 0