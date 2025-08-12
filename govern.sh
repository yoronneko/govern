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

VER='0.1.0'
BASE=$HOME/local

COL_RED='\033[31m'
COL_GRN='\033[32m'
COL_YEL='\033[33m'
COL_MAG='\033[35m'
COL_CYN='\033[36m'
COL_NOR='\033[0m'

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
        echo -e "${COL_RED}cannot start $conf${COL_NOR}"
    else
        echo -e "${COL_GRN}$conf started at pid $pid${COL_NOR}"
    fi
}

cmd_stop()
{
    local pid="$1"
    local conf="$2"
    kill "$pid"
    echo -e "${COL_MAG}$conf stopped (pid $pid)${COL_NOR}"
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
                echo -e "${COL_GRN}$conf already running at pid $pid${COL_NOR}"
            fi
            ;;
        stop)
            if [[ "$pid" == "" ]]; then
                echo -e "${COL_MAG}$conf already stopped${COL_NOR}"
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
                echo -e "${COL_MAG}$conf stopped${COL_NOR}"
            else
                echo -e "${COL_GRN}$conf running at pid $pid${COL_NOR}"
            fi
            ;;
        *)
            echo -e "${0##*/} [start|stop|restart|status]"
            exit 1
            ;;
    esac
}

show_name() 
{
    echo "Linux process governor ver.${VER} (${0##*/})"
}


# --- main ---

if [[ ! -d $BASE ]]; then
    show_name
    echo -e "${COL_RED}${0##*/}: directory $BASE is not found.${COL_NOR}"
    exit 1
fi
cd "$BASE" || exit

# glob conf files
# https://programwiz.org/2021/05/09/shellscript-in-bash-how-to-files-loop/
mapfile -t CONF < <(find . -maxdepth 1 -type f -name '*.conf.sh' -printf '%f\n' | sort)

# determine whether specific conf file is selected or not
# https://qiita.com/Hayao0819/items/0e04b39b0804a0d16020
if printf '%s\n' "${CONF[@]}" | grep -qx "$1"; then
    conf="$1"
    if [ -e "./$conf" ]; then
        unset MARK CMD ARGS
            . "./$conf"
        if [[ $? != 0 ]]; then
            echo -e "${COL_YEL}$conf: error occurred${COL_NOR}"
            exit 1
        elif [[ ! -v MARK || ! -v CMD || ! -v ARGS ]]; then
            echo -e "${COL_YEL}$conf: \$MARK, \$CMD or \$ARGS not defined${COL_NOR}"
            exit 1
        else
            do_cmd "$conf" "$MARK" "$CMD" "${ARGS[@]}" "$2"
        fi
    fi
    exit 0
fi

show_name
for conf in "${CONF[@]}"; do
    if [ -e "$conf" ]; then
        unset MARK CMD ARGS
            . ./"$conf"
        if [[ $? != 0 ]]; then
            echo -e "${COL_YEL}$conf: error occurred, skipping${COL_NOR}"
        elif [[ ! -v MARK || ! -v CMD || ! -v ARGS ]]; then
            echo -e "${COL_YEL}$conf: \$MARK, \$CMD or \$ARGS not defined, skipping${COL_NOR}"
        else
            do_cmd "$conf" "$MARK" "$CMD" "${ARGS[@]}" "$1"
        fi
    fi
done

# EOF
