/* Table calendar_hours pointing each hour for calendar dates.

 The fields
  -- date_hour char(13)
 or
 -- date_hour10 int(10)
 can be used as dimensions for aggregated tables.
See all presented columns with its description below..
 
 Table calendar_hours depends from the calendar_dates
  Please create calender_dates first

 In this example Hours focused on two time-zones: UTC and CET

 Please run first:
 SELECT *
 FROM mysql.time_zone_name
 WHERE name in ('UTC', 'CET');

 If you DONT have two lines, but NULL result, then you have to consider first to apply the file
 timezone_posix.sql (presented on the common MySQL level here in ZIP).


 If you have two timezones, then check next two:

 SELECT CONVERT_TZ('2023-01-01', 'UTC', 'CET');
 -- must be: 2023-01-01 01:00:00

 and

 SELECT CONVERT_TZ('2023-06-01', 'UTC', 'CET');
-- must be: 2023-06-01 02:00:00

 In this case we have summer time shift, so we can create the calendar_hours..

   All code here equal for MySQL 5.7 and MySQL 8.0
 --
 STEP 1.
 Create the _swap table to be able switch the table in one transaction:

 */

DROP TABLE IF EXISTS calendar_hours_swap;

CREATE TABLE calendar_hours_swap
(
    #original uniq combination
    date_hour             char(13) PRIMARY KEY COMMENT 'Date and hour YYYY-MM-DD hh -char(13)',
    date_hour10           int UNSIGNED     NOT NULL COMMENT 'YYYYMMDDhh -int',
    date                  date             NOT NULL COMMENT 'UTC date YYYY-MM-DD -date',
    hour                  tinyint UNSIGNED NOT NULL COMMENT 'Hour UTC -tinyint',
    hour_cet              tinyint UNSIGNED NOT NULL COMMENT 'Hour CET -tinyint',

    #data
    date_hour_cet         char(13)         NOT NULL COMMENT 'Date and hour YYYY-MM-DD hh in CET -char(13)',
    date_cet              date             NOT NULL COMMENT 'CET date YYYY-MM-DD -date',
    year_month2           char(7)          NOT NULL COMMENT 'Year - Month2 UTC YYYY-MM -char(7)',
    year_month2_cet       char(7)          NOT NULL COMMENT 'Year - Month2 CET YYYY-MM -char(7)',
    first_second          datetime(6)      NOT NULL COMMENT 'first second -datetime(6)',
    last_second           datetime(6)      NOT NULL COMMENT 'last second -datetime(6)',
    hour2                 char(2)          NOT NULL COMMENT 'Hour UTC -char(2)',
    hour2_cet             char(2)          NOT NULL COMMENT 'Hour CET -char(2)',
    dd_hh                 char(5)          NOT NULL COMMENT 'DD.hh -char(5)',
    is_last_in_week       boolean          NOT NULL COMMENT 'Hour is last in week -boolean',
    is_last_in_month      boolean          NOT NULL COMMENT 'Hour is last in month -boolean',
    is_last_in_quarter    boolean          NOT NULL COMMENT 'Hour is last in quarter -boolean',
    is_last_in_year       boolean          NOT NULL COMMENT 'Hour is last in year -boolean',

    is_lunch_hour         boolean          NOT NULL COMMENT 'Hour 12, 13 for weekdays not special -boolean',
    is_night              boolean          NOT NULL COMMENT 'Hour between 22 and 05 -boolean',
    is_morning            boolean          NOT NULL COMMENT 'Hour between 06 and 09 -boolean',
    is_daylight           boolean          NOT NULL COMMENT 'Hour between 10 and 18 -boolean',
    is_evening            boolean          NOT NULL COMMENT 'Hour between 19 and 22 -boolean',

    is_working_hour       boolean          NOT NULL COMMENT 'Hour 8-11 / 14-18 for weekdays not special -boolean',
    is_working_day        boolean          NOT NULL COMMENT 'Day of hour is working not special -boolean',
    is_public_holiday     boolean          NOT NULL COMMENT 'Is public holiday in -boolean',
    special_hour          varchar(255)     NULL     DEFAULT NULL COMMENT 'Special note for hour -varchar(255)',

    #short
    date_hour_short       char(11)         NOT NULL COMMENT 'Date and hour YY-MM-DD hh -char(11)',
    date_hour8            int UNSIGNED     NOT NULL COMMENT 'YYMMDDhh -int',
    date_short            char(8)          NOT NULL COMMENT 'UTC date YY-MM-DD -char(8)',
    date_hour_cet_short   char(11)         NOT NULL COMMENT 'Date and hour YY-MM-DD hh in CET -char(11)',
    date_cet_short        char(8)          NOT NULL COMMENT 'CET date YY-MM-DD -char(8)',
    year_month2_short     char(5)          NOT NULL COMMENT 'Year - Month2 UTC YY-MM -char(5)',
    year_month2_cet_short char(5)          NOT NULL COMMENT 'Year - Month2 CET YY-MM -char(5)',

    #row activity fields
    created_at            datetime(6)      NOT NULL DEFAULT NOW(6) COMMENT 'Created -datetime(6)',
    updated_at            datetime(6)      NULL     DEFAULT NULL ON UPDATE NOW(6) COMMENT 'Updated -datetime(6)',

    #common fields
    fullname              varchar(255)     NOT NULL COMMENT 'DD MMMM YYYY (DayName) -varchar(255)',
    description           varchar(1000)             DEFAULT NULL COMMENT 'Commentary for hour of date -varchar(1000)',

    UNIQUE INDEX uniq_index_calendar_hours_date_hour (date_hour),
    INDEX index_calendar_hours_date_hour_cet (date_hour_cet),
    INDEX index_calendar_hours_date (date),
    INDEX index_calendar_hours_year_month2 (year_month2)
) COMMENT = 'Hours of calendar dates';

