#!/bin/bash

case "$1" in
  "init")
    echo "Initialization process..."
    bash script.sh init sign 0
    bash script.sh init sign 1
    bash script.sh init sign 2
    bash script.sh init sign 3
    bash script.sh init sign 4
    bash script.sh init sign 5
    bash script.sh init peer 0
    bash script.sh init peer 1
    bash script.sh init peer 2
    ;;
  "start")
    echo "Starting process..."
    bash script.sh start boot
    bash script.sh start sign 0
    bash script.sh start sign 1
    bash script.sh start sign 2
    bash script.sh start sign 3
    bash script.sh start sign 4
    bash script.sh start sign 5
    bash script.sh start peer 0
    bash script.sh start peer 1
    bash script.sh start peer 2
    ;;
  "stop")
    echo "Stop process..."
    bash script.sh stop boot
    bash script.sh stop sign 0
    bash script.sh stop sign 1
    bash script.sh stop sign 2
    bash script.sh stop sign 3
    bash script.sh stop sign 4
    bash script.sh stop sign 5
    bash script.sh stop peer 0
    bash script.sh stop peer 1
    bash script.sh stop peer 2
    ;;
  "rm")
    echo "Removing process..."
    rm -rf data_*/geth data_*/geth.log
    ;;
  *)
    echo "사용법: $0 {init|start|rm|stop}"
    exit 1
    ;;
esac

exit 0

