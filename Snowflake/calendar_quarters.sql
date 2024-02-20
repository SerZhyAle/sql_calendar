/*
-- next code for MySQL 8.0 and higher:

 calendar_quarters is a VIEW based on table:
 -- calendar_dates

 Please create and fill this table before

 the working_hours is 8 per working_day

 USE Your_database_schema
GEAR here the name of SF schema. Change it on yours.
 */

CREATE OR REPLACE VIEW gear.calendar_quarters AS
(
WITH cte_dates_of_quarter AS (SELECT year,
                                     quarter,
                                     SUM(IFF(is_weekday = true, 1, 0))                         AS weekdays,
                                     SUM(iff(is_weekend = true, 1, 0))                         AS weekends,
                                     SUM(IfF(special_date IS NOT NULL, 1, 0)) AS special_days,
                                     SUM(IFf(is_working_day, 1, 0))           AS working_days,
                                     SUM(1)                                  AS days_in_quarter
                              FROM gear.calendar_dates
                              GROUP BY year,
                                       quarter)

SELECT CONCAT(last_day_of_quarter.year, ' ',
              last_day_of_quarter.quarter)                       AS year_quarter,
       last_day_of_quarter.year,
       last_day_of_quarter.quarter,
       last_day_of_quarter.year2,
       last_day_of_quarter.year2c,
       last_day_of_quarter.quarter_begin,
       last_day_of_quarter.quarter_end,
       DATEADD(day, 1, last_day_of_quarter.quarter_end) AS quarter_after_begin,
       last_day_of_quarter.quarter_after,
       last_day_of_quarter.quarter_before,
       dates_of_quarter.days_in_quarter,
       dates_of_quarter.days_in_quarter * 24                     AS hours_in_quarter,
       dates_of_quarter.weekdays,
       dates_of_quarter.weekends,
       dates_of_quarter.special_days,
       dates_of_quarter.working_days,
       last_day_of_quarter.year_num_since_2020                   AS order_year_number

FROM gear.calendar_dates AS last_day_of_quarter
    LEFT JOIN cte_dates_of_quarter AS dates_of_quarter
        ON dates_of_quarter.year = last_day_of_quarter.year
        AND dates_of_quarter.quarter = last_day_of_quarter.quarter
WHERE last_day_of_quarter.is_last_day_of_quarter = 1
    );

-- check..
SELECT *
FROM gear.calendar_quarters
order by year_quarter;

/*
 sza(c)
 */
