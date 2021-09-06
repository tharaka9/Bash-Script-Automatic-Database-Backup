#!/bin/bash

#get today date
today=$(date '+%Y-%m-%d')
#get today date time
datetime=$(date '+%Y-%m-%d %H:%M:%S')

#check if files exist
if [ -e "/var/test/json_files/indexs_"`date +"%Y-%m-%d"`".json" ] || [ -e "mongodb_"`date +"%Y-%m-%d"`".gz" ]; then 

    #extract index name which match with today
    get_index=$(jq -r '.[] | select(.cds | index('\"$today\"')) | .i' /var/test/json_files/indexs_"`date +"%Y-%m-%d"`".json) 
    #create backup with selected index
    curl -o "/var/test/json_files/snap_"`date +"%Y-%m-%d"`".json" -X PUT -H "Content-Type:application/json" "http://localhost:9200/_snapshot/backup/graylog_snapshot_"$today"?wait_for_completion=true" -d '
    {
        "indices": '\"$get_index\"',
        "ignore_unavailable": true,
        "include_global_state": false
    }'

    #extract error and add to log
    get_msg=$(jq -r '.error .root_cause | .[] .reason' /var/test/json_files/snap_"`date +"%Y-%m-%d"`".json)

     #Create logs
    echo $datetime "indexs_"`date +"%Y-%m-%d"`".json" ' already exists' >> /var/test/logs/$today.log 
    echo $datetime "mongodb_"`date +"%Y-%m-%d"`".gz" ' already exists' >> /var/test/logs/$today.log   
    echo $datetime   $get_msg >> /var/test/logs/$today.log

    exit 1

 #if files not exist   
fi
    #save all indexs as json
    curl -o "/var/test/json_files/indexs_"`date +"%Y-%m-%d"`".json" "http://localhost:9200/_cat/indices/graylog*?h=i,cds&s=index&format=json"
    
    #get current index from json
    get_index=$(jq -r '.[] | select(.cds | index('\"$today\"')) | .i' indexs_"`date +"%Y-%m-%d"`".json)
    
    #create backup with selected index
    curl -o "/var/test/json_files/snap_"`date +"%Y-%m-%d"`".json" -X PUT -H "Content-Type:application/json" "http://localhost:9200/_snapshot/backup/graylog_snapshot_"$today"?wait_for_completion=true" -d '
    {
        "indices": '\"$get_index\"',
        "ignore_unavailable": true,
        "include_global_state": false
    }'

    #get success message
    get_msg=$(jq -r '.snapshot .snapshot' /var/test/json_files/snap_"`date +"%Y-%m-%d"`".json)

    #mongodb backup
    mongodump=$(mongodump --gzip --archive=mongodb_"`date +"%Y-%m-%d"`".gz)

    #Create logs
    echo $datetime 'File Created' >> /var/test/logs/$today.log
    echo $datetime  $get_msg "Snapshot Created in /var/backup/" >> /var/test/logs/$today.log
    echo $datetime "mongodb_"`date +"%Y-%m-%d"`".gz is Created"  >> /var/test/logs/$today.log
