GITDM_HOME=${GITDM_HOME:-`cd "$(dirname "$0")/.." && pwd`}
./run.sh
mv first_run_* "$GITDM_HOME/kubernetes/all_time/"
