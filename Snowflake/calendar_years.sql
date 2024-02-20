/*
-- next code for MySQL 8.0 and higher:

 calendar_weeks is a VIEW based on table:
 -- calendar_dates

 Please create and fill this table before

 the working_hours is 8 per working_day

 USE Your_database_schema
GEAR here the name of SF schema. Change it on yours.
 */

CREATE OR REPLACE VIEW gear.calendar_years AS
(
WITH cte_dates_of_year AS (SELECT year,
                                  SUM(IFF(is_weekday, 1, 0))               AS weekdays,
                                  SUM(IFF(is_weekend, 1, 0))               AS weekends,
                                  SUM(IFF(special_date IS NOT NULL, 1, 0)) AS special_days,
                                  SUM(IFF(is_working_day, 1, 0))           AS working_days
                           FROM gear.calendar_dates
                           GROUP BY year)

SELECT last_day_of_year.year,
       last_day_of_year.year2,
       last_day_of_year.year2c,
       last_day_of_year.year_begin,
       last_day_of_year.year_end,
       DATEADD(DAY, 1, last_day_of_year.year_end)     AS year_after_begin,
       last_day_of_year.year_after                    AS year_after_end,
       last_day_of_year.year_before                   AS year_before_end,
       last_day_of_year.days_in_year,
       last_day_of_year.days_in_year * 24             AS hours_in_year,
       dates_of_year.weekdays,
       dates_of_year.weekends,
       dates_of_year.special_days,
       dates_of_year.working_days,
       IFF(last_day_of_year.days_in_year = 365, 0, 1) AS is_leap_year,
       last_day_of_year.year_num_since_2020           AS order_year_number

FROM gear.calendar_dates AS last_day_of_year
    LEFT JOIN cte_dates_of_year AS dates_of_year
        ON dates_of_year.year = last_day_of_year.year
WHERE last_day_of_year.is_last_day_of_year = 1
    );

-- check..
SELECT *
FROM gear.calendar_years;

/*
 sza(c)
 */
