/*
-- next code for SnowFlake:

 calendar_weeks is a VIEW based on table:
 -- calendar_dates

 Please create and fill this table before

 the working_hours is 8 per working_day

 USE Your_database_schema
GEAR here the name of SF schema. Change it on yours.
 */

CREATE OR REPLACE VIEW gear.calendar_weeks AS
(
WITH cte_dates_of_weeks AS (SELECT year,
                                   week,
                                   SUM(IFF(is_weekday = TRUE, 1, 0))        AS weekdays,
                                   SUM(IFF(is_weekend = TRUE, 1, 0))        AS weekends,
                                   SUM(IFF(special_date IS NOT NULL, 1, 0)) AS special_days,
                                   SUM(IFF(is_working_day = 1, 1, 0))       AS working_days,
                                   SUM(IFF(is_working_day = 1, 8, 0))       AS working_hours,
                                   SUM(1)                                   AS days_in_year_of_begin
                            FROM gear.calendar_dates
                            GROUP BY year,
                                     week)
SELECT sunday.year_week,
       sunday.year,
       sunday.week,
       RIGHT(CONCAT('0', sunday.week), 2)                              AS week2c,
       sunday.week_begin,
       sunday.week_end,
       MONTH(DATEADD(DAY, -7, sunday.date))                            AS month_begin,
       MONTH(sunday.date)                                              AS month_end,
       YEAR(DATEADD(DAY, -7, sunday.date))                             AS year_begin,
       YEAR(sunday.date)                                               AS year_end,
       IFF(sunday.month <> MONTH(DATEADD(DAY, -7, sunday.date)), 1, 0) AS is_week_in_two_months,
       IFF(sunday.year <> YEAR(DATEADD(DAY, -7, sunday.date)), 1, 0)   AS is_week_in_two_years,
       dates_of_week.weekdays,
       dates_of_week.weekends,
       dates_of_week.special_days,
       dates_of_week.working_days,
       dates_of_week.working_hours,
       dates_of_week.days_in_year_of_begin,
       (7 - dates_of_week.days_in_year_of_begin)                       AS days_in_year_of_end,
       CONCAT(sunday.week_end, ' 23')                                  AS last_hour,
       CONCAT(sunday.week_begin, ' 00')                                AS first_hour,
       CONCAT(DATEADD(DAY, -1, sunday.week_begin), ' 23')              AS last_hour_prev_week,
       CONCAT(DATEADD(DAY, 1, sunday.week_end), ' 00')                 AS first_hour_next_week,
       DATEADD(DAY, 1, sunday.week_end)                                AS next_day,
       sunday.week_after,
       sunday.week_before,
       sunday.week_num_since_2020                                      AS order_week_number,
       9999 - sunday.week_num_since_2020                               AS order_week_number_descent,
       CONCAT(sunday.year2, ' ', RIGHT(sunday.week_begin, 5), ' - ',
              RIGHT(sunday.week_end, 5))                               AS shortname,
       CONCAT('', sunday.week_begin, ' - ',
              sunday.week_end)                                         AS fullname
FROM gear.calendar_dates AS sunday
    LEFT JOIN cte_dates_of_weeks AS dates_of_week
        ON dates_of_week.year = sunday.year
        AND dates_of_week.week = sunday.week
WHERE sunday.day_of_week = 0
    );

-- _________________________________________________________________ --
-- check..
SELECT fullname
FROM gear.calendar_weeks
WHERE next_day < DATEADD(MONTH, 6, CURRENT_DATE)
ORDER BY order_week_number_descent
;

SELECT *
FROM gear.calendar_weeks
WHERE year = 2023;

/*
 sza(c)
 */
