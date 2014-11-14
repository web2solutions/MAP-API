#!/bin/sh

netstat -tulpn | grep :5000

kill $(cat /opt/MAP-API/apitestenv0_pid)
