#!/bin/bash

source "config.sh"

function send(){
    curl -s --header "Content-Type: text/plain" --request PUT --data "${2}" $OPENHAB/rest/items/${1}/state
}

function poll(){
    curl -s $OPENHAB/rest/items/{$1}/state
}

case "${1}" in
    tvon)
        send tv_switch ON
    ;;
    
    tvoff)
		send tv_switch OFF
    ;;

    avron)
		send avr_switch ON
    ;;

    avroff)
		send avr_switch OFF
    ;;
   
    tvstatus)
		poll tv_switch
    ;;
    
    avrstatus)
		poll avr_switch
    ;;      

    *)
        echo $"Usage: $0 {tvon|tvoff|avron|avroff|tvstatus|avrstatus}"
        exit 1
    ;;
esac


