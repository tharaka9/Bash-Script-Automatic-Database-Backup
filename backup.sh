#!/bin/bash

#get today date
today=$(date '+%Y-%m-%d')
#get today date time
datetime=$(date '+%Y-%m-%d %H:%M:%S')

if [ -e "/var/test/json_files/indexs_"`date +"%Y-%m-%d"`".json" ] || [ -e "mongodb_"`date +"%Y-%m-%d"`".gz" ]; then 
    echo $datetime "indexs_"`date +"%Y-%m-%d"`".json" ' already exists' >> /var/test/logs/$today.log 
    echo $datetime "mongodb_"`date +"%Y-%m-%d"`".gz" ' already exists' >> /var/test/logs/$today.log   

    #extract index name which match with today
    get_index=$(jq -r '.[] | select(.cds | index('\"$today\"')) | .i' /var/test/json_files/indexs_"`date +"%Y-%m-%d"`".json) 
    #create backup with selected index
    curl -o "/var/test/json_files/snap_"`date +"%Y-%m-%d"`".json" -X PUT -H "Content-Type:application/json" "http://localhost:9200/_snapshot/backup/$get_index"_snapshot_"$today?wait_for_completion=true" -d '
    {
        "indices": '\"$get_index\"',
        "ignore_unavailable": true,
        "include_global_state": false
    }'

    #extract error and add to log
    get_msg=$(jq -r '.error .root_cause | .[] .reason' /var/test/json_files/snap_"`date +"%Y-%m-%d"`".json)
    echo $datetime   $get_msg >> /var/test/logs/$today.log
    exit 1
fi
    curl -o "/var/test/json_files/indexs_"`date +"%Y-%m-%d"`".json" "http://localhost:9200/_cat/indices/graylog*?h=i,cds&s=index&format=json"
    echo $datetime 'File Created' >> /var/test/logs/$today.log
    get_index=$(jq -r '.[] | select(.cds | index('\"$today\"')) | .i' indexs_"`date +"%Y-%m-%d"`".json)

    curl -o "/var/test/json_files/snap_"`date +"%Y-%m-%d"`".json" -X PUT -H "Content-Type:application/json" "http://localhost:9200/_snapshot/backup/$get_index"_snapshot_"$today?wait_for_completion=true" -d '
    {
        "indices": '\"$get_index\"',
        "ignore_unavailable": true,
        "include_global_state": false
    }'

    get_msg=$(jq -r '.snapshot .snapshot' /var/test/json_files/snap_"`date +"%Y-%m-%d"`".json)
    echo $datetime  $get_msg "Snapshot Created in /var/backup/" >> /var/test/logs/$today.log

    #mongodb backup
    mongodump=$(mongodump --gzip --archive=mongodb_"`date +"%Y-%m-%d"`".gz)
    echo $datetime "mongodb_"`date +"%Y-%m-%d"`".gz is Created"  >> /var/test/logs/$today.log
