# Simple Bash Script For Automatic Databases Backup.
#### Databases: elasticsearch and mongodb
#### All backups save in local system.
#### Can get snapshot specific index. 
#### Before execute .sh need to create elasticsearch snapshot repository.
#### All indices save as json format and extract specific index using jq
#### Logs save in selected path
# This is for study. You can study this script and create own script.
#### After modify the script, add to this cron.
## I tested this only in ubuntu 18, 20
#### Before run, give permission chmod a+x backup.sh
