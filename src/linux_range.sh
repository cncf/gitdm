set -euo pipefail

if [ "$#" -ne 2 ]; then
  echo "Usage: $0 YYYY-MM-DD YYYY-MM-DD" >&2
  exit 2
fi

FROM="$1"
TO="$2"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
LINUX_DIR="/freebsd/data/dev/dev2/go/src/github.com/torvalds/linux"

PYTHON2="${PYTHON2:-python2}"

command -v "$PYTHON2" >/dev/null 2>&1 || {
  echo "ERROR: python2 not found. Install pyenv Python 2.7.18 and expose it as python2." >&2
  exit 1
}

[ -d "$LINUX_DIR/.git" ] || {
  echo "ERROR: Linux git repo not found: $LINUX_DIR" >&2
  exit 1
}

mkdir -p "$SCRIPT_DIR/linux_stats"

FN="$SCRIPT_DIR/linux_stats/range_${FROM}_${TO}"

echo "Using python: $(command -v "$PYTHON2")"
"$PYTHON2" --version
echo "Using git repo: $LINUX_DIR"
echo "Output prefix: $FN"

cd "$LINUX_DIR"

cleanup() {
  git config --unset diff.renameLimit 2>/dev/null || true
  git config --unset merge.renameLimit 2>/dev/null || true
}
trap cleanup EXIT

git config merge.renameLimit 100000
git config diff.renameLimit 100000

git log --all --numstat -M --since "$FROM" --until "$TO" |
  "$PYTHON2" "$SCRIPT_DIR/cncfdm.py" \
    -n \
    -b "$SCRIPT_DIR/" \
    -t \
    -z \
    -d \
    -D \
    -U \
    -u \
    -f "$FROM" \
    -e "$TO" \
    -h "$FN.html" \
    -o "$FN.txt" \
    -x "$FN.csv" \
    > "$FN.out"

echo "Wrote:"
ls -lh "$FN".*
