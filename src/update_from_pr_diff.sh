#!/bin/bash
if [ -z "${PG_PASS}" ]
then
  echo "$0: you need to specify PG_PASS='...'"
  exit 1
fi
./update_from_pr_diff.rb input.diff github_users.json cncf-config/email-map
