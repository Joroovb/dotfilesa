#!/bin/sh
#source https://github.com/x70b1/polybar-scripts

if ! updates_pamac=$(pamac checkupdates | wc -l); then
    updates_pamac=0
fi

if [ "$updates_pamac" -gt 0 ]; then
    echo "$updates_pamac"
else
    echo "0"
fi
