#!/bin/sh
# Portable per-release runner between two git tags.
# Honors env vars:
#   GITDM_HOME - path to this repo (defaults to parent of this script)
#   K8S_REPO   - path to kubernetes repo (defaults to $HOME/dev/go/src/k8s.io/kubernetes)

if [ $# -lt 2 ]; then
  echo "$0 tag1 tag2"
  echo "Use \"git tag -l\" to see available tags"
  exit 1
fi
PWD=`pwd`
FNP=$PWD/output_patch
FNN=$PWD/output_numstat
GITDM_HOME=${GITDM_HOME:-`cd "$(dirname "$0")/.." && pwd`}
K8S_REPO=${K8S_REPO:-$HOME/dev/go/src/k8s.io/kubernetes/}
CNCFDM="$GITDM_HOME/src/cncfdm.py"
cd "$K8S_REPO"
git config merge.renameLimit 100000
git config diff.renameLimit 100000
# -m --> map unknowns to 'DomainName *' , -u map unknowns to '(Unknown)'
git log --all -p -M $1..$2 | "$CNCFDM" -r '^vendor/|/vendor/|^Godeps/' -R -b "$GITDM_HOME/src/" -t -z -d -D -U -m -h $FNP.html -o $FNP.txt -x $FNP.csv
git log --all --numstat -M $1..$2 | "$CNCFDM" -r '^vendor/|/vendor/|^Godeps/' -R -n -b "$GITDM_HOME/src/" -t -z -d -D -U -m -h $FNN.html -o $FNN.txt -x $FNN.csv > $FNN.out
git config --unset diff.renameLimit
git config --unset merge.renameLimit
ls -l $FNP* $FNN*
cd $PWD
