#!/bin/bash

#install sysbench

sudo apt-get update > /dev/null
sudo apt-get install -y tuned
sudo tuned-adm profile virtual-guest
sudo apt-get -y install bc sysbench > /dev/null
