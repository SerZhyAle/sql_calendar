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

 Please check next:

   SELECT DBTIMEZONE FROM DUAL;
-- result must be: +00:00

SELECT to_timestamp('2023-01-01', 'YYYY-MM-DD') AT TIME ZONE 'Europe/Paris' FROM DUAL;
-- must be: 2023-01-01 01:00:00.000000000 +01:00

SELECT to_timestamp('2023-06-01', 'YYYY-MM-DD') AT TIME ZONE 'Europe/Paris' FROM DUAL;
-- must be: 2023-06-01 02:00:00.000000000 +02:00

 If you received this then we have summer time shift, so we can create the calendar_hours..

  A code here for Postgres SQL (tested on 16.1)
 --
 STEP 1.
 Create the _swap table to be able switch the table in one transaction:

  run one by one..
 */
BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE calendar_hours_swap';
EXCEPTION
    WHEN OTHERS THEN
        IF SQLCODE != -942 THEN -- table or view does not exist
            RAISE;
        END IF;
END;

CREATE TABLE calendar_hours_swap
(
    "date_hour"             char(13) PRIMARY KEY,   -- Date and hour YYYY-MM-DD hh -char(13)
    "date_hour10"           int
        CHECK ("date_hour10" > 0)         NOT NULL, -- YYYYMMDDhh -int
    "date"                  date          NOT NULL, -- UTC date YYYY-MM-DD -date
    "hour"                  smallint
        CHECK ("hour" >= 0)               NOT NULL, -- Hour UTC -smallint
    "hour_cet"              smallint
        CHECK ("hour_cet" >= 0)           NOT NULL, -- Hour CET -smallint
    "date_hour_cet"         char(13)      NOT NULL, -- Date and hour YYYY-MM-DD hh in CET -char(13)
    "date_cet"              date          NOT NULL, -- CET date YYYY-MM-DD -date
    "year_month2"           char(7)       NOT NULL, -- Year - Month2 UTC YYYY-MM -char(7)
    "year_month2_cet"       char(7)       NOT NULL, -- Year - Month2 CET YYYY-MM -char(7)
    "first_second"          timestamp(6)  NOT NULL, -- first second -timestamp(6)
    "last_second"           timestamp(6)  NOT NULL, -- last second -timestamp(6)
    "hour2"                 char(2)       NOT NULL, -- Hour UTC -char(2)
    "hour2_cet"             char(2)       NOT NULL, -- Hour CET -char(2)
    "dd_hh"                 char(5)       NOT NULL, -- DD.hh -char(5)
    "is_last_in_week"       number(1)     NOT NULL, -- Hour is last in week -number(1)
    "is_last_in_month"      number(1)     NOT NULL, -- Hour is last in month -number(1)
    "is_last_in_quarter"    number(1)     NOT NULL, -- Hour is last in quarter -number(1)
    "is_last_in_year"       number(1)     NOT NULL, -- Hour is last in year -number(1)
    "is_lunch_hour"         number(1)     NOT NULL, -- Hour 12 13 for weekdays not special -number(1)
    "is_night"              number(1)     NOT NULL, -- Hour between 22 and 05 -number(1)
    "is_morning"            number(1)     NOT NULL, -- Hour between 06 and 09 -number(1)
    "is_daylight"           number(1)     NOT NULL, -- Hour between 10 and 18 -number(1)
    "is_evening"            number(1)     NOT NULL, -- Hour between 19 and 22 -number(1)
    "is_working_hour"       number(1)     NOT NULL, -- Hour 8-11 / 14-18 for weekdays not special -number(1)
    "is_working_day"        number(1)     NOT NULL, -- Day of hour is working not special -number(1)
    "is_public_holiday"     number(1)     NOT NULL, -- Is public holiday in -number(1)
    "special_hour"          varchar(255)  NULL,     -- Special note for hour -varchar(255)
    "date_hour_short"       char(11)      NOT NULL, -- Date and hour YY-MM-DD hh -char(11)
    "date_hour8"            int
        CHECK ("date_hour8" > 0)          NOT NULL, -- YYMMDDhh -int
    "date_short"            char(8)       NOT NULL, -- UTC date YY-MM-DD -char(8)
    "date_hour_cet_short"   char(11)      NOT NULL, -- Date and hour YY-MM-DD hh in CET -char(11)
    "date_cet_short"        char(8)       NOT NULL, -- CET date YY-MM-DD -char(8)
    "year_month2_short"     char(5)       NOT NULL, -- Year - Month2 UTC YY-MM -char(5)
    "year_month2_cet_short" char(5)       NOT NULL, -- Year - Month2 CET YY-MM -char(5)
    "created_at"            timestamp(6)
        DEFAULT SYSDATE                   NOT NULL, -- Created -timestamp(6),
    "updated_at"            timestamp(6)  NULL,     -- Updated -timestamp(6)
    "fullname"              varchar(255)  NOT NULL, -- DD MMMM YYYY (DayName) -varchar(255)
    "description"           varchar(1000) NULL      -- Commentary for hour of date -varchar(1000)
); -- Hours of calendar dates;

