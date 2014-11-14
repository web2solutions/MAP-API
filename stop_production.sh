#!/bin/sh

netstat -tulpn | grep :5000

kill $(cat /opt/MAP-API/apiprodenv0_pid)
