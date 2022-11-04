#!/bin/bash


BOOTNETID=111
NODENETID=12321
IP="extip:192.168.100.25"
HTTPPORT=12312
GETHPATH="./build/bin/geth"
HOMEPATH="home_geth"
HTTPAPI="admin,eth,debug,miner,net,txpool,personal,web3,clique"
GENESIS="geth_poa.json"

BOOT="${GETHPATH} --datadir ${HOMEPATH} --networkid ${BOOTNETID} --nat ${IP} --http --http.port ${HTTPPORT}"
NODE="${GETHPATH} --datadir ${HOMEPATH} --http --http.port ${HTTPPORT} --http.api ${HTTPAPI} --networkid ${NODENETID} --port ${HTTPPORT} --verbosity 3 --mine --allow-insecure-unlock --unlock 0 --password password"

generate_json()
{
    cat<<EOF
{
    "enode":$1
}
EOF
}



if [ "$1" == "attach" ] ; then
    ${GETHPATH} attach ${HOMEPATH}/geth.ipc
else
    PIDS=`pgrep geth`
    PID=`cat ${HOMEPATH}/pid.txt`
    if [ "$1" == "stop" ] ; then
        echo "> Stop geth pid:${PID}"
        kill -9 ${PID}
    elif [ "$1" == "init" ] ; then
        ${GETHPATH} init --datadir ${HOMEPATH} ${GENESIS}
    elif [[ "boot node" =~ "$1" ]] ; then
        RUNOPTION="boot node"
        ENODENAME="enode"
        if [[ "$PIDS" =~ ${PID} ]] ; then
            echo "geth is already running"
        else
            if [ "$1" == "boot" ] ; then
                ENODENAME="$1$ENODENAME"
                echo "> Start bootstrap"
                nohup ${BOOT} >> home_geth/geth.log 2>&1 &
            elif [ "$1" == "node" ] ; then
                echo "> Start membership node"
                BOOTENODE=`cat home_geth/bootenode.json | jq '.enode' | sed 's/\"//g'`
                echo "${NODE} --bootnodes "${BOOTENODE}""
                nohup ${NODE} --bootnodes "${BOOTENODE}" >> home_geth/geth.log 2>&1 &
            fi
            echo $! > home_geth/pid.txt
            echo "pid : $!"
            sleep 2
            ENODE=`${GETHPATH} attach --exec admin.nodeInfo.enr home_geth/geth.ipc`
            echo $(generate_json ${ENODE}) > home_geth/$ENODENAME.json
	    echo "enode : ${ENODE}"
        fi
    fi
fi
