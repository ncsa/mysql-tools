#!/usr/bin/bash

### VARIABLES
BASE=$( dirname "$0" )
HOST=mysql
FILES=()


### FUNCTIONS
die() {
  echo "ERROR $*" >&2
  kill 0
  exit 99
}


get_files() {
  local _fn
  for _fn in "${@}"; do
    [[ -f "${_fn}" ]] || die "File not found '${_fn}'"
    FILES+=( "${_fn}" )
  done
  [[ ${#FILES[@]} -lt 1 ]] && die "Missing sql files for host: '$HOST'"
}


run_sql() {
  fn="$1"
  set -x
  cat "$fn" | ssh -tt $HOST "~/do_mysql.sh"
}


### MAIN
get_files "${@}"

for fn in "${FILES[@]}"; do
  set -x
  run_sql "$fn"
  set +x
  echo
done
