#!/bin/bash
#echo "Entered: $1"
if [ "$1" == "--productive" ]; then
	cp /etc/hosts.productive /etc/hosts
else
	cp /etc/hosts.clean /etc/hosts
fi
