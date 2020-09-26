#!/usr/bin/env bash

if pgrep -x "chromedriver" > /dev/null
then
  echo "Chromedriver already running!"
else
  /usr/local/bin/chromedriver ${CHROMEDRIVER_OPTS}
fi