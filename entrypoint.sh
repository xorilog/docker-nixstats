#!/bin/bash

if [ ! -f /etc/nixstats/user ]
then
  echo "$NIXSTAT_USER" > /etc/nixstats/user
fi

if [ ! -f /etc/nixstats/serverid ]
then
  if [ -z ${SERVERID+x} ]
  then
    echo "$(ip addr | grep inet) $(hostname)"  | sha256sum | awk '{print $1}' > /etc/nixstats/serverid
  else
    echo "$SERVERID"| sha256sum | awk '{print $1}' > /etc/nixstats/serverid
  fi
fi

if [ ! -f /var/log/cron.log ]
then
  touch /var/log/cron.log
fi

#cron && tail -f /var/log/cron.log

while true; do echo "$(date ='%D-%T') - Gathering metrics"; bash /opt/nixstats/nixstats.sh & sleep 60; done
