/* calendar_dates pointing each day in period

 The idea to have the table with already calculated parameters for any daily aggregations.
 The fields date and date8 (int 8) can be dimensions in joined aggregated tables.

 week_begin - pointing view calendar_weeks
 year_month2 - pointing view calendar_months
 year - pointing view calendar_years


 A code here for Postgres SQL (tested on 16.1)

 -- _________________________________________________________________ --
 STEP 1.
 Create the table calendar_dates

 USE Your_database_schema

 Use the '_swap' table for creation, filling the table before swap it onto place with one transaction:

 run one by one..
 */

DROP TABLE IF EXISTS calendar_dates_swap CASCADE;

CREATE TABLE calendar_dates_swap
(
    -- original uniq combination
    date                   date          NOT NULL
        PRIMARY KEY,                               -- YYYY-MM-DD -date
    date8                  int
        CHECK (date8 > 0)                NOT NULL, -- YYYYMMDD -int
    date_ymd               char(10)      NOT NULL, -- YYYY-MM-DD -char(10)
    date_dmy               char(10)      NOT NULL, -- DD.MM.YYYY -char(10)
    date_mdy               char(10)      NOT NULL, -- MM/DD/YYYY -char(10)

    -- data
    date_ddmm              char(5)       NOT NULL, -- DD.MM -char(5)
    date_mmdd              char(5)       NOT NULL, -- MM-DD -char(5)
    date_dmmmy             char(11)      NOT NULL, -- DD MMM YYYY -char(11)
    date_dmmmmy            varchar(25)   NOT NULL, -- DD Month YYYY -varchar(25)
    day_of_week            smallint
        CHECK (day_of_week >= 0)         NOT NULL, -- Day Number in Week 0=sunday -smallint
    day_of_week_char       varchar(5)    NOT NULL, -- Name of Number of Day in Week -varchar(5)
    is_weekday             boolean       NOT NULL, -- True if NOT Saturday and NOT Sunday -boolean
    is_weekend             boolean       NOT NULL, -- True if Saturday or Sunday -boolean
    is_last_day_of_week    boolean       NOT NULL, -- True if Sunday -boolean
    is_last_day_of_month   boolean       NOT NULL, -- True if last day of month -boolean
    is_last_day_of_quarter boolean       NOT NULL, -- True if last day of quarter -boolean
    is_last_day_of_year    boolean       NOT NULL, -- True if last day of year -boolean
    day_name               varchar(10)   NOT NULL, -- Day Name in Week -varchar(10)
    day_name3              char(3)       NOT NULL, -- Day Name in Week -char(3)
    day_of_month           smallint
        CHECK (day_of_month > 0)         NOT NULL, -- Day Number in Month -smallint
    day_of_month2          char(2)       NOT NULL, -- Day Number in Month (0 leads) -char(2)
    day_of_month_char      varchar(5)    NOT NULL, -- Name of Number of Day in Month -varchar(5)
    day_of_quarter         smallint      NOT NULL, -- Day Number in Quarter -smallint
    day_of_year            smallint
        CHECK (day_of_year > 0)          NOT NULL, -- Day Number in Year -smallint
    week                   smallint      NOT NULL, -- Week Number in Year (first day-monday) -tinyint
    week2                  char(2)       NOT NULL, -- Week Number in Year (first day-monday) -char(2)
    week_finance           smallint      NOT NULL, -- Week Number (finance) -tinyint
    week_fullname          varchar(23)   NOT NULL, -- Week YYYY-MM-DD - YYYY-MM-DD fullname -varchar(23)
    year_week              char(7)       NOT NULL, -- Year Week YYYY/WW -char(7)
    month                  smallint      NOT NULL, -- Month Number in Year -smallint
    month2                 char(2)       NOT NULL, -- Month Number in Year (0 leads) -char(2)
    year_month2            char(7)       NOT NULL, -- Year - Month2 YYYY-MM -char(7)
    month_name             varchar(10)   NOT NULL, -- Month Name -varchar(10)
    month_name3            char(3)       NOT NULL, -- Month Name -char(3)
    quarter                smallint
        CHECK (quarter > 0)              NOT NULL, -- Quarter Number in Year -smallint
    year_quarter           char(6)       NOT NULL, -- Year quarter YYYY Q -char(6)
    year                   smallint      NOT NULL, -- Year -smallint
    year2                  smallint
        CHECK (year2 > 0)                NOT NULL, -- Year last 2 figures -smallint
    year2c                 char(2)       NOT NULL, -- Year last 2 chars -char(2)
    days_in_year           smallint
        CHECK (days_in_year > 0)         NOT NULL
        DEFAULT 365,                               -- Amount days in this year def:365 -smallint

    next_date              date          NOT NULL, -- Next Date -date
    prev_date              date          NOT NULL, -- Previous Date -date

    day_num_since_2020     int           NOT NULL, -- Day number since 2020-01-01 for order -int
    week_num_since_2020    int           NOT NULL, -- Week number since 2020-01-01 for order -int
    month_num_since_2020   int           NOT NULL, -- Month number since 2020-01-01 for order -int
    quarter_num_since_2020 smallint      NOT NULL, -- Quarter number since 2020-01-01 for order -smallint
    year_num_since_2020    smallint      NOT NULL, -- Year number since 2020-01-01 for order -smallint

    week_begin             date          NOT NULL, -- Date of begin of this week -date
    week_end               date          NOT NULL, -- Date of end of this week -date
    month_begin            date          NOT NULL, -- Date of begin of this month -date
    month_end              date          NOT NULL, -- Date of end of this month -date
    quarter_begin          date          NOT NULL, -- Date of begin of this quarter -date
    quarter_end            date          NOT NULL, -- Date of end of this quarter -date
    year_begin             date          NOT NULL, -- Date of begin of this year -date
    year_end               date          NOT NULL, -- Date of end of this year -date

    week_before            date          NOT NULL, -- Same date week before -date
    week_after             date          NOT NULL, -- Same date prev week -date
    month_before           date          NOT NULL, -- Same date month before -date
    month_after            date          NOT NULL, -- Same date prev month -date
    quarter_before         date          NOT NULL, -- Same date quarter before -date
    quarter_after          date          NOT NULL, -- Same date prev quarter -date
    year_before            date          NOT NULL, -- Same date next year -date
    year_after             date          NOT NULL, -- Same date prev year -date

    is_working_day         boolean       NOT NULL, -- Day is working in Sweden not special -boolean
    is_public_holiday      boolean       NOT NULL, -- Is public holiday -boolean
    special_date           varchar(255)  NULL
        DEFAULT NULL,                              -- Special note for date -varchar(255)
    zodiac                 varchar(50)   NOT NULL, -- Zodiac sign -varchar(50)

    -- row activity fields
    created_at             timestamp(6)  NOT NULL
        CONSTRAINT df_calendar_dates_created
        DEFAULT (NOW()),                           -- Created -timestamp(6)
    updated_at             timestamp(6)  NULL
        DEFAULT NULL,                              -- Updated -timestamp(6)

    -- common fields
    fullname               varchar(255)  NOT NULL, -- DD MMMM YYYY (DayName) -varchar(255)
    description            varchar(1000) NULL
        DEFAULT NULL                               -- Commentary for the calendar date -varchar(1000)
);

