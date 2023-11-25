/*
-- next code for Oracle SQL:

 calendar_weeks is a VIEW based on table:
 -- calendar_dates

 Please create and fill this table before

 the working_hours is 8 per working_day
 */

CREATE OR REPLACE VIEW calendar_weeks AS
(
SELECT sunday."year_week",
       sunday."year",
       sunday."week",
       SUBSTR('0' || sunday."week", -2)                         AS "week2c",
       sunday."week_begin",
       sunday."week_end",
       EXTRACT(MONTH FROM (sunday."date" - 7))                  AS "month_begin",
       EXTRACT(MONTH FROM sunday."date")                        AS "month_end",
       EXTRACT(YEAR FROM (sunday."date" + 7))                   AS "year_begin",
       EXTRACT(YEAR FROM sunday."date")                         AS "year_end",
       CASE
           WHEN sunday."month" <> EXTRACT(MONTH FROM (sunday."date" - 7))
               THEN 1
           ELSE 0 END                                           AS "is_week_in_two_months",
       CASE
           WHEN sunday."year" <> EXTRACT(YEAR FROM (sunday."date" - 7))
               THEN 1
           ELSE 0 END                                           AS "is_week_in_two_years",
       dates_of_week."weekdays",
       dates_of_week."weekends",
       dates_of_week."special_days",
       dates_of_week."working_days",
       dates_of_week."working_hours",
       dates_of_week."days_in_year_of_begin",
       (7 - dates_of_week."days_in_year_of_begin")              AS "days_in_year_of_end",
       TO_CHAR(sunday."week_end", 'YYYY-MM-DD') || ' 23'        AS "last_hour",
       TO_CHAR(sunday."week_begin", 'YYYY-MM-DD') || ' 00'      AS "first_hour",
       TO_CHAR((sunday."week_begin" - 1), 'YYYY-MM-DD') || ' 23' AS "last_hour_prev_week",
       TO_CHAR((sunday."week_end" + 1), 'YYYY-MM-DD') || ' 00'   AS "first_hour_next_week",
       sunday."week_end" + 1                                    AS "next_day",
       sunday."week_after",
       sunday."week_before",
       sunday."week_num_since_2020"                             AS "order_week_number",
       9999 - sunday."week_num_since_2020"                      AS "order_week_number_descent",
       sunday."year2" || ' ' ||
       TO_CHAR(sunday."week_begin", 'MM-DD') || ' - ' ||
       TO_CHAR(sunday."week_end", 'MM-DD')                      AS "shortname",
       TO_CHAR(sunday."week_begin", 'YYYY-MM-DD') || ' - ' ||
       TO_CHAR(sunday."week_end", 'YYYY-MM-DD')                 AS "fullname"
FROM calendar_dates sunday
    LEFT JOIN (SELECT "year",
                      "week",
                      SUM(CASE WHEN "is_weekday" = 1 THEN 1 ELSE 0 END)           AS "weekdays",
                      SUM(CASE WHEN "is_weekend" = 1 THEN 1 ELSE 0 END)           AS "weekends",
                      SUM(CASE WHEN "special_date" IS NOT NULL THEN 1 ELSE 0 END) AS "special_days",
                      SUM(CASE WHEN "is_working_day" = 1 THEN 1 ELSE 0 END)       AS "working_days",
                      SUM(CASE WHEN "is_working_day" = 1 THEN 8 ELSE 0 END)       AS "working_hours",
                      SUM(1)                                                      AS "days_in_year_of_begin"
               FROM calendar_dates
               GROUP BY "year", "week") dates_of_week
        ON dates_of_week."year" = sunday."year"
        AND dates_of_week."week" = sunday."week"
WHERE sunday."day_of_week" = 0 );

-- _________________________________________________________________ --
-- check..
SELECT "fullname"
FROM calendar_weeks
WHERE "next_day" < ADD_MONTHS(CURRENT_DATE, 6)
ORDER BY "order_week_number_descent";

SELECT *
FROM calendar_weeks
WHERE "year" = 2023
ORDER BY "year_week";
/*
first line:
year_week,year,week,week2c,week_begin,week_end,month_begin,month_end,year_begin,year_end,is_week_in_two_months,is_week_in_two_years,weekdays,weekends,special_days,working_days,working_hours,days_in_year_of_begin,days_in_year_of_end,last_hour,first_hour,last_hour_prev_week,first_hour_next_week,next_day,week_after,week_before,order_week_number,order_week_number_descent,shortname,fullname
2023/01,2023,1,01,2023-01-02,2023-01-08,1,1,2023,2023,0,0,5,2,0,5,40,7,0,8/1/2023 23,2/1/2023 00,2023-01-0123,2023-01-0900,2023-01-09,2023-01-15,2023-01-01,158,9841,23 01-02- 01-08,2023-01-02 - 2023-01-08
*/
/*
 sza(c)
 */