CREATE INDEX index_calendar_hours_year_month2_cet
    ON calendar_hours_swap (year_month2_cet);

CREATE INDEX index_calendar_hours_date_hour10
    ON calendar_hours_swap (date_hour10);

/*
 STEP 2.

 Create procedure to populate the calendar_hours for calendar_dates:

  */

DROP PROCEDURE IF EXISTS service_calendar_hours_population;

CREATE PROCEDURE service_calendar_hours_population()
BEGIN
    SET @special = NULL;

    SELECT MIN(date) AS md
    FROM calendar_dates
    INTO @day_cursor;

    SET @hour_cursor = 0;
    SET @hour2 = 'XX';

    DROP TEMPORARY TABLE IF EXISTS temp_hours;
    CREATE TEMPORARY TABLE temp_hours LIKE calendar_hours_swap;

    SELECT MAX(date) AS md
    FROM calendar_dates
    INTO @dd;

    WHILE @day_cursor <= @dd
        DO

            SELECT is_last_day_of_week
            FROM calendar_dates
            WHERE date = @day_cursor
            INTO @last_day_of_week;

            SELECT is_last_day_of_month
            FROM calendar_dates
            WHERE date = @day_cursor
            INTO @last_day_of_month;

            SELECT is_last_day_of_quarter
            FROM calendar_dates
            WHERE date = @day_cursor
            INTO @last_day_of_period;

            SELECT is_last_day_of_year
            FROM calendar_dates
            WHERE date = @day_cursor
            INTO @last_day_of_year;

            SELECT is_public_holiday
            FROM calendar_dates
            WHERE date = @day_cursor
            INTO @is_public_holiday;

            SELECT IF(is_weekend = 0 AND is_public_holiday = 0, 1, 0) AS is_working_day
            FROM calendar_dates
            WHERE date = @day_cursor
            INTO @is_working_day;

            SET @hour_cursor = 0;

            WHILE @hour_cursor <= 23
                DO
                    SET @hour2 = RIGHT(CONCAT('0', @hour_cursor), 2);

                    SET @calculated_date_hour = CONCAT(@day_cursor, ' ', @hour2);
                    SET @first_sec = CONCAT(@calculated_date_hour, ':00:00');
                    -- UTC to CET
                    SET @cet = CONVERT_TZ(@first_sec, 'UTC', 'CET');

                    SET @date_cet = LEFT(@cet, 10);

                    INSERT INTO temp_hours(date,
                                           date_cet,
                                           date_hour_cet,
                                           year_month2,
                                           year_month2_cet,
                                           first_second,
                                           last_second,
                                           date_hour,
                                           date_hour10,
                                           hour,
                                           hour_cet,
                                           hour2,
                                           hour2_cet,
                                           special_hour,
                                           fullname,
                                           dd_hh,
                                           is_last_in_week,
                                           is_last_in_month,
                                           is_last_in_quarter,
                                           is_last_in_year,
                                           is_night,
                                           is_lunch_hour,
                                           is_working_hour,
                                           is_working_day,
                                           is_public_holiday,
                                           is_morning,
                                           is_daylight,
                                           is_evening,
                                           date_hour_short,
                                           date_hour8,
                                           date_short,
                                           date_hour_cet_short,
                                           date_cet_short,
                                           year_month2_short,
                                           year_month2_cet_short)
                    VALUES (@day_cursor,
                            @date_cet,
                            LEFT(@cet, 13),
                            LEFT(@day_cursor, 7),
                            LEFT(@cet, 7),
                            @first_sec,
                            CONCAT(@calculated_date_hour, ':59:59.999999'),
                            @calculated_date_hour,
                            CONCAT(DATE_FORMAT(@day_cursor, '%Y%m%d'), @hour2),
                            @hour_cursor,
                            SUBSTR(@cet, 12, 2),
                            @hour2,
                            SUBSTR(@cet, 12, 2),
                            @special, CONCAT(@calculated_date_hour, ' UTC'),
                            CONCAT(DATE_FORMAT(@day_cursor, '%d.'), @hour2),
                            IF(@last_day_of_week = 1 AND @hour_cursor = 23, 1, 0),
                            IF(@last_day_of_month = 1 AND @hour_cursor = 23, 1, 0),
                            IF(@last_day_of_period = 1 AND @hour_cursor = 23, 1, 0),
                            IF(@last_day_of_year = 1 AND @hour_cursor = 23, 1, 0),
                            IF(@hour_cursor > 22 OR @hour_cursor < 6, 1, 0),
                            IF(@hour_cursor = 12 OR @hour_cursor = 13, 1, 0),
                            IF(((@hour_cursor > 7 AND @hour_cursor < 12)
                                OR (@hour_cursor > 13 AND @hour_cursor < 19))
                                   AND @is_working_day = 1, 1, 0),
                            @is_working_day,
                            @is_public_holiday,
                            IF(@hour_cursor BETWEEN 6 AND 9, 1, 0),
                            IF(@hour_cursor BETWEEN 10 AND 18, 1, 0),
                            IF(@hour_cursor BETWEEN 19 AND 22, 1, 0),
                            RIGHT(@calculated_date_hour, 11),
                            RIGHT(CONCAT(DATE_FORMAT(@day_cursor, '%Y%m%d'), @hour2), 8),
                            RIGHT(@day_cursor, 8),
                            SUBSTR(@cet, 3, 11),
                            RIGHT(@date_cet, 8),
                            SUBSTR(@day_cursor, 3, 5),
                            SUBSTR(@cet, 3, 5));

                    SET @hour_cursor = @hour_cursor + 1;
                END WHILE;

            SET @day_cursor = DATE_ADD(@day_cursor, INTERVAL 1 DAY);
        END WHILE;

    INSERT INTO calendar_hours_swap(date,
                                    date_cet,
                                    date_hour_cet,
                                    year_month2,
                                    year_month2_cet,
                                    first_second,
                                    last_second,
                                    date_hour,
                                    date_hour10,
                                    hour,
                                    hour_cet,
                                    hour2,
                                    hour2_cet,
                                    special_hour,
                                    fullname,
                                    dd_hh,
                                    is_last_in_week,
                                    is_last_in_month,
                                    is_last_in_quarter,
                                    is_last_in_year,
                                    is_night,
                                    is_lunch_hour,
                                    is_working_hour,
                                    is_working_day,
                                    is_public_holiday,
                                    is_morning,
                                    is_daylight,
                                    is_evening,
                                    date_hour_short,
                                    date_hour8,
                                    date_short,
                                    date_hour_cet_short,
                                    date_cet_short,
                                    year_month2_short,
                                    year_month2_cet_short)
    SELECT date,
           date_cet,
           date_hour_cet,
           year_month2,
           year_month2_cet,
           first_second,
           last_second,
           date_hour,
           date_hour10,
           hour,
           hour_cet,
           hour2,
           hour2_cet,
           special_hour,
           fullname,
           dd_hh,
           is_last_in_week,
           is_last_in_month,
           is_last_in_quarter,
           is_last_in_year,
           is_night,
           is_lunch_hour,
           is_working_hour,
           is_working_day,
           is_public_holiday,
           is_morning,
           is_daylight,
           is_evening,
           date_hour_short,
           date_hour8,
           date_short,
           date_hour_cet_short,
           date_cet_short,
           year_month2_short,
           year_month2_cet_short
    FROM temp_hours;

    DROP TEMPORARY TABLE temp_hours;

    START TRANSACTION;
    DROP TABLE IF EXISTS calendar_hours;
    RENAME TABLE calendar_hours_swap TO calendar_hours;
    COMMIT;

