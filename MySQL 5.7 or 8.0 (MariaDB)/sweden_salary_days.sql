/*
 Next code an example to set the salary days for Sweden

 using (updating) the table calendar_dates which should be created and filled, presented in separated file)
 use view calendar_months (should be created, presented in separated file)

 Code for MySQL (MariaDB)
 */

DROP TEMPORARY TABLE IF EXISTS temp_se_salary_days;
CREATE TEMPORARY TABLE temp_se_salary_days
SELECT CONCAT(calendar_month.year, '-',
              date_25.month2, '-',
              IF(date_25.is_weekend
                     OR date_25.is_public_holiday,
                 IF(date_24.is_weekend
                        OR date_24.is_public_holiday,
                    IF(date_23.is_weekend
                           OR date_23.is_public_holiday,
                       IF(date_22.is_weekend
                              OR date_22.is_public_holiday, '21', '22'),
                       '23'), '24'), '25')) AS date_to_update
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
        AND date_22.day_of_month = 22;

UPDATE calendar_dates AS target
SET target.special_date = NULL
WHERE target.special_date = 'SE Salary day';

UPDATE calendar_dates AS target
SET target.special_date = 'SE Salary day'
WHERE target.date IN (SELECT date_to_update FROM temp_se_salary_days);

DROP TEMPORARY TABLE temp_se_salary_days;

-- check..
SELECT *
FROM calendar_dates
WHERE special_date = 'SE Salary day';

/*
 sza(c)
 */
