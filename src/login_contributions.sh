#!/bin/bash
# TESTSRV=1
# ADB=allcdf or ADB=allprj
if [ -z "${ADB}" ]
then
  export ADB=allprj
fi
echo "Using DB: ${ADB}"
if [ ! -z "${TESTSRV}" ]
then
  kubectl exec -n devstats-test devstats-postgres-0 -c devstats-postgres -- psql "${ADB}" -P pager=off --csv -c "with user_events as (select dup_actor_login as login, event_id from gha_commits where dup_actor_login is not null and dup_actor_login <> '' union all select dup_author_login as login, event_id from gha_commits where dup_author_login is not null and dup_author_login <> '' union all select dup_committer_login as login, event_id from gha_commits where dup_committer_login is not null and dup_committer_login <> '' union all select actor_login as login, event_id from gha_commits_roles where actor_login is not null and actor_login <> '' union all select dup_actor_login as login, id as event_id from gha_events where dup_actor_login is not null and dup_actor_login <> '' and type in ('PushEvent', 'PullRequestEvent', 'IssuesEvent', 'PullRequestReviewEvent', 'CommitCommentEvent', 'IssueCommentEvent', 'PullRequestReviewCommentEvent' )) select login, count(distinct event_id) as cnt from user_events group by 1 order by 2 desc" > login_contributions.csv
else
  kubectl exec -n devstats-prod devstats-postgres-0 -c devstats-postgres -- psql "${ADB}" -P pager=off --csv -c "with user_events as (select dup_actor_login as login, event_id from gha_commits where dup_actor_login is not null and dup_actor_login <> '' union all select dup_author_login as login, event_id from gha_commits where dup_author_login is not null and dup_author_login <> '' union all select dup_committer_login as login, event_id from gha_commits where dup_committer_login is not null and dup_committer_login <> '' union all select actor_login as login, event_id from gha_commits_roles where actor_login is not null and actor_login <> '' union all select dup_actor_login as login, id as event_id from gha_events where dup_actor_login is not null and dup_actor_login <> '' and type in ('PushEvent', 'PullRequestEvent', 'IssuesEvent', 'PullRequestReviewEvent', 'CommitCommentEvent', 'IssueCommentEvent', 'PullRequestReviewCommentEvent' )) select login, count(distinct event_id) as cnt from user_events group by 1 order by 2 desc" > login_contributions.csv
fi
./check_shas login_contributions.csv
echo -n "Proceed (y/n)? "
read ans
if [ ! "${ans}" = "y" ]
then
  echo "Fix forbiden SHAs and then run './update_login_contributions.rb && FULL=1 ./post_manual_checks.sh && ./post_manual_updates.sh' manually"
  exit 1
fi
./update_login_contributions.rb && FULL=1 ./post_manual_checks.sh && ./post_manual_updates.sh
