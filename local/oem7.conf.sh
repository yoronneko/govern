# shellcheck shell=bash
# govern.sh configuration file (*.conf.sh) located in ~/local/
#
# Environment variables of CMD, ARGS, and MARK should be specified in 
# this configuration file.
#   CMD:  the command file path to execute
#   ARGS: the arguments required for the command (as an array)
#   MARK: the process feature that is uniquely determined with ps command

HOST=192.168.0.1
RPORT=3002       # OEM729 ICOM2 (OEM7 raw)
LPORT=2000
MSG="\
1005(1),\
1019,\
1020,\
1033(1),\
1041,\
1042,\
1044,\
1045,\
1046,\
1077(1),\
1087(1),\
1097(1),\
1117(1),\
1127(1),\
1137(1),\
1230\
"
POSITION="34.4401061 132.4147804 233.362"
ANTENNA="JAVGRANT_G5T NONE,,0"
RECEIVER="NOV OEM729,OM7MR0814RN0000,"

MARK="tcpcli://$HOST:$RPORT#nov"
CMD=$HOME/bin/str2str
ARGS=(-in "$MARK" \
    -out "tcpsvr://:$LPORT" \
    -msg "$MSG" \
    -p   $POSITION \
    -i   "$RECEIVER" \
    -a   "$ANTENNA")

#EOF
