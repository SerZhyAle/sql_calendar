/*
-- next code for MYSQL 5.7:

 calendar_weeks is a VIEW based on table:
 -- calendar_dates

 Please create and fill this table before

 the working_hours is 8 per working_day
 */

CREATE OR REPLACE VIEW calendar_weeks AS
(
SELECT sunday.year,
       sunday.week,
       sunday.week_begin,
       sunday.week_end,
       MONTH(DATE_ADD(sunday.date, INTERVAL -7 DAY))               AS month_begin,
       sunday.month_end,
       YEAR(DATE_ADD(sunday.date, INTERVAL -7 DAY))                AS year_begin,
       sunday.year_end,
       CASE
           WHEN sunday.month <> MONTH(DATE_ADD(sunday.date, INTERVAL -7 DAY))
               THEN 1
           ELSE 0
           END                                                     AS is_week_in_two_months,
       CASE
           WHEN sunday.year <> YEAR(DATE_ADD(sunday.date, INTERVAL -7 DAY))
               THEN 1
           ELSE 0
           END                                                     AS is_week_in_two_years,
       dates_of_week.weekdays,
       dates_of_week.weekends,
       dates_of_week.special_days,
       dates_of_week.working_days,
       dates_of_week.working_hours,
       dates_of_week.days_in_year_of_begin,
       (7 - dates_of_week.days_in_year_of_begin)                   AS days_in_year_of_end,
       CONCAT(sunday.week_end, ' 23')                              AS last_hour,
       CONCAT(sunday.week_begin, ' 00')                            AS first_hour,
       CONCAT(DATE_ADD(sunday.week_begin, INTERVAL -1 DAY), ' 23') AS last_hour_prev_week,
       CONCAT(DATE_ADD(sunday.week_end, INTERVAL 1 DAY), ' 00')    AS first_hour_next_week,
       DATE_ADD(sunday.week_end, INTERVAL 1 DAY)                   AS next_day,
       sunday.week_after,
       sunday.week_before,
       sunday.week_num_since_2020                                  AS order_week_number,
       9999 - sunday.week_num_since_2020                           AS order_week_number_descent,
       CONCAT(sunday.year2, ' ', RIGHT(sunday.week_begin, 5), ' - ',
              RIGHT(sunday.week_end, 5))                           AS shortname,
       CONCAT('', sunday.week_begin, ' - ',
              sunday.week_end)                                     AS fullname
FROM calendar_dates AS sunday
    LEFT JOIN (SELECT year,
                      week,
                      SUM(is_weekday) AS weekdays,
                      SUM(is_weekend) AS weekends,
                      SUM(CASE
                              WHEN special_date IS NOT NULL
                                  THEN 1
                              ELSE 0
                          END)        AS special_days,
                      SUM(CASE
                              WHEN is_working_day = 1
                                  THEN 1
                              ELSE 0
                          END)        AS working_days,
                      SUM(CASE
                              WHEN is_working_day = 1
                                  THEN 8
                              ELSE 0
                          END)        AS working_hours,
                      SUM(1)          AS days_in_year_of_begin
               FROM calendar_dates
               GROUP BY year,
                        week) AS dates_of_week
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

SELECT *
FROM calendar_dates
WHERE year = 2024
  AND week = 1;

/*
 sza(c)
 */
