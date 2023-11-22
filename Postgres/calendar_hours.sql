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

 Please check next two:

select timestamp with time zone '2023-01-01' at time zone 'Europe/Paris' as time_zone_cet;
-- must be: 2023-01-01 01:00:00.000000

select timestamp with time zone '2023-06-01' at time zone 'Europe/Paris' as time_zone_cet;
-- must be: 2023-06-01 02:00:00.000000

 If you received this then we have summer time shift, so we can create the calendar_hours..

  A code here for Postgres SQL (tested on 16.1)
 --
 STEP 1.
 Create the _swap table to be able switch the table in one transaction:

  run one by one..
 */
DROP TABLE IF EXISTS calendar_hours_swap CASCADE;

CREATE TABLE calendar_hours_swap
(
    -- original uniq combination
    date_hour             char(13) PRIMARY KEY,            -- 'Date and hour YYYY-MM-DD hh -char(13)'
    date_hour10           int
        CHECK (date_hour10 > 0)        NOT NULL,           -- 'YYYYMMDDhh -int'
    date                  date         NOT NULL,           -- 'UTC date YYYY-MM-DD -date'
    hour                  smallint
        CHECK (hour >= 0)              NOT NULL,           -- 'Hour UTC -smallint'
    hour_cet              smallint
        CHECK (hour_cet >= 0)          NOT NULL,           -- 'Hour CET -smallint'

    -- data
    date_hour_cet         char(13)     NOT NULL,           -- 'Date and hour YYYY-MM-DD hh in CET -char(13)'
    date_cet              date         NOT NULL,           -- 'CET date YYYY-MM-DD -date'
    year_month2           char(7)      NOT NULL,           -- 'Year - Month2 UTC YYYY-MM -char(7)'
    year_month2_cet       char(7)      NOT NULL,           -- 'Year - Month2 CET YYYY-MM -char(7)'
    first_second          timestamp(6) NOT NULL,           -- 'first second -timestamp(6)'
    last_second           timestamp(6) NOT NULL,           -- 'last second -timestamp(6)'
    hour2                 char(2)      NOT NULL,           -- 'Hour UTC -char(2)'
    hour2_cet             char(2)      NOT NULL,           -- 'Hour CET -char(2)'
    dd_hh                 char(5)      NOT NULL,           -- 'DD.hh -char(5)'
    is_last_in_week       boolean      NOT NULL,           -- 'Hour is last in week -boolean'
    is_last_in_month      boolean      NOT NULL,           -- 'Hour is last in month -boolean'
    is_last_in_quarter    boolean      NOT NULL,           -- 'Hour is last in quarter -boolean'
    is_last_in_year       boolean      NOT NULL,           -- 'Hour is last in year -boolean'

    is_lunch_hour         boolean      NOT NULL,           -- 'Hour 12 13 for weekdays not special -boolean'
    is_night              boolean      NOT NULL,           -- 'Hour between 22 and 05 -boolean'
    is_morning            boolean      NOT NULL,           -- 'Hour between 06 and 09 -boolean'
    is_daylight           boolean      NOT NULL,           -- 'Hour between 10 and 18 -boolean'
    is_evening            boolean      NOT NULL,           -- 'Hour between 19 and 22 -boolean'

    is_working_hour       boolean      NOT NULL,           -- 'Hour 8-11 / 14-18 for weekdays not special -boolean'
    is_working_day        boolean      NOT NULL,           -- 'Day of hour is working not special -boolean'
    is_public_holiday     boolean      NOT NULL,           -- 'Is public holiday in -boolean'
    special_hour          varchar(255) NULL
                                             DEFAULT NULL, -- 'Special note for hour -varchar(255)'

    -- short
    date_hour_short       char(11)     NOT NULL,           -- 'Date and hour YY-MM-DD hh -char(11)'
    date_hour8            int
        CHECK (date_hour8 > 0)         NOT NULL,           -- 'YYMMDDhh -int'
    date_short            char(8)      NOT NULL,           -- 'UTC date YY-MM-DD -char(8)'
    date_hour_cet_short   char(11)     NOT NULL,           -- 'Date and hour YY-MM-DD hh in CET -char(11)'
    date_cet_short        char(8)      NOT NULL,           -- 'CET date YY-MM-DD -char(8)'
    year_month2_short     char(5)      NOT NULL,           -- 'Year - Month2 UTC YY-MM -char(5)'
    year_month2_cet_short char(5)      NOT NULL,           -- 'Year - Month2 CET YY-MM -char(5)'

    -- row activity fields
    created_at            timestamp(6) NOT NULL
        CONSTRAINT df_calendar_hours_created DEFAULT (NOW()),
    updated_at            timestamp(6) NULL  DEFAULT NULL, -- 'Updated -timestamp(6)'

    -- common fields
    fullname              varchar(255) NOT NULL,           -- 'DD MMMM YYYY (DayName) -varchar(255)'
    description           varchar(1000)      DEFAULT NULL  -- ', -- ary for hour of date -varchar(1000)'

); -- 'Hours of calendar dates';

