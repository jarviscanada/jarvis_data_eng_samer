#!/bin/bash

# Collects host hardware specification data and then insert it in the psql instance. 
# executed only once, assuming hardware specifications are static.

# Usage: host_info.sh psql_host psql_port db_name psql_user psql_password

#Check CLI arguments count
if [ "$#" != "5" ]; 
then
   echo "Invalid number of arguments"
   echo "Use format: host_info.sh psql_host psql_port db_name psql_user psql_password"
   exit 1
fi
# Assign CLI args
psql_host=$1
psql_port=$2
db_name=$3
psql_user=$4
psql_pass=$5

# Collect hardware specification data and assign it to reusable vars
lscpu_out=`lscpu`
meminfo=`cat /proc/meminfo`

#hardware specifications
hostname=$(hostname -f)
cpu_number=$(echo "$lscpu_out" | egrep "^CPU\(s\):" | awk '{print $2}' | xargs)
cpu_architecture=$(echo "$lscpu_out" | egrep "^Architecture:" | awk '{print $2}' | xargs)
cpu_model=$(echo "$lscpu_out" | egrep "^Model name:" | cut -d" " -f3- | xargs)
cpu_mhz=$(echo "$lscpu_out" | egrep "^CPU MHz:" | awk '{print $3}' | xargs)
l2_cache=$(echo "$lscpu_out" | egrep "^L2 cache:" | awk '{print substr($3, 1, length($3)-1)}' | xargs)
total_mem=$(echo "$meminfo" | egrep "^MemTotal:" | awk '{print $2}' | xargs)
timestamp=$(date +%F\ %T)   #timestamp in `2019-11-26 14:40:19` format

#query statement
query="INSERT INTO host_info 
(hostname, cpu_number, cpu_architecture, cpu_model, cpu_mhz, l2_cache, total_mem, timestamp) VALUES 
('"$hostname"', $cpu_number, '"$cpu_architecture"', '$cpu_model', $cpu_mhz, $l2_cache, $total_mem, '$timestamp');"

#execute query
export PGPASSWORD=$psql_pass
psql -h $psql_host -p $psql_port -d $db_name -U $psql_user -c "$query"

exit 0
