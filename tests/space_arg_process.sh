#!/bin/sh
# first argument is MARK, second is logfile
shift
logfile="$1"
shift
joined="$*"
printf '%s' "$joined" | tr -d "\"'" > "$logfile"
while true; do sleep 1; done