CREATE UNIQUE INDEX uniq_index_calendar_dates_date
    ON calendar_dates_swap (date);

CREATE UNIQUE INDEX uniq_index_calendar_dates_date8
    ON calendar_dates_swap (date8);

CREATE INDEX index_calendar_dates_week_num_since_2020
    ON calendar_dates_swap (week_num_since_2020);

CREATE INDEX index_calendar_dates_year_month2
    ON calendar_dates_swap (year_month2);

CREATE INDEX index_calendar_dates_year_quarter
    ON calendar_dates_swap (year_quarter);

/*
 STEP 2.

 Fill the calendar_dates:

 The next procedure stored to fill the calendar:

 Attention:
 day_cursor := '2019.12.31'; -- The BEGIN of the Dates
 day_cursor_end := '2036.12.31'; -- The END of the dates. You probably know what is going on later.

 Check next:
 SELECT  EXTRACT(DOW FROM '2023-11-12') -1;
 Must return: 0. In this case Sunday as 1st day of week for your server.
 In other case you have to shift this variable in code.

 In this example working days for 1,2,3,4,5 weekdays Mon-Fri

 Take a look onto commented block with holidays which can be changed for your country/region holidays.
 */ -- _________________________________________________________________ --

CREATE OR REPLACE PROCEDURE service_calendar_dates_population()
    LANGUAGE plpgsql
