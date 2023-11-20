/*
-- next code for MySQL 8.0 and higher:

 calendar_weeks is a VIEW based on table:
 -- calendar_dates

 Please create and fill this table before

 the working_hours is 8 per working_day
 */

CREATE OR REPLACE VIEW calendar_weeks AS
(
WITH cte_dates_of_weeks AS (SELECT year,
                                   week,
                                   SUM(is_weekday)                         AS weekdays,
                                   SUM(is_weekend)                         AS weekends,
                                   SUM(IF(special_date IS NOT NULL, 1, 0)) AS special_days,
                                   SUM(IF(is_working_day = 1, 1, 0))       AS working_days,
                                   SUM(IF(is_working_day = 1, 8, 0))       AS working_hours,
                                   SUM(1)                                  AS days_in_year_of_begin
                            FROM calendar_dates
                            GROUP BY year,
                                     week)
SELECT  sunday.year_week,
       sunday.year,
       sunday.week,
       RIGHT(CONCAT('0', sunday.week), 2)                                      AS week2c,
       sunday.week_begin,
       sunday.week_end,
       MONTH(DATE_ADD(sunday.date, INTERVAL -7 DAY))                           AS month_begin,
       sunday.month_end,
       YEAR(DATE_ADD(sunday.date, INTERVAL -7 DAY))                            AS year_begin,
       sunday.year_end,
       IF(sunday.month <> MONTH(DATE_ADD(sunday.date, INTERVAL -7 DAY)), 1, 0) AS is_week_in_two_months,
       IF(sunday.year <> YEAR(DATE_ADD(sunday.date, INTERVAL -7 DAY)), 1, 0)   AS is_week_in_two_years,
       dates_of_week.weekdays,
       dates_of_week.weekends,
       dates_of_week.special_days,
       dates_of_week.working_days,
       dates_of_week.working_hours,
       dates_of_week.days_in_year_of_begin,
       (7 - dates_of_week.days_in_year_of_begin)                               AS days_in_year_of_end,
       CONCAT(sunday.week_end, ' 23')                                          AS last_hour,
       CONCAT(sunday.week_begin, ' 00')                                        AS first_hour,
       CONCAT(DATE_ADD(sunday.week_begin, INTERVAL -1 DAY), ' 23')             AS last_hour_prev_week,
       CONCAT(DATE_ADD(sunday.week_end, INTERVAL 1 DAY), ' 00')                AS first_hour_next_week,
       DATE_ADD(sunday.week_end, INTERVAL 1 DAY)                               AS next_day,
       sunday.week_after,
       sunday.week_before,
       sunday.week_num_since_2020                                              AS order_week_number,
       9999 - sunday.week_num_since_2020                                       AS order_week_number_descent,
       CONCAT(sunday.year2, ' ', RIGHT(sunday.week_begin, 5), ' - ',
              RIGHT(sunday.week_end, 5))                                       AS shortname,
       CONCAT('', sunday.week_begin, ' - ',
              sunday.week_end)                                                 AS fullname
FROM calendar_dates AS sunday
    LEFT JOIN cte_dates_of_weeks AS dates_of_week
        ON dates_of_week.year = sunday.year
        AND dates_of_week.week = sunday.week
WHERE sunday.day_of_week = 0
    COLLATE utf8mb4_bin
    );

-- _________________________________________________________________ --
#check..
SELECT fullname
FROM calendar_weeks
WHERE next_day < DATE_ADD(CURRENT_DATE, INTERVAL 6 MONTH)
ORDER BY order_week_number_descent
;

SELECT *
FROM calendar_weeks
WHERE year = 2023;

/*
 sza(c)
 */
