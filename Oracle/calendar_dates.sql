/*
 The table calendar_dates pointing each day in period

 The idea to have the table with already calculated parameters for any daily aggregations.
 The fields date and date8 (int 8) can be dimensions in joined aggregated tables.

 week_begin - pointing view calendar_weeks
 year_month2 - pointing view calendar_months
 year - pointing view calendar_years

 All code here equal for Oracle SQL 19

 -- _________________________________________________________________ --
 STEP 1.
 Create the table calendar_dates

 Use the '_swap' table for creation, filling the table before swap it onto place with one transaction:
 */
BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE calendar_dates_swap';
EXCEPTION
    WHEN OTHERS THEN
        IF SQLCODE != -942 THEN -- table or view does not exist
            RAISE;
        END IF;
END;

CREATE TABLE calendar_dates_swap
(
    "date"                   date              NOT NULL
        PRIMARY KEY,                                     -- YYYY-MM-DD -date
    "date8"                  int
        CHECK ("date8" > 0)                    NOT NULL, -- YYYYMMDD -int
    "date_ymd"               char(10)          NOT NULL, -- YYYY-MM-DD -char(10)
    "date_dmy"               char(10)          NOT NULL, -- DD.MM.YYYY -char(10)
    "date_mdy"               char(10)          NOT NULL, -- MM/DD/YYYY -char(10)
    "date_ddmm"              char(5)           NOT NULL, -- DD.MM -char(5)
    "date_mmdd"              char(5)           NOT NULL, -- MM-DD -char(5)
    "date_dmmmy"             char(11)          NOT NULL, -- DD MMM YYYY -char(11)
    "date_dmmmmy"            varchar2(25)      NOT NULL, -- DD Month YYYY -varchar2(25)
    "day_of_week"            number(2, 0)
        CHECK ("day_of_week" >= 0)             NOT NULL, -- Day Number in Week 0=sunday -number(21, 0)
    "day_of_week_char"       varchar2(10)       NOT NULL, -- Name of Number of Day in Week -varchar2(5)
    "is_weekday"             number(1)         NOT NULL, -- True if NOT Saturday and NOT Sunday -number(1)
    "is_weekend"             number(1)         NOT NULL, -- True if Saturday or Sunday -number(1)
    "is_last_day_of_week"    number(1)         NOT NULL, -- True if Sunday -number(1)
    "is_last_day_of_month"   number(1)         NOT NULL, -- True if last day of month -number(1)
    "is_last_day_of_quarter" number(1)         NOT NULL, -- True if last day of quarter -number(1)
    "is_last_day_of_year"    number(1)         NOT NULL, -- True if last day of year -number(1)
    "day_name"               varchar2(10)      NOT NULL, -- Day Name in Week -varchar2(10)
    "day_name3"              char(3)           NOT NULL, -- Day Name in Week -char(3)
    "day_of_month"           number(2, 0)
        CHECK ("day_of_month" > 0)             NOT NULL, -- Day Number in Month -number(21, 0)
    "day_of_month2"          char(2)           NOT NULL, -- Day Number in Month (0 leads) -char(2)
    "day_of_month_char"      varchar2(5)       NOT NULL, -- Name of Number of Day in Month -varchar2(5)
    "day_of_quarter"         number(2, 0)      NOT NULL, -- Day Number in Quarter -number(2, 0)
    "day_of_year"            number(3, 0)
        CHECK ("day_of_year" > 0)              NOT NULL, -- Day Number in Year -number(3, 0)
    "week"                   number(2, 0)      NOT NULL, -- Week Number in Year (first day-monday) -number(2, 0)
    "week2"                  char(2)           NOT NULL, -- Week Number in Year (first day-monday) -char(2)
    "week_finance"           number(2, 0)      NOT NULL, -- Week Number (finance) -number(2, 0)
    "week_fullname"          char(23)          NOT NULL, -- Week YYYY-MM-DD - YYYY-MM-DD fullname -char(23)
    "year_week"              char(7)           NOT NULL, -- Year Week YYYY/WW -char(7)
    "month"                  number(2, 0)      NOT NULL, -- Month Number in Year -number(2, 0)
    "month2"                 char(2)           NOT NULL, -- Month Number in Year (0 leads) -char(2)
    "year_month2"            char(7)           NOT NULL, -- Year - Month2 YYYY-MM -char(7)
    "month_name"             varchar2(10)      NOT NULL, -- Month Name -varchar2(10)
    "month_name3"            char(3)           NOT NULL, -- Month Name -char(3)
    "quarter"                number(2, 0)
        CHECK ("quarter" > 0)                  NOT NULL, -- Quarter Number in Year -number(21, 0)
    "year_quarter"           char(6)           NOT NULL, -- Year quarter YYYY Q -char(6)
    "year"                   smallint          NOT NULL, -- Year -smallint
    "year2"                  smallint
        CHECK ("year2" > 0)                    NOT NULL, -- Year last 2 figures -tinyint
    "year2c"                 char(2)           NOT NULL, -- Year last 2 chars -char(2)
    "days_in_year"           number(3, 0)
        DEFAULT 365 CHECK ("days_in_year" > 0) NOT NULL, -- Amount days in this year def:365 -number(3, 0)
    "next_date"              date              NOT NULL, -- Next Date -date
    "prev_date"              date              NOT NULL, -- Previous Date -date
    "day_num_since_2020"     number(6, 0)      NOT NULL, -- Day number since 2020-01-01 for order -number(6, 0)
    "week_num_since_2020"    number(5, 0)      NOT NULL, -- Week number since 2020-01-01 for order -number(5, 0)
    "month_num_since_2020"   number(4, 0)      NOT NULL, -- Month number since 2020-01-01 for order -number(4, 0)
    "quarter_num_since_2020" number(3, 0)      NOT NULL, -- Quarter number since 2020-01-01 for order -number(3, 0)
    "year_num_since_2020"    number(2, 0)      NOT NULL, -- Year number since 2020-01-01 for order -number(2, 0)
    "week_begin"             date              NOT NULL, -- Date of begin of this week -date
    "week_end"               date              NOT NULL, -- Date of end of this week -date
    "month_begin"            date              NOT NULL, -- Date of begin of this month -date
    "month_end"              date              NOT NULL, -- Date of end of this month -date
    "quarter_begin"          date              NOT NULL, -- Date of begin of this quarter -date
    "quarter_end"            date              NOT NULL, -- Date of end of this quarter -date
    "year_begin"             date              NOT NULL, -- Date of begin of this year -date
    "year_end"               date              NOT NULL, -- Date of end of this year -date
    "week_before"            date              NOT NULL, -- Same date week before -date
    "week_after"             date              NOT NULL, -- Same date prev week -date
    "month_before"           date              NOT NULL, -- Same date month before -date
    "month_after"            date              NOT NULL, -- Same date prev month -date
    "quarter_before"         date              NOT NULL, -- Same date quarter before -date
    "quarter_after"          date              NOT NULL, -- Same date prev quarter -date
    "year_before"            date              NOT NULL, -- Same date next year -date
    "year_after"             date              NOT NULL, -- Same date prev year -date
    "is_working_day"         number(1)         NOT NULL, -- Day is working in Sweden not special -tiny(int)
    "is_public_holiday"      number(1)         NOT NULL, -- Is public holiday -tiny(int)
    "special_date"           varchar2(255)     NULL,     -- Special note for date -varchar2(255)
    "zodiac"                 varchar2(50)      NOT NULL, -- Zodiac sign -varchar2(50)
    "created_at"             timestamp(6)
        DEFAULT SYSDATE                        NOT NULL, -- Created -timestamp(6),
    "updated_at"             timestamp(6)      NULL,     -- Updated -timestamp(6)
    "fullname"               varchar2(255)     NOT NULL, -- DD MMMM YYYY (DayName) -varchar2(255)
    "description"            varchar2(1000)    NULL      -- Commentary for the calendar date -varchar2(1000)
);