CREATE INDEX index_calendar_hours_date
    ON calendar_hours_swap ("date");

CREATE INDEX index__calendar_hours_date_hour_cet
    ON calendar_hours_swap ("date_hour_cet");

CREATE INDEX index_calendar_hours_year_month2
    ON calendar_hours_swap ("year_month2");

CREATE INDEX index_calendar_hours_year_month2_cet
    ON calendar_hours_swap ("year_month2_cet");

CREATE INDEX index_calendar_hours_date_hour10
    ON calendar_hours_swap ("date_hour10");

/*
 STEP 2.

 Create procedure to populate the calendar_hours for calendar_dates:

 */

CREATE OR REPLACE PROCEDURE service_calendar_hours_population AS
    special              varchar(50) := NULL;
    day_cursor           date ;
    hour_cursor          smallint    := 0;
    hour2                char(2)     := 'XX';
    dd                   date ;
    last_day_of_week     number(1)   := 0;
    last_day_of_month    number(1)   := 0;
    last_day_of_period   number(1)   := 0;
    last_day_of_year     number(1)   := 0;
    is_public_holiday    number(1)   := 0;
    is_working_day       number(1)   := 0;
    calculated_date_hour char(13);
    first_sec            timestamp(6);
    cet                  timestamp(6);
    date_cet             date;
    cet_char             varchar(10);

