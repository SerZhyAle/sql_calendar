/*
 The table calendar_dates pointing each day in period

 The idea to have the table with already calculated parameters for any daily aggregations.
 The fields date and date8 (int 8) can be dimensions in joined aggregated tables.

 week_begin - pointing view calendar_weeks
 year_month2 - pointing view calendar_months
 year - pointing view calendar_years


 All code here equal for MySQL 5.7 and MySQL 8.0 (MariaDB)

 -- _________________________________________________________________ --
 STEP 1.
 Create the table calendar_dates

 USE Your_database_schema

 Use the '_swap' table for creation, filling the table before swap it onto place with one transaction:
 */

DROP TABLE IF EXISTS calendar_dates_swap;

CREATE TABLE calendar_dates_swap
(
    #original uniq combination
    date                   date              NOT NULL PRIMARY KEY COMMENT 'YYYY-MM-DD -date',
    date8                  int UNSIGNED      NOT NULL COMMENT 'YYYYMMDD -int',
    date_ymd               char(10)          NOT NULL COMMENT 'YYYY-MM-DD -char(10)',
    date_dmy               char(10)          NOT NULL COMMENT 'DD.MM.YYYY -char(10)',
    date_mdy               char(10)          NOT NULL COMMENT 'MM/DD/YYYY -char(10)',

    #data
    date_ddmm              char(5)           NOT NULL COMMENT 'DD.MM -char(5)',
    date_mmdd              char(5)           NOT NULL COMMENT 'MM-DD -char(5)',
    date_dmmmy             char(11)          NOT NULL COMMENT 'DD MMM YYYY -char(11)',
    date_dmmmmy            varchar(25)       NOT NULL COMMENT 'DD Month YYYY -varchar(25)',
    day_of_week            smallint UNSIGNED NOT NULL COMMENT 'Day Number in Week 0=sunday -smallint',
    day_of_week_char       varchar(5)        NOT NULL COMMENT 'Name of Number of Day in Week -varchar(5)',
    is_weekday             boolean           NOT NULL COMMENT 'True if NOT Saturday and NOT Sunday -boolean',
    is_weekend             boolean           NOT NULL COMMENT 'True if Saturday or Sunday -boolean',
    is_last_day_of_week    boolean           NOT NULL COMMENT 'True if Sunday -boolean',
    is_last_day_of_month   boolean           NOT NULL COMMENT 'True if last day of month -boolean',
    is_last_day_of_quarter boolean           NOT NULL COMMENT 'True if last day of quarter -boolean',
    is_last_day_of_year    boolean           NOT NULL COMMENT 'True if last day of year -boolean',
    day_name               varchar(10)       NOT NULL COMMENT 'Day Name in Week -varchar(10)',
    day_name3              char(3)           NOT NULL COMMENT 'Day Name in Week -char(3)',
    day_of_month           tinyint UNSIGNED  NOT NULL COMMENT 'Day Number in Month -tinyint',
    day_of_month2          char(2)           NOT NULL COMMENT 'Day Number in Month (0 leads) -char(2)',
    day_of_month_char      varchar(5)        NOT NULL COMMENT 'Name of Number of Day in Month -varchar(5)',
    day_of_quarter         tinyint           NOT NULL COMMENT 'Day Number in Quarter -tinyint',
    day_of_year            smallint UNSIGNED NOT NULL COMMENT 'Day Number in Year -smallint',
    week                   tinyint           NOT NULL COMMENT 'Week Number in Year (first day-monday) -tinyint',
    week2                  char(2)           NOT NULL COMMENT 'Week Number in Year (first day-monday) -char(2)',
    week_finance           tinyint           NOT NULL COMMENT 'Week Number (finance) -tinyint',
    week_fullname          char(23)          NOT NULL COMMENT 'Week YYYY-MM-DD - YYYY-MM-DD fullname -char(23)',
    year_week              char(7)           NOT NULL COMMENT 'Year week YYYY/WW -char(7)',
    month                  tinyint           NOT NULL COMMENT 'Month Number in Year -tinyint',
    month2                 char(2)           NOT NULL COMMENT 'Month Number in Year (0 leads) -char(2)',
    year_month2            char(7)           NOT NULL COMMENT 'Year - Month2 YYYY-MM -char(7)',
    month_name             varchar(10)       NOT NULL COMMENT 'Month Name -varchar(10)',
    month_name3            char(3)           NOT NULL COMMENT 'Month Name -char(3)',
    quarter                tinyint UNSIGNED  NOT NULL COMMENT 'Quarter Number in Year -tinyint',
    year_quarter           char(6)           NOT NULL COMMENT 'Year quarter YYYY Q -char(6)',
    year                   smallint          NOT NULL COMMENT 'Year -smallint',
    year2                  tinyint UNSIGNED  NOT NULL COMMENT 'Year last 2 figures -tinyint',
    year2c                 char(2)           NOT NULL COMMENT 'Year last 2 chars -char(2)',
    days_in_year           smallint UNSIGNED NOT NULL DEFAULT 365 COMMENT 'Amount days in this year def:365 -smallint',

    next_date              date              NOT NULL COMMENT 'Next Date -date',
    prev_date              date              NOT NULL COMMENT 'Previous Date -date',

    day_num_since_2020     int               NOT NULL COMMENT 'Day number since 2020-01-01 for order -int',
    week_num_since_2020    int               NOT NULL COMMENT 'Week number since 2020-01-01 for order -int',
    month_num_since_2020   int               NOT NULL COMMENT 'Month number since 2020-01-01 for order -int',
    quarter_num_since_2020 tinyint           NOT NULL COMMENT 'Quarter number since 2020-01-01 for order -tinyint',
    year_num_since_2020    tinyint           NOT NULL COMMENT 'Year number since 2020-01-01 for order -tinyint',

    week_begin             date              NOT NULL COMMENT 'Date of begin of this week -date',
    week_end               date              NOT NULL COMMENT 'Date of end of this week -date',
    month_begin            date              NOT NULL COMMENT 'Date of begin of this month -date',
    month_end              date              NOT NULL COMMENT 'Date of end of this month -date',
    quarter_begin          date              NOT NULL COMMENT 'Date of begin of this quarter -date',
    quarter_end            date              NOT NULL COMMENT 'Date of end of this quarter -date',
    year_begin             date              NOT NULL COMMENT 'Date of begin of this year -date',
    year_end               date              NOT NULL COMMENT 'Date of end of this year -date',

    week_before            date              NOT NULL COMMENT 'Same date week before -date',
    week_after             date              NOT NULL COMMENT 'Same date prev week -date',
    month_before           date              NOT NULL COMMENT 'Same date month before -date',
    month_after            date              NOT NULL COMMENT 'Same date prev month -date',
    quarter_before         date              NOT NULL COMMENT 'Same date quarter before -date',
    quarter_after          date              NOT NULL COMMENT 'Same date prev quarter -date',
    year_before            date              NOT NULL COMMENT 'Same date next year -date',
    year_after             date              NOT NULL COMMENT 'Same date prev year -date',

    is_working_day         boolean           NOT NULL COMMENT 'Day is working in Sweden not special -tiny(int)',
    is_public_holiday      boolean           NOT NULL COMMENT 'Is public holiday -tiny(int)',
    special_date           varchar(255)      NULL     DEFAULT NULL COMMENT 'Special note for date -varchar(255)',

    zodiac                 varchar(50)       NOT NULL COMMENT 'Zodiac sign -varchar(50)',

    #row activity fields
    created_at             datetime(6)       NOT NULL DEFAULT NOW(6) COMMENT 'Created -datetime(6)',
    updated_at             datetime(6)       NULL     DEFAULT NULL ON UPDATE NOW(6) COMMENT 'Updated -datetime(6)',

    #common fields
    fullname               varchar(255)      NOT NULL COMMENT 'DD MMMM YYYY (DayName) -varchar(255)',
    description            varchar(1000)     NULL     DEFAULT NULL COMMENT 'Commentary for the calendar date -varchar(1000)',

    UNIQUE KEY unique_key_calendar_date (date)
) DEFAULT CHARSET = latin1 COMMENT ='Calendar dates';