END;

/*
  STEP 3.
  RUN IT!

  It can take up to 30 seconds
 */
-- _________________________________________________________________ --

CALL service_calendar_hours_population();

/*
   check..

   SELECT * FROM calendar_hours;
   SELECT COUNT(*) as h FROM calendar_hours;
   -- 149064

   SELECT COUNT(*)/24 as d FROM calendar_hours;
   -- 6211.0000

   SELECT (COUNT(*)/24)/356 as y FROM calendar_hours;
   -- 17.44662921

#check..
SELECT *
FROM calendar_hours
WHERE date IN (CURRENT_DATE, '2023.12.01', '2022-12-31')
ORDER BY date_hour;

   first line:
date_hour,date_hour10,date,hour,hour_cet,date_hour_cet,date_cet,year_month2,year_month2_cet,first_second,last_second,hour2,hour2_cet,dd_hh,is_last_in_week,is_last_in_month,is_last_in_quarter,is_last_in_year,is_lunch_hour,is_night,is_morning,is_daylight,is_evening,is_working_hour,is_working_day,is_public_holiday,special_hour,date_hour_short,date_hour8,date_short,date_hour_cet_short,date_cet_short,year_month2_short,year_month2_cet_short,created_at,updated_at,fullname,description
2022-12-31 00,2022123100,2022-12-31,0,1,2022-12-31 01,2022-12-31,2022-12,2022-12,2022-12-31 00:00:00.000000,2022-12-31 00:59:59.999999,00,01,31.00,0,0,0,0,0,1,0,0,0,0,0,0,,22-12-31 00,22123100,22-12-31,22-12-31 01,22-12-31,22-12,22-12,2023-11-20 20:56:35.756567,,2022-12-31 00 UTC,

 */