AS
$$
DECLARE
    special                 varchar(50) := NULL;
    is_public_holiday       boolean     := NULL;
    day_of_period           smallint    := 92;
    day_cursor              date        := '2019-12-31';
    quarter                 smallint    := 4;
    quarter_was             smallint    := 4;
    number_of_calendar_week smallint    := 53;
    day_cursor_end          date        := '2036-12-31';
    begin_of_period         date        := '2019-10-01';
    end_of_period           date        := (DATE_TRUNC('month', begin_of_period) + INTERVAL '3 month - 1 day')::date;
    day_num_since_2020      int         := 0;
    week_num_since_2020     int         := 1;
    month_num_since_2020    int         := 0;
    quarter_num_since_2020  int         := 0;
    year_num_since_2020     int         := 0;
    is_weekend              boolean     := 0;
    is_working_day          boolean     := 0;
    week_day_number         smallint    := EXTRACT(DOW FROM day_cursor);
    days_in_the_year        int         := 365;
    cur_day_n               int         := 0;
    cur_mon_n               int         := 0;
    tomorrow                date        := NULL;
    day_date                date        := NULL;

BEGIN
    -- _________________________________________________________________ --
    WHILE (day_cursor <= day_cursor_end)
        LOOP
            week_day_number := EXTRACT(DOW FROM day_cursor);

            IF EXTRACT(YEAR FROM day_cursor) IN (2020, 2024, 2028, 2032, 2036, 2040) THEN
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
            END IF;

            IF (EXTRACT(MONTH FROM day_cursor) = 5 AND EXTRACT(DAY FROM day_cursor) = 1) THEN
                is_public_holiday := 1;
                special := 'May Day';
            END IF;

            IF (EXTRACT(MONTH FROM day_cursor) = 12 AND EXTRACT(DAY FROM day_cursor) = 25) THEN
                is_public_holiday := 1;
                special := 'Christmas Day';
            END IF;

            IF (EXTRACT(MONTH FROM day_cursor) = 12 AND EXTRACT(DAY FROM day_cursor) = 26) THEN
                is_public_holiday := 1;
                special := '2nd Day of Christmas';
            END IF;

            IF (week_day_number IN (6, 0)) THEN
                is_weekend := 1;
            ELSE
                is_weekend := 0;
            END IF;

            IF (is_public_holiday = FALSE AND is_weekend = FALSE) THEN
                is_working_day := 1;
            ELSE
                is_working_day := 0;
            END IF;

            IF (EXTRACT(MONTH FROM day_cursor) IN (4, 7, 10, 1) AND EXTRACT(DAY FROM day_cursor) = 1) THEN
                quarter := quarter + 1;
                begin_of_period := day_cursor;
                end_of_period := (DATE_TRUNC('month', begin_of_period) + INTERVAL '3 month - 1 day')::date;
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
                    number_of_calendar_week = 1;
                ELSE
                    number_of_calendar_week = number_of_calendar_week + 1;
                END IF;
            END IF;

            IF week_day_number = 1 THEN
                week_num_since_2020 := week_num_since_2020 + 1;
            END IF;

            day_date := CAST(day_cursor AS date);
            cur_day_n := EXTRACT(DAY FROM day_date);
            cur_mon_n := EXTRACT(MONTH FROM day_date);
            tomorrow := day_date + INTERVAL '1 day';

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
            VALUES (day_cursor,
                    TO_CHAR(day_date, 'YYYYMMDD')::int,
                    TO_CHAR(day_date, 'YYYY-MM-DD'),
                    TO_CHAR(day_date, 'DD.MM.YYYY'),
                    TO_CHAR(day_date, 'DD.MM'),
                    TO_CHAR(day_date, 'MM/DD/YYYY'),
                    TO_CHAR(day_date, 'D MON YY'),
                    TO_CHAR(day_date, 'D Month YY'),
                    week_day_number,
                    CONCAT((week_day_number + 1),
                           CASE
                               WHEN (week_day_number + 1) > 3 THEN 'th'
                               WHEN (week_day_number + 1) = 1 THEN 'st'
                               WHEN (week_day_number + 1) = 2 THEN 'nd'
                               ELSE 'rd' END),
                    CASE WHEN week_day_number IN (6, 0) THEN FALSE ELSE TRUE END,
                    is_weekend,
                    TO_CHAR(day_date, 'Day'),
                    TO_CHAR(day_date, 'DY'),
                    EXTRACT(DAY FROM day_cursor),
                    TO_CHAR(day_date, 'DD'),
                    CONCAT(EXTRACT(DAY FROM day_cursor),
                           CASE
                               WHEN EXTRACT(DAY FROM day_cursor) IN (1, 21, 31) THEN 'st'
                               WHEN EXTRACT(DAY FROM day_cursor) IN (2, 22) THEN 'nd'
                               WHEN EXTRACT(DAY FROM day_cursor) IN (3, 23) THEN 'rd'
                               ELSE 'th' END),
                    day_of_period,
                    TO_CHAR(day_date, 'DDD')::int,
                    number_of_calendar_week,
                    RIGHT(CONCAT('0', number_of_calendar_week), 2),
                    TO_CHAR(day_date, 'IW')::int,
                    CONCAT(EXTRACT(YEAR FROM day_cursor), '/', RIGHT(CONCAT('0', number_of_calendar_week), 2)),
                    cur_mon_n,
                    TO_CHAR(day_date, 'MM'),
                    TO_CHAR(day_date, 'Month'),
                    TO_CHAR(day_date, 'Mon'),
                    quarter,
                    CONCAT(EXTRACT(YEAR FROM day_cursor), ' ', quarter),
                    EXTRACT(YEAR FROM day_date),
                    TO_CHAR(day_date, 'YY')::int,
                    TO_CHAR(day_date, 'YY'),
                    days_in_the_year,
                    CASE
                        WHEN (cur_day_n >= 21 AND cur_mon_n = 3 OR
                              cur_day_n <= 19 AND cur_mon_n = 4) THEN '03 Aries'
                        WHEN (cur_day_n >= 20 AND cur_mon_n = 4 OR
                              cur_day_n <= 20 AND cur_mon_n = 5) THEN '04 Taurus'
                        WHEN (cur_day_n >= 21 AND cur_mon_n = 5 OR
                              cur_day_n <= 20 AND cur_mon_n = 6) THEN '05 Gemini'
                        WHEN (cur_day_n >= 21 AND cur_mon_n = 6 OR
                              cur_day_n <= 22 AND cur_mon_n = 7) THEN '06 Cancer'
                        WHEN (cur_day_n >= 23 AND cur_mon_n = 7 OR
                              cur_day_n <= 22 AND cur_mon_n = 8) THEN '07 Leo'
                        WHEN (cur_day_n >= 23 AND cur_mon_n = 8 OR
                              cur_day_n <= 22 AND cur_mon_n = 9) THEN '08 Virgo'
                        WHEN (cur_day_n >= 23 AND cur_mon_n = 9 OR
                              cur_day_n <= 22 AND cur_mon_n = 10) THEN '09 Libra'
                        WHEN (cur_day_n >= 23 AND cur_mon_n = 10 OR
                              cur_day_n <= 21 AND cur_mon_n = 11) THEN '10 Scorpio'
                        WHEN (cur_day_n >= 22 AND cur_mon_n = 11 OR
                              cur_day_n <= 21 AND cur_mon_n = 12) THEN '11 Sagittarius'
                        WHEN (cur_day_n >= 22 AND cur_mon_n = 12 OR
                              cur_day_n <= 20 AND cur_mon_n = 1) THEN '12 Capricorn'
                        WHEN (cur_day_n >= 21 AND cur_mon_n = 1 OR
                              cur_day_n <= 18 AND cur_mon_n = 2) THEN '01 Aquarius'
                        ELSE '02 Pisces' END,
                    is_public_holiday,
                    TO_CHAR(day_date, 'DD Month YYYY (WW)'),
                    CASE WHEN week_day_number = 0 THEN TRUE ELSE FALSE END,
                    CASE WHEN EXTRACT(DAY FROM tomorrow) = 1 THEN TRUE ELSE FALSE END,
                    CASE
                        WHEN EXTRACT(MONTH FROM tomorrow) IN (1, 4, 7, 10)
                            AND EXTRACT(DAY FROM tomorrow) = 1 THEN TRUE
                        ELSE FALSE END,
                    CASE
                        WHEN EXTRACT(MONTH FROM tomorrow) = 1
                            AND EXTRACT(DAY FROM tomorrow) = 1 THEN TRUE
                        ELSE FALSE END,
                    day_date + CASE WHEN (week_day_number = 0) THEN -6 ELSE - week_day_number + 1 END,
                    day_date + CASE WHEN (week_day_number = 0) THEN 0 ELSE 7 - week_day_number END,
                    CAST(TO_CHAR(day_date, 'YYYY-MM-01') AS date),
                    (DATE_TRUNC('month', day_date) + INTERVAL '1 month - 1 day')::date,
                    begin_of_period,
                    end_of_period,
                    CAST(TO_CHAR(day_date, 'YYYY-01-01') AS date),
                    CAST(TO_CHAR(day_date, 'YYYY-12-31') AS date),
                    day_date + INTERVAL '-7 day',
                    day_date + INTERVAL '7 day',
                    day_date + INTERVAL '-1 month',
                    day_date + INTERVAL '1 month',
                    day_date + INTERVAL '-3 month',
                    day_date + INTERVAL '3 month',
                    day_date + INTERVAL '-1 year',
                    day_date + INTERVAL '1 year',
                    special,
                    is_working_day,
                    day_num_since_2020,
                    week_num_since_2020,
                    month_num_since_2020,
                    quarter_num_since_2020,
                    year_num_since_2020,
                    TO_CHAR(day_date, 'YYYY-MM'),
                    day_date + INTERVAL '1 day',
                    day_date + INTERVAL '-1 day',
                    TO_CHAR(day_date, 'MM-DD'),
                    CONCAT(TO_CHAR(day_date + CASE WHEN (week_day_number = 0) THEN -6 ELSE week_day_number + 1 END, 'YY-MM-DD - '),
                           TO_CHAR(day_date + CASE WHEN (week_day_number = 0) THEN 0 ELSE 7 - week_day_number END, 'YY-MM-DD')));

            day_cursor = day_cursor + INTERVAL '1 day';

            day_of_period = day_of_period + 1;

            day_num_since_2020 = day_num_since_2020 + 1;
        END LOOP;

    DROP TABLE IF EXISTS calendar_dates CASCADE;
    ALTER TABLE calendar_dates_swap
        RENAME TO calendar_dates;
    COMMIT;
