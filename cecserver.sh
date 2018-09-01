#!/bin/bash

source "config.sh"

log(){
    echo "$(date +"%Y-%m-%d %T.%3N") [CEC] - $1" >> $CECLOG
}

stop(){
    declare -a TAILPIDS=(`ps aux | grep 'tailf /dev/null' | egrep -v grep | awk '{print $2}'`)
    declare -a CATPIDS=(`ps aux | grep 'cat $CECFIFO' | egrep -v grep | awk '{print $2}'`)
    if [ ${#TAILPIDS[@]} -gt 0 ]
        then
            for i in "${TAILPIDS[@]}"
            do
                kill $i
            done
    fi

    if [ ${#CATPIDS[@]} -gt 0 ]
        then
            for i in "${CATPIDS[@]}"
            do
                kill $i
            done
    fi

    killall -s 2 cec-client 2> $CECLOG
    rm $CECFIFO 2> $CECLOG
    echo "" > $CECLOG
}

case "${1}" in
    start|restart)
            log "Starting server.  Since only one server can run at a time, stopping first."
        stop
            log "Done stopping, now starting..."
            log "Setting up FIFOs..."
        mkfifo $CECFIFO
        chmod 666 $CECFIFO
        chmod 666 $CECLOG
            log "Open pipe for writing..."
        tail -f /dev/null > $CECFIFO &
            log "Opening pipe for reading and start cec-client..."
        cat $CECFIFO | $CECCLIENT | while read line
        do
            part=$(echo $line | awk -F">>|<<" '{print $2}' | cut -c 2-);
            case $line in
    
                *"15:90:00"*|*"51:90:00"*|*"50:72:01"*|*"50:90:00"*|*" on"*|*"5f:84:40:00:05"*) # CEC codes that indicate that the AVR is turned on
                    if [[ $($STATE avrstatus) != "ON" ]]; then 
                        $STATE avron
                        log "AVR is on ($part)";
                    fi
                    ;;
                
                *"15:90:01"*|*"5f:72:00"*|*"50:90:01"*|*"standby"*) # CEC codes that indicate that the AVR is turned off
                    if [[ $($STATE avrstatus) != "OFF" ]]; then 
                        $STATE avroff
                        log "AVR is off ($part)";
                    fi
                    ;;
                    
                *"01:90:00"*|*"10:90:00"*|*"0f:84:00:00:00"*) # CEC codes that indicate that the TV is turned on
                    if [[ $($STATE tvstatus) != "ON" ]]; then 
                        $STATE tvon
                        log "TV is on ($part)";
                    fi
                    ;;
                    
                *"01:90:01"*|*"10:90:01"*) # CEC codes that indicate that the TV is turned off
                    if [[ $($STATE tvstatus) != "OFF" ]]; then 
                        $STATE tvoff
                        log "TV is off ($part)";
                    fi
                    ;;
                    
                *"0f:a0:08:00:46:00:09:00:01"*)
                    $STATE tvoff
                    $STATE avroff #only if TV is set to turn off CEC devices
                    log "TV and AVR are off ($part)";
                    ;;

                *"01:44:0d"*)       $ACTION keypress "Escape";;   #Back
                *"01:44:00"*)       $ACTION keypress "Return";;   #Enter
                *"01:44:01"*)       $ACTION keypress "Up";; 	  #Up
                *"01:44:02"*)       $ACTION keypress "Down";; 	  #Down
                *"01:44:03"*)       $ACTION keypress "Left";; 	  #Left
                *"01:44:04"*)       $ACTION keypress "Right";; 	  #Right
                *"01:44:44"*)       $ACTION keypress "p";;		  #Play
                *"01:44:45"*)       $ACTION keypress "x";;		  #Stop
                *"01:44:46"*)       $ACTION keypress "space";;	  #Pause
                *"01:44:48"*)       $ACTION keypress "period";;	  #Skip backward
                *"01:44:49"*)       $ACTION keypress "comma";;	  #Skip forward
                *"01:44:51"*)       $ACTION keypress "t";;		  #Subtitles                  
            *)
            esac
        done
        log "Start up complete."
    ;;
    
    stop)
        stop
    ;;

    *)
        echo $"Usage: $0 {start|stop|restart}"
        exit 1
esac

exit 0