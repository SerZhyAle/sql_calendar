/*
 The table calendar_dates pointing each day in period

 The idea to have the table with already calculated parameters for any daily aggregations.
 The fields date and date8 (int 8) can be dimensions in joined aggregated tables.

 week_begin - pointing view calendar_weeks
 year_month2 - pointing view calendar_months
 year - pointing view calendar_years


 All code here equal for Snowflake

 -- _________________________________________________________________ --
 STEP 1.
 Create the table calendar_dates

 USE Your_database_schema
GEAR here the name of SF schema. Change it on yours.
 */

CREATE OR REPLACE TABLE gear.calendar_dates
(
    -- original uniq combination
    date                   date          NOT NULL PRIMARY KEY COMMENT 'YYYY-MM-DD -date',
    date8                  int           NOT NULL COMMENT 'YYYYMMDD -int',
    date_ymd               char(10)      NOT NULL COMMENT 'YYYY-MM-DD -char(10)',
    date_dmy               char(10)      NOT NULL COMMENT 'DD.MM.YYYY -char(10)',
    date_mdy               char(10)      NOT NULL COMMENT 'MM/DD/YYYY -char(10)',

    -- data
    date_ddmm              char(5)       NOT NULL COMMENT 'DD.MM -char(5)',
    date_mmdd              char(5)       NOT NULL COMMENT 'MM-DD -char(5)',
    date_dmmmy             char(11)      NOT NULL COMMENT 'DD MMM YYYY -char(11)',
    date_dmmmmy            varchar(25)   NOT NULL COMMENT 'DD Month YYYY -varchar(25)',
    day_of_week            smallint      NOT NULL COMMENT 'Day Number in Week 0=sunday -smallint',
    day_of_week_char       varchar(5)    NOT NULL COMMENT 'Name of Number of Day in Week -varchar(5)',
    is_weekday             boolean       NOT NULL COMMENT 'True if NOT Saturday and NOT Sunday -boolean',
    is_weekend             boolean       NOT NULL COMMENT 'True if Saturday or Sunday -boolean',
    is_last_day_of_week    boolean       NOT NULL COMMENT 'True if Sunday -boolean',
    is_last_day_of_month   boolean       NOT NULL COMMENT 'True if last day of month -boolean',
    is_last_day_of_quarter boolean       NOT NULL COMMENT 'True if last day of quarter -boolean',
    is_last_day_of_year    boolean       NOT NULL COMMENT 'True if last day of year -boolean',
    day_name               varchar(10)   NOT NULL COMMENT 'Day Name in Week -varchar(10)',
    day_name3              char(3)       NOT NULL COMMENT 'Day Name in Week -char(3)',
    day_of_month           tinyint       NOT NULL COMMENT 'Day Number in Month -tinyint',
    day_of_month2          char(2)       NOT NULL COMMENT 'Day Number in Month (0 leads) -char(2)',
    day_of_month_char      varchar(5)    NOT NULL COMMENT 'Name of Number of Day in Month -varchar(5)',
    day_of_quarter         tinyint       NOT NULL COMMENT 'Day Number in Quarter -tinyint',
    day_of_year            smallint      NOT NULL COMMENT 'Day Number in Year -smallint',
    week                   tinyint       NOT NULL COMMENT 'Week Number in Year (first day-monday) -tinyint',
    week2                  char(2)       NOT NULL COMMENT 'Week Number in Year (first day-monday) -char(2)',
    week_finance           tinyint       NOT NULL COMMENT 'Week Number (finance) -tinyint',
    week_fullname          char(23)      NOT NULL COMMENT 'Week YYYY-MM-DD - YYYY-MM-DD fullname -char(23)',
    year_week              char(7)       NOT NULL COMMENT 'Year week YYYY/WW -char(7)',
    month                  tinyint       NOT NULL COMMENT 'Month Number in Year -tinyint',
    month2                 char(2)       NOT NULL COMMENT 'Month Number in Year (0 leads) -char(2)',
    year_month2            char(7)       NOT NULL COMMENT 'Year - Month2 YYYY-MM -char(7)',
    month_name             varchar(10)   NOT NULL COMMENT 'Month Name -varchar(10)',
    month_name3            char(3)       NOT NULL COMMENT 'Month Name -char(3)',
    quarter                tinyint       NOT NULL COMMENT 'Quarter Number in Year -tinyint',
    year_quarter           char(6)       NOT NULL COMMENT 'Year quarter YYYY Q -char(6)',
    year                   smallint      NOT NULL COMMENT 'Year -smallint',
    year2                  tinyint       NOT NULL COMMENT 'Year last 2 figures -tinyint',
    year2c                 char(2)       NOT NULL COMMENT 'Year last 2 chars -char(2)',
    days_in_year           smallint      NOT NULL DEFAULT 365 COMMENT 'Amount days in this year def:365 -smallint',

    next_date              date          NOT NULL COMMENT 'Next Date -date',
    prev_date              date          NOT NULL COMMENT 'Previous Date -date',

    day_num_since_2020     int           NOT NULL COMMENT 'Day number since 2020-01-01 for order -int',
    week_num_since_2020    int           NOT NULL COMMENT 'Week number since 2020-01-01 for order -int',
    month_num_since_2020   int           NOT NULL COMMENT 'Month number since 2020-01-01 for order -int',
    quarter_num_since_2020 tinyint       NOT NULL COMMENT 'Quarter number since 2020-01-01 for order -tinyint',
    year_num_since_2020    tinyint       NOT NULL COMMENT 'Year number since 2020-01-01 for order -tinyint',

    week_begin             date          NOT NULL COMMENT 'Date of begin of this week -date',
    week_end               date          NOT NULL COMMENT 'Date of end of this week -date',
    month_begin            date          NOT NULL COMMENT 'Date of begin of this month -date',
    month_end              date          NOT NULL COMMENT 'Date of end of this month -date',
    quarter_begin          date          NOT NULL COMMENT 'Date of begin of this quarter -date',
    quarter_end            date          NOT NULL COMMENT 'Date of end of this quarter -date',
    year_begin             date          NOT NULL COMMENT 'Date of begin of this year -date',
    year_end               date          NOT NULL COMMENT 'Date of end of this year -date',

    week_before            date          NOT NULL COMMENT 'Same date week before -date',
    week_after             date          NOT NULL COMMENT 'Same date prev week -date',
    month_before           date          NOT NULL COMMENT 'Same date month before -date',
    month_after            date          NOT NULL COMMENT 'Same date prev month -date',
    quarter_before         date          NOT NULL COMMENT 'Same date quarter before -date',
    quarter_after          date          NOT NULL COMMENT 'Same date prev quarter -date',
    year_before            date          NOT NULL COMMENT 'Same date next year -date',
    year_after             date          NOT NULL COMMENT 'Same date prev year -date',

    is_working_day         boolean       NOT NULL COMMENT 'Day is working in Sweden not special -tiny(int)',
    is_public_holiday      boolean       NOT NULL COMMENT 'Is public holiday -tiny(int)',
    special_date           varchar(255)  NULL     DEFAULT NULL COMMENT 'Special note for date -varchar(255)',

    zodiac                 varchar(50)   NOT NULL COMMENT 'Zodiac sign -varchar(50)',

    -- row activity fields
    created_at             timestamp     NOT NULL DEFAULT CURRENT_TIMESTAMP() COMMENT 'Created -timestamp',

    -- common fields
    fullname               varchar(255)  NOT NULL COMMENT 'DD MMMM YYYY (DayName) -varchar(255)',
    description            varchar(1000) NULL     DEFAULT NULL COMMENT 'Commentary for the calendar date -varchar(1000)'

) COMMENT ='Calendar dates';

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

