# TempExecuteSQL Stored Procedure

This repository contains the `TempExecuteSQL` stored procedure that allows executing dynamic SQL queries with customizable parameters such as column list, `WHERE` clause, linked server name, database name, and table name.

## Features

- Execute dynamic SQL queries based on parameters passed to the stored procedure.
- Supports optional parameters for linked server and `WHERE` clause.
- Allows inserting the results of the executed query into a table.
  
## Procedure Parameters

- `@columns`: The list of columns to select in the query.
- `@whereClause`: Optional `WHERE` clause to filter the data (default is `NULL`).
- `@linkedServer`: Optional linked server name if querying from a remote database (default is `NULL`).
- `@database`: The name of the database to query from.
- `@table`: The name of the table to query.

## Usage

### 1. Executing the Stored Procedure and Inserting Results into an Existing Table

To execute the stored procedure and insert the query result into an existing table, use the following example.

#### Example

```sql
-- Assuming the destination table `DestinationTable` has the same structure as the query result
INSERT INTO DestinationTable (Column1, Column2, Column3)
EXEC TempExecuteSQL 
    @columns = 'Column1, Column2, Column3',
    @whereClause = 'Column1 = 10',
    @database = 'MyDatabase',
    @table = 'MyTable';
