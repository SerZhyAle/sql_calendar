/* calendar_dates pointing each day in period

 The idea to have the table with already calculated parameters for any daily aggregations.
 The fields date and date8 (int 8) can be dimensions in joined aggregated tables.

 week_begin - pointing view calendar_weeks
 year_month2 - pointing view calendar_months
 year - pointing view calendar_years


 A code here for Microsoft SQL

 -- _________________________________________________________________ --
 STEP 1.
 Create the table calendar_dates

 USE Your_database_schema

 Use the '_swap' table for creation, filling the table before swap it onto place with one transaction:

  run one by one..
 */
-- ALTER TABLE [calendar_dates_swap] DROP CONSTRAINT if EXISTS [DF_calendar_dates_created];
ALTER TABLE calendar_dates
    DROP CONSTRAINT IF EXISTS df_calendar_dates_created;
DROP TABLE IF EXISTS calendar_dates_swap

CREATE TABLE calendar_dates_swap
(
    -- original uniq combination
    date                   date         NOT NULL
        PRIMARY KEY,                              -- 'YYYY-MM-DD -date'
    date8                  int
        CHECK (date8 > 0)               NOT NULL, -- 'YYYYMMDD -int'
    date_ymd               char(10)     NOT NULL, -- 'YYYY-MM-DD -char(10)'
    date_dmy               char(10)     NOT NULL, -- 'DD.MM.YYYY -char(10)'
    date_mdy               char(10)     NOT NULL, -- 'MM/DD/YYYY -char(10)'

    -- data
    date_ddmm              char(5)      NOT NULL, -- 'DD.MM -char(5)'
    date_mmdd              char(5)      NOT NULL, -- 'MM-DD -char(5)'
    date_dmmmy             char(11)     NOT NULL, -- 'DD MMM YYYY -char(11)'
    date_dmmmmy            varchar(25)  NOT NULL, -- 'DD Month YYYY -varchar(25)'
    day_of_week            smallint
        CHECK (day_of_week >= 0)        NOT NULL, -- 'Day Number in Week 0=sunday -smallint'
    day_of_week_char       varchar(5)   NOT NULL, -- 'Name of Number of Day in Week -varchar(5)'
    is_weekday             bit          NOT NULL, -- 'True if NOT Saturday and NOT Sunday -bit'
    is_weekend             bit          NOT NULL, -- 'True if Saturday or Sunday -bit'
    is_last_day_of_week    bit          NOT NULL, -- 'True if Sunday -bit'
    is_last_day_of_month   bit          NOT NULL, -- 'True if last day of month -bit'
    is_last_day_of_quarter bit          NOT NULL, -- 'True if last day of quarter -bit'
    is_last_day_of_year    bit          NOT NULL, -- 'True if last day of year -bit'
    day_name               varchar(10)  NOT NULL, -- 'Day Name in Week -varchar(10)'
    day_name3              char(3)      NOT NULL, -- 'Day Name in Week -char(3)'
    day_of_month           smallint
        CHECK (day_of_month > 0)        NOT NULL, -- 'Day Number in Month -tinyint'
    day_of_month2          char(2)      NOT NULL, -- 'Day Number in Month (0 leads) -char(2)'
    day_of_month_char      varchar(5)   NOT NULL, -- 'Name of Number of Day in Month -varchar(5)'
    day_of_quarter         smallint     NOT NULL, -- 'Day Number in Quarter -tinyint'
    day_of_year            smallint
        CHECK (day_of_year > 0)         NOT NULL, -- 'Day Number in Year -smallint'
    week                   smallint     NOT NULL, -- 'Week Number in Year (first day-monday) -tinyint'
    week2                  char(2)      NOT NULL, -- 'Week Number in Year (first day-monday) -char(2)'
    week_finance           smallint     NOT NULL, -- 'Week Number (finance) -tinyint'
    week_fullname          char(23)     NOT NULL, -- 'Week YYYY-MM-DD - YYYY-MM-DD fullname -char(23)'
    year_week              char(7)      NOT NULL, -- 'Year Week YYYY/WW -char(7)'
    month                  smallint     NOT NULL, -- 'Month Number in Year -tinyint'
    month2                 char(2)      NOT NULL, -- 'Month Number in Year (0 leads) -char(2)'
    year_month2            char(7)      NOT NULL, -- 'Year - Month2 YYYY-MM -char(7)'
    month_name             varchar(10)  NOT NULL, -- 'Month Name -varchar(10)'
    month_name3            char(3)      NOT NULL, -- 'Month Name -char(3)'
    quarter                smallint
        CHECK (quarter > 0)             NOT NULL, -- 'Quarter Number in Year -tinyint'
    year_quarter           char(6)      NOT NULL, -- 'Year quarter YYYY Q -char(6)'
    year                   smallint     NOT NULL, -- 'Year -smallint'
    year2                  smallint
        CHECK (year2 > 0)               NOT NULL, -- 'Year last 2 figures -tinyint'
    year2c                 char(2)      NOT NULL, -- 'Year last 2 chars -char(2)'
    days_in_year           smallint
        CHECK (days_in_year > 0)        NOT NULL
        DEFAULT '365',                            -- 'Amount days in this year def:365 -smallint'

    next_date              date         NOT NULL, -- 'Next Date -date'
    prev_date              date         NOT NULL, -- 'Previous Date -date'

    day_num_since_2020     int          NOT NULL, -- 'Day number since 2020-01-01 for order -int'
    week_num_since_2020    int          NOT NULL, -- 'Week number since 2020-01-01 for order -int'
    month_num_since_2020   int          NOT NULL, -- 'Month number since 2020-01-01 for order -int'
    quarter_num_since_2020 smallint     NOT NULL, -- 'Quarter number since 2020-01-01 for order -tinyint'
    year_num_since_2020    smallint     NOT NULL, -- 'Year number since 2020-01-01 for order -tinyint'

    week_begin             date         NOT NULL, -- 'Date of begin of this week -date'
    week_end               date         NOT NULL, -- 'Date of end of this week -date'
    month_begin            date         NOT NULL, -- 'Date of begin of this month -date'
    month_end              date         NOT NULL, -- 'Date of end of this month -date'
    quarter_begin          date         NOT NULL, -- 'Date of begin of this quarter -date'
    quarter_end            date         NOT NULL, -- 'Date of end of this quarter -date'
    year_begin             date         NOT NULL, -- 'Date of begin of this year -date'
    year_end               date         NOT NULL, -- 'Date of end of this year -date'

    week_before            date         NOT NULL, -- 'Same date week before -date'
    week_after             date         NOT NULL, -- 'Same date prev week -date'
    month_before           date         NOT NULL, -- 'Same date month before -date'
    month_after            date         NOT NULL, -- 'Same date prev month -date'
    quarter_before         date         NOT NULL, -- 'Same date quarter before -date'
    quarter_after          date         NOT NULL, -- 'Same date prev quarter -date'
    year_before            date         NOT NULL, -- 'Same date next year -date'
    year_after             date         NOT NULL, -- 'Same date prev year -date'

    is_working_day         bit          NOT NULL, -- 'Day is working in Sweden not special -tiny(int)'
    is_public_holiday      bit          NOT NULL, -- 'Is public holiday -tiny(int)'
    special_date           varchar(255) NULL
        DEFAULT NULL,                             -- 'Special note for date -varchar(255)'

    zodiac                 varchar(50)  NOT NULL, -- 'Zodiac sign -varchar(50)'

    -- row activity fields
    created_at             datetime2(6) NOT NULL
        CONSTRAINT df_calendar_dates_created
            DEFAULT (SYSDATETIME()),
    updated_at             datetime2(6) NULL
        DEFAULT NULL,                             -- 'Updated -datetime(6)'

    -- common fields
    fullname               varchar(255) NOT NULL, -- 'DD MMMM YYYY (DayName) -varchar(255)'
    description            varchar(1000)
        DEFAULT NULL                              -- ', -- ary for the calendar date -varchar(1000)'
)