-- EXECUTE IMMEDIATE $$
-- BEGIN

CREATE OR REPLACE PROCEDURE gear.service_calendar_dates_population()
    RETURNS boolean
    LANGUAGE SQL
AS
DECLARE
    var_special                 char(200);
    var_is_public_holiday       int;
    var_day_of_period           int;
    var_day_cursor_end          date;
    var_quarter                 int;
    var_quarter_was             int;
    var_number_of_calendar_week int;
    var_begin_of_period         date;
    var_end_of_period           date;
    var_day_num_since_2020      int;
    var_week_num_since_2020     int;
    var_month_num_since_2020    int;
    var_quarter_num_since_2020  int;
    var_year_num_since_2020     int;
    var_days_in_the_year        int;
    var_is_working_day          int;
    var_week_day_number         int;
    var_is_weekend              int;
    var_month_cursor            int;
    var_day_of_cursor           int;
    var_tomorrow                int;

BEGIN
    var_special := NULL;
    var_is_public_holiday := NULL;
    var_day_of_period := 1;

    LET var_day_cursor date := '2019-12-31'::date;
    var_quarter := 4; -- for '2019.12.31'
    var_quarter_was := 4; -- for '2019.12.31'
    var_number_of_calendar_week := 53; -- for '2019.12.31'
    var_day_cursor_end := '2036-12-31'::date;
    var_begin_of_period := '2019-10-01'::date;

    var_end_of_period := LAST_DAY(DATEADD(MONTH, 3, var_begin_of_period));
    var_day_num_since_2020 := 0;
    var_week_num_since_2020 := 1;
    var_month_num_since_2020 := 0;
    var_quarter_num_since_2020 := 0;
    var_year_num_since_2020 := 0;
    var_day_of_period := 92;
    var_days_in_the_year := 365;
    var_is_working_day := 1;

    LET loopblock int := 0;

    CREATE OR REPLACE TEMPORARY TABLE temp_calendar_dates LIKE gear.CALENDAR_DATES;

    WHILE (DATEDIFF(DAY, var_day_cursor, var_day_cursor_end) >= 0 AND loopblock <= 10000)
    LOOP
        var_week_day_number := MOD(DAYOFWEEK(var_day_cursor) - 1, 7);
        IF (RIGHT(TO_VARCHAR(var_day_cursor, 'YY'), 2) IN ('20', '24', '28', '32', '36', '40')) THEN
            var_days_in_the_year := 366;
        ELSE
            var_days_in_the_year := 365;
        END IF;

        IF (DAY(var_day_cursor) = 1) THEN
            var_month_num_since_2020 := var_month_num_since_2020 + 1;
        END IF;

        IF (MONTH(var_day_cursor) = 1
            AND DAY(var_day_cursor) = 1) THEN
            var_is_public_holiday := 1;
            var_special := 'New Year Day';
        ELSEIF (MONTH(var_day_cursor) = 5
            AND DAY(var_day_cursor) = 1) THEN
            var_is_public_holiday := 1;
            var_special := 'May Day';
        ELSEIF (MONTH(var_day_cursor) = 12
            AND DAY(var_day_cursor) = 25) THEN
            var_is_public_holiday := 1;
            var_special := 'Christmas Day';
        ELSEIF (MONTH(var_day_cursor) = 12
            AND DAY(var_day_cursor) = 26) THEN
            var_is_public_holiday := 1;
            var_special := '2nd Day of Christmas';
        ELSE
            var_is_public_holiday := 0;
            var_special := NULL;
        END IF;

        var_is_weekend := IFF(var_week_day_number IN (6, 0), 1, 0);

        IF ((var_is_public_holiday + var_is_weekend) = 0) THEN
            var_is_working_day := 1;
        ELSE
            var_is_working_day := 0;
        END IF;

        IF (MONTH(var_day_cursor) IN (4, 7, 10, 1)
            AND DAY(var_day_cursor) = 1) THEN
            var_quarter := var_quarter + 1;
            var_begin_of_period := var_day_cursor;
            var_end_of_period := LAST_DAY(DATEADD(MONTH, 3, var_begin_of_period));
        END IF;

        IF (MONTH(var_day_cursor) = 1
            AND DAY(var_day_cursor) = 1) THEN
            var_quarter := 1;
            var_year_num_since_2020 := var_year_num_since_2020 + 1;
        END IF;

        IF (var_quarter <> var_quarter_was) THEN
            var_day_of_period := 1;
            var_quarter_was := var_quarter;
            var_quarter_num_since_2020 := var_quarter_num_since_2020 + 1;
        END IF;

        IF (var_week_day_number = 1) THEN

            IF (MONTH(var_day_cursor) = 1
                AND var_number_of_calendar_week > 50) THEN
                var_number_of_calendar_week := 1;
            ELSE
                var_number_of_calendar_week := var_number_of_calendar_week + 1;
            END IF;
        END IF;

        IF (var_week_day_number = 1) THEN
            var_week_num_since_2020 := var_week_num_since_2020 + 1;
        END IF;

        var_month_cursor := MONTH(var_day_cursor);
        var_day_of_cursor := DAY(var_day_cursor);
        var_tomorrow := DAY(DATEADD(DAY, 1, var_day_cursor));

        INSERT INTO temp_calendar_dates(date,
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
        VALUES (:var_day_cursor,
                TO_VARCHAR(:var_day_cursor, 'YYYYMMDD'),
                TO_VARCHAR(:var_day_cursor, 'YYYY-MM-DD'),
                TO_VARCHAR(:var_day_cursor, 'DD.MM.YYYY'),
                TO_VARCHAR(:var_day_cursor, 'DD.MM'),
                TO_VARCHAR(:var_day_cursor, 'MM/DD/YYYY'),
                TO_VARCHAR(:var_day_cursor, 'DD MON YYYY'),
                TO_VARCHAR(:var_day_cursor, 'DD MMMM YYYY'),
                :var_week_day_number,
                CONCAT((:var_week_day_number + 1), CASE
                                                       WHEN (:var_week_day_number + 1) > 3 THEN 'th'
                                                       WHEN (:var_week_day_number + 1) = 1 THEN 'st'
                                                       WHEN (:var_week_day_number + 1) = 2 THEN 'nd'
                                                       ELSE 'rd' END),
                IFF(:var_week_day_number IN (6, 0), FALSE, TRUE),
                :var_is_weekend,
                DECODE(UPPER(TO_VARCHAR(:var_day_cursor, 'DY')),
                       'MON', 'Monday',
                       'TUE', 'Tuesday',
                       'WED', 'Wednesday',
                       'THU', 'Thursday',
                       'FRI', 'Friday',
                       'SAT', 'Saturday',
                       'SUN', 'Sunday'),
                UPPER(TO_VARCHAR(:var_day_cursor, 'DY')),
                DAY(:var_day_cursor),
                TO_CHAR(:var_day_cursor, 'DD'),
                TO_CHAR(DAY(:var_day_cursor)),
                :var_day_of_period,
                DAYOFYEAR(:var_day_cursor),
                :var_number_of_calendar_week,
                RIGHT(CONCAT('0', WEEK(:var_day_cursor)), 2),
                WEEKISO(:var_day_cursor),
                CONCAT(YEAR(:var_day_cursor), '/', RIGHT(CONCAT('0', :var_number_of_calendar_week), 2)),
                :var_month_cursor,
                RIGHT(CONCAT('0', MONTH(:var_day_cursor)), 2),
                TO_VARCHAR(:var_day_cursor, 'MMMM'),
                TO_VARCHAR(:var_day_cursor, 'MON'),
                :var_quarter,
                CONCAT(YEAR(:var_day_cursor), ' ', :var_quarter),
                YEAR(:var_day_cursor),
                TO_NUMBER(RIGHT(YEAR(:var_day_cursor), 2)),
                RIGHT(YEAR(:var_day_cursor), 2),
                :var_days_in_the_year,
                CASE
                    WHEN (:var_day_of_cursor >= 21 AND :var_month_cursor = 3
                        OR :var_day_of_cursor <= 19 AND :var_month_cursor = 4)
                        THEN '03 Aries'
                    WHEN (:var_day_of_cursor >= 20 AND :var_month_cursor = 4
                        OR :var_day_of_cursor <= 20 AND :var_month_cursor = 5)
                        THEN '04 Taurus'
                    WHEN (:var_day_of_cursor >= 21 AND :var_month_cursor = 5
                        OR :var_day_of_cursor <= 20 AND :var_month_cursor = 6)
                        THEN '05 Gemini'
                    WHEN (:var_day_of_cursor >= 21 AND :var_month_cursor = 6
                        OR :var_day_of_cursor <= 22 AND :var_month_cursor = 7)
                        THEN '06 Cancer'
                    WHEN (:var_day_of_cursor >= 23 AND :var_month_cursor = 7
                        OR :var_day_of_cursor <= 22 AND :var_month_cursor = 8)
                        THEN '07 Leo'
                    WHEN (:var_day_of_cursor >= 23 AND :var_month_cursor = 8
                        OR :var_day_of_cursor <= 22 AND :var_month_cursor = 9)
                        THEN '08 Virgo'
                    WHEN (:var_day_of_cursor >= 23 AND :var_month_cursor = 9
                        OR :var_day_of_cursor <= 22 AND :var_month_cursor = 10)
                        THEN '09 Libra'
                    WHEN (:var_day_of_cursor >= 23 AND :var_month_cursor = 10
                        OR :var_day_of_cursor <= 21 AND :var_month_cursor = 11)
                        THEN '10 Scorpio'
                    WHEN (:var_day_of_cursor >= 22 AND :var_month_cursor = 11
                        OR :var_day_of_cursor <= 21 AND :var_month_cursor = 12)
                        THEN '11 Sagittarius'
                    WHEN (:var_day_of_cursor >= 22 AND :var_month_cursor = 12
                        OR :var_day_of_cursor <= 20 AND :var_month_cursor = 1)
                        THEN '12 Capricorn'
                    WHEN (:var_day_of_cursor >= 21 AND :var_month_cursor = 1
                        OR :var_day_of_cursor <= 18 AND :var_month_cursor = 2)
                        THEN '01 Aquarius'
                    ELSE '02 Pisces'
                    END,
                :var_is_public_holiday,
                CONCAT(TO_VARCHAR(:var_day_cursor, 'DD MM YYYY'), ' (', :var_number_of_calendar_week, ')'),
                IFF(:var_week_day_number = 0, 1, 0),
                IFF(:var_tomorrow = 1, 1, 0),
                IFF(MONTH(DATEADD(DAY, 1, :var_day_cursor)) IN (1, 4, 7, 10)
                        AND :var_tomorrow = 1, 1, 0),
                IFF(MONTH(DATEADD(DAY, 1, :var_day_cursor)) = 1
                        AND :var_tomorrow = 1, 1, 0),
                DATEADD(DAY, IFF(:var_week_day_number = 0, -6, - :var_week_day_number + 1), :var_day_cursor),
                DATEADD(DAY, IFF(:var_week_day_number = 0, 0, 7 - :var_week_day_number), :var_day_cursor),
                TO_VARCHAR(:var_day_cursor, 'YYYY-MM-01'),
                LAST_DAY(:var_day_cursor),
                :var_begin_of_period,
                :var_end_of_period,
                TO_DATE(CONCAT(YEAR(:var_day_cursor), '-01-01')),
                TO_DATE(CONCAT(YEAR(:var_day_cursor), '-12-31')),
                DATEADD(DAY, -7, :var_day_cursor),
                DATEADD(DAY, 7, :var_day_cursor),
                DATEADD(MONTH, -1, :var_day_cursor),
                DATEADD(MONTH, 1, :var_day_cursor),
                DATEADD(MONTH, -3, :var_day_cursor),
                DATEADD(MONTH, 3, :var_day_cursor),
                DATEADD(YEAR, -1, :var_day_cursor),
                DATEADD(YEAR, 1, :var_day_cursor),
                :var_special,
                :var_is_working_day,
                :var_day_num_since_2020,
                :var_week_num_since_2020,
                :var_month_num_since_2020,
                :var_quarter_num_since_2020,
                :var_year_num_since_2020,
                CONCAT(YEAR(:var_day_cursor), '-', TO_CHAR(:var_day_cursor, 'MM')),
                DATEADD(DAY, 1, :var_day_cursor),
                DATEADD(DAY, -1, :var_day_cursor),
                TO_CHAR(:var_day_cursor, 'MM-DD'),
                CONCAT(DATEADD(DAY, IFF(:var_week_day_number = 0, -6, - :var_week_day_number + 1), :var_day_cursor)::varchar, ' - ',
                       DATEADD(DAY, IFF(:var_week_day_number = 0, 0, 7 - :var_week_day_number), :var_day_cursor))::varchar);

        var_day_cursor := DATEADD(DAY, 1, var_day_cursor);
        var_day_of_period := var_day_of_period + 1;
        var_day_num_since_2020 := var_day_num_since_2020 + 1;
        loopblock := loopblock + 1;

    END LOOP;

    INSERT INTO gear.CALENDAR_DATES(DATE, DATE8, DATE_YMD, DATE_DMY, DATE_MDY, DATE_DDMM, DATE_MMDD, DATE_DMMMY, DATE_DMMMMY, DAY_OF_WEEK, DAY_OF_WEEK_CHAR, IS_WEEKDAY,
                                       IS_WEEKEND, IS_LAST_DAY_OF_WEEK, IS_LAST_DAY_OF_MONTH, IS_LAST_DAY_OF_QUARTER, IS_LAST_DAY_OF_YEAR, DAY_NAME, DAY_NAME3, DAY_OF_MONTH,
                                       DAY_OF_MONTH2, DAY_OF_MONTH_CHAR, DAY_OF_QUARTER, DAY_OF_YEAR, WEEK, WEEK2, WEEK_FINANCE, WEEK_FULLNAME, YEAR_WEEK, MONTH, MONTH2,
                                       YEAR_MONTH2, MONTH_NAME, MONTH_NAME3, QUARTER, YEAR_QUARTER, YEAR, YEAR2, YEAR2C, NEXT_DATE, PREV_DATE, DAY_NUM_SINCE_2020,
                                       WEEK_NUM_SINCE_2020, MONTH_NUM_SINCE_2020, QUARTER_NUM_SINCE_2020, YEAR_NUM_SINCE_2020, WEEK_BEGIN, WEEK_END, MONTH_BEGIN, MONTH_END,
                                       QUARTER_BEGIN, QUARTER_END, YEAR_BEGIN, YEAR_END, WEEK_BEFORE, WEEK_AFTER, MONTH_BEFORE, MONTH_AFTER, QUARTER_BEFORE, QUARTER_AFTER,
                                       YEAR_BEFORE, YEAR_AFTER, IS_WORKING_DAY, IS_PUBLIC_HOLIDAY, SPECIAL_DATE, ZODIAC, FULLNAME, DESCRIPTION)
    SELECT DATE,
           DATE8,
           DATE_YMD,
           DATE_DMY,
           DATE_MDY,
           DATE_DDMM,
           DATE_MMDD,
           DATE_DMMMY,
           DATE_DMMMMY,
           DAY_OF_WEEK,
           DAY_OF_WEEK_CHAR,
           IS_WEEKDAY,
           IS_WEEKEND,
           IS_LAST_DAY_OF_WEEK,
           IS_LAST_DAY_OF_MONTH,
           IS_LAST_DAY_OF_QUARTER,
           IS_LAST_DAY_OF_YEAR,
           DAY_NAME,
           DAY_NAME3,
           DAY_OF_MONTH,
           DAY_OF_MONTH2,
           DAY_OF_MONTH_CHAR,
           DAY_OF_QUARTER,
           DAY_OF_YEAR,
           WEEK,
           WEEK2,
           WEEK_FINANCE,
           WEEK_FULLNAME,
           YEAR_WEEK,
           MONTH,
           MONTH2,
           YEAR_MONTH2,
           MONTH_NAME,
           MONTH_NAME3,
           QUARTER,
           YEAR_QUARTER,
           YEAR,
           YEAR2,
           YEAR2C,
           NEXT_DATE,
           PREV_DATE,
           DAY_NUM_SINCE_2020,
           WEEK_NUM_SINCE_2020,
           MONTH_NUM_SINCE_2020,
           QUARTER_NUM_SINCE_2020,
           YEAR_NUM_SINCE_2020,
           WEEK_BEGIN,
           WEEK_END,
           MONTH_BEGIN,
           MONTH_END,
           QUARTER_BEGIN,
           QUARTER_END,
           YEAR_BEGIN,
           YEAR_END,
           WEEK_BEFORE,
           WEEK_AFTER,
           MONTH_BEFORE,
           MONTH_AFTER,
           QUARTER_BEFORE,
           QUARTER_AFTER,
           YEAR_BEFORE,
           YEAR_AFTER,
           IS_WORKING_DAY,
           IS_PUBLIC_HOLIDAY,
           SPECIAL_DATE,
           ZODIAC,
           FULLNAME,
           DESCRIPTION
    FROM temp_calendar_dates;

    DROP TABLE temp_calendar_dates;

    RETURN TRUE;

END;
;
/*
 STEP 3.

 RUN IT!

 It takes up to 40 seconds.
 */

TRUNCATE TABLE gear.calendar_dates;
CALL gear.service_calendar_dates_population();

/*
 Check it..
 */
SELECT *
FROM gear.calendar_dates;

SELECT COUNT(*) AS d
FROM gear.calendar_dates;
-- result: 6211

SELECT (COUNT(*) / 356) AS y
FROM  gear.calendar_dates;
-- 17.4466

SELECT *
FROM  gear.calendar_dates
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