-- _________________________________________________________________ --

/*
 The next tables is optional.

 This is short indexed versions of the calendar_hours
 If you use date_hour or date_hour10 as a dimension for the data, next tables will be better to use for joins for big data selections:


 */
-- _________________________________________________________________ --
/*
 short version for date_hour char(13)

 for example:

SELECT src.*
FROM data_table AS src
    JOIN calendar_hours_short AS h
        ON h.date_hour = src.date_hour
WHERE h.date = '2023-11-16';
 */


DROP TABLE IF EXISTS calendar_hours_short;

CREATE TABLE calendar_hours_short
(
    date_hour   char(13) PRIMARY KEY COMMENT 'Date and hour YYYY-MM-DD hh -char(13)',
    date        date             NOT NULL COMMENT 'UTC date YYYY-MM-DD -date',
    year_month2 char(7)          NOT NULL COMMENT 'Year - Month2 YYYY-MM -char(7)',
    hour        tinyint UNSIGNED NOT NULL COMMENT 'Hour -tinyint'
) COMMENT = 'Hours of calendar dates Short version';

INSERT INTO calendar_hours_short(date_hour, date, year_month2, hour)
SELECT date_hour,
       date,
       year_month2,
       hour
FROM calendar_hours AS hours;

CREATE INDEX index_calendar_hours_short_date
    ON calendar_hours_short (date);

CREATE INDEX index_calendar_hours_short_hour
    ON calendar_hours_short (hour);

CREATE INDEX index_calendar_hours_short_year_month2
    ON calendar_hours_short (year_month2);

SELECT *
FROM calendar_hours_short;
/*
first line:
date_hour,date,year_month2,hour
2019-12-31 00,2019-12-31,2019-12,0
 */

-- _________________________________________________________________ --
/* short version to gain CET hour/date/year from data's UTC original hour

 for example:

SELECT h.date_hour_cet,
   src.*
FROM data_table AS src
    JOIN calendar_hours_cet_short AS h
        ON h.date_hour = src.date_hour;
  */

DROP TABLE IF EXISTS calendar_hours_cet_short;