CREATE UNIQUE INDEX uniq_index_calendar_dates_date
    ON calendar_dates_swap (date)

CREATE UNIQUE INDEX uniq_index_calendar_dates_date8
    ON calendar_dates_swap (date8)

CREATE INDEX index_calendar_dates_week_num_since_2020
    ON calendar_dates_swap (week_num_since_2020)

CREATE INDEX index_calendar_dates_year_month2
    ON calendar_dates_swap (year_month2)

CREATE INDEX index_calendar_dates_year_quarter
    ON calendar_dates_swap (year_quarter);

/*
 STEP 2.

 Fill the calendar_dates:

 The next procedure stored to fill the calendar:

 Attention:
 @day_cursor = '2019.12.31'; -- The BEGIN of the Dates
 @day_cursor_end = '2036.12.31'; -- The END of the dates. You probably know what is going on later.

 Check next:
 SELECT DATEPART(DW, '2023-11-12') -1;
 Must return: 0. In this case Sunday set as 1st day of week for your server.
 In other case you have to shift this variable in code.

 In this example working days set for 1,2,3,4,5 weekdays Mon-Fri

 Take a look onto commented block with holidays which can be changed for your country/region holidays.
 */ -- _________________________________________________________________ --

CREATE OR ALTER PROCEDURE service_calendar_dates_population AS

