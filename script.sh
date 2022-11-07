#!/bin/bash
help()
{
    cat << HELP
Usage:
    bash script.sh <command> <node> <number>

The commands are:
        init        init geth
        attach      attach to geth js console
        start       start geth
        status      status geth
        stop        stop geth
        log         cat geth log
        account     make newaccount
        
The nodes are:
        boot        bootstrap node
        peer        peer node

The number is:
        1 ~         (default : 0)
HELP
}

# Check the string list($1) include a str parameter($2)
# use : check_list $strArray $str
check_list()
{
    check=0
    for member in $1
    do

        [ "${member}" == "$2" ] && check=1 && break
    done
    echo $check
}

# Check the command line is correct 
check_command()
{
    return1=$(check_list "attach init start stop account log status" "$command")
    return2=$(check_list "BOOT PEER" "$mode")
    if [ -n "${index//[0-9]/}" ] || [ $return1 -eq 0 ] || [ $return2 -eq 0 ] ; then
        echo "invalid command"
        help
        exit 100
    fi
}

# Check the folder exists and create it if it does not exist
# use : check_directory $path
check_directory()
{
    if [ ! -d $1 ]; then
        mkdir $1
    fi
}

# Check the file exists and create it if it does not exist
# use : check_file $path
check_file()
{
    if [ ! -e $1 ];then
        echo "" > $1
    fi
}

# Create a json file in the format { "enode" : argument }
# use : generate_json $str
generate_json()
{
    cat<<EOF
{
    "enode":$1
}
EOF
}

# Showing help
[ -z "$1" ] || [ "$1" == help ] && help && exit 0

# init commandLine argument
command=$1
mode=`echo $2 | tr [a-z] [A-Z]`
index=$3
if [ -z "$index" ] ; then
    index=0 # default value
fi
# Call check_command function
check_command

# Init values
GETHPATH=`cat config.json | jq '.BUILDPATH' | sed 's/\"//g'`
GENESIS=`cat config.json | jq '.GENESIS' | sed 's/\"//g'`
NETWORKID=`cat config.json | jq '.'$mode'['$index'].NETWORKID' | sed 's/\"//g'`
PORT=`cat config.json | jq '.'$mode'['$index'].PORT' | sed 's/\"//g'`
AUTHPORT=`cat config.json | jq '.'$mode'['$index'].AUTHPORT' | sed 's/\"//g'`

DATAPATH=`cat config.json | jq '.'$mode'['$index'].DATAPATH' | sed 's/\"//g'`
HTTPPORT=`cat config.json | jq '.'$mode'['$index'].HTTPPORT' | sed 's/\"//g'`
HTTPAPI=`cat config.json | jq '.'$mode'['$index'].HTTPAPI' | sed 's/\"//g'`
HTTPADDR=`cat config.json | jq '.'$mode'['$index'].HTTPADDR' | sed 's/\"//g'`
PWDPATH=`cat config.json | jq '.'$mode'['$index'].PWDPATH' | sed 's/\"//g'`
BOOTENODEPATH=`cat config.json | jq '.'$mode'['$index'].BOOTENODEPATH' | sed 's/\"//g'`
DEFAULTOPTION=`cat config.json | jq '.'$mode'['$index'].DEFAULTOPTION' | sed 's/\"//g'`
if [ -n $BOOTENODEPATH ] ; then 
    BOOTENODEPATH="./" # default value
fi

# Get geth's pid list
PIDS=`pgrep geth`

# Command processing
case $1 in
    "init")       
        ${GETHPATH} init --datadir ${DATAPATH} ${GENESIS} ;;
    "account") 
        ${NEWACCOUNT} ;;
    "attach")     
        ${GETHPATH} attach $DATAPATH/geth.ipc ;;
    "log")        
        tail -F ${DATAPATH}/geth.log ;;
    "stop")
        check_file ${DATAPATH}/pid.txt
        check_directory $DATAPATH
        PID=`cat ${DATAPATH}/pid.txt`
        echo $DATAPATH
        echo "> Stop geth pid:${PID}"
        kill -9 ${PID}
        rm -rf ${DATAPATH}/pid.txt
        ;;
    "status")
        if [[ "$PIDS" =~ ${PID} ]] ; then
            echo "$2$index is running"
        fi
        ;;
    "start")
        check_file ${DATAPATH}/pid.txt
        check_directory $DATAPATH
        PID=`cat ${DATAPATH}/pid.txt`
        if [[ "$PIDS" =~ ${PID} ]] ; then
            echo "$2$index is already running"
            exit 100
        fi
        ENODENAME="enode"
        case $2 in
            "boot")
                echo "> Start bootstrap"
                BOOT="${GETHPATH} --datadir ${DATAPATH} --networkid ${NETWORKID} --nat "extip:${HTTPADDR}" --port ${PORT} --authrpc.port ${AUTHPORT}"
                ENODENAME="boot$ENODENAME" 
                echo ">> $BOOT"
                nohup ${BOOT} >> ${DATAPATH}/geth.log 2>&1 & ;;
            "peer")
                echo "> Start membership node"
                BOOTENODE=`cat ${BOOTENODEPATH}/bootenode.json | jq '.enode' | sed 's/\"//g'`
                PEER="${GETHPATH} --datadir ${DATAPATH} --http --http.port ${HTTPPORT} --http.api ${HTTPAPI} --http.addr ${HTTPADDR} --networkid ${NETWORKID} ${DEFAULTOPTION} --password ${PWDPATH} --bootnodes ${BOOTENODE} --port ${PORT} --authrpc.port ${AUTHPORT}"
                echo ">> $PEER"
                nohup ${PEER} >> ${DATAPATH}/geth.log 2>&1 & ;;
        esac 
        echo $! > ${DATAPATH}/pid.txt
        echo "pid : $!"
        sleep 2
        ENODE=`${GETHPATH} attach --exec admin.nodeInfo.enr ${DATAPATH}/geth.ipc`
        echo $(generate_json ${ENODE}) > $ENODENAME.json
        echo "enode : ${ENODE}" ;;
esac
