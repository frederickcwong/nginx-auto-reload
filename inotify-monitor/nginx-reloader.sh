#!/bin/sh

while :
do
    # recursively monitor new certificate creation events
    echo "Monitoring new certificate creation in ${NGINX_PATH_TO_MONITOR}"
    inotifywait -r -e create $NGINX_PATH_TO_MONITOR
    echo "Detecting new certificate creation, reloading nginx in 30 seconds"
    sleep 30s
    nginx -s reload
done
