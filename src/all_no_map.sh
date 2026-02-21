GITDM_HOME=${GITDM_HOME:-`cd "$(dirname "$0")/.." && pwd`}
./run_no_map.sh
mv run_no_map_* "$GITDM_HOME/kubernetes/all_time/"
