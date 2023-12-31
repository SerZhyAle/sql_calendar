/*
-- next code for Microsoft SQL:

 calendar_quarters is a VIEW based on table:
 -- calendar_dates

 Please create and fill this table before

 the working_hours is 8 per working_day
 */

CREATE OR alter VIEW calendar_quarters AS
(
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

FROM calendar_dates AS last_day_of_quarter
    LEFT JOIN (SELECT year,
                      quarter,
                      SUM(iif(is_weekday = 1, 1, 0))                         AS weekdays,
                      SUM(iif(is_weekend = 1, 1, 0))                         AS weekends,
                      SUM(IiF(special_date IS NOT NULL, 1, 0)) AS special_days,
                      SUM(IiF(is_working_day = 1, 1, 0))           AS working_days,
                      SUM(1)                                  AS days_in_quarter
               FROM calendar_dates
               GROUP BY year,
                        quarter) AS dates_of_quarter
        ON dates_of_quarter.year = last_day_of_quarter.year
        AND dates_of_quarter.quarter = last_day_of_quarter.quarter
WHERE last_day_of_quarter.is_last_day_of_quarter = 1
    );

-- check..
SELECT *
FROM calendar_quarters;

/*
 sza(c)
 */
