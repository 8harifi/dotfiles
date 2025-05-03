#!/bin/bash

while true; do
    STATUS_FILE=/tmp/is_safe

    if [ -f "$STATUS_FILE" ]; then
        STATUS=$(<"$STATUS_FILE")
        STATUS=$(echo "$STATUS" | tr '[:upper:]' '[:lower:]')  # make it lowercase, for good measure

        if [ "$STATUS" == "true" ]; then
        feh --randomize --bg-fill ~/wallpapers2 & 
        else
        feh --randomize --bg-fill ~/wallpapers & 
        fi
    else
        feh --randomize --bg-fill ~/wallpapers & 
    fi

    sleep 600
done

