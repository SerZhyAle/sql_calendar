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
                             IIF(date_25.is_weekend = 1
                                     OR date_25.is_public_holiday = 1,
                                 IIF(date_24.is_weekend = 1
                                         OR date_24.is_public_holiday = 1,
                                     IIF(date_23.is_weekend = 1
                                             OR date_23.is_public_holiday = 1,
                                         IIF(date_22.is_weekend = 1
                                                 OR date_22.is_public_holiday = 1, '21', '22'),
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
                       AND date_22.day_of_month = 22);


-- check..
SELECT *
FROM calendar_dates
WHERE special_date = 'SE Salary day';

/*
 sza(c)
 */
