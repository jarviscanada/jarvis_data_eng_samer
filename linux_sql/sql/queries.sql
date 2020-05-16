--Some queries for cluster management and as a future resource

--q1: Group hosts by CPU number and sort by their memory size in descending order (within each cpu_number group)
--using ROW_NUMBER window function approach
SELECT 
	cpu_number, 
	id AS host_id, 
	total_mem, 
	ROW_NUMBER () 
		OVER (
			PARTITION BY cpu_number 
			ORDER BY total_mem DESC
			) 
FROM 
	host_info;

--using GROUP BY approach
SELECT 
	cpu_number, 
	id AS host_id, 
	total_mem
FROM 
	host_info
GROUP BY
	cpu_number, 
	id, 
	total_mem
ORDER BY
	total_mem
DESC;
	
--q2: Average used memory in percentage over 5 mins interval for each host. (used memory = total memory - free memory).

--using nested sub queries, TO_TIMESTAMP, extract 'epoch' and GROUP BY approach
--https://gis.stackexchange.com/questions/57582/group-by-timestamp-interval-10-minutes-postgresql
--inline version to pase and execute: 
----SELECT host_usage_five.id AS host_id, host_info.hostname AS host_name, ROUND ( ( 1.0 - host_usage_five.avg_mem_free/(1.0*host_info.total_mem) )*100 , 2) AS avg_used_mem_percent, five_min_interval AS timestamp FROM  host_info, (SELECT id, ROUND( AVG( memory_free), 2) AS avg_mem_free, TO_TIMESTAMP ( FLOOR ( EXTRACT('epoch' FROM timestamp)/300 )*300) AS five_min_interval FROM host_usage GROUP BY five_min_interval, host_usage.id) AS host_usage_five  WHERE host_usage_five.id = host_info.id ORDER BY host_usage_five.five_min_interval;

SELECT 
	host_usage_five.id AS host_id,
	host_info.hostname AS host_name,
	ROUND( ( 1.0 - host_usage_five.avg_mem_free/(1.0*host_info.total_mem) )*100, 2) AS avg_used_mem_percent, 
	five_min_interval AS timestamp 
FROM  
	host_info, 
	(
		SELECT 
			id, 
			ROUND( AVG( memory_free), 2) AS avg_mem_free,
			TO_TIMESTAMP ( FLOOR ( EXTRACT('epoch' FROM timestamp)/300 )*300) AS five_min_interval
			FROM 
				host_usage 
			GROUP BY 
				five_min_interval, 
				host_usage.id
	) 
	AS host_usage_five  
	WHERE host_usage_five.id = host_info.id
	ORDER BY host_usage_five.five_min_interval;

--q3: Detect node failure. Find out when a node failed to write usage data to DB three times in a row.
-- to be implemented
