GITDM_HOME=${GITDM_HOME:-`cd "$(dirname "$0")/.." && pwd`}
./run_with_map.sh
mv run_with_map_* "$GITDM_HOME/kubernetes/all_time/"
