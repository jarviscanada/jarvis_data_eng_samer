# :microscope: Cluster Monitoring Agent :telescope:
## Introduction
- A **Linux Cluster**: is a connected array of Linux computers or nodes that work together and can be viewed and managed as a single system. Nodes are usually connected by fast LANs, with each node running its own instance of Linux. Nodes may be physical or virtual machines, and they may be separated geographically. Each node includes storage capacity, processing power and I/O bandwidth. Multiple redundant nodes of Linux servers may be connected as a cluster for high availability (HA) and Fault tolerance where each node is capable of failure detection and recovery.
[Linux Cluster Definition](https://susedefines.suse.com/definition/linux-cluster/)
- A **Cluster Monitoring Agent**: is an intelligent real-time application that observes the system resources and gathers data from each node of the cluster about hardware specifications and usage perfomance such as CPU utilization, Networking traffic, etc. The collected metrics are stored in a PostgreSQL database hosted locally on a designated node. It performs data analytics using the persisted data to assist in servers load balancing, failure detection and fast recovery, resource management and forecasting.

![Monitoring agent](./assets/monitor_agent.png "Monitoring Agent")
## Architecture and Design
- An elected **PSQL node** with a central **PSQL** database, running in a **Docker** container, recieves metrics collected from all nodes and stores **hardware specifications** in table `host_info` and **server usage** data in table `host_usage`.
- Each host runs two scripts: `host_info.sh` and `host_usage.sh` to collect metrics about this node, then persists it in the PSQL database.
- The `host_info` script is executed once upon initialization, assuming that hardware specifications are static.
- The `host_usage` script is scheduled by a Linux **crontab** job to be executed every minute.
- The PSQL node executes a bash script `psql_docker.sh` that creates, starts or stops the PostgreSQL server container.
- Another bash script `ddl.sql` on the PSQL node defines the database schema, and creates PostgreSQL database along with host_info and host_usage tables.
- Table **host_info** is defined with data columns: 
*id, hostname, cpu_number, cpu_architecture, cpu_model, cpu_mhz, L2_cache, timestamp*.
- Table **host_usage** is defined with data columns:
*timestamp, host_id, memory_free, cpu_idle, cpu_kernel, disk_io, disk_available*
## Usage

| BASH FILE | COMMAND |
| --------- | ------- |
| `psql_docker.sh` | psql_docker.sh start |
|                  | psql_docker.sh stop |
|                  | psql_docker.sh create [DB_USERNAME][DB_PASSWORD]
| `ddl.sql` | psql -h [HOSTNAME] -U [HOST_AGENT] -d  [DB_NAME] -f ddl.sql |
| `host_info.sh` | host_info.sh [PSQL_HOST] [PSQL_PORT] [DB_NAME] [PSQL_USER ] [PSQL_PASSWORD] |
| `host_usage.sh` | host_usage.sh  [PSQL_HOST] [PSQL_PORT] [DB_NAME] [PSQL_USER ] [PSQL_PASSWORD]|
| `queries.sql` | psql -h [HOSTNAME] -p [port number] -U [username] -c "queries.sql" |


### Steps
1. Provision a psql instance using docker
  - Create container with name *jrvs-psql*, db_name *postgres*, volume *pgdata*, db_username *centos* and db_password *password*by executing: 
`./psql_docker.sh create centos password`
  - Check docker was created and running: 
`docker ps -l`      or      `docker ps -f name=jrvs-psql`
  - Check volume was created: 
`docker volume ls`

2. Create tables *host_info* and *host_usage* in database *postgres*
  - Execute ddl.sql script on the host_agent database against the psql instance: 
`psql -h localhost -U centos -d postgres -f ddl.sql`

3. Connect to database *postgres* and check tables were created
  - Connect: 
`psql -h localhost -p 5432 -U centos -W postgres`
  - List tables: 
`\dt`

4. Collect host info and usage data
  - Execute host_info.sh to collect host hardware specification data and insert it in *host_info* table: 
`./host_info.sh localhost 5432 postgres centos password`
  - Execute host_usage.sh to collect server usage data and insert it in *host_usage* table: 
`./host_info.sh localhost 5432 postgres centos password`

5. Schedule execution of host_usage.sh every minute by crontab
  - Edit crontab: 
`crontab -e`
  - Add this line to crontab file:
`* * * * * /home/centos/dev/jarvis_data_eng_myname/linux_sql/scripts/host_usage.sh localhost 5432 postgres centos password`

6. Run some queries:
  - Execute queries.sql: 
`psql -h localhost -U centos -d postgres -f queries.sql`

## Improvements
1. Add more fields to the tables in the database.
2. Create more queries.
3. Run a script to Clean up old data.