DECLARE
    @special              varchar(50), @is_public_holiday bit, @day_of_period smallint, @quarter tinyint, @quarter_was tinyint, @number_of_calendar_week smallint,
    @day_cursor           date, @day_cursor_end date, @begin_of_period date, @end_of_period date, @day_num_since_2020 int, @week_num_since_2020 int,
    @month_num_since_2020 int, @quarter_num_since_2020 int, @year_num_since_2020 int , @week_day_number tinyint, @days_in_the_year smallint,
    @is_weekend           bit, @is_working_day bit, @day_int int, @month_int int, @day_date date, @day_tomorrow date;

    SET @special = NULL;
    SET @is_public_holiday = NULL;
    SET @day_of_period = 1;

    SET @day_cursor = '2019.12.31';
    SET @quarter = 4;
    SET @quarter_was = 4;
    SET @number_of_calendar_week = 53;
    SET @day_cursor_end = '2036.12.31';
    SET @begin_of_period = '2019.10.01';

    SET @end_of_period = EOMONTH(DATEADD(MONTH, 3, @begin_of_period));
    SET @day_num_since_2020 = 1;
    SET @week_num_since_2020 = 1;
    SET @month_num_since_2020 = 0;
    SET @quarter_num_since_2020 = 1;
    SET @year_num_since_2020 = 0;
    SET @is_weekend = 0

