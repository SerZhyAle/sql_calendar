/*
-- next code for Microsoft SQL:

 calendar_months is a VIEW based on tables:
 -- calendar_dates
 -- calendar_hours

 Please create and fill these tables before

 the working_hours is 8 per working_day
 */

CREATE OR ALTER VIEW calendar_months AS
(
SELECT last_day_of_month.year_month2,
       last_day_of_month.year_quarter,
       last_day_of_month.year,
       last_day_of_month.month,
       last_day_of_month.quarter,
       last_day_of_month.month_name,
       last_day_of_month.month2,
       last_day_of_month.month_name3,
       last_day_of_month.month_begin,
       last_day_of_month.month_end,
       DATEDIFF(DAY, last_day_of_month.month_begin,
                first_day_of_month.month_end) + 1                          AS days_in_month,
       (DATEDIFF(DAY, last_day_of_month.month_begin,
                 first_day_of_month.month_end) + 1) * 24                   AS hours_in_month,
       DATEADD(DAY, -1, first_day_of_month.date)                           AS prev_month_last_day,
       LEFT(DATEADD(DAY, -1, first_day_of_month.date), 7)                  AS prev_year_month2,
       IIF(last_day_of_month.month IN (3, 6, 9, 12), 1, 0)                 AS is_last_in_quarter,
       IIF(last_day_of_month.month = 12, 1, 0)                             AS is_last_in_year,
       dates_of_month.weekdays,
       dates_of_month.weekends,
       dates_of_month.special_days,
       dates_of_month.working_days,
       dates_of_month.working_hours,
       first_and_last_hours.min_date_hour,
       first_and_last_hours.max_date_hour,
       first_and_last_hours_cet.min_date_hour_utc_to_cet,
       first_and_last_hours_cet.max_date_hour_utc_to_cet,
       last_day_of_month.next_date,
       CONCAT(last_day_of_month.month_name3, ' ', last_day_of_month.year2) AS fullname,
       LEFT(last_day_of_month.next_date, 7)                                AS next_year_month2,
       last_day_of_month.month_num_since_2020                              AS order_month_number,
       9999 - last_day_of_month.month_num_since_2020                       AS order_month_number_desc

FROM calendar_dates AS last_day_of_month
    JOIN calendar_dates AS first_day_of_month
        ON first_day_of_month.date = last_day_of_month.month_begin
    JOIN (SELECT year_month2,
                 SUM(IIF(is_weekday = 1, 1, 0))           AS weekdays,
                 SUM(IIF(is_weekend = 1, 1, 0))           AS weekends,
                 SUM(IIF(special_date IS NOT NULL, 1, 0)) AS special_days,
                 SUM(IIF(is_working_day = 1, 1, 0))       AS working_days,
                 SUM(IIF(is_working_day = 1, 8, 0))       AS working_hours
          FROM calendar_dates
          GROUP BY year_month2) AS dates_of_month
        ON dates_of_month.year_month2 = last_day_of_month.year_month2
    JOIN (SELECT hours.year_month2,
                 MAX(hours.date_hour) AS max_date_hour,
                 MIN(hours.date_hour) AS min_date_hour
          FROM calendar_hours AS hours
              JOIN (SELECT year_month2,
                           SUM(IIF(is_weekday = 1, 1, 0))           AS weekdays,
                           SUM(IIF(is_weekend = 1, 1, 0))           AS weekends,
                           SUM(IIF(special_date IS NOT NULL, 1, 0)) AS special_days,
                           SUM(IIF(is_working_day = 1, 1, 0))       AS working_days,
                           SUM(IIF(is_working_day = 1, 8, 0))       AS working_hours
                    FROM calendar_dates
                    GROUP BY year_month2) AS dates
                  ON dates.year_month2 = hours.year_month2
          GROUP BY hours.year_month2) AS first_and_last_hours
        ON first_and_last_hours.year_month2 = last_day_of_month.year_month2
    JOIN (SELECT hours.year_month2_cet,
                 MAX(hours.date_hour) AS max_date_hour_utc_to_cet,
                 MIN(hours.date_hour) AS min_date_hour_utc_to_cet
          FROM calendar_hours AS hours
              JOIN (SELECT year_month2,
                           SUM(IIF(is_weekday = 1, 1, 0))           AS weekdays,
                           SUM(IIF(is_weekend = 1, 1, 0))           AS weekends,
                           SUM(IIF(special_date IS NOT NULL, 1, 0)) AS special_days,
                           SUM(IIF(is_working_day = 1, 1, 0))       AS working_days,
                           SUM(IIF(is_working_day = 1, 8, 0))       AS working_hours
                    FROM calendar_dates
                    GROUP BY year_month2) AS dates
                  ON dates.year_month2 = hours.year_month2_cet
          GROUP BY hours.year_month2_cet) AS first_and_last_hours_cet
        ON first_and_last_hours_cet.year_month2_cet = last_day_of_month.year_month2
WHERE last_day_of_month.is_last_day_of_month = 1
    )

-- check..
SELECT *
FROM calendar_months;

/*
 sza(c)
 */
