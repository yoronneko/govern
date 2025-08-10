# shellcheck shell=bash
# govern.sh configuration file (*.conf.sh) located in ~/local/
#
# Environment variables of CMD, ARGS, and MARK should be specified in 
# this configuration file.
#   CMD:  the command file path to execute
#   ARGS: the arguments required for the command (as an array)
#   MARK: the process feature that is uniquely determind with ps command

# With this example configuration, govern.sh executes:
# ---
#  $HOME/exec/str2str -in serial://ttyF9P -a "JAVGRANT_G5T NONE" -out tcpserver://:2001 -b 1
# ---

LPORT=2001
DEV=ttyF9P

if [ ! -e /dev/$DEV ]; then echo "$0: no /dev/$DEV"; exit 1; fi
MARK="serial://$DEV:230400"
CMD=$HOME/exec/str2str
ARGS=(-in "$MARK" -a "JAVGRANT_G5T NONE" -out "tcpsvr://:$LPORT" -b 1)

# EOF