BEGIN
    -- _________________________________________________________________ --
    SELECT MIN("date") AS md INTO day_cursor FROM calendar_dates;
    SELECT MAX("date") AS md INTO dd FROM calendar_dates;

    WHILE day_cursor <= dd
        LOOP

            SELECT "is_last_day_of_week"
            INTO last_day_of_week
            FROM calendar_dates
            WHERE "date" = day_cursor;

            SELECT "is_last_day_of_month"
            INTO last_day_of_month
            FROM calendar_dates
            WHERE "date" = day_cursor;

            SELECT "is_last_day_of_quarter"
            INTO last_day_of_period
            FROM calendar_dates
            WHERE "date" = day_cursor;

            SELECT "is_last_day_of_year"
            INTO last_day_of_year
            FROM calendar_dates
            WHERE "date" = day_cursor;

            SELECT "is_public_holiday"
            INTO is_public_holiday
            FROM calendar_dates
            WHERE "date" = day_cursor;

            SELECT CASE WHEN ("is_weekend" = 0 AND "is_public_holiday" = 0) THEN 1 ELSE 0 END AS is_working_day
            INTO is_working_day
            FROM calendar_dates
            WHERE "date" = day_cursor;

            hour_cursor := 0;

            WHILE hour_cursor <= 23
                LOOP
                    hour2 := SUBSTR('0' || TO_CHAR(hour_cursor), -2);

                    calculated_date_hour := TO_CHAR(day_cursor, 'YYYY-MM-DD') || ' ' || hour2;
                    first_sec := TO_TIMESTAMP(calculated_date_hour || ':00:00', 'YYYY-MM-DD HH24:MI:SS');
                    -- UTC to CET
                    cet := first_sec AT TIME ZONE 'Europe/Paris';
                    cet_char := TO_CHAR(cet, 'YYYY-MM-DD');
                    date_cet := TO_DATE(cet_char, 'YYYY-MM-DD');

                    INSERT INTO calendar_hours_swap("date",
                                                    "date_cet",
                                                    "date_hour_cet",
                                                    "year_month2",
                                                    "year_month2_cet",
                                                    "first_second",
                                                    "last_second",
                                                    "date_hour",
                                                    "date_hour10",
                                                    "hour",
                                                    "hour_cet",
                                                    "hour2",
                                                    "hour2_cet",
                                                    "special_hour",
                                                    "fullname",
                                                    "dd_hh",
                                                    "is_last_in_week",
                                                    "is_last_in_month",
                                                    "is_last_in_quarter",
                                                    "is_last_in_year",
                                                    "is_night",
                                                    "is_lunch_hour",
                                                    "is_working_hour",
                                                    "is_working_day",
                                                    "is_public_holiday",
                                                    "is_morning",
                                                    "is_daylight",
                                                    "is_evening",
                                                    "date_hour_short",
                                                    "date_hour8",
                                                    "date_short",
                                                    "date_hour_cet_short",
                                                    "date_cet_short",
                                                    "year_month2_short",
                                                    "year_month2_cet_short")
                    VALUES (day_cursor,
                            date_cet,
                            TO_CHAR(cet, 'YYYY-MM-DD HH24'),
                            TO_CHAR(day_cursor, 'YYYY-MM'),
                            TO_CHAR(cet, 'YYYY-MM'),
                            first_sec,
                            TO_TIMESTAMP(CONCAT(calculated_date_hour, ':59:59.999999'), 'YYYY-MM-DD HH24:MI:SS.FF'),
                            calculated_date_hour,
                            TO_NUMBER(TO_CHAR(day_cursor, 'YYYYMMDD') || hour2),
                            hour_cursor,
                            EXTRACT(HOUR FROM cet),
                            hour2,
                            SUBSTR('0' || TO_CHAR(EXTRACT(HOUR FROM cet)), -2),
                            special, calculated_date_hour || ' UTC',
                            TO_CHAR(day_cursor, 'DD') || hour2,
                            CASE WHEN last_day_of_week = 1 AND hour_cursor = 23 THEN 1 ELSE 0 END,
                            CASE WHEN last_day_of_month = 1 AND hour_cursor = 23 THEN 1 ELSE 0 END,
                            CASE WHEN last_day_of_period = 1 AND hour_cursor = 23 THEN 1 ELSE 0 END,
                            CASE WHEN last_day_of_year = 1 AND hour_cursor = 23 THEN 1 ELSE 0 END,
                            CASE WHEN hour_cursor > 22 OR hour_cursor < 6 THEN 1 ELSE 0 END,
                            CASE WHEN hour_cursor = 12 OR hour_cursor = 13 THEN 1 ELSE 0 END,
                            CASE
                                WHEN ((hour_cursor > 7 AND hour_cursor < 12) OR (hour_cursor > 13 AND hour_cursor < 19))
                                    AND is_working_day = 1 THEN 1
                                ELSE 0 END,
                            is_working_day,
                            is_public_holiday,
                            CASE WHEN hour_cursor BETWEEN 6 AND 9 THEN 1 ELSE 0 END,
                            CASE WHEN hour_cursor BETWEEN 10 AND 18 THEN 1 ELSE 0 END,
                            CASE WHEN hour_cursor BETWEEN 19 AND 22 THEN 1 ELSE 0 END,
                            SUBSTR(calculated_date_hour, -11),
                            SUBSTR(TO_CHAR(day_cursor, 'YYMMDD') || hour2, -8),
                            TO_CHAR(day_cursor, 'YY-MM-DD'),
                            SUBSTR(TO_CHAR(cet, 'YY-MM-DD HH24'), -11),
                            TO_CHAR(date_cet, 'YY-MM-DD'),
                            TO_CHAR(day_cursor, 'YY-MM'),
                            SUBSTR(cet_char, 3, 5));

                    hour_cursor := hour_cursor + 1;
                END LOOP;

            day_cursor := day_cursor + 1;

        END LOOP;

    BEGIN
        EXECUTE IMMEDIATE 'DROP TABLE calendar_hours';
    EXCEPTION
        WHEN OTHERS THEN
            IF SQLCODE != -942 THEN -- table or view does not exist
                RAISE;
            END IF;
    END;

    BEGIN
        EXECUTE IMMEDIATE 'ALTER TABLE calendar_hours_swap RENAME TO calendar_hours';
    END;
    COMMIT;

END service_calendar_hours_population;
/

/*
 STEP 3.
 RUN IT!

 It can take up to 20 seconds
 */
-- _________________________________________________________________ --

CALL service_calendar_hours_population();

