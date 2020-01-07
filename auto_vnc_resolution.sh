#!/bin/bash

# Automatically change the resolution that adapts to your VNC client when connected,
# and recover the server resolution when disconnected.

SERVER_IP="" # Set the server IP manually if automatic acquisition fails.
SERVER_RESOLUTION="1920x1080"
CLIENT_RESOLUTION="1440x900"
FREQUENCY="1s"

function log() {
    DEBUG=0
    [ ${DEBUG} -eq 0 ] || echo $1
}

VNC_PORT="5900"
[ -n "${SERVER_IP}" ] || SERVER_IP=`ifconfig enp3s0 | grep inet | grep -v 127.0.0.1 | grep -v inet6 | awk '{print $2}' | tr -d "addr:"`
log "Server IP: ${SERVER_IP}"

while true ; do
    NOW_SCREEN=`xrandr --current | grep \* | sed 's/ *\([0-9]*x[0-9]*\).*/\1/g' | head -n1`
    log "Now screen: "${NOW_SCREEN}
    STATE=`netstat -na | grep "${SERVER_IP}:${VNC_PORT}[ ]" | grep ESTABLISHED`
    if [ -n "${STATE}" ] ; then
        NEW_SCREEN=${CLIENT_RESOLUTION}
    else
        NEW_SCREEN=${SERVER_RESOLUTION}
    fi
    log "New screen: "${NEW_SCREEN}
    if [ "${NEW_SCREEN}" != "${NOW_SCREEN}" ] ; then
        log "Switching..."
        if [ "${NEW_SCREEN}" == "${CLIENT_RESOLUTION}" ] ; then
            xrandr --output HDMI-1-1 --mode ${NEW_SCREEN} \
            --output HDMI-0 --same-as HDMI-1-1 --mode ${NEW_SCREEN}
        else
            xrandr --output HDMI-1-1 --primary --mode ${NEW_SCREEN} \
            --output HDMI-0 --right-of HDMI-1-1 --mode ${NEW_SCREEN}
        fi
    fi
    sleep ${FREQUENCY}
done