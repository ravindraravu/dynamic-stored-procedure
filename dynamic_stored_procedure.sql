CREATE PROCEDURE TempExecuteSQL
    @columns NVARCHAR(MAX),        -- List of columns to select
    @whereClause NVARCHAR(MAX) = NULL,  -- WHERE clause (optional)
    @linkedServer NVARCHAR(128) = NULL, -- Linked server name (optional)
    @database NVARCHAR(128),       -- Database name
    @table NVARCHAR(128)           -- Table name
AS
BEGIN
    DECLARE @sqlQuery NVARCHAR(MAX);

    -- Build the base query
    SET @sqlQuery = 'SELECT ' + @columns + ' FROM ';

    -- If linked server is provided, add it to the query
    IF @linkedServer IS NOT NULL
    BEGIN
        SET @sqlQuery = @sqlQuery + '[' + @linkedServer + '].';
    END

    -- Append the database and table names
    SET @sqlQuery = @sqlQuery + '[' + @database + '].dbo.[' + @table + ']';

    -- If a WHERE clause is provided, append it to the query
    IF @whereClause IS NOT NULL
    BEGIN
        SET @sqlQuery = @sqlQuery + ' WHERE ' + @whereClause;
    END

    -- Debugging: Optionally print the SQL query for verification
    PRINT @sqlQuery;

    -- Use TRY...CATCH for error handling
    BEGIN TRY
        -- Execute the dynamic SQL query
        EXEC sp_executesql @sqlQuery;
    END TRY
    BEGIN CATCH
        -- Handle any errors
        DECLARE @ErrorMessage NVARCHAR(4000);
        DECLARE @ErrorSeverity INT;
        DECLARE @ErrorState INT;

        SELECT 
            @ErrorMessage = ERROR_MESSAGE(),
            @ErrorSeverity = ERROR_SEVERITY(),
            @ErrorState = ERROR_STATE();

        RAISERROR (@ErrorMessage, @ErrorSeverity, @ErrorState);
    END CATCH
END;
