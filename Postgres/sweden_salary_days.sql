/*
 Next code an example to set the salary days for Sweden

 using (updating) the table calendar_dates which should be created and filled, presented in separated file)
 use view calendar_months (should be created, presented in separated file)

 */
UPDATE calendar_dates
SET special_date = NULL
WHERE special_date = 'SE Salary day';

UPDATE calendar_dates
SET special_date = 'SE Salary day'
WHERE date IN (SELECT CONCAT(calendar_month.year, '-',
                             date_25.month2, '-',
                             CASE
                                 WHEN (date_25.is_weekend = TRUE
                                     OR date_25.is_public_holiday = TRUE) THEN
                                     CASE
                                         WHEN (date_24.is_weekend = TRUE
                                             OR date_24.is_public_holiday = TRUE) THEN
                                             CASE
                                                 WHEN (date_23.is_weekend = TRUE
                                                     OR date_23.is_public_holiday = TRUE) THEN
                                                     CASE
                                                         WHEN (date_22.is_weekend = TRUE
                                                             OR date_22.is_public_holiday = TRUE) THEN '21'
                                                         ELSE '22' END
                                                 ELSE '23' END
                                         ELSE '24' END
                                 ELSE '25' END)::date AS date_to_update
               FROM calendar_months AS calendar_month
                   JOIN calendar_dates AS date_25
                       ON calendar_month.year = date_25.year
                       AND calendar_month.month = date_25.month
                       AND date_25.day_of_month = 25
                   JOIN calendar_dates AS date_24
                       ON calendar_month.year = date_24.year
                       AND calendar_month.month = date_24.month
                       AND date_24.day_of_month = 24
                   JOIN calendar_dates AS date_23
                       ON calendar_month.year = date_23.year
                       AND calendar_month.month = date_23.month
                       AND date_23.day_of_month = 23
                   JOIN calendar_dates AS date_22
                       ON calendar_month.year = date_22.year
                       AND calendar_month.month = date_22.month
                       AND date_22.day_of_month = 22);

-- check..
SELECT *
FROM calendar_dates
WHERE special_date = 'SE Salary day';
/*
 first line:
date,date8,date_ymd,date_dmy,date_mdy,date_ddmm,date_mmdd,date_dmmmy,date_dmmmmy,day_of_week,day_of_week_char,is_weekday,is_weekend,is_last_day_of_week,is_last_day_of_month,is_last_day_of_quarter,is_last_day_of_year,day_name,day_name3,day_of_month,day_of_month2,day_of_month_char,day_of_quarter,day_of_year,week,week2,week_finance,week_fullname,year_week,month,month2,year_month2,month_name,month_name3,quarter,year_quarter,year,year2,year2c,days_in_year,next_date,prev_date,day_num_since_2020,week_num_since_2020,month_num_since_2020,quarter_num_since_2020,year_num_since_2020,week_begin,week_end,month_begin,month_end,quarter_begin,quarter_end,year_begin,year_end,week_before,week_after,month_before,month_after,quarter_before,quarter_after,year_before,year_after,is_working_day,is_public_holiday,special_date,zodiac,created_at,updated_at,fullname,description
2020-01-24,20200124,2020-01-24,24.01.2020,01/24/2020,24.01,01-24,6 JAN 20   ,6 January   20,5,6th,true,false,false,false,false,false,Friday   ,FRI,24,24,24th,24,24,3,03,4,20-01-30 - 20-01-26,2020/03,1,01,2020-01,January  ,Jan,1,2020 1,2020,20,20,366,2020-01-25,2020-01-23,25,4,1,2,1,2020-01-20,2020-01-26,2020-01-01,2020-01-31,2020-01-01,2020-03-31,2020-01-01,2020-12-31,2020-01-17,2020-01-31,2019-12-24,2020-02-24,2019-10-24,2020-04-24,2019-01-24,2021-01-24,true,false,SE Salary day,01 Aquarius,2023-11-22 17:34:32.919887,,24 January   2020 (04),
 */
/*
 sza(c)
 */
