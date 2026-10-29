#!/usr/bin/bash

### VARIABLES
LOGDIR=/var/log/mysql


### FUNCTIONS
die() {
  echo "ERROR $*" >&2
  kill 0
  exit 99
}


get_audit_log_filenames() {
  ls -t -r "$LOGDIR"/server_audit.log*
}


### MAIN

for _fn in $(get_audit_log_filenames); do
  cat "$_fn"
done \
| awk -F',' '
  BEGIN {
    out_format="%-12s %-18s %-45s %s\n"
  }
  {
    k=$3 FS $4 FS $8
    last[k]=$1
  }
  END {
    printf out_format, "DB", "USER", "REMOTE_HOST", "LAST_SEEN"
    for (k in last) {
      split(k,a,FS)
      printf out_format, (a[3]==""?"-":a[3]), a[1], a[2], last[k]
    }
  }
' \
| (read -r h; echo "$h"; sort -k1,1 -k4,4 -k5,5)
