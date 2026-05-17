#!/bin/bash

KAFKA_CLUSTER_ID="$(kafka-storage.sh random-uuid)"
kafka-storage.sh format --standalone -t $KAFKA_CLUSTER_ID -c "/home/vagrant/kafka/kafka_2.13-4.2.0/config/server.properties"
kafka-server-start.sh -daemon "/home/vagrant/kafka/kafka_2.13-4.2.0/config/server.properties"
