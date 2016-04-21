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

cron && tail -f /var/log/cron.log