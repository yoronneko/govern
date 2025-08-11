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
#  $HOME/bin/str2str -in serial://ttyF9P -a "JAVGRANT_G5T NONE" -out tcpserver://:2001 -b 1
# ---

MARK="serial://ttyF9P:230400"
CMD=$HOME/bin/str2str
ARGS=(-in "$MARK" -a "JAVGRANT_G5T NONE" -out "tcpsvr://:2001" -b 1)

# EOF
