#!/bin/bash

USERNAME="vagrant"
IP="192.168.56.10"

while true; do
  ssh $USERNAME@$IP 'cat ~/clip' | xsel --clipboard --input
  sleep 1
done &
SYNC_PID=$!

ssh $USERNAME@$IP

echo $SYNC_PID
kill $SYNC_PID
