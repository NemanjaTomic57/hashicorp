#!/usr/bin/env bash

BOX_PATH="$1"

if [ -z "$BOX_PATH" ]; then
  echo "Usage: $0 <box-path>"
  exit 1
fi

aws s3 cp "$BOX_PATH" s3://archives-761018874759/vagrant/
