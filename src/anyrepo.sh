#!/bin/sh
PWD=`pwd`
FN=$PWD/repos/$2
GITDM_HOME=${GITDM_HOME:-`cd "$(dirname "$0")/.." && pwd`}
CNCFDM="$GITDM_HOME/src/cncfdm.py"
cd "$1"
echo "Processing repo $1 $2"
git config merge.renameLimit 100000
git config diff.renameLimit 100000
git log --all --numstat -M | "$CNCFDM" -r '^vendor/|/vendor/|^Godeps/' -R -n -b "$GITDM_HOME/src/" -t -z -d -D -U -u -h $FN.html -o $FN.txt -x $FN.csv > $FN.out
git config --unset diff.renameLimit
git config --unset merge.renameLimit
