#!/bin/sh

DIR="$( cd "$( dirname "$0" )" && pwd )"

# run the monitor in the background
$DIR/nginx-reloader.sh &

# start the nginx in foreground
# use "exec" so that docker can monitor nginx
# and properly propogating signals to nginx
exec nginx -g "daemon off;"
