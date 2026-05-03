#!/bin/bash

kafka-topics.sh \
	--create \
	--topic products.prices.changelog \
	--partitions 6 \
	--replication-factor 3 \
	--bootstrap-server 192.168.56.12:9092
