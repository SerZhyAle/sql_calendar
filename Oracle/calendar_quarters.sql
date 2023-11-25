/*
-- next code for Oracle SQL:

 calendar_quarters is a VIEW based on table:
 -- calendar_dates

 Please create and fill this table before

 the working_hours is 8 per working_day
 */

CREATE OR REPLACE VIEW calendar_quarters AS
(
SELECT last_day_of_quarter."year" || ' ' ||
       last_day_of_quarter."quarter"             AS "year_quarter",
       last_day_of_quarter."year",
       last_day_of_quarter."quarter",
       last_day_of_quarter."year2",
       last_day_of_quarter."year2c",
       last_day_of_quarter."quarter_begin",
       last_day_of_quarter."quarter_end",
       last_day_of_quarter."quarter_end" + 1     AS "quarter_after_begin",
       last_day_of_quarter."quarter_after",
       last_day_of_quarter."quarter_before",
       dates_of_quarter."days_in_quarter",
       dates_of_quarter."days_in_quarter" * 24   AS "hours_in_quarter",
       dates_of_quarter."weekdays",
       dates_of_quarter."weekends",
       dates_of_quarter."special_days",
       dates_of_quarter."working_days",
       last_day_of_quarter."year_num_since_2020" AS "order_year_number"
FROM calendar_dates last_day_of_quarter
    LEFT JOIN (SELECT "year",
                      "quarter",
                      SUM(CASE WHEN "is_weekday" = 1 THEN 1 ELSE 0 END)           AS "weekdays",
                      SUM(CASE WHEN "is_weekend" = 1 THEN 1 ELSE 0 END)           AS "weekends",
                      SUM(CASE WHEN "special_date" IS NOT NULL THEN 1 ELSE 0 END) AS "special_days",
                      SUM(CASE WHEN "is_working_day" = 1 THEN 1 ELSE 0 END)       AS "working_days",
                      SUM(1)                                                      AS "days_in_quarter"
               FROM calendar_dates
               GROUP BY "year",
                        "quarter") dates_of_quarter
        ON dates_of_quarter."year" = last_day_of_quarter."year"
        AND dates_of_quarter."quarter" = last_day_of_quarter."quarter"
WHERE last_day_of_quarter."is_last_day_of_quarter" = 1
    );

-- check..
SELECT *
FROM calendar_quarters
order by "year_quarter";
/*
 first line:
year_quarter,year,quarter,year2,year2c,quarter_begin,quarter_end,quarter_after_begin,quarter_after,quarter_before,days_in_quarter,hours_in_quarter,weekdays,weekends,special_days,working_days,order_year_number
2019 4,2019,4,19,19,2019-10-01,2020-01-31,2020-02-01,2020-03-31,2019-09-30,1,24,1,0,0,1,0
  */
/*
 sza(c)
 */
