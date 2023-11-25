/*
-- next code for Oracle SQL:

 calendar_weeks is a VIEW based on table:
 -- calendar_dates

 Please create and fill this table before

 the working_hours is 8 per working_day
 */

CREATE OR REPLACE VIEW calendar_years AS
(
SELECT last_day_of_year."year",
       last_day_of_year."year2",
       last_day_of_year."year2c",
       last_day_of_year."year_begin",
       last_day_of_year."year_end",
       last_day_of_year."year_end" + 1        AS "year_after_begin",
       last_day_of_year."year_after"          AS "year_after_end",
       last_day_of_year."year_before"         AS "year_before_end",
       last_day_of_year."days_in_year",
       last_day_of_year."days_in_year" * 24   AS "hours_in_year",
       dates_of_year."weekdays",
       dates_of_year."weekends",
       dates_of_year."special_days",
       dates_of_year."working_days",
       CASE
           WHEN last_day_of_year."days_in_year" = 365
               THEN 1
           ELSE 0 END                         AS "is_leap_year",
       last_day_of_year."year_num_since_2020" AS "order_year_number"
FROM calendar_dates last_day_of_year
    LEFT JOIN (SELECT "year",
                      SUM(CASE WHEN "is_weekday" = 1 THEN 1 ELSE 0 END)           AS "weekdays",
                      SUM(CASE WHEN "is_weekend" = 1 THEN 1 ELSE 0 END)           AS "weekends",
                      SUM(CASE WHEN "special_date" IS NOT NULL THEN 1 ELSE 0 END) AS "special_days",
                      SUM(CASE WHEN "is_working_day" = 1 THEN 1 ELSE 0 END)       AS "working_days"
               FROM calendar_dates
               GROUP BY "year") dates_of_year
        ON dates_of_year."year" = last_day_of_year."year"
WHERE last_day_of_year."is_last_day_of_year" = 1
    );

-- check..
SELECT *
FROM calendar_years
ORDER BY "year";
/*
 first line:
year,year2,year2c,year_begin,year_end,year_after_begin,year_after_end,year_before_end,days_in_year,hours_in_year,weekdays,weekends,special_days,working_days,is_leap_year,order_year_number
2019,19,19,2019-01-01,2019-12-31,2020-01-01,2020-12-31,2018-12-31,365,8760,1,0,0,1,1,0
 */

/*
 sza(c)
 */
