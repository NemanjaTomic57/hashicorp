#!/bin/bash

kafka-topics.sh \
	--create \
	--topic products.prices.changelog \
	--partitions 1 \
	--replication-factor 1 \
	--bootstrap-server localhost:9092
