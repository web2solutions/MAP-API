#!/bin/sh

cd /opt/MAP-API

start_server --port=5000 --pid-file=apitestenv0_pid --status-file=apitestenv0_status -- plackup -R /opt/MAP-API/lib/MAP -E deployment -s Twiggy  --workers=5 bin/app.pl
