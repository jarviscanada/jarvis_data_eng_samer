# script collects server usage data and then insert the data into the psql database. 
# The script will be executed every minute using Linux crontab

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
diskinfo=`df -BM /`

hostname=$(hostname -f)
timestamp=$(date +%F\ %T)   #timestamp in `2019-11-26 14:40:19` format

#usage
memory_free=$(echo "$(vmstat -a -S M)" | awk 'FNR==3 {print $4}' | xargs)
cpu_idle=$(echo "$diskinfo" | awk 'FNR==2 {print 100-$5}' | xargs)
cpu_kernel=$(echo "$meminfo" | egrep "^KernelStack:" | awk '{print $2}' | xargs)
disk_io=$(echo "$(vmstat --unit M)" | awk 'FNR==3 {print $9}' | xargs)
disk_available=$(echo "$diskinfo" | awk 'FNR==2 {print substr($3, 1, length($3)-1)}'  | xargs)

#get id by hostname to update 
id_query="SELECT id FROM host_info WHERE hostname='$hostname'"

#execute query
export PGPASSWORD=$psql_pass
id=`psql -h $psql_host -p $psql_port -d $db_name -U $psql_user -t -c "$id_query"`
echo "$id"
# construct and execute main query
query="INSERT INTO host_usage
       (id, hostname, timestamp, memory_free, cpu_idle, cpu_kernel, disk_io, disk_available) 
       VALUES 
       ('$id', '"$hostname"', '"$timestamp"', $memory_free, $cpu_idle, $cpu_kernel, $disk_io, $disk_available);"

psql -h $psql_host -p $psql_port -d $db_name -U $psql_user -c "$query"

exit 0