CREATE TABLE calendar_hours_cet_short
(
    date_hour       char(13) PRIMARY KEY COMMENT 'Date and hour UTC YYYY-MM-DD hh -char(13)',
    date_hour_cet   char(13)         NOT NULL COMMENT 'Date and hour CET YYYY-MM-DD hh -char(13)',
    year_month2_cet char(7)          NOT NULL COMMENT 'Year - Month2 CET YYYY-MM -char(7)',
    date_cet        date             NOT NULL COMMENT 'CET date YYYY-MM-DD -date',
    hour_cet        tinyint UNSIGNED NOT NULL COMMENT 'Hour -tinyint'
) COMMENT = 'Hours of calendar dates Short version';

INSERT INTO calendar_hours_cet_short(date_hour, date_cet, hour_cet, date_hour_cet, year_month2_cet)
SELECT date_hour,
       date_cet,
       hour_cet,
       date_hour_cet,
       year_month2_cet
FROM calendar_hours AS hours;

CREATE INDEX index_calendar_hours_cet_short_date_cet
    ON calendar_hours_cet_short (date_cet);

CREATE INDEX index_calendar_hours_cet_short_date_hour_cet
    ON calendar_hours_cet_short (date_hour_cet);

CREATE INDEX index_calendar_hours_cet_short_hour_cet
    ON calendar_hours_cet_short (hour_cet);

CREATE INDEX index_calendar_hours_cet_short_year_month2_cet
    ON calendar_hours_cet_short (year_month2_cet);

SELECT *
FROM calendar_hours_cet_short;
/*
 first line:
date_hour,date_hour_cet,year_month2_cet,date_cet,hour_cet
2019-12-31 00,2019-12-31 01,2019-12,2019-12-31,1
 */

-- _________________________________________________________________ --
/* short version for hour presented as int(10) like 202311600 ('2023-11-16 00')
   when its a data dimension

 for example:

SELECT h.date_hour,
   src.*
FROM data_table AS src
    JOIN calendar_hours10_short AS h
        ON h.date_hour10 = src.date_hour10;
  */

DROP TABLE IF EXISTS calendar_hours10_short;
CREATE TABLE calendar_hours10_short
(
    date_hour10         int UNSIGNED     NOT NULL PRIMARY KEY COMMENT 'YYYYMMDDhh -int',
    date_hour           char(13)         NOT NULL COMMENT 'Date and hour UTC YYYY-MM-DD hh -char(13)',
    date_hour_cet       char(13)         NOT NULL COMMENT 'Date and hour CET YYYY-MM-DD hh -char(13)',
    year_month2         char(7)          NOT NULL COMMENT 'Year - Month2 YYYY-MM -char(7)',
    hour                tinyint UNSIGNED NOT NULL COMMENT 'Hour UTC -tinyint',
    hour_cet            tinyint UNSIGNED NOT NULL COMMENT 'Hour CET -tinyint',
    date                date             NOT NULL COMMENT 'UTC date YYYY-MM-DD -date',
    date_hour_cet_short char(11)         NOT NULL COMMENT 'Date and hour YY-MM-DD hh in CET -char(11)',
    date_cet            date             NOT NULL COMMENT 'CET date YYYY-MM-DD -date'
) COMMENT = 'Hours of calendar dates int10 Short version';

INSERT INTO calendar_hours10_short(date_hour10, date_hour, date_hour_cet,
                                   year_month2, date, date_hour_cet_short,
                                   date_cet, hour, hour_cet)
SELECT date_hour10,
       date_hour,
       date_hour_cet,
       year_month2,
       date,
       date_hour_cet_short,
       date_cet,
       hour,
       hour_cet
FROM calendar_hours AS hours;

CREATE INDEX index_calendar_hours10_short_date_hour10
    ON calendar_hours10_short (date_hour10);

CREATE INDEX index_calendar_hours10_short_date_hour_cet
    ON calendar_hours10_short (date_hour_cet);

CREATE INDEX index_calendar_hours10_short_date_hour
    ON calendar_hours10_short (date_hour);

SELECT *
FROM calendar_hours10_short;
/*
first line:
date_hour10,date_hour,date_hour_cet,year_month2,hour,hour_cet,date,date_hour_cet_short,date_cet
2019123100,2019-12-31 00,2019-12-31 01,2019-12,0,1,2019-12-31,19-12-31 01,2019-12-31

 NEXT: calendar_weeks, calendar_months, calendar_years presented in separated sql files

 */
/*
 sza(c)
 */