DROP INDEX IF EXISTS uniq_index_calendar_hours_date_hour;
CREATE UNIQUE INDEX uniq_index_calendar_hours_date_hour
    ON calendar_hours_swap (date_hour);

DROP INDEX IF EXISTS index__calendar_hours_date_hour_cet;
CREATE INDEX index__calendar_hours_date_hour_cet
    ON calendar_hours_swap (date_hour_cet);

DROP INDEX IF EXISTS index_calendar_hours_date;
CREATE INDEX index_calendar_hours_date
    ON calendar_hours_swap (date);

DROP INDEX IF EXISTS index_calendar_hours_year_month2;
CREATE INDEX index_calendar_hours_year_month2
    ON calendar_hours_swap (year_month2);

DROP INDEX IF EXISTS index_calendar_hours_year_month2_cet;
CREATE INDEX index_calendar_hours_year_month2_cet
    ON calendar_hours_swap (year_month2_cet);

DROP INDEX IF EXISTS index_calendar_hours_date_hour10;
CREATE INDEX index_calendar_hours_date_hour10
    ON calendar_hours_swap (date_hour10);

/*
 STEP 2.

 Create procedure to populate the calendar_hours for calendar_dates:

 */

CREATE OR REPLACE PROCEDURE service_calendar_hours_population()
    LANGUAGE plpgsql
AS
$$
DECLARE
    special              varchar(50) := NULL;
    day_cursor           date        := (SELECT MIN(date) AS md
                                         FROM calendar_dates);
    hour_cursor          smallint    := 0;
    hour2                char(2)     := 'XX';
    dd                   date        := (SELECT MAX(date) AS md
                                         FROM calendar_dates);
    last_day_of_week     boolean     := FALSE;
    last_day_of_month    boolean     := FALSE;
    last_day_of_period   boolean     := FALSE;
    last_day_of_year     boolean     := FALSE;
    is_public_holiday    boolean     := FALSE;
    is_working_day       boolean     := FALSE;
    calculated_date_hour char(13);
    first_sec            timestamp(6);
    cet                  timestamp(6);
    date_cet             date;
    cet_char             varchar(10);