CREATE UNIQUE INDEX uniq_index_calendar_dates_date8
    ON calendar_dates_swap ("date8");

CREATE INDEX index_calendar_dates_week_num_since_2020
    ON calendar_dates_swap ("week_num_since_2020");

CREATE INDEX index_calendar_dates_year_month2
    ON calendar_dates_swap ("year_month2");

CREATE INDEX index_calendar_dates_year_quarter
    ON calendar_dates_swap ("year_quarter");

/*
 STEP 2.

 Fill the calendar_dates:

 The next procedure stored to fill the calendar:

 Attention:
 day_cursor     date := TO_DATE('2019.12.31', 'YYYY.MM.DD'); -- The BEGIN of the Dates
 day_cursor_end date := TO_DATE('2036.12.31', 'YYYY.MM.DD'); -- The END of the dates. You probably know what is going on later.

 Check next:
 SELECT to_char(to_date('2023-11-12', 'YYYY-MM-DD'), 'D') -1 from dual;

 Must return: 0. In this case Sunday set as 1st day of week for your server.
 In other case you have to shift this variable in code.

 In this example working days set for 1,2,3,4,5 weekdays Mon-Fri

 Take a look onto commented block with holidays which can be changed for your country/region holidays.
 */ -- _________________________________________________________________ --