-- _________________________________________________________________ --
    WHILE @day_cursor <= @day_cursor_end BEGIN

        SET @week_day_number = DATEPART(DW, @day_cursor) - 1; -- DW returns 1 for Sunday

        IF RIGHT(DATEPART(YY, @day_cursor), 2) IN (20, 24, 28, 32, 36, 40)
            SET @days_in_the_year = 366;
        ELSE
            SET @days_in_the_year = 365;

        IF DAY(@day_cursor) = 1
            SET @month_num_since_2020 = @month_num_since_2020 + 1;

        SET @is_public_holiday = 0;
        SET @special = NULL;

        IF (MONTH(@day_cursor) = 1 AND DAY(@day_cursor) = 1)
            BEGIN
                SET @is_public_holiday = 1;
                SET @special = 'New Year Day';
            END;

        IF (MONTH(@day_cursor) = 5 AND DAY(@day_cursor) = 1)
            BEGIN
                SET @is_public_holiday = 1;
                SET @special = 'May Day';
            END;

        IF (MONTH(@day_cursor) = 12 AND DAY(@day_cursor) = 25)
            BEGIN
                SET @is_public_holiday = 1;
                SET @special = 'Christmas Day';
            END;

        IF (MONTH(@day_cursor) = 12 AND DAY(@day_cursor) = 26)
            BEGIN
                SET @is_public_holiday = 1;
                SET @special = '2nd Day of Christmas';
            END;

        IF (@week_day_number IN (6, 0))
            SET @is_weekend = 1;
        ELSE
            SET @is_weekend = 0;

        IF (@is_public_holiday = 0 AND @is_weekend = 0)
            SET @is_working_day = 1;
        ELSE
            SET @is_working_day = 0;

        IF (MONTH(@day_cursor) IN (4, 7, 10, 1) AND DAY(@day_cursor) = 1)
            BEGIN
                SET @quarter = @quarter + 1;
                SET @begin_of_period = @day_cursor;
                SET @end_of_period = EOMONTH(DATEADD(MONTH, 3, @begin_of_period));
            END;

        IF (MONTH(@day_cursor) = 1 AND DAY(@day_cursor) = 1)
            BEGIN
                SET @quarter = 1;
                SET @year_num_since_2020 = @year_num_since_2020 + 1;
            END;

        IF (@quarter <> @quarter_was)
            BEGIN
                SET @day_of_period = 1;
                SET @quarter_was = @quarter;
                SET @quarter_num_since_2020 = @quarter_num_since_2020 + 1;
            END;

        IF @week_day_number = 1
            IF (MONTH(@day_cursor) = 1 AND @number_of_calendar_week > 50)
                SET @number_of_calendar_week = 1;
            ELSE
                SET @number_of_calendar_week = @number_of_calendar_week + 1;

        IF @week_day_number = 1
            SET @week_num_since_2020 = @week_num_since_2020 + 1;

        SET @day_date = CAST(@day_cursor AS date);
        SET @day_int = DAY(@day_date);
        SET @month_int = MONTH(@day_date);
        SET @day_tomorrow = DATEADD(DAY, 1, @day_cursor);

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
                FORMAT(@day_date, 'yyyyMMdd'),
                FORMAT(@day_date, 'yyyy-MM-dd'),
                FORMAT(@day_date, 'dd.MM.yyyy'),
                FORMAT(@day_date, 'dd.MM'),
                FORMAT(@day_date, 'MM/dd/yyyy'),
                FORMAT(@day_date, 'd MMM yy'),
                FORMAT(@day_date, 'd MMMM yy'),
                @week_day_number,
                CONCAT((@week_day_number + 1),
                       CASE
                           WHEN (@week_day_number + 1) > 3 THEN 'th'
                           WHEN (@week_day_number + 1) = 1 THEN 'st'
                           WHEN (@week_day_number + 1) = 2 THEN 'nd'
                           ELSE 'rd' END),
                IIF(@week_day_number IN (6, 0), 0, 1),
                @is_weekend,
                DATENAME(WEEKDAY, @day_date),
                LEFT(DATENAME(WEEKDAY, @day_date), 3),
                @day_int,
                FORMAT(@day_date, 'dd'),
                CONCAT(@day_int,
                       CASE
                           WHEN @day_int IN (1, 21, 31) THEN 'st'
                           WHEN @day_int IN (2, 22) THEN 'nd'
                           WHEN @day_int IN (3, 23) THEN 'rd'
                           ELSE 'th' END),
                @day_of_period,
                DATENAME(DAYOFYEAR, @day_date),
                @number_of_calendar_week,
                RIGHT(CONCAT('0', @number_of_calendar_week), 2),
                DATENAME(ISO_WEEK, @day_date),
                CONCAT(YEAR(@day_cursor), '/', RIGHT(CONCAT('0', @number_of_calendar_week), 2)),
                @month_int,
                FORMAT(@day_date, 'MM'),
                DATENAME(MONTH, @day_date),
                UPPER(LEFT(DATENAME(MM, @day_date), 3)),
                @quarter,
                CONCAT(YEAR(@day_cursor), ' ', @quarter),
                YEAR(@day_date),
                FORMAT(@day_date, 'yy'),
                FORMAT(@day_date, 'yy'),
                @days_in_the_year,
                CASE
                    WHEN (@day_int >= 21 AND @month_int = 3 OR
                          @day_int <= 19 AND @month_int = 4) THEN '03 Aries'
                    WHEN (@day_int >= 20 AND @month_int = 4 OR
                          @day_int <= 20 AND @month_int = 5) THEN '04 Taurus'
                    WHEN (@day_int >= 21 AND @month_int = 5 OR
                          @day_int <= 20 AND @month_int = 6) THEN '05 Gemini'
                    WHEN (@day_int >= 21 AND @month_int = 6 OR
                          @day_int <= 22 AND @month_int = 7) THEN '06 Cancer'
                    WHEN (@day_int >= 23 AND @month_int = 7 OR
                          @day_int <= 22 AND @month_int = 8) THEN '07 Leo'
                    WHEN (@day_int >= 23 AND @month_int = 8 OR
                          @day_int <= 22 AND @month_int = 9) THEN '08 Virgo'
                    WHEN (@day_int >= 23 AND @month_int = 9 OR
                          @day_int <= 22 AND @month_int = 10) THEN '09 Libra'
                    WHEN (@day_int >= 23 AND @month_int = 10 OR
                          @day_int <= 21 AND @month_int = 11) THEN '10 Scorpio'
                    WHEN (@day_int >= 22 AND @month_int = 11 OR
                          @day_int <= 21 AND @month_int = 12) THEN '11 Sagittarius'
                    WHEN (@day_int >= 22 AND @month_int = 12 OR
                          @day_int <= 20 AND @month_int = 1) THEN '12 Capricorn'
                    WHEN (@day_int >= 21 AND @month_int = 1 OR
                          @day_int <= 18 AND @month_int = 2) THEN '01 Aquarius'
                    ELSE '02 Pisces' END,
                @is_public_holiday,
                FORMAT(@day_date, 'dd MMMM yyyy (ww)'),
                IIF(@week_day_number = 0, 1, 0),
                IIF(DAY(@day_tomorrow) = 1, 1, 0),
                IIF(MONTH(@day_tomorrow) IN (1, 4, 7, 10)
                        AND DAY(@day_tomorrow) = 1, 1, 0),
                IIF(MONTH(@day_tomorrow) = 1
                        AND DAY(@day_tomorrow) = 1, 1, 0),
                DATEADD(DAY, IIF((@week_day_number = 0), -6, -@week_day_number + 1), @day_date),
                DATEADD(DAY, IIF((@week_day_number = 0), 0, 7 - @week_day_number),
                        @day_date),
                CAST(FORMAT(@day_date, 'yyyy-MM-01') AS date),
                EOMONTH(@day_date),
                @begin_of_period,
                @end_of_period,
                CAST(FORMAT(@day_date, 'yyyy-01-01') AS date),
                CAST(FORMAT(@day_date, 'yyyy-12-31') AS date),
                DATEADD(DAY, -7, @day_date),
                DATEADD(DAY, 7, @day_date),
                DATEADD(MONTH, -1, @day_date),
                DATEADD(MONTH, 1, @day_date),
                DATEADD(MONTH, -3, @day_date),
                DATEADD(MONTH, 3, @day_date),
                DATEADD(YEAR, -1, @day_date),
                DATEADD(YEAR, 1, @day_date),
                @special,
                @is_working_day,
                @day_num_since_2020,
                @week_num_since_2020,
                @month_num_since_2020,
                @quarter_num_since_2020,
                @year_num_since_2020,
                FORMAT(@day_date, 'yyyy-MM'),
                @day_tomorrow,
                DATEADD(DAY, -1, @day_date),
                FORMAT(@day_date, 'MM-dd'),
                CONCAT(FORMAT(DATEADD(DAY,
                                      IIF((@week_day_number = 0), -6, -@week_day_number + 1),
                                      @day_date), 'yy-MM-dd - '),
                       FORMAT(DATEADD(DAY,
                                      IIF((@week_day_number = 0), 0, 7 - @week_day_number),
                                      @day_date), 'yy-MM-dd')));

        SET @day_cursor = DATEADD(DAY, 1, @day_cursor);

        SET @day_of_period = @day_of_period + 1;

        SET @day_num_since_2020 = @day_num_since_2020 + 1;
    END;

    BEGIN TRANSACTION calendar_dates
    DROP TABLE IF EXISTS calendar_dates;

    EXEC sp_rename 'calendar_dates_swap', 'calendar_dates'

    COMMIT TRANSACTION calendar_dates;