BEGIN
    -- _________________________________________________________________ --
    day_cursor = (SELECT MIN(date) AS md
                  FROM calendar_dates);
    hour_cursor = 0;
    hour2 = 'XX';
    dd = (SELECT MAX(date) AS md
          FROM calendar_dates);

    WHILE day_cursor <= dd
        LOOP

            last_day_of_week := (SELECT is_last_day_of_week FROM calendar_dates WHERE date = day_cursor);
            last_day_of_month := (SELECT is_last_day_of_month FROM calendar_dates WHERE date = day_cursor);
            last_day_of_period := (SELECT is_last_day_of_quarter FROM calendar_dates WHERE date = day_cursor);
            last_day_of_year := (SELECT is_last_day_of_year FROM calendar_dates WHERE date = day_cursor);
            is_public_holiday := (SELECT d.is_public_holiday FROM calendar_dates AS d WHERE date = day_cursor);

            is_working_day :=
                    (SELECT CASE WHEN (d.is_weekend = FALSE AND d.is_public_holiday = FALSE) THEN TRUE ELSE FALSE END AS is_working_day
                     FROM calendar_dates AS d
                     WHERE date = day_cursor);

            hour_cursor := 0;

            WHILE hour_cursor <= 23
                LOOP
                    IF hour_cursor < 10 THEN
                        hour2 = CONCAT('0', hour_cursor);
                    ELSE
                        hour2 = hour_cursor;
                    END IF;

                    calculated_date_hour := CONCAT(day_cursor, ' ', hour2);
                    first_sec := CONCAT(calculated_date_hour, ':00:00');
                    -- UTC to CET
                    cet := CAST(TO_CHAR((CAST(first_sec AS timestamp) AT TIME ZONE 'UTC') AT TIME ZONE 'Europe/Paris', 'YYYY-MM-DD HH24:MI:SS') AS timestamp);
                    cet_char := CAST(cet AS varchar(10));
                    date_cet := cet::date;

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
                    VALUES (day_cursor,
                            date_cet,
                            TO_CHAR(cet, 'YYYY-MM-DD HH24'),
                            TO_CHAR(day_cursor, 'YYYY-MM'),
                            TO_CHAR(cet, 'YYYY-MM'),
                            first_sec,
                            CONCAT(calculated_date_hour, ':59:59.999999')::timestamp,
                            calculated_date_hour,
                            CONCAT(TO_CHAR(day_cursor, 'YYYYMMDD'), hour2)::int,
                            hour_cursor,
                            EXTRACT(HOUR FROM cet),
                            hour2,
                            SUBSTRING(cet_char, 12, 2),
                            special, CONCAT(calculated_date_hour, ' UTC'),
                            CONCAT(TO_CHAR(day_cursor, 'DD'), hour2),
                            CASE WHEN last_day_of_week = TRUE AND hour_cursor = 23 THEN TRUE ELSE FALSE END,
                            CASE WHEN last_day_of_month = TRUE AND hour_cursor = 23 THEN TRUE ELSE FALSE END,
                            CASE WHEN last_day_of_period = TRUE AND hour_cursor = 23 THEN TRUE ELSE FALSE END,
                            CASE WHEN last_day_of_year = TRUE AND hour_cursor = 23 THEN TRUE ELSE FALSE END,
                            CASE WHEN hour_cursor > 22 OR hour_cursor < 6 THEN TRUE ELSE FALSE END,
                            CASE WHEN hour_cursor = 12 OR hour_cursor = 13 THEN TRUE ELSE FALSE END,
                            CASE
                                WHEN ((hour_cursor > 7 AND hour_cursor < 12) OR (hour_cursor > 13 AND hour_cursor < 19))
                                    AND is_working_day = TRUE THEN TRUE
                                ELSE FALSE END,
                            is_working_day,
                            is_public_holiday,
                            CASE WHEN hour_cursor BETWEEN 6 AND 9 THEN TRUE ELSE FALSE END,
                            CASE WHEN hour_cursor BETWEEN 10 AND 18 THEN TRUE ELSE FALSE END,
                            CASE WHEN hour_cursor BETWEEN 19 AND 22 THEN TRUE ELSE FALSE END,
                            RIGHT(calculated_date_hour, 11),
                            RIGHT(CONCAT(TO_CHAR(day_cursor, 'YYMMDD'), hour2), 8)::int,
                            TO_CHAR(day_cursor, 'YY-MM-DD'),
                            RIGHT(CAST(cet AS varchar(13)), 11),
                            TO_CHAR(date_cet, 'YY-MM-DD'),
                            SUBSTRING(CAST(day_cursor AS varchar(10)), 3, 5),
                            SUBSTRING(cet_char, 3, 5));

                    hour_cursor := hour_cursor + 1;
                END LOOP;

            day_cursor := day_cursor + INTERVAL '1 day';

        END LOOP;

    DROP TABLE IF EXISTS calendar_hours CASCADE;
    ALTER TABLE calendar_hours_swap
        RENAME TO calendar_hours;
    COMMIT;

END;
$$;

/*
 STEP 3.
 RUN IT!

 It can take up to 20 seconds
 */
-- _________________________________________________________________ --

CALL service_calendar_hours_population();

/*
  check..

  SELECT * FROM calendar_hours;
  SELECT COUNT(*) as h FROM calendar_hours;
  -- 149064

  SELECT COUNT(*)/24 as d FROM calendar_hours;
  -- 6211

  SELECT (COUNT(*)/24)/356 as y FROM calendar_hours;
  -- 17

-- check..

SELECT *
FROM calendar_hours
WHERE date IN (cast(now() as date), '2023.12.01', '2022-12-31')
ORDER BY date_hour;

-- 72 rows and first line of result:

date_hour,date_hour10,date,hour,hour_cet,date_hour_cet,date_cet,year_month2,year_month2_cet,first_second,last_second,hour2,hour2_cet,dd_hh,is_last_in_week,is_last_in_month,is_last_in_quarter,is_last_in_year,is_lunch_hour,is_night,is_morning,is_daylight,is_evening,is_working_hour,is_working_day,is_public_holiday,special_hour,date_hour_short,date_hour8,date_short,date_hour_cet_short,date_cet_short,year_month2_short,year_month2_cet_short,created_at,updated_at,fullname,description
2022-12-31 00,2022123100,2022-12-31,0,1,2022-12-31 01,2022-12-31,2022-12,2022-12,2022-12-31 00:00:00.000000,2022-12-31 00:59:59.999999,00,  ,3100 ,false,false,false,false,false,true,false,false,false,false,false,false,,22-12-31 00,22123100,22-12-31,2022-12-31 ,22-12-31,22-12,22-12,2023-11-22 15:13:23.353101,,2022-12-31 00 UTC,

 */
