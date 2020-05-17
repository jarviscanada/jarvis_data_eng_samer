-- script that automates the database initialization.
-- Assuming host_agent db already exists,
-- It creates host_info, host_usage tables in host_agent db if tables not exist.

-- table to store hardware specifications
CREATE TABLE PUBLIC.host_info (
  id SERIAL NOT NULL UNIQUE, 
  hostname VARCHAR NOT NULL UNIQUE, 
  cpu_number integer NOT NULL, 
  cpu_architecture VARCHAR NOT NULL, 
  cpu_model VARCHAR NOT NULL, 
  cpu_mhz FLOAT NOT NULL, 
  l2_cache integer NOT NULL, 
  total_mem integer NOT NULL, 
  timestamp TIMESTAMP NOT NULL, 
  PRIMARY KEY (id, hostname)
);
-- table to resource usage data
CREATE TABLE PUBLIC.host_usage (
  timestamp TIMESTAMP NOT NULL,  
  host_id SERIAL NOT NULL, 
  hostname VARCHAR NOT NULL REFERENCES host_info(hostname), 
  memory_free integer NOT NULL, 
  cpu_idle integer NOT NULL,
  cpu_kernel integer NOT NULL, 
  disk_io integer NOT NULL,
  disk_available integer NOT NULL,
  PRIMARY KEY (host_id, timestamp), 
  FOREIGN KEY (host_id) REFERENCES host_info(id)
);