GO

/*
 STEP 3.

 RUN IT!

 It takes up to 10 seconds.
 */

EXEC service_calendar_dates_population;

-- _________________________________________________________________ --
DROP TRIGGER IF EXISTS updatemodified

CREATE TRIGGER updatemodified
    ON calendar_dates
    AFTER UPDATE AS UPDATE calendar_dates
                    SET updated_at = SYSDATETIME()
                    FROM inserted i
                    WHERE calendar_dates.date = i.date; -- 'Updated_at for calendar dates';

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
    WHERE date IN (CAST(GETDATE() AS date), '2023.12.01', '2024.01.01', '2023-02-25', '2022-12-31', '2023-03-31')
    ORDER BY date;
/*
result:

date,date8,date_ymd,date_dmy,date_mdy,date_ddmm,date_mmdd,date_dmmmy,date_dmmmmy,day_of_week,day_of_week_char,is_weekday,is_weekend,is_last_day_of_week,is_last_day_of_month,is_last_day_of_quarter,is_last_day_of_year,day_name,day_name3,day_of_month,day_of_month2,day_of_month_char,day_of_quarter,day_of_year,week,week2,week_finance,week_fullname,year_week,month,month2,year_month2,month_name,month_name3,quarter,year_quarter,year,year2,year2c,days_in_year,next_date,prev_date,day_num_since_2020,week_num_since_2020,month_num_since_2020,quarter_num_since_2020,year_num_since_2020,week_begin,week_end,month_begin,month_end,quarter_begin,quarter_end,year_begin,year_end,week_before,week_after,month_before,month_after,quarter_before,quarter_after,year_before,year_after,is_working_day,is_public_holiday,special_date,zodiac,created_at,updated_at,fullname,description
2022-12-31,20221231,2022-12-31,31.12.2022,12/31/2022,31.12,12-31,31 Dec 22  ,31 December 22,6,7th,false,true,false,true,true,true,Saturday,Sat,31,31,31st,92,365,52,52,52,22-12-26 - 23-01-01    ,2022/52,12,12,2022-12,December,DEC,4,2022 4,2022,22,22,365,2023-01-01,2022-12-30,1097,157,36,13,3,2022-12-26,2023-01-01,2022-12-01,2022-12-31,2022-10-01,2023-01-31,2022-01-01,2022-12-31,2022-12-24,2023-01-07,2022-11-30,2023-01-31,2022-09-30,2023-03-31,2021-12-31,2023-12-31,false,false,,12 Capricorn,2023-11-22 03:49:34.970507,,31 December 2022 (ww),
2023-02-25,20230225,2023-02-25,25.02.2023,02/25/2023,25.02,02-25,25 Feb 23  ,25 February 23,6,7th,false,true,false,false,false,false,Saturday,Sat,25,25,25th,56,56,8,08,8,23-02-20 - 23-02-26    ,2023/08,2,02,2023-02,February,FEB,1,2023 1,2023,23,23,365,2023-02-26,2023-02-24,1153,165,38,14,4,2023-02-20,2023-02-26,2023-02-01,2023-02-28,2023-01-01,2023-04-30,2023-01-01,2023-12-31,2023-02-18,2023-03-04,2023-01-25,2023-03-25,2022-11-25,2023-05-25,2022-02-25,2024-02-25,false,false,,02 Pisces,2023-11-22 03:49:34.986141,,25 February 2023 (ww),
2023-03-31,20230331,2023-03-31,31.03.2023,03/31/2023,31.03,03-31,31 Mar 23  ,31 March 23,5,6th,true,false,false,true,true,false,Friday,Fri,31,31,31st,90,90,13,13,13,23-03-27 - 23-04-02    ,2023/13,3,03,2023-03,March,MAR,1,2023 1,2023,23,23,365,2023-04-01,2023-03-30,1187,170,39,14,4,2023-03-27,2023-04-02,2023-03-01,2023-03-31,2023-01-01,2023-04-30,2023-01-01,2023-12-31,2023-03-24,2023-04-07,2023-02-28,2023-04-30,2022-12-31,2023-06-30,2022-03-31,2024-03-31,true,false,,03 Aries,2023-11-22 03:49:34.986141,,31 March 2023 (ww),
2023-11-22,20231122,2023-11-22,22.11.2023,11/22/2023,22.11,11-22,22 Nov 23  ,22 November 23,3,4th,true,false,false,false,false,false,Wednesday,Wed,22,22,22nd,53,326,47,47,47,23-11-20 - 23-11-26    ,2023/47,11,11,2023-11,November,NOV,4,2023 4,2023,23,23,365,2023-11-23,2023-11-21,1423,204,47,17,4,2023-11-20,2023-11-26,2023-11-01,2023-11-30,2023-10-01,2024-01-31,2023-01-01,2023-12-31,2023-11-15,2023-11-29,2023-10-22,2023-12-22,2023-08-22,2024-02-22,2022-11-22,2024-11-22,true,false,,11 Sagittarius,2023-11-22 03:49:35.064257,,22 November 2023 (ww),
2023-12-01,20231201,2023-12-01,01.12.2023,12/01/2023,01.12,12-01,1 Dec 23   ,1 December 23,5,6th,true,false,false,false,false,false,Friday,Fri,1,01,1st,62,335,48,48,48,23-11-27 - 23-12-03    ,2023/48,12,12,2023-12,December,DEC,4,2023 4,2023,23,23,365,2023-12-02,2023-11-30,1432,205,48,17,4,2023-11-27,2023-12-03,2023-12-01,2023-12-31,2023-10-01,2024-01-31,2023-01-01,2023-12-31,2023-11-24,2023-12-08,2023-11-01,2024-01-01,2023-09-01,2024-03-01,2022-12-01,2024-12-01,true,false,,11 Sagittarius,2023-11-22 03:49:35.064257,,01 December 2023 (ww),
2024-01-01,20240101,2024-01-01,01.01.2024,01/01/2024,01.01,01-01,1 Jan 24   ,1 January 24,1,2nd,true,false,false,false,false,false,Monday,Mon,1,01,1st,1,1,1,01,1,24-01-01 - 24-01-07    ,2024/01,1,01,2024-01,January,JAN,1,2024 1,2024,24,24,366,2024-01-02,2023-12-31,1463,210,49,18,5,2024-01-01,2024-01-07,2024-01-01,2024-01-31,2024-01-01,2024-04-30,2024-01-01,2024-12-31,2023-12-25,2024-01-08,2023-12-01,2024-02-01,2023-10-01,2024-04-01,2023-01-01,2025-01-01,false,true,New Year Day,12 Capricorn,2023-11-22 03:49:35.079882,,01 January 2024 (ww),
 */

-- NEXT: calendar_hours presented in separated sql file

/*
 sza(c)
 */
