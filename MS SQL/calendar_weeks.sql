/*
-- next code for Microsoft SQL:

 calendar_weeks is a VIEW based on table:
 -- calendar_dates

 Please create and fill this table before

 the working_hours is 8 per working_day
 */

CREATE OR ALTER VIEW calendar_weeks AS
(
SELECT sunday.year,
       sunday.week,
       sunday.week_begin,
       sunday.week_end,
       MONTH(DATEADD(DAY, -7, sunday.date))                            AS month_begin,
       sunday.month_end,
       YEAR(DATEADD(DAY, 7, sunday.date))                              AS year_begin,
       sunday.year_end,
       IIF(sunday.month <> MONTH(DATEADD(DAY, -7, sunday.date)), 1, 0) AS is_week_in_two_months,
       IIF(sunday.year <> YEAR(DATEADD(DAY, -7, sunday.date)), 1, 0)   AS is_week_in_two_years,
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
       CONCAT(sunday.year2, ' ',
              RIGHT(sunday.week_begin, 5), ' - ',
              RIGHT(sunday.week_end, 5))                               AS shortname,
       CONCAT('', sunday.week_begin, ' - ', sunday.week_end)           AS fullname
FROM calendar_dates AS sunday
    LEFT JOIN (SELECT year,
                      week,
                      SUM(IIF(is_weekday = 1, 1, 0))           AS weekdays,
                      SUM(IIF(is_weekend = 1, 1, 0))           AS weekends,
                      SUM(IIF(special_date IS NOT NULL, 1, 0)) AS special_days,
                      SUM(IIF(is_working_day = 1, 1, 0))       AS working_days,
                      SUM(IIF(is_working_day = 1, 8, 0))       AS working_hours,
                      SUM(1)                                   AS days_in_year_of_begin
               FROM calendar_dates
               GROUP BY year, week) AS dates_of_week
        ON dates_of_week.year = sunday.year
        AND dates_of_week.week = sunday.week
WHERE sunday.day_of_week = 0 )

-- _________________________________________________________________ --
-- check..
SELECT fullname
FROM calendar_weeks
WHERE next_day < DATEADD(MONTH, 6, CAST(GETDATE() AS date))
ORDER BY order_week_number_descent;

SELECT *
FROM calendar_weeks
WHERE year = 2023;

SELECT *
FROM calendar_dates
WHERE year = 2024
  AND week = 1;

/*
 sza(c)
 */