CREATE OR REPLACE PROCEDURE service_calendar_dates_population AS

    quarter                 number(21, 0) := 4;
    quarter_was             number(21, 0) := 4;
    day_cursor              date         := TO_DATE('2019.12.31', 'YYYY.MM.DD');
    number_of_calendar_week smallint     := 53;
    day_cursor_end          date         := TO_DATE('2036.12.31', 'YYYY.MM.DD');
    begin_of_period         date         := TO_DATE('2019.10.01', 'YYYY.MM.DD');
    special                 varchar2(50) := NULL;
    is_public_holiday       number(1)    := NULL;
    day_of_period           smallint     := 92;
    end_of_period           date         := LAST_DAY(ADD_MONTHS(begin_of_period, 3));
    day_num_since_2020      int          := 0;
    week_num_since_2020     int          := 1;
    month_num_since_2020    int          := 0;
    quarter_num_since_2020  int          := 0;
    year_num_since_2020     int          := 0;
    week_day_number         number(21, 0) := TO_CHAR(day_cursor, 'D') - 1;
    days_in_the_year        smallint     := 365;
    is_weekend              number(1)    := 1;
    is_working_day          number(1)    := 0;
    day_int                 int          := 31;
    month_int               int          := 12;
    day_date                date         := TO_DATE('2019.12.31', 'YYYY.MM.DD');
    day_tomorrow            date         := TO_DATE('2020.01.01', 'YYYY.MM.DD');

