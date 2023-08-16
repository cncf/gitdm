#!/bin/bash
if [ "${1}" = "" ]
then
  echo "$0: need filename argument"
  exit 1
fi
grep -HIn '\w@\w' "${1}"
cp "${1}" out && vim -c "%s/[A-Z]/\L&/g|%s/\([a-zA-Z0-9]\)@\([a-zA-Z0-9]\)/\1!\2/g|w|q" out && cat out | sort > out1 && cat out | sort | uniq > out2 && diff out1 out2 && rm -f out out1 out2
echo 'Checking for multiple emails per single lines'
echo ''
grep -E '[A-Za-z0-9._%+-]+\![A-Za-z0-9.-]+\.[A-Za-z]{2,6}\s*,\s*[A-Za-z0-9._%+-]+\![A-Za-z0-9.-]+\.[A-Za-z]{2,6}\s+[A-Za-z0-9._%+-]+' "${1}"
echo 'Checking for multiple emails per single line in github_users.json file'
echo ''
cat github_users.json | grep '"email":' | grep -E ',\s*\w+'