CREATE UNIQUE INDEX uniq_index_calendar_dates_date8
    ON calendar_dates_swap (date8);

CREATE INDEX index_calendar_dates_week_num_since_2020
    ON calendar_dates_swap (week_num_since_2020);

CREATE INDEX index_calendar_dates_year_month2
    ON calendar_dates_swap (year_month2);

CREATE INDEX index_calendar_dates_year_quarter
    ON calendar_dates_swap (year_quarter);
/*
 -- _________________________________________________________________ --
 STEP 2.

 Fill the calendar_dates:

 The next procedure stored to fill the calendar:

 Attention:
 SET @day_cursor = '2019.12.31'; -- The BEGIN of the Dates
 SET @day_cursor_end = '2036.12.31';  -- The END of the dates. You probably know what is going on later.

 Take a look onto commented block with holidays which can be changed for your country/region holidays.
 In this example working days set for  1,2,3,4,5 weekdays Mon-Fri
 */

DROP PROCEDURE IF EXISTS service_calendar_dates_population;

CREATE PROCEDURE service_calendar_dates_population()
BEGIN

    SET @special = NULL;
    SET @is_public_holiday = NULL;
    SET @day_of_period = 1;

    SET @day_cursor = '2019-12-31';
    SET @quarter = 4; -- for '2019.12.31'
    SET @quarter_was = 4; -- for '2019.12.31'
    SET @number_of_calendar_week = 53; -- for '2019.12.31'
    SET @day_cursor_end = '2036-12-31';
    SET @begin_of_period = '2019-10-01';

    SET @end_of_period = LAST_DAY(DATE_ADD(@begin_of_period, INTERVAL 3 MONTH));
    SET @day_num_since_2020 = 0,
        @week_num_since_2020 = 1,
        @month_num_since_2020 = 0,
        @quarter_num_since_2020 = 0,
        @year_num_since_2020 = 0,
        @day_of_period = 92;

    WHILE @day_cursor <= @day_cursor_end
        DO
            SET @week_day_number = DATE_FORMAT(@day_cursor, '%w');

            IF DATE_FORMAT(@day_cursor, '%y') IN (20, 24, 28, 32, 36, 40) THEN
                SET @days_in_the_year = 366;
            ELSE
                SET @days_in_the_year = 365;
            END IF;

            IF DAY(@day_cursor) = 1 THEN
                SET @month_num_since_2020 = @month_num_since_2020 + 1;
            END IF;

            IF MONTH(@day_cursor) = 1
                AND DAY(@day_cursor) = 1
            THEN
                SET @is_public_holiday = 1;
                SET @special = 'New Year Day';
            ELSEIF MONTH(@day_cursor) = 5
                AND DAY(@day_cursor) = 1
            THEN
                SET @is_public_holiday = 1;
                SET @special = 'May Day';
            ELSEIF MONTH(@day_cursor) = 12
                AND DAY(@day_cursor) = 25
            THEN
                SET @is_public_holiday = 1;
                SET @special = 'Christmas Day';
            ELSEIF MONTH(@day_cursor) = 12
                AND DAY(@day_cursor) = 26
            THEN
                SET @is_public_holiday = 1;
                SET @special = '2nd Day of Christmas';
                /*
            ELSEIF MONTH(@day_cursor) = 1
                AND DAY(@day_cursor) = 5
            THEN
                SET @is_public_holiday = 1;
                SET @special = 'Epiphany';
            ELSEIF MONTH(@day_cursor) = 4
                AND DAY(@day_cursor) = 6
                AND YEAR(@day_cursor) = 2023
            THEN
                SET @is_public_holiday = 1;
                SET @special = 'Maundy Thursday';
            ELSEIF MONTH(@day_cursor) = 4
                AND DAY(@day_cursor) = 7
                AND YEAR(@day_cursor) = 2023
            THEN
                SET @is_public_holiday = 1;
                SET @special = 'Good Friday';
            ELSEIF MONTH(@day_cursor) = 4
                AND DAY(@day_cursor) = 9
                AND YEAR(@day_cursor) = 2023
            THEN
                SET @is_public_holiday = 1;
                SET @special = 'Easter Sunday';
            ELSEIF MONTH(@day_cursor) = 4
                AND DAY(@day_cursor) = 10
                AND YEAR(@day_cursor) = 2023
            THEN
                SET @is_public_holiday = 1;
                SET @special = 'Easter Monday';
            ELSEIF MONTH(@day_cursor) = 5
                AND DAY(@day_cursor) = 5
            THEN
                SET @is_public_holiday = 1;
                SET @special = 'Prayer Day';
            ELSEIF MONTH(@day_cursor) = 5
                AND DAY(@day_cursor) = 18
            THEN
                SET @is_public_holiday = 1;
                SET @special = 'Ascension Day';
            ELSEIF MONTH(@day_cursor) = 5
                AND DAY(@day_cursor) = 28
            THEN
                SET @is_public_holiday = 1;
                SET @special = 'Whit Sunday';
            ELSEIF MONTH(@day_cursor) = 5
                AND DAY(@day_cursor) = 29
            THEN
                SET @is_public_holiday = 1;
                SET @special = 'Whit Monday';
            ELSEIF MONTH(@day_cursor) = 6
                AND DAY(@day_cursor) = 6
            THEN
                SET @is_public_holiday = 1;
                SET @special = 'National Day';
            ELSEIF MONTH(@day_cursor) = 6
                AND DAY(@day_cursor) = 24
            THEN
                SET @is_public_holiday = 1;
                SET @special = 'Midsummer Day';
            ELSEIF MONTH(@day_cursor) = 11
                AND DAY(@day_cursor) = 4
            THEN
                SET @is_public_holiday = 1;
                SET @special = 'All Saints Day';

                 */
            ELSE
                SET @is_public_holiday = 0;
                SET @special = NULL;
            END IF;

            SET @is_weekend = (IF(@week_day_number IN (6, 0), 1, 0));

            IF (@is_public_holiday + @is_weekend) = 0
            THEN
                SET @is_working_day = 1;
            ELSE
                SET @is_working_day = 0;
            END IF;

            IF MONTH(@day_cursor) IN (4, 7, 10, 1)
                AND DAY(@day_cursor) = 1 THEN

                SET @quarter = @quarter + 1,
                    @begin_of_period = @day_cursor,
                    @end_of_period = LAST_DAY(DATE_ADD(@begin_of_period, INTERVAL 3 MONTH));
            END IF;

            IF MONTH(@day_cursor) = 1
                AND DAY(@day_cursor) = 1 THEN

                SET @quarter = 1,
                    @year_num_since_2020 = @year_num_since_2020 + 1;
            END IF;

            IF @quarter <> @quarter_was THEN
                SET @day_of_period = 1,
                    @quarter_was = @quarter,
                    @quarter_num_since_2020 = @quarter_num_since_2020 + 1;
            END IF;

            IF @week_day_number = 1 THEN

                IF MONTH(@day_cursor) = 1
                    AND @number_of_calendar_week > 50 THEN

                    SET @number_of_calendar_week = 1;
                ELSE
                    SET @number_of_calendar_week = @number_of_calendar_week + 1;
                END IF;
            END IF;

            IF @week_day_number = 1 THEN
                SET @week_num_since_2020 = @week_num_since_2020 + 1;
            END IF;

            SET @month_cursor = EXTRACT(MONTH FROM @day_cursor);
            SET @day_of_cursor = EXTRACT(DAY FROM @day_cursor);
            SET @tomorrow = EXTRACT(DAY FROM DATE_ADD(@day_cursor, INTERVAL 1 DAY));

            INSERT INTO calendar_dates_swap(date,
                                            date8,
                                            date_ymd,
                                            date_dmy,
                                            date_ddmm,
                                            date_mdy,
                                            date_dmmmy,
                                            date_dmmmmy,
                                            day_of_week,
                                            day_of_week_char,
                                            is_weekday,
                                            is_weekend,
                                            day_name,
                                            day_name3,
                                            day_of_month,
                                            day_of_month2,
                                            day_of_month_char,
                                            day_of_quarter,
                                            day_of_year,
                                            week,
                                            week2,
                                            week_finance,
                                            year_week,
                                            month,
                                            month2,
                                            month_name,
                                            month_name3,
                                            quarter,
                                            year_quarter,
                                            year,
                                            year2,
                                            year2c,
                                            days_in_year,
                                            zodiac,
                                            is_public_holiday,
                                            fullname,
                                            is_last_day_of_week,
                                            is_last_day_of_month,
                                            is_last_day_of_quarter,
                                            is_last_day_of_year,
                                            week_begin,
                                            week_end,
                                            month_begin,
                                            month_end,
                                            quarter_begin,
                                            quarter_end,
                                            year_begin,
                                            year_end,
                                            week_before,
                                            week_after,
                                            month_before,
                                            month_after,
                                            quarter_before,
                                            quarter_after,
                                            year_before,
                                            year_after,
                                            special_date,
                                            is_working_day,
                                            day_num_since_2020,
                                            week_num_since_2020,
                                            month_num_since_2020,
                                            quarter_num_since_2020,
                                            year_num_since_2020,
                                            year_month2,
                                            next_date,
                                            prev_date,
                                            date_mmdd,
                                            week_fullname)
            VALUES (@day_cursor,
                    DATE_FORMAT(@day_cursor, '%Y%m%d'),
                    DATE_FORMAT(@day_cursor, '%Y-%m-%d'),
                    DATE_FORMAT(@day_cursor, '%d.%m.%Y'),
                    DATE_FORMAT(@day_cursor, '%d.%m'),
                    DATE_FORMAT(@day_cursor, '%m/%d/%Y'),
                    DATE_FORMAT(@day_cursor, '%d %b %Y'),
                    DATE_FORMAT(@day_cursor, '%d %M %Y'),
                    @week_day_number,
                    CONCAT((@week_day_number + 1), CASE
                                                       WHEN (@week_day_number + 1) > 3 THEN 'th'
                                                       WHEN (@week_day_number + 1) = 1 THEN 'st'
                                                       WHEN (@week_day_number + 1) = 2 THEN 'nd'
                                                       ELSE 'rd' END),
                    IF(@week_day_number IN (6, 0), FALSE, TRUE),
                    @is_weekend,
                    DATE_FORMAT(@day_cursor, '%W'),
                    DATE_FORMAT(@day_cursor, '%a'),
                    EXTRACT(DAY FROM @day_cursor),
                    DATE_FORMAT(@day_cursor, '%d'),
                    DATE_FORMAT(@day_cursor, '%D'),
                    @day_of_period,
                    DATE_FORMAT(@day_cursor, '%j'),
                    @number_of_calendar_week,
                    RIGHT(CONCAT('0', WEEK(@day_cursor, 1)), 2),
                    DATE_FORMAT(@day_cursor, '%v'),
                    CONCAT(EXTRACT(YEAR FROM @day_cursor), '/', RIGHT(CONCAT('0', @number_of_calendar_week), 2)),
                    @month_cursor,
                    DATE_FORMAT(@day_cursor, '%m'),
                    DATE_FORMAT(@day_cursor, '%M'),
                    DATE_FORMAT(@day_cursor, '%b'),
                    @quarter,
                    CONCAT(EXTRACT(YEAR FROM @day_cursor), ' ', @quarter),
                    EXTRACT(YEAR FROM @day_cursor),
                    DATE_FORMAT(@day_cursor, '%y'),
                    DATE_FORMAT(@day_cursor, '%y'),
                    @days_in_the_year,
                    CASE
                        WHEN (@day_of_cursor >= 21 AND @month_cursor = 3
                            OR @day_of_cursor <= 19 AND @month_cursor = 4)
                            THEN '03 Aries'
                        WHEN (@day_of_cursor >= 20 AND @month_cursor = 4
                            OR @day_of_cursor <= 20 AND @month_cursor = 5)
                            THEN '04 Taurus'
                        WHEN (@day_of_cursor >= 21 AND @month_cursor = 5
                            OR @day_of_cursor <= 20 AND @month_cursor = 6)
                            THEN '05 Gemini'
                        WHEN (@day_of_cursor >= 21 AND @month_cursor = 6
                            OR @day_of_cursor <= 22 AND @month_cursor = 7)
                            THEN '06 Cancer'
                        WHEN (@day_of_cursor >= 23 AND @month_cursor = 7
                            OR @day_of_cursor <= 22 AND @month_cursor = 8)
                            THEN '07 Leo'
                        WHEN (@day_of_cursor >= 23 AND @month_cursor = 8
                            OR @day_of_cursor <= 22 AND @month_cursor = 9)
                            THEN '08 Virgo'
                        WHEN (@day_of_cursor >= 23 AND @month_cursor = 9
                            OR @day_of_cursor <= 22 AND @month_cursor = 10)
                            THEN '09 Libra'
                        WHEN (@day_of_cursor >= 23 AND @month_cursor = 10
                            OR @day_of_cursor <= 21 AND @month_cursor = 11)
                            THEN '10 Scorpio'
                        WHEN (@day_of_cursor >= 22 AND @month_cursor = 11
                            OR @day_of_cursor <= 21 AND @month_cursor = 12)
                            THEN '11 Sagittarius'
                        WHEN (@day_of_cursor >= 22 AND @month_cursor = 12
                            OR @day_of_cursor <= 20 AND @month_cursor = 1)
                            THEN '12 Capricorn'
                        WHEN (@day_of_cursor >= 21 AND @month_cursor = 1
                            OR @day_of_cursor <= 18 AND @month_cursor = 2)
                            THEN '01 Aquarius'
                        ELSE '02 Pisces'
                        END,
                    @is_public_holiday,
                    DATE_FORMAT(@day_cursor, '%D %M %Y (%W)'),
                    IF(@week_day_number = 0, 1, 0),
                    IF(@tomorrow = 1, 1, 0),
                    IF(EXTRACT(MONTH FROM DATE_ADD(@day_cursor, INTERVAL 1 DAY)) IN (1, 4, 7, 10)
                           AND @tomorrow = 1, 1, 0),
                    IF(EXTRACT(MONTH FROM DATE_ADD(@day_cursor, INTERVAL 1 DAY)) = 1
                           AND @tomorrow = 1, 1, 0),
                    DATE_ADD(@day_cursor, INTERVAL IF(@week_day_number = 0, -6, -@week_day_number + 1) DAY),
                    DATE_ADD(@day_cursor, INTERVAL IF(@week_day_number = 0, 0, 7 - @week_day_number) DAY),
                    DATE_FORMAT(@day_cursor, '%Y-%m-01'),
                    LAST_DAY(@day_cursor),
                    @begin_of_period,
                    @end_of_period,
                    MAKEDATE(YEAR(@day_cursor), 1),
                    DATE_ADD(MAKEDATE(YEAR(@day_cursor) + 1, 1), INTERVAL -1 DAY),
                    DATE_ADD(@day_cursor, INTERVAL -7 DAY),
                    DATE_ADD(@day_cursor, INTERVAL 7 DAY),
                    DATE_ADD(@day_cursor, INTERVAL -1 MONTH),
                    DATE_ADD(@day_cursor, INTERVAL 1 MONTH),
                    DATE_ADD(@day_cursor, INTERVAL -3 MONTH),
                    DATE_ADD(@day_cursor, INTERVAL 3 MONTH),
                    DATE_ADD(@day_cursor, INTERVAL -1 YEAR),
                    DATE_ADD(@day_cursor, INTERVAL 1 YEAR),
                    @special,
                    @is_working_day,
                    @day_num_since_2020,
                    @week_num_since_2020,
                    @month_num_since_2020,
                    @quarter_num_since_2020,
                    @year_num_since_2020,
                    CONCAT(EXTRACT(YEAR FROM @day_cursor), '-', DATE_FORMAT(@day_cursor, '%m')),
                    DATE_ADD(@day_cursor, INTERVAL 1 DAY),
                    DATE_ADD(@day_cursor, INTERVAL -1 DAY),
                    DATE_FORMAT(@day_cursor, '%m-%d'),
                    CONCAT(DATE_ADD(@day_cursor, INTERVAL IF(@week_day_number = 0, -6, -@week_day_number + 1)
                                    DAY), ' - ',
                           DATE_ADD(@day_cursor, INTERVAL IF(@week_day_number = 0, 0, 7 - @week_day_number)
                                    DAY)));

            SET @day_cursor = DATE_ADD(@day_cursor, INTERVAL 1 DAY);
            SET @day_of_period = @day_of_period + 1;
            SET @day_num_since_2020 = @day_num_since_2020 + 1;

        END WHILE;
    START TRANSACTION ;
    DROP TABLE IF EXISTS calendar_dates;
    RENAME TABLE calendar_dates_swap TO calendar_dates;
    COMMIT;