/*
  check..

  SELECT * FROM calendar_hours ORDER BY "date_hour";
  SELECT COUNT(*) as h FROM calendar_hours;
  -- 149064

  SELECT COUNT(*)/24 as d FROM calendar_hours;
  -- 6211

  SELECT (COUNT(*)/24)/356 as y FROM calendar_hours;
  -- 17.44662921348314606741573033707865168539

-- check..

SELECT *
FROM calendar_hours
WHERE "date" IN
      (TO_DATE(CURRENT_DATE), TO_DATE('2023.12.01', 'YYYY.MM.DD'), TO_DATE('2024.01.01', 'YYYY.MM.DD'), TO_DATE('2023-02-25', 'YYYY.MM.DD'), TO_DATE('2022-12-31', 'YYYY.MM.DD'),
       TO_DATE('2023-03-31', 'YYYY.MM.DD'))
ORDER BY "date_hour";

-- 144 rows and first line of result:

date_hour,date_hour10,date,hour,hour_cet,date_hour_cet,date_cet,year_month2,year_month2_cet,first_second,last_second,hour2,hour2_cet,dd_hh,is_last_in_week,is_last_in_month,is_last_in_quarter,is_last_in_year,is_lunch_hour,is_night,is_morning,is_daylight,is_evening,is_working_hour,is_working_day,is_public_holiday,special_hour,date_hour_short,date_hour8,date_short,date_hour_cet_short,date_cet_short,year_month2_short,year_month2_cet_short,created_at,updated_at,fullname,description
2022-12-31 00,2022123100,2022-12-31,0,1,2022-12-31 01,2022-12-31,2022-12,2022-12,2022-12-31 00:00:00.000000,2022-12-31 00:59:59.999999,00,01,3100 ,0,0,0,0,0,1,0,0,0,0,0,0,,22-12-31 00,22123100,22-12-31,22-12-31 01,22-12-31,22-12,22-12,2023-11-25 17:45:29.000000,,2022-12-31 00 UTC,

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
    ON h."date_hour" = src."date_hour"
WHERE h."date" = to_char('2023-11-16', 'YYYY-MM-DD');
 */

BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE calendar_hours_short';
EXCEPTION
    WHEN OTHERS THEN
        IF SQLCODE != -942 THEN -- table or view does not exist
            RAISE;
        END IF;
END;

CREATE TABLE calendar_hours_short
(
    "date_hour"   char(13) PRIMARY KEY, -- Date and hour YYYY-MM-DD hh -char(13)
    "date"        date      NOT NULL,   -- UTC date YYYY-MM-DD -date
    "year_month2" char(7)   NOT NULL,   -- Year - Month2 YYYY-MM -char(7)
    "hour"        smallint
        CHECK ("hour" >= 0) NOT NULL    -- Hour -smallint
); -- Hours of calendar dates Short version

INSERT INTO calendar_hours_short("date_hour", "date", "year_month2", "hour")
SELECT "date_hour", "date", "year_month2", "hour"
FROM calendar_hours;

CREATE INDEX index_calendar_hours_short_date
    ON calendar_hours_short ("date");

CREATE INDEX index_calendar_hours_short_hour
    ON calendar_hours_short ("hour");

CREATE INDEX index_calendar_hours_short_year_month2
    ON calendar_hours_short ("year_month2");

SELECT *
FROM calendar_hours_short
ORDER BY "date_hour";

/*
first line:
date_hour,date,year_month2,hour
2019-12-31 00,2019-12-31,2019-12,0
 */

-- _________________________________________________________________ --
/* short version to gain CET hour/date/year from data's UTC original hour

 for example:

SELECT h."date_hour_cet",
  src.*
FROM data_table AS src
  JOIN calendar_hours_cet_short AS h
    ON h."date_hour" = src."date_hour";
 */

BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE calendar_hours_cet_short';
EXCEPTION
    WHEN OTHERS THEN
        IF SQLCODE != -942 THEN -- table or view does not exist
            RAISE;
        END IF;
END;

CREATE TABLE calendar_hours_cet_short
(
    "date_hour"       char(13) PRIMARY KEY, -- Date and hour UTC YYYY-MM-DD hh -char(13)
    "date_hour_cet"   char(13)  NOT NULL,   -- Date and hour CET YYYY-MM-DD hh -char(13)
    "year_month2_cet" char(7)   NOT NULL,   -- Year - Month2 CET YYYY-MM -char(7)
    "date_cet"        date      NOT NULL,   -- CET date YYYY-MM-DD -date
    "hour_cet"        smallint
        CHECK ("hour_cet" >= 0) NOT NULL    -- Hour -smallint
); -- Hours of calendar dates Short version