BEGIN
    -- _________________________________________________________________ --
    WHILE day_cursor <= day_cursor_end
        LOOP
            week_day_number := TO_CHAR(day_cursor, 'D') - 1; -- DW returns 1 for Sunday

            IF TO_CHAR(day_cursor, 'YY') IN ('20', '24', '28', '32', '36', '40') THEN
                days_in_the_year := 366;
            ELSE
                days_in_the_year := 365;
            END IF;

            IF EXTRACT(DAY FROM day_cursor) = 1 THEN
                month_num_since_2020 := month_num_since_2020 + 1;
            END IF;

            is_public_holiday := 0;
            special := NULL;

            IF (EXTRACT(MONTH FROM day_cursor) = 1 AND EXTRACT(DAY FROM day_cursor) = 1) THEN
                is_public_holiday := 1;
                special := 'New Year Day';
            ELSIF (EXTRACT(MONTH FROM day_cursor) = 5 AND EXTRACT(DAY FROM day_cursor) = 1) THEN
                is_public_holiday := 1;
                special := 'May Day';
            ELSIF (EXTRACT(MONTH FROM day_cursor) = 12 AND EXTRACT(DAY FROM day_cursor) = 25) THEN
                is_public_holiday := 1;
                special := 'Christmas Day';
            ELSIF (EXTRACT(MONTH FROM day_cursor) = 12 AND EXTRACT(DAY FROM day_cursor) = 26) THEN
                is_public_holiday := 1;
                special := '2nd Day of Christmas';
            END IF;

            IF (week_day_number IN (6, 0)) THEN
                is_weekend := 1;
            ELSE
                is_weekend := 0;
            END IF;

            IF (is_public_holiday = 0 AND is_weekend = 0) THEN
                is_working_day := 1;
            ELSE
                is_working_day := 0;
            END IF;

            IF (EXTRACT(MONTH FROM day_cursor) IN (4, 7, 10, 1) AND EXTRACT(DAY FROM day_cursor) = 1) THEN
                quarter := quarter + 1;
                begin_of_period := day_cursor;
                end_of_period := LAST_DAY(ADD_MONTHS(begin_of_period, 3));
            END IF;

            IF (EXTRACT(MONTH FROM day_cursor) = 1 AND EXTRACT(DAY FROM day_cursor) = 1) THEN
                quarter := 1;
                year_num_since_2020 := year_num_since_2020 + 1;
            END IF;

            IF (quarter <> quarter_was) THEN
                day_of_period := 1;
                quarter_was := quarter;
                quarter_num_since_2020 := quarter_num_since_2020 + 1;
            END IF;

            IF week_day_number = 1 THEN
                IF (EXTRACT(MONTH FROM day_cursor) = 1 AND number_of_calendar_week > 50) THEN
                    number_of_calendar_week := 1;
                ELSE
                    number_of_calendar_week := number_of_calendar_week + 1;
                END IF;
            END IF;

            IF week_day_number = 1 THEN
                week_num_since_2020 := week_num_since_2020 + 1;
            END IF;

            day_date := CAST(day_cursor AS date);
            day_int := EXTRACT(DAY FROM day_date);
            month_int := EXTRACT(MONTH FROM day_date);
            day_tomorrow := day_cursor + 1;

            INSERT INTO calendar_dates_swap("date",
                                            "date8",
                                            "date_ymd",
                                            "date_dmy",
                                            "date_ddmm",
                                            "date_mdy",
                                            "date_dmmmy",
                                            "date_dmmmmy",
                                            "day_of_week",
                                            "day_of_week_char",
                                            "is_weekday",
                                            "is_weekend",
                                            "day_name",
                                            "day_name3",
                                            "day_of_month",
                                            "day_of_month2",
                                            "day_of_month_char",
                                            "day_of_quarter",
                                            "day_of_year",
                                            "week",
                                            "week2",
                                            "week_finance",
                                            "year_week",
                                            "month",
                                            "month2",
                                            "month_name",
                                            "month_name3",
                                            "quarter",
                                            "year_quarter",
                                            "year",
                                            "year2",
                                            "year2c",
                                            "days_in_year",
                                            "zodiac",
                                            "is_public_holiday",
                                            "fullname",
                                            "is_last_day_of_week",
                                            "is_last_day_of_month",
                                            "is_last_day_of_quarter",
                                            "is_last_day_of_year",
                                            "week_begin",
                                            "week_end",
                                            "month_begin",
                                            "month_end",
                                            "quarter_begin",
                                            "quarter_end",
                                            "year_begin",
                                            "year_end",
                                            "week_before",
                                            "week_after",
                                            "month_before",
                                            "month_after",
                                            "quarter_before",
                                            "quarter_after",
                                            "year_before",
                                            "year_after",
                                            "special_date",
                                            "is_working_day",
                                            "day_num_since_2020",
                                            "week_num_since_2020",
                                            "month_num_since_2020",
                                            "quarter_num_since_2020",
                                            "year_num_since_2020",
                                            "year_month2",
                                            "next_date",
                                            "prev_date",
                                            "date_mmdd",
                                            "week_fullname")
            VALUES (day_cursor,
                    TO_CHAR(day_date, 'YYYYMMDD'),
                    TO_CHAR(day_date, 'YYYY-MM-DD'),
                    TO_CHAR(day_date, 'DD.MM.YYYY'),
                    TO_CHAR(day_date, 'DD.MM'),
                    TO_CHAR(day_date, 'MM/DD/YYYY'),
                    TO_CHAR(day_date, 'DD Mon YY'),
                    TO_CHAR(day_date, 'DD Month YY'),
                    week_day_number,
                    CONCAT(to_char(week_day_number),
                           CASE
                               WHEN (week_day_number + 1) > 3 THEN 'th'
                               WHEN (week_day_number + 1) = 1 THEN 'st'
                               WHEN (week_day_number + 1) = 2 THEN 'nd'
                               ELSE 'rd' END),
                    CASE WHEN week_day_number IN (6, 0) THEN 0 ELSE 1 END,
                    is_weekend,
                    TO_CHAR(day_date, 'Day'),
                    SUBSTR(TO_CHAR(day_date, 'DAY'), 1, 3),
                    day_int,
                    SUBSTR(CONCAT('0', TO_CHAR(day_date, 'DD')), -2),
                    CONCAT(day_int,
                           CASE
                               WHEN day_int IN (1, 21, 31) THEN 'st'
                               WHEN day_int IN (2, 22) THEN 'nd'
                               WHEN day_int IN (3, 23) THEN 'rd'
                               ELSE 'th' END),
                    day_of_period,
                    TO_CHAR(day_date, 'DDD'),
                    number_of_calendar_week,
                    SUBSTR(CONCAT('0', number_of_calendar_week), -2),
                    TO_CHAR(day_date, 'WW'),
                    TO_CHAR(day_cursor, 'YYYY') || '/' || SUBSTR(CONCAT('0', TO_CHAR(number_of_calendar_week)), -2),
                    month_int,
                    TO_CHAR(day_date, 'MM'),
                    TO_CHAR(day_date, 'Month'),
                    UPPER(SUBSTR(TO_CHAR(day_date, 'Month'), 1, 3)),
                    quarter,
                    TO_CHAR(day_cursor, 'YYYY') || ' ' || TO_CHAR(quarter),
                    EXTRACT(YEAR FROM day_date),
                    TO_CHAR(day_date, 'yy'),
                    TO_CHAR(day_date, 'yy'),
                    days_in_the_year,
                    CASE
                        WHEN (day_int >= 21 AND month_int = 3 OR
                              day_int <= 19 AND month_int = 4) THEN '03 Aries'
                        WHEN (day_int >= 20 AND month_int = 4 OR
                              day_int <= 20 AND month_int = 5) THEN '04 Taurus'
                        WHEN (day_int >= 21 AND month_int = 5 OR
                              day_int <= 20 AND month_int = 6) THEN '05 Gemini'
                        WHEN (day_int >= 21 AND month_int = 6 OR
                              day_int <= 22 AND month_int = 7) THEN '06 Cancer'
                        WHEN (day_int >= 23 AND month_int = 7 OR
                              day_int <= 22 AND month_int = 8) THEN '07 Leo'
                        WHEN (day_int >= 23 AND month_int = 8 OR
                              day_int <= 22 AND month_int = 9) THEN '08 Virgo'
                        WHEN (day_int >= 23 AND month_int = 9 OR
                              day_int <= 22 AND month_int = 10) THEN '09 Libra'
                        WHEN (day_int >= 23 AND month_int = 10 OR
                              day_int <= 21 AND month_int = 11) THEN '10 Scorpio'
                        WHEN (day_int >= 22 AND month_int = 11 OR
                              day_int <= 21 AND month_int = 12) THEN '11 Sagittarius'
                        WHEN (day_int >= 22 AND month_int = 12 OR
                              day_int <= 20 AND month_int = 1) THEN '12 Capricorn'
                        WHEN (day_int >= 21 AND month_int = 1 OR
                              day_int <= 18 AND month_int = 2) THEN '01 Aquarius'
                        ELSE '02 Pisces' END,
                    is_public_holiday,
                    TO_CHAR(day_date, 'DD Month YYYY') || ' (' || TO_CHAR(day_date, 'ww') || ')',
                    CASE WHEN week_day_number = 0 THEN 1 ELSE 0 END,
                    CASE WHEN EXTRACT(DAY FROM day_tomorrow) = 1 THEN 1 ELSE 0 END,
                    CASE
                        WHEN (EXTRACT(MONTH FROM day_tomorrow) IN (1, 4, 7, 10)
                            AND EXTRACT(DAY FROM day_tomorrow) = 1) THEN 1
                        ELSE 0 END,
                    CASE
                        WHEN (EXTRACT(MONTH FROM day_tomorrow) = 1
                            AND EXTRACT(DAY FROM day_tomorrow) = 1) THEN 1
                        ELSE 0 END,
                    CASE
                        WHEN (week_day_number = 0) THEN day_cursor - 6
                        ELSE day_cursor - week_day_number + 1 END,
                    CASE
                        WHEN (week_day_number = 0) THEN day_cursor
                        ELSE day_cursor + 7 - week_day_number END,
                    TO_DATE(TO_CHAR(day_cursor, 'YYYY-MM') || '-01', 'YYYY-MM-DD'),
                    LAST_DAY(day_cursor),
                    begin_of_period,
                    end_of_period,
                    TO_DATE(TO_CHAR(day_cursor, 'YYYY') || '-01-01', 'YYYY-MM-DD'),
                    TO_DATE(TO_CHAR(day_cursor, 'YYYY') || '-12-31', 'YYYY-MM-DD'),
                    day_date - 7,
                    day_date + 7,
                    ADD_MONTHS(day_date, -1),
                    ADD_MONTHS(day_date, 1),
                    ADD_MONTHS(day_date, -3),
                    ADD_MONTHS(day_date, 3),
                    ADD_MONTHS(day_date, -12),
                    ADD_MONTHS(day_date, 12),
                    special,
                    is_working_day,
                    day_num_since_2020,
                    week_num_since_2020,
                    month_num_since_2020,
                    quarter_num_since_2020,
                    year_num_since_2020,
                    TO_CHAR(day_date, 'YYYY-MM'),
                    day_tomorrow,
                    day_cursor - 1,
                    TO_CHAR(day_date, 'MM-DD'),
                    TO_CHAR(CASE
                                       WHEN (week_day_number = 0)
                                           THEN day_date - 6
                                       ELSE day_date - week_day_number + 1 END, 'YY-MM-DD') || ' - ' ||
                           TO_CHAR(CASE
                                       WHEN (week_day_number = 0) THEN day_date
                                       ELSE day_date + 7 - week_day_number END, 'YY-MM-DD'));

            day_cursor := day_cursor + 1;
            day_of_period := day_of_period + 1;
            day_num_since_2020 := day_num_since_2020 + 1;
        END LOOP;

    BEGIN
        EXECUTE IMMEDIATE 'DROP TABLE calendar_dates';
    EXCEPTION
        WHEN OTHERS THEN
            IF SQLCODE != -942 THEN -- table or view does not exist
                RAISE;
            END IF;
    END;

    BEGIN
        EXECUTE IMMEDIATE 'ALTER TABLE calendar_dates_swap RENAME TO calendar_dates';
    END;
    COMMIT;

