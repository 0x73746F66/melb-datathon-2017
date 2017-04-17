#!/usr/bin/env bash
user=root
password=admin

result=$(mysql melbdatathon2017 -hmysql -u $user -p$password<<<"SELECT DISTINCT postcode FROM stores")
post_code_list=(`echo ${result}`)
delete=(postcode)
array=( "${post_code_list[@]/$delete}" )

for post_code in "${array[@]}"
do
    post_code=`echo "${post_code}" | tr -d '\r\n'`
    if echo $post_code | egrep -q '^[0-9]{4}+$'; then
        res=`curl -s "http://v0.postcodeapi.com.au/suburbs/${post_code}.json" -H 'Accept: application/json; indent=2'`
        name=`echo $res | jq -r '.[0].name'`
        lon=`echo $res | jq -r '.[0].longitude'`
        lat=`echo $res | jq -r '.[0].latitude'`
        echo "{
  \"name\": \"${name}\",
  \"location\": {
    \"lat\": ${lat},
    \"lon\": ${lon}
  }
}" > ./postcode/${post_code}.json
    fi
done
