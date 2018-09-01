#!/bin/bash

# CEC variables
CECDEV=/dev/ttyACM0
CECFIFO=/tmp/cec.fifo
CECCLIENT="/usr/bin/cec-client -d 8 -p 1 -o Codex -f $CECLOG $CECDEV"

# Additional scripts
ACTION='cecaction.sh'
STATE='dfevicestate.sh'

#OpenHab
OPENHAB='http://localhost:8080'

#Program to receive keystrokes
PROGRAM='Kodi'

#Logs
CECLOG=/tmp/cec.log