-- _________________________________________________________________ --

/*
 The next tables is optional.
 
 This is short indexed versions of the calendar_hours
 If you use date_hour or date_hour10 as a dimension for the data, next tables will be better to use for joins for big data selections:

 short version for date_hour char(13)

 for example:

SELECT src.*
FROM data_table AS src
  JOIN calendar_hours_short AS h
    ON h.date_hour = src.date_hour
WHERE h.date = '2023-11-16';
 */


DROP TABLE IF EXISTS calendar_hours_short CASCADE;

CREATE TABLE calendar_hours_short
(
    date_hour   char(13) PRIMARY KEY, -- 'Date and hour YYYY-MM-DD hh -char(13)',
    date        date      NOT NULL,   -- 'UTC date YYYY-MM-DD -date',
    year_month2 char(7)   NOT NULL,   -- 'Year - Month2 YYYY-MM -char(7)',
    hour        smallint
        CHECK (hour >= 0) NOT NULL    -- 'Hour -smallint'
); -- 'Hours of calendar dates Short version'

INSERT INTO calendar_hours_short(date_hour, date, year_month2, hour)
SELECT date_hour, date, year_month2, hour
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

DROP TABLE IF EXISTS calendar_hours_cet_short CASCADE;

CREATE TABLE calendar_hours_cet_short
(
    date_hour       char(13) PRIMARY KEY, -- 'Date and hour UTC YYYY-MM-DD hh -char(13)',
    date_hour_cet   char(13)  NOT NULL,   -- 'Date and hour CET YYYY-MM-DD hh -char(13)',
    year_month2_cet char(7)   NOT NULL,   -- 'Year - Month2 CET YYYY-MM -char(7)',
    date_cet        date      NOT NULL,   -- 'CET date YYYY-MM-DD -date',
    hour_cet        smallint
        CHECK (hour_cet >= 0) NOT NULL    -- 'Hour -smallint'
); -- 'Hours of calendar dates Short version'

INSERT INTO calendar_hours_cet_short(date_hour, date_cet, hour_cet, date_hour_cet, year_month2_cet)
SELECT date_hour, date_cet, hour_cet, date_hour_cet, year_month2_cet
FROM calendar_hours AS hours;

CREATE INDEX index_calendar_hours_cet_short_date_cet
    ON calendar_hours_cet_short (date_cet);

CREATE INDEX index_calendar_hours_cet_short_date_hour_cet
    ON calendar_hours_cet_short (date_hour_cet);

CREATE INDEX index_calendar_hours_cet_short_hour_cet
    ON calendar_hours_cet_short (hour_cet);

CREATE INDEX index_calendar_hours_cet_short_date_year_month2_cet
    ON calendar_hours_cet_short (year_month2_cet);

SELECT *
FROM calendar_hours_cet_short;
/*
 -- first line:
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
  JOIN calendar_hours10_short; AS h
    ON h.date_hour10 = src.date_hour10;
 */

DROP TABLE IF EXISTS calendar_hours10_short CASCADE;

CREATE TABLE calendar_hours10_short
(
    date_hour10         int
        CHECK (date_hour10 > 0)  NOT NULL PRIMARY KEY, -- 'YYYYMMDDhh -int'
    date_hour           char(13) NOT NULL,             -- 'Date and hour UTC YYYY-MM-DD hh -char(13)'
    date_hour_cet       char(13) NOT NULL,             -- 'Date and hour CET YYYY-MM-DD hh -char(13)'
    year_month2         char(7)  NOT NULL,             -- 'Year - Month2 YYYY-MM -char(7)'
    hour                smallint
        CHECK (hour >= 0)        NOT NULL,             -- 'Hour UTC -smallint'
    hour_cet            smallint
        CHECK (hour_cet >= 0)    NOT NULL,             -- 'Hour CET -smallint'
    date                date     NOT NULL,             -- 'UTC date YYYY-MM-DD -date'
    date_hour_cet_short char(11) NOT NULL,             -- 'Date and hour YY-MM-DD hh in CET -char(11)'
    date_cet            date     NOT NULL              -- 'CET date YYYY-MM-DD -date'
); -- 'Hours of calendar dates int10 Short version'

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
 -- first line:
date_hour10,date_hour,date_hour_cet,year_month2,hour,hour_cet,date,date_hour_cet_short,date_cet
2019123100,2019-12-31 00,2019-12-31 01,2019-12,0,1,2019-12-31,19-12-31 01,2019-12-31
 */

-- NEXT: calendar_weeks, calendar_months, calendar_years presented in separated sql files

/*
 sza(c)
 */
