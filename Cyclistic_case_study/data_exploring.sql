-- Data exploring

-- Total number of rows
select *
from cyclistic_202302_202401
-- Result: 5,674,449

-- Distinct values
SELECT COUNT(*) FROM
(
    SELECT DISTINCT * FROM cyclistic_202302_202401
) T1
-- Result: 5,674,449

-- Max and Min of ride_length
select MAX(ride_length),
MIN(ride_length)
from cyclistic_202302_202401
-- MAX: 23:95:55, Min: 00:00:00

/*Note that the ride_length data type is stored
time(0) which has a limitation to 23:59:59.
Upon looking at the data in excel I noticed
some cells exceeding that limit, but I didn't
find any other data type that works in this scenario.*/

-- Number of rows for each rideable_bike
SELECT count(case rideable_type when 'classic_bike' then 1 else null end) classic_bike,
count(case rideable_type when 'docked_bike' then 1 else null end) docked_bike,
count(case rideable_type when 'electric_bike' then 1 else null end) electric_bike
FROM cyclistic_202302_202401

-- Number of casual riders for each rideable_bike
SELECT count(case rideable_type when 'classic_bike' then 1 else null end) classic_bike,
count(case rideable_type when 'docked_bike' then 1 else null end) docked_bike,
count(case rideable_type when 'electric_bike' then 1 else null end) electric_bike
FROM cyclistic_202302_202401
WHERE member_casual = 'casual'

-- Number of member riders for each rideable_bike
SELECT count(case rideable_type when 'classic_bike' then 1 else null end) classic_bike,
count(case rideable_type when 'docked_bike' then 1 else null end) docked_bike,
count(case rideable_type when 'electric_bike' then 1 else null end) electric_bike
FROM cyclistic_202302_202401
WHERE member_casual = 'member'

-- Count each day_of_week
SELECT count(day_of_week) rows_per_day_of_week
FROM cyclistic_202302_202401
GROUP BY day_of_week

-- Percentage of each day_of_week
SELECT day_of_week, CAST(ROUND(count(*) * 100.0 / (SELECT count(*) from cyclistic_202302_202401) ,2) as decimal(18,2)) as 'percentage_of_day_per_of_week' 
FROM cyclistic_202302_202401
GROUP BY day_of_week
ORDER BY day_of_week DESC