END;
$$;

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
FROM calendar_dates;

SELECT COUNT(*) AS d
FROM calendar_dates;
-- result: 6211

SELECT (COUNT(*) / 356) AS y
FROM calendar_dates;
-- 17

SELECT *
FROM calendar_dates
WHERE date IN (CAST(NOW() AS date), '2023.12.01', '2024.01.01', '2023-02-25', '2022-12-31', '2023-03-31')
ORDER BY date;
/*
result:

date,date8,date_ymd,date_dmy,date_mdy,date_ddmm,date_mmdd,date_dmmmy,date_dmmmmy,day_of_week,day_of_week_char,is_weekday,is_weekend,is_last_day_of_week,is_last_day_of_month,is_last_day_of_quarter,is_last_day_of_year,day_name,day_name3,day_of_month,day_of_month2,day_of_month_char,day_of_quarter,day_of_year,week,week2,week_finance,week_fullname,year_week,month,month2,year_month2,month_name,month_name3,quarter,year_quarter,year,year2,year2c,days_in_year,next_date,prev_date,day_num_since_2020,week_num_since_2020,month_num_since_2020,quarter_num_since_2020,year_num_since_2020,week_begin,week_end,month_begin,month_end,quarter_begin,quarter_end,year_begin,year_end,week_before,week_after,month_before,month_after,quarter_before,quarter_after,year_before,year_after,is_working_day,is_public_holiday,special_date,zodiac,created_at,updated_at,fullname,description
2022-12-31,20221231,2022-12-31,31.12.2022,12/31/2022,31.12,12-31,7 DEC 22   ,7 December  22,6,7th,false,true,false,true,true,true,Saturday ,SAT,31,31,31st,92,365,52,52,52,23-01-07 - 23-01-01    ,2022/52,12,12,2022-12,December ,Dec,4,2022 4,2022,22,22,365,2023-01-01,2022-12-30,1097,157,36,13,3,2022-12-26,2023-01-01,2022-12-01,2022-12-31,2022-10-01,2022-12-31,2022-01-01,2022-12-31,2022-12-24,2023-01-07,2022-11-30,2023-01-31,2022-09-30,2023-03-31,2021-12-31,2023-12-31,false,false,,12 Capricorn,2023-11-22 14:26:31.334021,,31 December  2022 (53),
2023-02-25,20230225,2023-02-25,25.02.2023,02/25/2023,25.02,02-25,7 FEB 23   ,7 February  23,6,7th,false,true,false,false,false,false,Saturday ,SAT,25,25,25th,56,56,8,08,8,23-03-04 - 23-02-26    ,2023/08,2,2 ,2023-02,February ,Feb,1,2023 1,2023,23,23,365,2023-02-26,2023-02-24,1153,165,38,14,4,2023-02-20,2023-02-26,2023-02-01,2023-02-28,2023-01-01,2023-03-31,2023-01-01,2023-12-31,2023-02-18,2023-03-04,2023-01-25,2023-03-25,2022-11-25,2023-05-25,2022-02-25,2024-02-25,false,false,,02 Pisces,2023-11-22 14:26:31.334021,,25 February  2023 (08),
2023-03-31,20230331,2023-03-31,31.03.2023,03/31/2023,31.03,03-31,6 MAR 23   ,6 March     23,5,6th,true,false,false,true,true,false,Friday   ,FRI,31,31,31st,90,90,13,13,13,23-04-06 - 23-04-02    ,2023/13,3,3 ,2023-03,March    ,Mar,1,2023 1,2023,23,23,365,2023-04-01,2023-03-30,1187,170,39,14,4,2023-03-27,2023-04-02,2023-03-01,2023-03-31,2023-01-01,2023-03-31,2023-01-01,2023-12-31,2023-03-24,2023-04-07,2023-02-28,2023-04-30,2022-12-31,2023-06-30,2022-03-31,2024-03-31,true,false,,03 Aries,2023-11-22 14:26:31.334021,,31 March     2023 (13),
2023-11-22,20231122,2023-11-22,22.11.2023,11/22/2023,22.11,11-22,4 NOV 23   ,4 November  23,3,4th,true,false,false,false,false,false,Wednesday,WED,22,22,22nd,53,326,47,47,47,23-11-26 - 23-11-26    ,2023/47,11,11,2023-11,November ,Nov,4,2023 4,2023,23,23,365,2023-11-23,2023-11-21,1423,204,47,17,4,2023-11-20,2023-11-26,2023-11-01,2023-11-30,2023-10-01,2023-12-31,2023-01-01,2023-12-31,2023-11-15,2023-11-29,2023-10-22,2023-12-22,2023-08-22,2024-02-22,2022-11-22,2024-11-22,true,false,,11 Sagittarius,2023-11-22 14:26:31.334021,,22 November  2023 (47),
2023-12-01,20231201,2023-12-01,01.12.2023,12/01/2023,01.12,12-01,6 DEC 23   ,6 December  23,5,6th,true,false,false,false,false,false,Friday   ,FRI,1,01,1st,62,335,48,48,48,23-12-07 - 23-12-03    ,2023/48,12,12,2023-12,December ,Dec,4,2023 4,2023,23,23,365,2023-12-02,2023-11-30,1432,205,48,17,4,2023-11-27,2023-12-03,2023-12-01,2023-12-31,2023-10-01,2023-12-31,2023-01-01,2023-12-31,2023-11-24,2023-12-08,2023-11-01,2024-01-01,2023-09-01,2024-03-01,2022-12-01,2024-12-01,true,false,,11 Sagittarius,2023-11-22 14:26:31.334021,,01 December  2023 (48),
2024-01-01,20240101,2024-01-01,01.01.2024,01/01/2024,01.01,01-01,2 JAN 24   ,2 January   24,1,2nd,true,false,false,false,false,false,Monday   ,MON,1,01,1st,1,1,1,01,1,24-01-03 - 24-01-07    ,2024/01,1,1 ,2024-01,January  ,Jan,1,2024 1,2024,24,24,366,2024-01-02,2023-12-31,1463,210,49,18,5,2024-01-01,2024-01-07,2024-01-01,2024-01-31,2024-01-01,2024-03-31,2024-01-01,2024-12-31,2023-12-25,2024-01-08,2023-12-01,2024-02-01,2023-10-01,2024-04-01,2023-01-01,2025-01-01,false,true,New Year Day,12 Capricorn,2023-11-22 14:26:31.334021,,01 January   2024 (01),
 */

-- NEXT: calendar_hours presented in separated sql file

/*
 sza(c)
 */
