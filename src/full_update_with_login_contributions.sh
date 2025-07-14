#!/bin/bash
FULL=1 ./post_manual_checks.sh && ./post_manual_updates.sh && ./update_login_contributions.rb && JSON=affiliated.json ./update_login_contributions.rb && cp affiliated.json ../../devstats/github_users.json
