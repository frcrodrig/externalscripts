#!/bin/bash

# $1 = "ss.com flats hand over"
# $2 = https://www.ss.com/lv/real-estate/flats/riga/all/hand_over
# $3 = /dev/shm

jobid=$(echo $2 | sed "s/\/$//" | sed "s/^.*\///g")
out=$3/zbx.ss.com.$jobid.json

cd /usr/lib/zabbix/externalscripts
./ss-com-property-discover.sh $2 > $out

jq . $out > /dev/null
/usr/bin/zabbix_sender -z 127.0.0.1 -s "$1" -k json.error -o $?

# escape the backslash
sed -i 's/\\/\\\\/g' $out

# escape the double quotes
sed -i 's|\"|\\\"|g' $out

# set destination (hostname and item) where this json should be delivered
sed -i "s|^|\"$1\" discover.ss.items\ \"|;s|$|\"|" $out

# send the json to server
zabbix_sender -z 127.0.0.1 -i $out