/*
-- next code for Postgres SQL:

 calendar_months is a VIEW based on tables:
 -- calendar_dates
 -- calendar_hours

 Please create and fill these tables before

 the working_hours is 8 per working_day
 */

CREATE OR REPLACE VIEW calendar_months AS
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
       first_day_of_month.month_end - last_day_of_month.month_begin + 1            AS days_in_month,
       (first_day_of_month.month_end - last_day_of_month.month_begin + 1) * 24     AS hours_in_month,
       first_day_of_month.date - 1                                                 AS prev_month_last_day,
       TO_CHAR(first_day_of_month.date - 1, 'YYYY-MM')                             AS prev_year_month2,
       CASE WHEN last_day_of_month.month IN (3, 6, 9, 12) THEN TRUE ELSE FALSE END AS is_last_in_quarter,
       CASE WHEN last_day_of_month.month = 12 THEN TRUE ELSE FALSE END             AS is_last_in_year,
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
       CONCAT(last_day_of_month.month_name3, ' ', last_day_of_month.year2)         AS fullname,
       TO_CHAR(last_day_of_month.next_date, 'YYYY-MM')                             AS next_year_month2,
       last_day_of_month.month_num_since_2020                                      AS order_month_number,
       9999 - last_day_of_month.month_num_since_2020                               AS order_month_number_desc

FROM calendar_dates AS last_day_of_month
    JOIN calendar_dates AS first_day_of_month
        ON first_day_of_month.date = last_day_of_month.month_begin
    JOIN (SELECT year_month2,
                 SUM(CASE WHEN is_weekday = TRUE THEN 1 ELSE 0 END)        AS weekdays,
                 SUM(CASE WHEN is_weekend = TRUE THEN 1 ELSE 0 END)        AS weekends,
                 SUM(CASE WHEN special_date IS NOT NULL THEN 1 ELSE 0 END) AS special_days,
                 SUM(CASE WHEN is_working_day = TRUE THEN 1 ELSE 0 END)    AS working_days,
                 SUM(CASE WHEN is_working_day = TRUE THEN 8 ELSE 0 END)    AS working_hours
          FROM calendar_dates
          GROUP BY year_month2) AS dates_of_month
        ON dates_of_month.year_month2 = last_day_of_month.year_month2
    JOIN (SELECT hours.year_month2,
                 MAX(hours.date_hour) AS max_date_hour,
                 MIN(hours.date_hour) AS min_date_hour
          FROM calendar_hours AS hours
              JOIN (SELECT year_month2,
                           SUM(CASE WHEN is_weekday = TRUE THEN 1 ELSE 0 END)        AS weekdays,
                           SUM(CASE WHEN is_weekend = TRUE THEN 1 ELSE 0 END)        AS weekends,
                           SUM(CASE WHEN special_date IS NOT NULL THEN 1 ELSE 0 END) AS special_days,
                           SUM(CASE WHEN is_working_day = TRUE THEN 1 ELSE 0 END)    AS working_days,
                           SUM(CASE WHEN is_working_day = TRUE THEN 8 ELSE 0 END)    AS working_hours
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
                           SUM(CASE WHEN is_weekday = TRUE THEN 1 ELSE 0 END)        AS weekdays,
                           SUM(CASE WHEN is_weekend = TRUE THEN 1 ELSE 0 END)        AS weekends,
                           SUM(CASE WHEN special_date IS NOT NULL THEN 1 ELSE 0 END) AS special_days,
                           SUM(CASE WHEN is_working_day = TRUE THEN 1 ELSE 0 END)    AS working_days,
                           SUM(CASE WHEN is_working_day = TRUE THEN 8 ELSE 0 END)    AS working_hours
                    FROM calendar_dates
                    GROUP BY year_month2) AS dates
                  ON dates.year_month2 = hours.year_month2_cet
          GROUP BY hours.year_month2_cet) AS first_and_last_hours_cet
        ON first_and_last_hours_cet.year_month2_cet = last_day_of_month.year_month2
WHERE last_day_of_month.is_last_day_of_month = TRUE
    );

-- check..
SELECT *
FROM calendar_months;
/*
first line:
year_month2,year_quarter,year,month,quarter,month_name,month2,month_name3,month_begin,month_end,days_in_month,hours_in_month,prev_month_last_day,prev_year_month2,is_last_in_quarter,is_last_in_year,weekdays,weekends,special_days,working_days,working_hours,min_date_hour,max_date_hour,min_date_hour_utc_to_cet,max_date_hour_utc_to_cet,next_date,fullname,next_year_month2,order_month_number,order_month_number_desc
2020-01,2020 1,2020,1,1,January  ,01,Jan,2020-01-01,2020-01-31,31,744,2019-12-31,2019-12,false,false,23,8,1,22,176,2020-01-01 00,2020-01-31 23,2019-12-31 23,2020-01-31 22,2020-02-01,Jan 20,2020-02,1,9998
 */
/*
 sza(c)
 */
