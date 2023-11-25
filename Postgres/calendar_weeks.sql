/*
-- next code for Postgres SQL:

 calendar_weeks is a VIEW based on table:
 -- calendar_dates

 Please create and fill this table before

 the working_hours is 8 per working_day
 */

CREATE OR REPLACE VIEW calendar_weeks AS
(
SELECT sunday.year_week,
       sunday.year,
       sunday.week,
       RIGHT(CONCAT('0', sunday.week), 2)                    AS week2c,
       sunday.week_begin,
       sunday.week_end,
       EXTRACT(MONTH FROM (sunday.date - 7))                 AS month_begin,
       EXTRACT(MONTH FROM sunday.date)                       AS month_end,
       EXTRACT(YEAR FROM (sunday.date + 7))                  AS year_begin,
       EXTRACT(YEAR FROM sunday.date)                        AS year_end,
       CASE
           WHEN sunday.month <> EXTRACT(MONTH FROM (sunday.date - 7))
               THEN TRUE
           ELSE FALSE END                                    AS is_week_in_two_months,
       CASE
           WHEN sunday.year <> EXTRACT(YEAR FROM (sunday.date - 7))
               THEN TRUE
           ELSE FALSE END                                    AS is_week_in_two_years,
       dates_of_week.weekdays,
       dates_of_week.weekends,
       dates_of_week.special_days,
       dates_of_week.working_days,
       dates_of_week.working_hours,
       dates_of_week.days_in_year_of_begin,
       (7 - dates_of_week.days_in_year_of_begin)             AS days_in_year_of_end,
       CONCAT(sunday.week_end, ' 23')                        AS last_hour,
       CONCAT(sunday.week_begin, ' 00')                      AS first_hour,
       TO_CHAR((sunday.week_begin - 1), 'YYYY-MM-DD 23')     AS last_hour_prev_week,
       TO_CHAR((sunday.week_end + 1), 'YYYY-MM-DD 00')       AS first_hour_next_week,
       sunday.week_end + 1                                   AS next_day,
       sunday.week_after,
       sunday.week_before,
       sunday.week_num_since_2020                            AS order_week_number,
       9999 - sunday.week_num_since_2020                     AS order_week_number_descent,
       CONCAT(sunday.year2, ' ',
              TO_CHAR(sunday.week_begin, 'MM-DD - '),
              TO_CHAR(sunday.week_end, 'MM-DD'))             AS shortname,
       CONCAT('', sunday.week_begin, ' - ', sunday.week_end) AS fullname
FROM calendar_dates AS sunday
    LEFT JOIN (SELECT year,
                      week,
                      SUM(CASE WHEN is_weekday = TRUE THEN 1 ELSE 0 END)        AS weekdays,
                      SUM(CASE WHEN is_weekend = TRUE THEN 1 ELSE 0 END)        AS weekends,
                      SUM(CASE WHEN special_date IS NOT NULL THEN 1 ELSE 0 END) AS special_days,
                      SUM(CASE WHEN is_working_day = TRUE THEN 1 ELSE 0 END)    AS working_days,
                      SUM(CASE WHEN is_working_day = TRUE THEN 8 ELSE 0 END)    AS working_hours,
                      SUM(1)                                                    AS days_in_year_of_begin
               FROM calendar_dates
               GROUP BY year, week) AS dates_of_week
        ON dates_of_week.year = sunday.year
        AND dates_of_week.week = sunday.week
WHERE sunday.day_of_week = 0 );

-- _________________________________________________________________ --
-- check..
SELECT fullname
FROM calendar_weeks
WHERE next_day < CAST(NOW() AS date) + INTERVAL '6 month'
ORDER BY order_week_number_descent;

SELECT *
FROM calendar_weeks
WHERE year = 2023;

/*
 sza(c)
 */
