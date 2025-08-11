#!/bin/bash
#
# govern.sh
#  Linux process governor: a simple shell script to manage multiple processes
#
# Copyright (c) 2023 Satoshi Takahashi, all rights reserved.
#
# Released under BSD 2-clause license.
#
# After placing configuration files in ~/local/ directory, we can manage
# processes by typing following commands:
#
#   govern.sh start:
#       start all processes
#   govern.sh stop:
#       stop  all processes
#   govern.sh restart:
#       restart  all processes
#   govern.sh status, or govern.sh:
#       show status  of all processes
#   govern.sh sample.conf.sh start:
#       start a process described in the configration ~/local/sample.conf.sh
#   govern.sh sample.conf.sh stop:
#       stop the process related to sample.conf.sh
#   govern.sh sample.conf.sh restart:
#       restart the process related to sample.conf.sh
#   govern.sh sample.conf.sh status, or govern.sh sample.conf.sh:
#       show the process status related to sample.conf.sh

BASE=$HOME/local
if [[ ! -d $BASE ]]; then
    echo "$BASE directory is not found."
    exit 1
fi
cd "$BASE" || exit

cmd_start()
{
    local conf="$1"
    local MARK="$2"
    local CMD="$3"
    shift 3
    local -a ARGS=("$@")
    "$CMD" "${ARGS[@]}" > /dev/null 2>&1 < /dev/null &
    # cannot obtain status code for background process directly as
    # if [ $? != 0 ]; then echo "${0##*/}: cannot start"; exit 1; fi
    sleep 0.1
    pid=$(get_pid "$MARK")
    if [[ $pid == "" ]]; then
        echo "cannot start $conf"
    else
        echo "$conf started at pid $pid"
    fi
}

cmd_stop()
{
    local pid="$1"
    local conf="$2"
    kill "$pid"
    echo "$conf stopped (pid $pid)"
}

get_pid()
{
    local MARK="$1"
    ps -axw | grep "$MARK" | grep -v grep | \
        (read pid args_to_discard; echo "$pid")
}

do_cmd()
{
    local conf=$1
    local MARK=$2
    local CMD=$3
    shift 3
    local ACTION="${!#}"
    local -a ARGS=("${@:1:$#-1}")
    pid=$(get_pid "$MARK")
    case "$ACTION" in
        start)
            if [[ "$pid" == "" ]]; then
                cmd_start "$conf" "$MARK" "$CMD" "${ARGS[@]}"
            else
                echo "$conf already running at pid $pid"
            fi
            ;;
        stop)
            if [[ "$pid" == "" ]]; then
                echo "$conf already stopped"
            else
                cmd_stop "$pid" "$conf"
            fi
            ;;
        restart)
            if [[ "$pid" != "" ]]; then
                cmd_stop "$pid" "$conf"
                sleep 0.5
            fi
            cmd_start "$conf" "$MARK" "$CMD" "${ARGS[@]}"
            ;;
        "" | status)
            if [[ "$pid" == "" ]]; then
                echo "$conf stopped"
            else
                echo "$conf running at pid $pid"
            fi
            ;;
        *)
            echo "${0##*/} [start|stop|restart|status]"
            exit 1
            ;;
    esac
}

# --- main ---

# glob conf files
# https://programwiz.org/2021/05/09/shellscript-in-bash-how-to-files-loop/
mapfile -t CONF < <(find . -maxdepth 1 -type f -name '*.conf.sh' -printf '%f\n' | sort)

# determine whether specific conf file is selected or not
# https://qiita.com/Hayao0819/items/0e04b39b0804a0d16020
if printf '%s\n' "${CONF[@]}" | grep -qx "$1"; then
    conf="$1"
    if [ -e "./$conf" ]; then
        unset MARK CMD ARGS
            . ./"$conf"
        [[ $? != 0 ]] && exit 1
        if [[ ! -v MARK || ! -v CMD || ! -v ARGS ]]; then
            echo "${0##*/}: \$MARK, \$CMD or \$ARGS not defined in $conf."
            exit 1
        fi
        do_cmd "$conf" "$MARK" "$CMD" "${ARGS[@]}" "$2"
    fi
    exit 0
fi

for conf in "${CONF[@]}"; do
    if [ -e "$conf" ]; then
        unset MARK CMD ARGS
            . ./"$conf"
        [[ $? != 0 ]] && continue
        if [[ ! -v MARK || ! -v CMD || ! -v ARGS ]]; then
            echo "${0##*/}: \$MARK, \$CMD or \$ARGS not defined in $conf."
            exit 1
        fi
        do_cmd "$conf" "$MARK" "$CMD" "${ARGS[@]}" "$1"
    fi
done

# EOF
