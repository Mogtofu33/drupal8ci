#!/usr/bin/env bash

if pgrep -x "chrome" > /dev/null
then
  echo "Chrome already running!"
else
  /usr/bin/google-chrome ${CHROME_OPTS}
fi