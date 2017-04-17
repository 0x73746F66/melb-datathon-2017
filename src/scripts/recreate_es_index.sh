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

# elasticsearch server
host=$1
if [[ -z "$host" ]]; then
    echo -e "Enter host ${YELLOW}(localhost:9200)${END}:"
    read host
    if [[ -z "$host" ]]; then
        host="localhost:9200"
    fi
fi

# index mapping file
mapping=$2
if [[ -z "$mapping" ]]; then
    echo -e "Enter mapping json file ${YELLOW}(elasticsearch_mapping.json)${END}:"
    read mapping
    if [[ -z "$mapping" ]]; then
        mapping="./elasticsearch_mapping.json"
    fi
fi

if [ "$silent" = false ]; then
    echo -e "${RED}-------- PLEASE CONFIRM --------${END}"
    echo -e "host\t\t${BLUE}$host${END}"
    echo -e "mapping\t\t${BLUE}$mapping${END}"
    pause 'Press [Enter] key to continue... [CTRL+C] to quit'
fi

echo -e "[DELETE] ${CYAN}melbdatathon2017${END}"
curl -XDELETE http://$host/melbdatathon2017
echo -e ""
echo -e "[POST] ${CYAN}melbdatathon2017${END}"
curl -XPOST http://$host/melbdatathon2017 -d @$mapping
echo -e ""

echo -e "${GREEN}[DONE]${END}"
exit 0