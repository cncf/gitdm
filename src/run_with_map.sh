#!/bin/sh
PWD=`pwd`
FNP=$PWD/run_with_map_patch
FNN=$PWD/run_with_map_numstat
GITDM_HOME=${GITDM_HOME:-`cd "$(dirname "$0")/.." && pwd`}
K8S_REPO=${K8S_REPO:-$HOME/dev/go/src/k8s.io/kubernetes/}
CNCFDM="$GITDM_HOME/src/cncfdm.py"
cd "$K8S_REPO"
git config merge.renameLimit 100000
git config diff.renameLimit 100000
# -m --> map unknowns to 'DomainName *' , -u map unknowns to '(Unknown)'
git log --all -p -M | "$CNCFDM" -r '^vendor/|/vendor/|^Godeps/' -R -b "$GITDM_HOME/src/" -t -z -d -D -U -m -h $FNP.html -o $FNP.txt -x $FNP.csv
git log --all --numstat -M | "$CNCFDM" -r '^vendor/|/vendor/|^Godeps/' -R -n -b "$GITDM_HOME/src/" -t -z -d -D -U -m -h $FNN.html -o $FNN.txt -x $FNN.csv > $FNN.out
git config --unset diff.renameLimit
git config --unset merge.renameLimit
cd $PWD
