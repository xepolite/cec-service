#!/bin/bash

source "config.sh"

send_command(){
    echo $1 > $CECFIFO
}

keypress(){
    WINDOWID=$(xdotool search --name $PROGRAM)
	xdotool key --window "$WINDOWID" "$1"
}

log(){
    echo "$(date +"%Y-%m-%d %T.%3N") [ACTION] - $1" >> $CECLOG
}

case "${1}" in
    tvon)
        send_command "on 0"
        ;;
    
    tvoff)
        send_command "standby 0"
        ;;

    avron)
        send_command "on 5"
        send_command "pow 5"
        ;;

    avroff)
        send_command "standby 5"
        ;;

    activesrc)
        send_command "as"
        ;;

    powTV)
        send_command "pow 0"
       ;;

    powAVR)
       send_command "pow 5"
       ;;

    cec_volup)
       send_command "volup"
    ;;
    
    cec_voldown)
        send_command "voldown"
    ;;
       
    keypress)
        keypress "${2}"
        ;;
        
    *)
    exit 1
    ;;
esac

exit 0