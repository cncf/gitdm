#!/bin/sh
# Portable runner for all-time analysis of the main repo.
# Honors env vars:
#   GITDM_HOME - path to this repo (defaults to parent of this script)
#   K8S_REPO   - path to kubernetes repo (defaults to $HOME/dev/go/src/k8s.io/kubernetes)

PWD=`pwd`
FNP=$PWD/first_run_patch
FNN=$PWD/first_run_numstat
# Resolve repo roots
GITDM_HOME=${GITDM_HOME:-`cd "$(dirname "$0")/.." && pwd`}
K8S_REPO=${K8S_REPO:-$HOME/dev/go/src/k8s.io/kubernetes/}
CNCFDM="$GITDM_HOME/src/cncfdm.py"

cd "$K8S_REPO"
git config merge.renameLimit 100000
git config diff.renameLimit 100000
# git log --all -p -M | cncfdm.py -r '^vendor/|/vendor/|^Godeps/' -R -b ~/dev/gitdm/ > first_run.txt
# -m --> map unknowns to 'DomainName *' , -u map unknowns to '(Unknown)'
git log --all -p -M | "$CNCFDM" -r '^vendor/|/vendor/|^Godeps/' -R -b "$GITDM_HOME/src/" -t -z -d -D -U -u -h $FNP.html -o $FNP.txt -x $FNP.csv
git log --all --numstat -M | "$CNCFDM" -r '^vendor/|/vendor/|^Godeps/' -R -n -b "$GITDM_HOME/src/" -t -z -d -D -U -u -h $FNN.html -o $FNN.txt -x $FNN.csv > $FNN.out
git config --unset diff.renameLimit
git config --unset merge.renameLimit
cd $PWD

