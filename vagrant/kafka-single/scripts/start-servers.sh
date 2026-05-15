#!/bin/bash

kafka-server-start.sh -daemon /home/vagrant/kafka/config/kafka1.properties
kafka-server-start.sh -daemon /home/vagrant/kafka/config/kafka2.properties
kafka-server-start.sh -daemon /home/vagrant/kafka/config/kafka3.properties
