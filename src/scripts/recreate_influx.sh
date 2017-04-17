#!/usr/bin/env bash
# ex30a.sh: "Colorized" version of ex30.sh.

# Note: this will physically delete entire index and re-create a new one, so data will be erased completely

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
END='\033[0m' # No Color
function pause(){
   read -p "$*"
}

silent=$3
if [[ -z "$silent" ]]; then
    silent=false
fi

host=$1
if [[ -z "$host" ]]; then
    echo -e "Enter host ${YELLOW}(localhost:8086)${END}:"
    read host
    if [[ -z "$host" ]]; then
        host="localhost:9200"
    fi
fi

database=$2
if [[ -z "$database" ]]; then
    echo -e "Enter database name ${YELLOW}(melbdatathon2017)${END}:"
    read database
    if [[ -z "$database" ]]; then
        database="melbdatathon2017"
    fi
fi

if [ "$silent" = false ]; then
    echo -e "${RED}-------- PLEASE CONFIRM --------${END}"
    echo -e "host\t\t${BLUE}$host${END}"
    echo -e "database\t${BLUE}$database${END}"
    pause 'Press [Enter] key to continue... [CTRL+C] to quit'
fi

echo -e "[DROP] ${CYAN}${database}${END}"
curl -XPOST -G http://${host}/query --data-urlencode "q=DROP DATABASE ${database}"
echo -e ""
echo -e "[CREATE] ${CYAN}${database}${END}"
curl -XPOST -G http://${host}/query --data-urlencode "q=CREATE DATABASE ${database}"
echo -e ""

echo -e "${GREEN}[DONE]${END}"
exit 0