INSERT INTO calendar_hours_cet_short("date_hour", "date_cet", "hour_cet", "date_hour_cet", "year_month2_cet")
SELECT "date_hour", "date_cet", "hour_cet", "date_hour_cet", "year_month2_cet"
FROM calendar_hours;

CREATE INDEX index_calendar_hours_cet_short_date_cet
    ON calendar_hours_cet_short ("date_cet");

CREATE INDEX index_calendar_hours_cet_short_date_hour_cet
    ON calendar_hours_cet_short ("date_hour_cet");

CREATE INDEX index_calendar_hours_cet_short_hour_cet
    ON calendar_hours_cet_short ("hour_cet");

CREATE INDEX index_calendar_hours_cet_short_date_year_month2_cet
    ON calendar_hours_cet_short ("year_month2_cet");

SELECT *
FROM calendar_hours_cet_short
ORDER BY "date_hour";

/*
 -- first line:
date_hour,date_hour_cet,year_month2_cet,date_cet,hour_cet
2019-12-31 00,2019-12-31 01,2019-12,2019-12-31,1
 */

-- _________________________________________________________________ --
/* short version for hour presented as int(10) like 202311600 ('2023-11-16 00')
  when its a data dimension

 for example:

SELECT h."date_hour",
  src.*
FROM data_table AS src
  JOIN calendar_hours10_short AS h
    ON h."date_hour10" = src."date_hour10";
 */

BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE calendar_hours10_short';
EXCEPTION
    WHEN OTHERS THEN
        IF SQLCODE != -942 THEN -- table or view does not exist
            RAISE;
        END IF;
END;

CREATE TABLE calendar_hours10_short
(
    "date_hour10"         int
        CHECK ("date_hour10" > 0)  NOT NULL PRIMARY KEY, -- 'YYYYMMDDhh -int'
    "date_hour"           char(13) NOT NULL,             -- 'Date and hour UTC YYYY-MM-DD hh -char(13)'
    "date_hour_cet"       char(13) NOT NULL,             -- 'Date and hour CET YYYY-MM-DD hh -char(13)'
    "year_month2"         char(7)  NOT NULL,             -- 'Year - Month2 YYYY-MM -char(7)'
    "hour"                smallint
        CHECK ("hour" >= 0)        NOT NULL,             -- 'Hour UTC -smallint'
    "hour_cet"            smallint
        CHECK ("hour_cet" >= 0)    NOT NULL,             -- 'Hour CET -smallint'
    "date"                date     NOT NULL,             -- 'UTC date YYYY-MM-DD -date'
    "date_hour_cet_short" char(11) NOT NULL,             -- 'Date and hour YY-MM-DD hh in CET -char(11)'
    "date_cet"            date     NOT NULL              -- 'CET date YYYY-MM-DD -date'
); -- Hours of calendar dates int10 Short version

INSERT INTO calendar_hours10_short("date_hour10", "date_hour", "date_hour_cet",
                                   "year_month2", "date", "date_hour_cet_short",
                                   "date_cet", "hour", "hour_cet")
SELECT "date_hour10",
       "date_hour",
       "date_hour_cet",
       "year_month2",
       "date",
       "date_hour_cet_short",
       "date_cet",
       "hour",
       "hour_cet"
FROM calendar_hours;

CREATE INDEX index_calendar_hours10_short_date_hour_cet
    ON calendar_hours10_short ("date_hour_cet");

CREATE INDEX index_calendar_hours10_short_date_hour
    ON calendar_hours10_short ("date_hour");

SELECT *
FROM calendar_hours10_short
order by "date_hour10";
/*
 -- first line:
date_hour10,date_hour,date_hour_cet,year_month2,hour,hour_cet,date,date_hour_cet_short,date_cet
2019123100,2019-12-31 00,2019-12-31 01,2019-12,0,1,2019-12-31,19-12-31 01,2019-12-31
 */

-- NEXT: calendar_weeks, calendar_months, calendar_years presented in separated sql files

/*
 sza(c)
 */
