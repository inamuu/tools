#!/bin/bash

if [ -z "$1" ];then
  MESSAGE='Command Finished⭐'
else
  MESSAGE=$1
fi

osascript -e "display notification \"${MESSAGE}\" \
              with title \"Simple Notify\" \
              sound name \"Blow\""

