# CEC SERVICE

In short, I have a somewhat older AVR without any networking capabilities but still wanted to integrate the receiver into my Openhab setup. Luckily, the receiver is CEC capable and I had a pulse-eight CEC USB adapter laying around, whic can send and receive CEC commands from attached devices with the cec-client software. 
However, sending single commands through the software introduces a delay which kind of ruins the whole media experience. To circumvent this, Will Cooke (http://www.whizzy.org) published a script that keeps the cec software running and accepts input through a pipe/fifo, eliminating delays.

I have adapted the script to include integration with OpenHab and Kodi. Although Kodi has its own CEC-adapter support, only one device can use the USB adapter at a time. So using the Kodi built-in support would exclude OpenHab from sending/receiving signals. With these scripts you can do both and easily customize every button on your remote!
Been running the script for months without problems. 

## Explanation

The cecserver.sh file runs the cec-client software. The cec-client output with CEC traffic is then monitored for known CEC commands. When CEC output is recognised (e.g. remote button presses or CEC traffic related to device power states) any desired script can be run in response. In these scripts, STATE and ACTION commands are incorporated and can be issued by "$STATE/$ACTION command" if the config file is loaded. The config file contains details on the location of the CEC adapter, the Openhab server adress, the name of the program that should receive keystroke commands and the location of the other included scripts.

## Commands

STATE commands change or poll switches in OpenHab; 
"$STATE tvon" will flip the switch "tv_switch" in OpenHab to ON, while "$STATE tvoff" will turn it to OFF
"$STATE tvstatus" on the other hand will return the current state of the switch (ON/OFF)

ACTION commands can be used to control devices via CEC or send keystrokes to any program;
"$ACTION tvon" will turn the connected TV on via CEC and "$ACTION keypress left" will send the keystroke "left button" to the program defined in the config file (in the default case, Kodi)

## Dependencies
- libcec
- curl
- OpenHab (with REST api)
- kodi
- xdotool

## Assumptions
- all the files are stored in the same folder (or edit the reference to the config.sh location in each file)
- the user that runs cecserver.sh should have access to the cec-adapter (e.g. dialout group)
- if bi-directional communication is wanted between the scripts and OpenHab (e.g. OpenHab can issue cec commands) then the OpenHab user must have the necessary permissions as well (access/executable rights to the files and the cec-adapter)
- Kodi is installed and the builtin cec function is turned off (because only one program can have access to the cec-adapter)
- cecserver.sh can be run as a service, to automatically run after a reboot.