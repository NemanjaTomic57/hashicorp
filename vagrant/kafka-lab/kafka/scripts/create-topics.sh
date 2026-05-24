#!/bin/bash

set -o errexit
set -o pipefail
set -o nounset

kafka-topics.sh --bootstrap-server localhost:9092 \
  --topic git.projects \
  --create
