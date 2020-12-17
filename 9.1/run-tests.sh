#!/bin/bash
set -eu

run_tests() {

  local __osht=${1:-0}
  if (($__osht)); then
    local runs='RUNS'
  else
    local runs=''
  fi

  if [ -f "/opt/drupal/vendor/bin/drush" ]; then
    # Print Drupal version.
    if [ -f "/opt/drupal/composer.json" ]; then 
  $runs /opt/drupal/vendor/bin/drush --root="/opt/drupal" status --fields="drupal-version"
    fi
  $runs /opt/drupal/vendor/bin/drush --version
  fi

  $runs php -v
  $runs apache2 -v
  $runs composer --version
  $runs mysql -V
  $runs robo -V
  $runs node --version
  $runs yarn versions
  $runs phpqa tools
  $runs jq --version
  $runs google-chrome --version
  $runs chromedriver --version

  # Get and compare Chrome and Chromedriver versions.
  __chrome_version=($(google-chrome --version))
  __chrome_version=${__chrome_version[2]}
  __chrome_version=(${__chrome_version//./ })
  __chrome_version=${__chrome_version[0]}

  __chromedriver_version=($(chromedriver --version))
  __chromedriver_version=${__chromedriver_version[1]}
  __chromedriver_version=(${__chromedriver_version//./ })
  __chromedriver_version=${__chromedriver_version[0]}

  if (($__osht)); then
    OSHT_VERBOSE=1
    IS $__chromedriver_version == $__chrome_version
  fi

  if (($__osht)); then
    PLAN $num
  fi
}

get_num_tests() {
  num=12
  if [ -f "/opt/drupal/vendor/bin/drush" ]; then
    num=13
    if [ -f "/opt/drupal/composer.json" ]; then 
      num=14
    fi
  fi
}

if [ ${1:-""} = "report" ]; then

  # eval "$(curl -q -s https://raw.githubusercontent.com/coryb/osht/master/osht.sh)"
  eval "$(curl -q -s https://raw.githubusercontent.com/dcsobral/osht/bug/junitXML/osht.sh)"

  # Force report file.
  OSHT_JUNIT=1
  OSHT_JUNIT_OUTPUT=/tmp/report/report.xml

  get_num_tests

  run_tests 1

else
  echo -e "-------------- Tests --------------"
  run_tests
  echo -e "------------- End tests -------------"
fi
