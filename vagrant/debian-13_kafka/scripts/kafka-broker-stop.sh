#!/bin/bash

BROKER_ID="$1"

if [ -z "$BROKER_ID" ]; then
  echo "usage ./kafka-broker-stop.sh [BROKER-ID]"
  exit 1
fi

PIDS=$(ps ax | grep -i 'kafka\.Kafka' | grep java | grep "kafka${BROKER_ID}.
properties" | grep -v grep | awk '{print $1}')

if [ -z "$PIDS" ]; then
  echo "No kafka server to stop"
  exit 1
else
  kill -s TERM $PIDS
fi

