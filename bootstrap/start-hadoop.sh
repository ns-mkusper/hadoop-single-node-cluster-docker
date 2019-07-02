#!/usr/bin/env bash

source /root/.bashrc

hdfs namenode -format -nonInteractive
bash /usr/local/hadoop/sbin/start-dfs.sh
