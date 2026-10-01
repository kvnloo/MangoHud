#!/usr/bin/env bash
set -euo pipefail

if (( $# < 2 )) || [[ "$1" != "--" ]]; then
  echo "usage: $0 -- <workload command...>" >&2
  exit 2
fi
shift

root="${LATENCY_RESULTS_DIR:-mangohud-observer-$(date +%Y%m%d-%H%M%S)}"
mkdir -p "$root"
root="$(realpath "$root")"

run_one() {
  local index="$1"
  local label="$2"
  local mode="$3"
  shift 3

  local dir="$root/${index}-${label}"
  mkdir -p "$dir"

  {
    echo "started_at=$(date --iso-8601=ns)"
    echo "label=$label"
    echo "mode=$mode"
    uname -a
    nvidia-smi 2>/dev/null || true
  } > "$dir/environment.txt"

  local -a envargs=()
  case "$mode" in
    off)
      envargs+=(MANGOHUD=0)
      ;;
    minimal)
      envargs+=(MANGOHUD=1)
      envargs+=(MANGOHUD_CONFIGFILE="$PWD/experiments/e2e-latency/configs/minimal.conf")
      ;;
    detailed)
      envargs+=(MANGOHUD=1)
      envargs+=(MANGOHUD_CONFIGFILE="$PWD/experiments/e2e-latency/configs/detailed.conf")
      ;;
  esac

  set +e
  env "${envargs[@]}" perf stat -x, \
    -e task-clock,cycles,instructions,context-switches,cpu-migrations \
    -o "$dir/perf.csv" -- "$@"
  status=$?
  set -e

  echo "exit_status=$status" >> "$dir/environment.txt"
  echo "ended_at=$(date --iso-8601=ns)" >> "$dir/environment.txt"
}

run_one 1 A off "$@"
run_one 2 B minimal "$@"
run_one 3 B minimal "$@"
run_one 4 A off "$@"

echo "results: $root"