END service_calendar_dates_population;
/

/*
 STEP 3.

 RUN IT!

 It takes up to 10 seconds.
 */

CALL service_calendar_dates_population();
-- _________________________________________________________________ --

/*
 Check it..
 */
SELECT *
FROM calendar_dates
ORDER BY "date";

SELECT COUNT(*) AS d
FROM calendar_dates;
-- result: 6211

SELECT (COUNT(*) / 356) AS y
FROM calendar_dates;
-- 17.44662921348314606741573033707865168539

SELECT *
FROM calendar_dates
WHERE
    "date" IN
    (to_date(current_date), to_date('2023.12.01', 'YYYY.MM.DD'), to_date('2024.01.01', 'YYYY.MM.DD'), to_date('2023-02-25', 'YYYY.MM.DD'), to_date('2022-12-31', 'YYYY.MM.DD'), to_date('2023-03-31', 'YYYY.MM.DD')) ORDER BY
    "date";
/*
result:

date,date8,date_ymd,date_dmy,date_mdy,date_ddmm,date_mmdd,date_dmmmy,date_dmmmmy,day_of_week,day_of_week_char,is_weekday,is_weekend,is_last_day_of_week,is_last_day_of_month,is_last_day_of_quarter,is_last_day_of_year,day_name,day_name3,day_of_month,day_of_month2,day_of_month_char,day_of_quarter,day_of_year,week,week2,week_finance,week_fullname,year_week,month,month2,year_month2,month_name,month_name3,quarter,year_quarter,year,year2,year2c,days_in_year,next_date,prev_date,day_num_since_2020,week_num_since_2020,month_num_since_2020,quarter_num_since_2020,year_num_since_2020,week_begin,week_end,month_begin,month_end,quarter_begin,quarter_end,year_begin,year_end,week_before,week_after,month_before,month_after,quarter_before,quarter_after,year_before,year_after,is_working_day,is_public_holiday,special_date,zodiac,created_at,updated_at,fullname,description
2022-12-31,20221231,2022-12-31,31.12.2022,12/31/2022,31.12,12-31,31 Dec 22  ,31 December  22,6,6th,0,1,0,1,1,1,Saturday ,SAT,31,31,31st,92,365,52,52,53,22-12-26 - 23-01-01    ,2022/52,12,12,2022-12,December ,DEC,4,2022 4,2022,22,22,365,2023-01-01,2022-12-30,1096,157,36,12,3,2022-12-26,2023-01-01,2022-12-01,2022-12-31,2022-10-01,2023-01-31,2022-01-01,2022-12-31,2022-12-24,2023-01-07,2022-11-30,2023-01-31,2022-09-30,2023-03-31,2021-12-31,2023-12-31,0,0,,12 Capricorn,2023-11-25 03:19:05.000000,,31 December  2022 (53),
2023-02-25,20230225,2023-02-25,25.02.2023,02/25/2023,25.02,02-25,25 Feb 23  ,25 February  23,6,6th,0,1,0,0,0,0,Saturday ,SAT,25,25,25th,56,56,8,08,8,23-02-20 - 23-02-26    ,2023/08,2,02,2023-02,February ,FEB,1,2023 1,2023,23,23,365,2023-02-26,2023-02-24,1152,165,38,13,4,2023-02-20,2023-02-26,2023-02-01,2023-02-28,2023-01-01,2023-04-30,2023-01-01,2023-12-31,2023-02-18,2023-03-04,2023-01-25,2023-03-25,2022-11-25,2023-05-25,2022-02-25,2024-02-25,0,0,,02 Pisces,2023-11-25 03:19:05.000000,,25 February  2023 (08),
2023-03-31,20230331,2023-03-31,31.03.2023,03/31/2023,31.03,03-31,31 Mar 23  ,31 March     23,5,5th,1,0,0,1,1,0,Friday   ,FRI,31,31,31st,90,90,13,13,13,23-03-27 - 23-04-02    ,2023/13,3,03,2023-03,March    ,MAR,1,2023 1,2023,23,23,365,2023-04-01,2023-03-30,1186,170,39,13,4,2023-03-27,2023-04-02,2023-03-01,2023-03-31,2023-01-01,2023-04-30,2023-01-01,2023-12-31,2023-03-24,2023-04-07,2023-02-28,2023-04-30,2022-12-31,2023-06-30,2022-03-31,2024-03-31,1,0,,03 Aries,2023-11-25 03:19:05.000000,,31 March     2023 (13),
2023-11-25,20231125,2023-11-25,25.11.2023,11/25/2023,25.11,11-25,25 Nov 23  ,25 November  23,6,6th,0,1,0,0,0,0,Saturday ,SAT,25,25,25th,56,329,47,47,47,23-11-20 - 23-11-26    ,2023/47,11,11,2023-11,November ,NOV,4,2023 4,2023,23,23,365,2023-11-26,2023-11-24,1425,204,47,16,4,2023-11-20,2023-11-26,2023-11-01,2023-11-30,2023-10-01,2024-01-31,2023-01-01,2023-12-31,2023-11-18,2023-12-02,2023-10-25,2023-12-25,2023-08-25,2024-02-25,2022-11-25,2024-11-25,0,0,,11 Sagittarius,2023-11-25 03:19:05.000000,,25 November  2023 (47),
2023-12-01,20231201,2023-12-01,01.12.2023,12/01/2023,01.12,12-01,01 Dec 23  ,01 December  23,5,5th,1,0,0,0,0,0,Friday   ,FRI,1,01,1st,62,335,48,48,48,23-11-27 - 23-12-03    ,2023/48,12,12,2023-12,December ,DEC,4,2023 4,2023,23,23,365,2023-12-02,2023-11-30,1431,205,48,16,4,2023-11-27,2023-12-03,2023-12-01,2023-12-31,2023-10-01,2024-01-31,2023-01-01,2023-12-31,2023-11-24,2023-12-08,2023-11-01,2024-01-01,2023-09-01,2024-03-01,2022-12-01,2024-12-01,1,0,,11 Sagittarius,2023-11-25 03:19:05.000000,,01 December  2023 (48),
2024-01-01,20240101,2024-01-01,01.01.2024,01/01/2024,01.01,01-01,01 Jan 24  ,01 January   24,1,1nd,1,0,0,0,0,0,Monday   ,MON,1,01,1st,1,1,1,01,1,24-01-01 - 24-01-07    ,2024/01,1,01,2024-01,January  ,JAN,1,2024 1,2024,24,24,366,2024-01-02,2023-12-31,1462,210,49,17,5,2024-01-01,2024-01-07,2024-01-01,2024-01-31,2024-01-01,2024-04-30,2024-01-01,2024-12-31,2023-12-25,2024-01-08,2023-12-01,2024-02-01,2023-10-01,2024-04-01,2023-01-01,2025-01-01,0,1,New Year Day,12 Capricorn,2023-11-25 03:19:05.000000,,01 January   2024 (01),
 */

-- NEXT: calendar_hours presented in separated sql file

/*
 sza(c)
 */
