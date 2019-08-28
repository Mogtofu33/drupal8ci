#!/bin/bash
# set -e

if [ -x "$(command -v java)" ]; then
  java -version
else
  printf "%sJava missing!%s\\n" "${red}" "${end}"
  __error=1
fi