END;

/*
 STEP 3.

 RUN IT!

 It takes up to 40 seconds.
 */

CALL service_calendar_dates_population();

/*
 Check it..
 */
SELECT *
FROM calendar_dates;

SELECT COUNT(*) AS d
FROM calendar_dates;
-- result: 6211

SELECT (COUNT(*) / 356) AS y
FROM calendar_dates;
-- 17.4466

SELECT *
FROM calendar_dates
WHERE date IN (CURRENT_DATE, '2023.12.01', '2024.01.01', '2023-02-25', '2022-12-31', '2023-03-31')
ORDER BY date;
/*
result:

date,date8,date_ymd,date_dmy,date_mdy,date_ddmm,date_mmdd,date_dmmmy,date_dmmmmy,day_of_week,day_of_week_char,is_weekday,is_weekend,is_last_day_of_week,is_last_day_of_month,is_last_day_of_quarter,is_last_day_of_year,day_name,day_name3,day_of_month,day_of_month2,day_of_month_char,day_of_quarter,day_of_year,week,week2,week_finance,week_fullname,year_week,month,month2,year_month2,month_name,month_name3,quarter,year_quarter,year,year2,year2c,days_in_year,next_date,prev_date,day_num_since_2020,week_num_since_2020,month_num_since_2020,quarter_num_since_2020,year_num_since_2020,week_begin,week_end,month_begin,month_end,quarter_begin,quarter_end,year_begin,year_end,week_before,week_after,month_before,month_after,quarter_before,quarter_after,year_before,year_after,is_working_day,is_public_holiday,special_date,zodiac,created_at,updated_at,fullname,description
2022-12-31,20221231,2022-12-31,31.12.2022,12/31/2022,31.12,12-31,31 Dec 2022,31 December 2022,6,7th,0,1,0,1,1,1,Saturday,Sat,31,31,31st,92,365,52,52,52,2022-12-26 - 2023-01-01,2022/52,12,12,2022-12,December,Dec,4,2022 4,2022,22,22,365,2023-01-01,2022-12-30,1097,157,36,13,3,2022-12-26,2023-01-01,2022-12-01,2022-12-31,2022-10-01,2023-01-31,2022-01-01,2022-12-31,2022-12-24,2023-01-07,2022-11-30,2023-01-31,2022-09-30,2023-03-31,2021-12-31,2023-12-31,0,0,,12 Capricorn,2023-11-22 03:45:21.483214,,31st December 2022 (Saturday),
2023-02-25,20230225,2023-02-25,25.02.2023,02/25/2023,25.02,02-25,25 Feb 2023,25 February 2023,6,7th,0,1,0,0,0,0,Saturday,Sat,25,25,25th,56,56,8,8,8,2023-02-20 - 2023-02-26,2023/08,2,02,2023-02,February,Feb,1,2023 1,2023,23,23,365,2023-02-26,2023-02-24,1153,165,38,14,4,2023-02-20,2023-02-26,2023-02-01,2023-02-28,2023-01-01,2023-04-30,2023-01-01,2023-12-31,2023-02-18,2023-03-04,2023-01-25,2023-03-25,2022-11-25,2023-05-25,2022-02-25,2024-02-25,0,0,,02 Pisces,2023-11-22 03:45:21.646322,,25th February 2023 (Saturday),
2023-03-31,20230331,2023-03-31,31.03.2023,03/31/2023,31.03,03-31,31 Mar 2023,31 March 2023,5,6th,1,0,0,1,1,0,Friday,Fri,31,31,31st,90,90,13,13,13,2023-03-27 - 2023-04-02,2023/13,3,03,2023-03,March,Mar,1,2023 1,2023,23,23,365,2023-04-01,2023-03-30,1187,170,39,14,4,2023-03-27,2023-04-02,2023-03-01,2023-03-31,2023-01-01,2023-04-30,2023-01-01,2023-12-31,2023-03-24,2023-04-07,2023-02-28,2023-04-30,2022-12-31,2023-06-30,2022-03-31,2024-03-31,1,0,,03 Aries,2023-11-22 03:45:21.724917,,31st March 2023 (Friday),
2023-11-22,20231122,2023-11-22,22.11.2023,11/22/2023,22.11,11-22,22 Nov 2023,22 November 2023,3,4th,1,0,0,0,0,0,Wednesday,Wed,22,22,22nd,53,326,47,47,47,2023-11-20 - 2023-11-26,2023/47,11,11,2023-11,November,Nov,4,2023 4,2023,23,23,365,2023-11-23,2023-11-21,1423,204,47,17,4,2023-11-20,2023-11-26,2023-11-01,2023-11-30,2023-10-01,2024-01-31,2023-01-01,2023-12-31,2023-11-15,2023-11-29,2023-10-22,2023-12-22,2023-08-22,2024-02-22,2022-11-22,2024-11-22,1,0,,11 Sagittarius,2023-11-22 03:45:22.312390,,22nd November 2023 (Wednesday),
2023-12-01,20231201,2023-12-01,01.12.2023,12/01/2023,01.12,12-01,01 Dec 2023,01 December 2023,5,6th,1,0,0,0,0,0,Friday,Fri,1,01,1st,62,335,48,48,48,2023-11-27 - 2023-12-03,2023/48,12,12,2023-12,December,Dec,4,2023 4,2023,23,23,365,2023-12-02,2023-11-30,1432,205,48,17,4,2023-11-27,2023-12-03,2023-12-01,2023-12-31,2023-10-01,2024-01-31,2023-01-01,2023-12-31,2023-11-24,2023-12-08,2023-11-01,2024-01-01,2023-09-01,2024-03-01,2022-12-01,2024-12-01,1,0,,11 Sagittarius,2023-11-22 03:45:22.332508,,1st December 2023 (Friday),
2024-01-01,20240101,2024-01-01,01.01.2024,01/01/2024,01.01,01-01,01 Jan 2024,01 January 2024,1,2nd,1,0,0,0,0,0,Monday,Mon,1,01,1st,1,1,1,1,1,2024-01-01 - 2024-01-07,2024/01,1,01,2024-01,January,Jan,1,2024 1,2024,24,24,366,2024-01-02,2023-12-31,1463,210,49,18,5,2024-01-01,2024-01-07,2024-01-01,2024-01-31,2024-01-01,2024-04-30,2024-01-01,2024-12-31,2023-12-25,2024-01-08,2023-12-01,2024-02-01,2023-10-01,2024-04-01,2023-01-01,2025-01-01,0,1,New Year Day,12 Capricorn,2023-11-22 03:45:22.407701,,1st January 2024 (Monday),
 */

-- NEXT: calendar_hours presented in separated sql file

/*
 sza(c)
 */
