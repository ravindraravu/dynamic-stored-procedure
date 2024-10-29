-- Monitor Page Splits
SELECT 
    OBJECT_NAME(i.object_id) AS TableName,
    i.name AS IndexName,
    p.page_id,
    p.index_id,
    p.partition_id,
    p.leaf_insert_count AS InsertCount,
    p.page_count AS PageCount,
    p.page_split_count AS PageSplitCount
FROM 
    sys.dm_db_index_usage_stats AS s
JOIN 
    sys.indexes AS i ON s.object_id = i.object_id AND s.index_id = i.index_id
JOIN 
    sys.dm_db_index_physical_stats(DB_ID(), i.object_id, i.index_id, NULL, 'DETAILED') AS p ON i.object_id = p.object_id
WHERE 
    OBJECT_NAME(i.object_id) = 'YourTableName';


-- Use Extended Events
CREATE EVENT SESSION [PageSplitsMonitoring] ON SERVER 
ADD EVENT sqlserver.sql_statement_completed(
    ACTION(sqlserver.sql_text, sqlserver.database_id)
    WHERE (sqlserver.database_id = DB_ID('YourDatabaseName')))
ADD TARGET package0.event_file(SET filename = 'C:\YourPath\PageSplitsMonitoring.xel')
WITH (MAX_MEMORY=4096 KB, EVENT_RETENTION_MODE=ALLOW_SINGLE_EVENT_LOSS, MAX_DISPATCH_LATENCY=30 SECONDS, MAX_EVENT_SIZE=0 KB, MEMORY_PARTITION_MODE=NONE, TRACK_CAUSALITY=OFF, STARTUP_STATE=OFF);
GO

ALTER EVENT SESSION [PageSplitsMonitoring] ON SERVER STATE = START;

-- Monitor Wait Statistics
SELECT 
    wait_type,
    wait_time_ms / 1000.0 AS WaitTimeSec,
    waiting_tasks_count AS WaitCount
FROM 
    sys.dm_os_wait_stats
WHERE 
    wait_type IN ('PAGEIOLATCH_SH', 'PAGEIOLATCH_EX', 'LCK_M_X', 'LCK_M_S')
ORDER BY 
    WaitTimeSec DESC;

-- Check Index Fragmentation
SELECT 
    OBJECT_NAME(object_id) AS TableName,
    index_id,
    index_depth,
    index_leaf_insert_count AS LeafInsertCount,
    page_count,
    avg_fragmentation_in_percent
FROM 
    sys.dm_db_index_physical_stats(DB_ID(), OBJECT_ID('YourTableName'), NULL, NULL, 'LIMITED')
WHERE 
    index_id = 1;  -- Assuming clustered index has index_id = 1
