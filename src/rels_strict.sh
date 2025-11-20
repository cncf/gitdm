#!/bin/sh
GITDM_HOME=${GITDM_HOME:-`cd "$(dirname "$0")/.." && pwd`}
out() { mv output_strict_* "$GITDM_HOME/kubernetes/$1"; }

./run_for_rels_strict.sh v1.0.0 v1.1.0
out v1.0.0-v1.1.0
./run_for_rels_strict.sh v1.1.0 v1.2.0
out v1.1.0-v1.2.0
./run_for_rels_strict.sh v1.2.0 v1.3.0
out v1.2.0-v1.3.0
./run_for_rels_strict.sh v1.3.0 v1.4.0
out v1.3.0-v1.4.0
./run_for_rels_strict.sh v1.4.0 v1.5.0
out v1.4.0-v1.5.0
./run_for_rels_strict.sh v1.5.0 v1.6.0
out v1.5.0-v1.6.0
./run_for_rels_strict.sh v1.6.0 v1.7.0
out v1.6.0-v1.7.0
