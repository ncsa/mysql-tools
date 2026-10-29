#!/usr/bin/bash

### VARIABLES
BASE=$( dirname "$0" )
HOST=''
CONF=''
FILES=()
SUDO=
MYSQL=/usr/local/bin/mysql


### FUNCTIONS
die() {
  echo "ERROR $*" >&2
  kill 0
  exit 99
}


get_host() {
  HOST="$1"
  [[ -z "$HOST" ]] && die 'Missing host'
}


get_files() {
  local _fn
  for _fn in "${@}"; do
    [[ -f "${_fn}" ]] || die "File not found '${_fn}'"
    FILES+=( "${_fn}" )
  done
  [[ ${#FILES[@]} -lt 1 ]] && die "Missing sql files for host: '$HOST'"
}


prep() {
  # check if will be running as sudo
  SUDOCONF=~/.my.cnf.${HOST}.sudo
  CONF=~/.my.cnf.${HOST}
  if [[ -f "${SUDOCONF}" ]] ; then
    SUDO=/usr/bin/sudo
  else
    [[ -f "${CONF}" ]] || die "config file not found '${CONF}'"
    rsync "${CONF}" ${HOST}:.my.cnf
  fi
}


run_sql() {
  fn="$1"
  cat "$fn" | ssh $HOST "${MYSQL}"
}


### MAIN
get_host "$1"
shift
get_files "${@}"

prep

for fn in "${FILES[@]}"; do
  set -x
  run_sql "$fn"
  set +x
  echo
done
