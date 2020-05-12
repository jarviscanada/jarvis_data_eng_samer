#!/bin/bash
# A Script to start/stop/create (if not already created) the psql container
# # script usage:  ./scripts/psql_docker.sh start|stop|create [db_username][db_password]

# Start docker_deamon, if not already running
systemctl status docker || systemctl start docker

container_name=jrvs-psql
cmd=$1

if [ "$cmd" = "create" ];
then
#  echo "in create"
  # list all docker containers and filter by name, if it already exists print usage and error
  if [ "$(docker container ls -a -f name=$container_name | wc -l)" == "2" ];
  then
    echo "container already created"
    exit 1
  fi

  # case not created
  #validate arguments
  if [ "$#" -ne 3 ];
  then
      echo "Illegal number of parameters"
      exit 1
  fi

  volume_name=pgdata

  # create volume
  if [ "$(docker volume ls -f name=${volume_name} | wc -l)" != "2" ];
  then
    docker volume create volume_name
    echo "volume created"
  fi
  # create container
  docker run  --name $container_name \
              -e POSTGRES_PASSWORD=$3 \
              -e POSTGRES_USER=$2 \
              -d -v ${volume_name}:/var/lib/postgresql/data \
              -p 5432:5432 postgres
  exit $?
fi


if [ "$cmd" = "start" ];
then
#  echo "in start"
  docker start $container_name
  exit $?
fi

if [ "$cmd" == "stop" ];
then
#  echo "in stop"
  docker stop $container_name
  exit $?
fi
# else
echo "Invalid command, usage start|stop|create [db_username][db_password]"
exit 1
