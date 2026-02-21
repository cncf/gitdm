#!/bin/sh
WD=`pwd`
FN=$WD/git.log
F=$WD/repos/combined
F2=$WD/repos/combined_no_map
F3=$WD/repos/combined_with_map
GITDM_HOME=${GITDM_HOME:-`cd "$(dirname "$0")/.." && pwd`}
CNCFDM="$GITDM_HOME/src/cncfdm.py"
> $FN
for var in "$@"
do
  echo "Processing $var"
  cd "$var"
  git config merge.renameLimit 100000
  git config diff.renameLimit 100000
  git log --all --numstat -M >> $FN
  git config --unset diff.renameLimit
  git config --unset merge.renameLimit
  ls -l $FN
done
PWD=$WD
cd $PWD
cat $FN | "$CNCFDM" -r '^vendor/|/vendor/|^Godeps/' -R -n -b "$GITDM_HOME/src/" -t -z -d -D -U -u -h $F.html -o $F.txt -x $F.csv > $F.out
cat $FN | "$CNCFDM" -r '^vendor/|/vendor/|^Godeps/' -R -n -b "$GITDM_HOME/src/" -t -z -d -D -U -h $F2.html -o $F2.txt -x $F2.csv > $F2.out
cat $FN | "$CNCFDM" -r '^vendor/|/vendor/|^Godeps/' -R -n -b "$GITDM_HOME/src/" -t -z -d -D -U -m -h $F3.html -o $F3.txt -x $F3.csv > $F3.out
./commits_in_default_ranges.sh all_kubernetes $FN
#rm -f $FN
#xz -9 $FN
