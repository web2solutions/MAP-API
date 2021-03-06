#!/bin/sh

netstat -tulpn | grep :5000

kill $(cat /opt/MAP-API/apiprodenv0_pid)

cd /opt/MAP-API

start_server --port=5000 --pid-file=apiprodenv0_pid --status-file=apiprodenv0_status -- plackup -R /opt/MAP-API/lib/MAP -E production -s Starman  --workers=15 bin/app.pl
