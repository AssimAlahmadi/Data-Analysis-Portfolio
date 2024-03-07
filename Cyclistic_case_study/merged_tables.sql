-- Change the name of each table to more understandable name
sp_rename ['202401-divvy-tripdata$'], cyclistic_202401

-- Change the ride_length data type from datetime to time(0)
ALTER TABLE cyclistic_202401
ALTER COLUMN ride_length time(0)

-- Merge all tables into one table
SELECT *
  INTO  cyclistic_202302_202401
FROM
(
        SELECT     *
    FROM         cyclistic_202302
    UNION
    SELECT     *
    FROM         cyclistic_202303
    UNION
    SELECT     *
    FROM         cyclistic_202304
    UNION
    SELECT     *
    FROM         cyclistic_202305
    UNION
    SELECT     *
    FROM         cyclistic_202306
	UNION
    SELECT     *
    FROM         cyclistic_202307
	UNION
    SELECT     *
    FROM         cyclistic_202308
	UNION
    SELECT     *
    FROM         cyclistic_202309
	UNION
    SELECT     *
    FROM         cyclistic_202310
	UNION
    SELECT     *
    FROM         cyclistic_202311
	UNION
    SELECT     *
    FROM         cyclistic_202312
	UNION
    SELECT     *
    FROM         cyclistic_202401
) a