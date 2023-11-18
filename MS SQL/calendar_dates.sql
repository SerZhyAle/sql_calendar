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
-- ALTER TABLE [calendar_dates] DROP CONSTRAINT if EXISTS [DF_calendar_dates_created];
DROP TABLE IF EXISTS [calendar_dates_swap]

CREATE TABLE [calendar_dates_swap] (
    -- original uniq combination
    [date]                   DATE                                NOT NULL PRIMARY KEY,   --  'YYYY.MM.DD -date'
    [date8]                  INT CHECK ([date8] > 0)             NOT NULL,               --  'YYYYMMDD -int'
    [date_ymd]               CHAR(10)                            NOT NULL,               --  'YYYY-MM-DD -char(10)'
    [date_dmy]               CHAR(10)                            NOT NULL,               --  'DD.MM.YYYY -char(10)'
    [date_mdy]               CHAR(10)                            NOT NULL,               --  'MM/DD/YYYY -char(10)'

    -- data
    [date_ddmm]              CHAR(5)                             NOT NULL,               --  'DD.MM -char(5)'
    [date_mmdd]              CHAR(5)                             NOT NULL,               --  'MM-DD -char(5)'
    [date_dmmmy]             CHAR(11)                            NOT NULL,               --  'DD MMM YYYY -char(11)'
    [date_dmmmmy]            VARCHAR(25)                         NOT NULL,               --  'DD Month YYYY -varchar(25)'
    [day_of_week]            SMALLINT CHECK ([day_of_week] >= 0) NOT NULL,               --  'Day Number in Week 0=sunday -smallint'
    [day_of_week_char]       VARCHAR(5)                          NOT NULL,               --  'Name of Number of Day in Week -varchar(5)'
    [is_weekday]             BIT                                 NOT NULL,               --  'True if NOT Saturday and NOT Sunday -bit'
    [is_weekend]             BIT                                 NOT NULL,               --  'True if Saturday or Sunday -bit'
    [is_last_day_of_week]    BIT                                 NOT NULL,               --  'True if Sunday -bit'
    [is_last_day_of_month]   BIT                                 NOT NULL,               --  'True if last day of month -bit'
    [is_last_day_of_quarter] BIT                                 NOT NULL,               --  'True if last day of quarter -bit'
    [is_last_day_of_year]    BIT                                 NOT NULL,               --  'True if last day of year -bit'
    [day_name]               VARCHAR(10)                         NOT NULL,               --  'Day Name in Week -varchar(10)'
    [day_name3]              CHAR(3)                             NOT NULL,               --  'Day Name in Week -char(3)'
    [day_of_month]           SMALLINT CHECK ([day_of_month] > 0) NOT NULL,               --  'Day Number in Month -tinyint'
    [day_of_month2]          CHAR(2)                             NOT NULL,               --  'Day Number in Month (0 leads) -char(2)'
    [day_of_month_char]      VARCHAR(5)                          NOT NULL,               -- 'Name of Number of Day in Month -varchar(5)'
    [day_of_quarter]         SMALLINT                            NOT NULL,               --  'Day Number in Quarter -tinyint'
    [day_of_year]            SMALLINT CHECK ([day_of_year] > 0)  NOT NULL,               --  'Day Number in Year -smallint'
    [week]                   SMALLINT                            NOT NULL,               --  'Week Number in Year (first day-monday) -tinyint'
    [week_num]               SMALLINT                            NOT NULL,               --  'Week Number in Year (first day-monday) -tinyint'
    [week_finance]           SMALLINT                            NOT NULL,               --  'Week Number (finance) -tinyint'
    [week_fullname]          CHAR(23)                            NOT NULL,               --  'Week YYYY-MM-DD - YYYY-MM-DD fullname -char(23)'
    [month]                  SMALLINT                            NOT NULL,               --  'Month Number in Year -tinyint'
    [month2]                 CHAR(2)                             NOT NULL,               --  'Month Number in Year (0 leads) -char(2)'
    [year_month2]            CHAR(7)                             NOT NULL,               --  'Year - Month2 YYYY-MM -char(7)'
    [month_name]             VARCHAR(10)                         NOT NULL,               --  'Month Name -varchar(10)'
    [month_name3]            CHAR(3)                             NOT NULL,               --  'Month Name -char(3)'
    [quarter]                SMALLINT CHECK ([quarter] > 0)      NOT NULL,               --  'Quarter Number in Year -tinyint'
    [year]                   SMALLINT                            NOT NULL,               --  'Year -smallint'
    [year2]                  SMALLINT CHECK ([year2] > 0)        NOT NULL,               --  'Year last 2 figures -tinyint'
    [year2c]                 CHAR(2)                             NOT NULL,               --  'Year last 2 chars -char(2)'
    [days_in_year]           SMALLINT CHECK ([days_in_year] > 0) NOT NULL DEFAULT '365', --  'Amount days in this year def:365 -smallint'

    [next_date]              DATE                                NOT NULL,               --  'Next Date -date'
    [prev_date]              DATE                                NOT NULL,               --  'Previous Date -date'

    [day_num_since_2020]     INT                                 NOT NULL,               --  'Day number since 2020-01-01 for order -int'
    [week_num_since_2020]    INT                                 NOT NULL,               --  'Week number since 2020-01-01 for order -int'
    [month_num_since_2020]   INT                                 NOT NULL,               --  'Month number since 2020-01-01 for order -int'
    [quarter_num_since_2020] SMALLINT                            NOT NULL,               --  'Quarter number since 2020-01-01 for order -tinyint'
    [year_num_since_2020]    SMALLINT                            NOT NULL,               --  'Year number since 2020-01-01 for order -tinyint'

    [week_begin]             DATE                                NOT NULL,               --  'Date of begin of this week -date'
    [week_end]               DATE                                NOT NULL,               --  'Date of end of this week -date'
    [month_begin]            DATE                                NOT NULL,               --  'Date of begin of this month -date'
    [month_end]              DATE                                NOT NULL,               --  'Date of end of this month -date'
    [quarter_begin]          DATE                                NOT NULL,               --  'Date of begin of this quarter -date'
    [quarter_end]            DATE                                NOT NULL,               --  'Date of end of this quarter -date'
    [year_begin]             DATE                                NOT NULL,               --  'Date of begin of this year -date'
    [year_end]               DATE                                NOT NULL,               --  'Date of end of this year -date'

    [week_before]            DATE                                NOT NULL,               --  'Same date week before -date'
    [week_after]             DATE                                NOT NULL,               --  'Same date prev week -date'
    [month_before]           DATE                                NOT NULL,               --  'Same date month before -date'
    [month_after]            DATE                                NOT NULL,               --  'Same date prev month -date'
    [quarter_before]         DATE                                NOT NULL,               --  'Same date quarter before -date'
    [quarter_after]          DATE                                NOT NULL,               --  'Same date prev quarter -date'
    [year_before]            DATE                                NOT NULL,               --  'Same date next year -date'
    [year_after]             DATE                                NOT NULL,               --  'Same date prev year -date'

    [is_working_day]         BIT                                 NOT NULL,               --  'Day is working in Sweden not special -tiny(int)'
    [is_public_holiday]      BIT                                 NOT NULL,               --  'Is public holiday -tiny(int)'
    [special_date]           VARCHAR(255)                        NULL     DEFAULT NULL,  --  'Special note for date -varchar(255)'

    [zodiac]                 VARCHAR(50)                         NOT NULL,               --  'Zodiac sign -varchar(50)'

    -- row activity fields
    [created_at]             DATETIME2(6)                        NOT NULL CONSTRAINT [DF_calendar_dates_created] DEFAULT (SYSDATETIME()),
    [updated_at]             DATETIME2(6)                        NULL     DEFAULT NULL,  --  'Updated -datetime(6)'

    -- common fields
    [fullname]               VARCHAR(255)                        NOT NULL,               --  'DD MMMM YYYY (DayName) -varchar(255)'
    [description]            VARCHAR(1000)                                DEFAULT NULL   --  ', -- ary for the calendar date -varchar(1000)'
)

CREATE UNIQUE INDEX [uniq_index_calendar_date] ON [calendar_dates_swap] ([date])

CREATE UNIQUE INDEX [uniq_index_calendar_date8] ON [calendar_dates_swap] ([date8])
CREATE INDEX [index_calendar_week_num_since_2020] ON [calendar_dates_swap] ([week_num_since_2020])
CREATE INDEX [index_calendar_year_month2] ON [calendar_dates_swap] ([year_month2])

/*
 STEP 1.5.

 Separate..
*/
DROP TRIGGER IF EXISTS [updateModified]

CREATE TRIGGER [updateModified]
    ON [calendar_dates_swap]
    AFTER UPDATE AS UPDATE [calendar_dates_swap]
                    SET [updated_at] = SYSDATETIME()
                    FROM [Inserted] [i]
                    WHERE [calendar_dates_swap].[date] = [i].[date]; --  'Updated_at for calendar dates';

/*
 STEP 2.

 Fill the calendar_dates:

 The next procedure stored to fill the calendar:

 Attention:
 @day_cursor = '2019.12.31'; -- The BEGIN of the Dates
 @day_cursor_end = '2036.12.31';  -- The END of the dates. You probably know what is going on later.

 Check next:
  SELECT DATEPART(DW, '2023-11-12') -1;
 Must return: 0. In this case Sunday set as 1st day of week for your server.
 In other case you have to shift this variable in code.

 In this example working days set for 1,2,3,4,5 weekdays Mon-Fri

 Take a look onto commented block with holidays which can be changed for your country/region holidays.
 */ -- _________________________________________________________________ --
CREATE OR ALTER PROCEDURE [service_calendar_dates_population] AS

DECLARE
    @special VARCHAR(50), @is_public_holiday BIT, @day_of_period SMALLINT, @period_now TINYINT, @period_was TINYINT, @number_of_calendar_week SMALLINT, @day_cursor DATE, @day_cursor_end DATE, @begin_of_period DATE, @end_of_period DATE, @day_num_since_2020 INT, @week_num_since_2020 INT, @month_num_since_2020 INT, @quarter_num_since_2020 INT, @year_num_since_2020 INT , @week_day_number TINYINT, @days_in_the_year SMALLINT, @is_weekend BIT, @is_working_day BIT;

    SET @special = NULL;
    SET @is_public_holiday = NULL;
    SET @day_of_period = 1;
    SET @period_now = 1;
    SET @period_was = 1;
    SET @number_of_calendar_week = 1;

    SET @day_cursor = '2019.12.31';
    SET @day_cursor_end = '2036.12.31';

    SET @begin_of_period = @day_cursor;
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
        IF RIGHT(DATEPART(YY, @day_cursor), 2) IN (20, 24, 28, 32, 36, 40) SET @days_in_the_year = 366; ELSE SET @days_in_the_year = 365;
        IF DAY(@day_cursor) = 1 SET @month_num_since_2020 = @month_num_since_2020 + 1;

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
        IF (@week_day_number IN (6, 0)) SET @is_weekend = 1 ELSE SET @is_weekend = 0;
        IF (@is_public_holiday = 0 AND @is_weekend = 0) SET @is_working_day = 1 ELSE SET @is_working_day = 0;
        IF (MONTH(@day_cursor) IN (4, 7, 10, 1) AND DAY(@day_cursor) = 1)
            BEGIN
                SET @period_now = @period_now + 1;
                SET @begin_of_period = @day_cursor;
                SET @end_of_period = EOMONTH(DATEADD(MONTH, 3, @begin_of_period));
            END;
        IF (MONTH(@day_cursor) IN (4, 7, 10, 1) AND DAY(@day_cursor) = 1)
            BEGIN
                SET @period_now = @period_now + 1;
                SET @begin_of_period = @day_cursor;
                SET @end_of_period = EOMONTH(DATEADD(MONTH, 3, @begin_of_period));
            END;
        IF (MONTH(@day_cursor) = 1 AND DAY(@day_cursor) = 1)
            BEGIN
                SET @period_now = 1;
                SET @year_num_since_2020 = @year_num_since_2020 + 1;
            END;
        IF (@period_now <> @period_was)
            BEGIN
                SET @day_of_period = 1;
                SET @period_was = @period_now;
                SET @quarter_num_since_2020 = @quarter_num_since_2020 + 1;
            END;
        IF @week_day_number = 1
            IF (MONTH(@day_cursor) = 1 AND @number_of_calendar_week > 50) SET @number_of_calendar_week = 1; ELSE SET @number_of_calendar_week = @number_of_calendar_week + 1;
        IF @week_day_number = 1 SET @week_num_since_2020 = @week_num_since_2020 + 1;

        INSERT INTO [calendar_dates_swap]([date],
                                          [date8],
                                          [date_ymd],
                                          [date_dmy],
                                          [date_ddmm],
                                          [date_mdy],
                                          [date_dmmmy],
                                          [date_dmmmmy],
                                          [day_of_week],
                                          [day_of_week_char],
                                          [is_weekday],
                                          [is_weekend],
                                          [day_name],
                                          [day_name3],
                                          [day_of_month],
                                          [day_of_month2],
                                          [day_of_month_char],
                                          [day_of_quarter],
                                          [day_of_year],
                                          [week],
                                          [week_num],
                                          [week_finance],
                                          [month],
                                          [month2],
                                          [month_name],
                                          [month_name3],
                                          [quarter],
                                          [year],
                                          [year2],
                                          [year2c],
                                          [days_in_year],
                                          [zodiac],
                                          [is_public_holiday],
                                          [fullname],
                                          [is_last_day_of_week],
                                          [is_last_day_of_month],
                                          [is_last_day_of_quarter],
                                          [is_last_day_of_year],
                                          [week_begin],
                                          [week_end],
                                          [month_begin],
                                          [month_end],
                                          [quarter_begin],
                                          [quarter_end],
                                          [year_begin],
                                          [year_end],
                                          [week_before],
                                          [week_after],
                                          [month_before],
                                          [month_after],
                                          [quarter_before],
                                          [quarter_after],
                                          [year_before],
                                          [year_after],
                                          [special_date],
                                          [is_working_day],
                                          [day_num_since_2020],
                                          [week_num_since_2020],
                                          [month_num_since_2020],
                                          [quarter_num_since_2020],
                                          [year_num_since_2020],
                                          [year_month2],
                                          [next_date],
                                          [prev_date],
                                          [date_mmdd],
                                          [week_fullname])
        VALUES (@day_cursor,
                FORMAT(CAST(@day_cursor AS DATE), 'yyyyMMdd'),
                FORMAT(CAST(@day_cursor AS DATE), 'yyyy-MM-dd'),
                FORMAT(CAST(@day_cursor AS DATE), 'dd.MM.yyyy'),
                FORMAT(CAST(@day_cursor AS DATE), 'dd.MM'),
                FORMAT(CAST(@day_cursor AS DATE), 'MM/dd/yyyy'),
                FORMAT(CAST(@day_cursor AS DATE), 'd MMM yy'),
                FORMAT(CAST(@day_cursor AS DATE), 'd MMMM yy'),
                @week_day_number,
                CONCAT((@week_day_number + 1),
                       CASE WHEN (@week_day_number + 1) > 3 THEN 'th' WHEN (@week_day_number + 1) = 1 THEN 'st' WHEN (@week_day_number + 1) = 2 THEN 'nd' ELSE 'rd' END),
                (CASE WHEN @week_day_number IN (6, 0) THEN 0 ELSE 1 END),
                @is_weekend,
                DATENAME(WEEKDAY, CAST(@day_cursor AS DATE)),
                LEFT(DATENAME(WEEKDAY, CAST(@day_cursor AS DATE)), 3),
                DAY(CAST(@day_cursor AS DATE)),
                FORMAT(CAST(@day_cursor AS DATE), 'dd'),
                CONCAT(DAY(CAST(@day_cursor AS DATE)), CASE
                                                           WHEN DAY(CAST(@day_cursor AS DATE)) IN (1, 21, 31) THEN 'st'
                                                           WHEN DAY(CAST(@day_cursor AS DATE)) IN (2, 22) THEN 'nd'
                                                           WHEN DAY(CAST(@day_cursor AS DATE)) IN (3, 23) THEN 'rd'
                                                           ELSE 'th' END),
                @day_of_period,
                DATENAME(DAYOFYEAR, CAST(@day_cursor AS DATE)),
                @number_of_calendar_week,
                DATENAME(WEEK, CAST(@day_cursor AS DATE)),
                DATENAME(ISO_WEEK, CAST(@day_cursor AS DATE)),
                MONTH(CAST(@day_cursor AS DATE)),
                FORMAT(CAST(@day_cursor AS DATE), 'MM'),
                DATENAME(MONTH, CAST(@day_cursor AS DATE)),
                UPPER(LEFT(DATENAME(MM, CAST(@day_cursor AS DATE)), 3)),
                @period_now,
                YEAR(CAST(@day_cursor AS DATE)),
                FORMAT(CAST(@day_cursor AS DATE), 'yy'),
                FORMAT(CAST(@day_cursor AS DATE), 'yy'),
                @days_in_the_year,
                CASE
                    WHEN (DAY(CAST(@day_cursor AS DATE)) >= 21 AND MONTH(CAST(@day_cursor AS DATE)) = 3 OR
                          DAY(CAST(@day_cursor AS DATE)) <= 19 AND MONTH(CAST(@day_cursor AS DATE)) = 4) THEN '03 Aries'
                    WHEN (DAY(CAST(@day_cursor AS DATE)) >= 20 AND MONTH(CAST(@day_cursor AS DATE)) = 4 OR
                          DAY(CAST(@day_cursor AS DATE)) <= 20 AND MONTH(CAST(@day_cursor AS DATE)) = 5) THEN '04 Taurus'
                    WHEN (DAY(CAST(@day_cursor AS DATE)) >= 21 AND MONTH(CAST(@day_cursor AS DATE)) = 5 OR
                          DAY(CAST(@day_cursor AS DATE)) <= 20 AND MONTH(CAST(@day_cursor AS DATE)) = 6) THEN '05 Gemini'
                    WHEN (DAY(CAST(@day_cursor AS DATE)) >= 21 AND MONTH(CAST(@day_cursor AS DATE)) = 6 OR
                          DAY(CAST(@day_cursor AS DATE)) <= 22 AND MONTH(CAST(@day_cursor AS DATE)) = 7) THEN '06 Cancer'
                    WHEN (DAY(CAST(@day_cursor AS DATE)) >= 23 AND MONTH(CAST(@day_cursor AS DATE)) = 7 OR
                          DAY(CAST(@day_cursor AS DATE)) <= 22 AND MONTH(CAST(@day_cursor AS DATE)) = 8) THEN '07 Leo'
                    WHEN (DAY(CAST(@day_cursor AS DATE)) >= 23 AND MONTH(CAST(@day_cursor AS DATE)) = 8 OR
                          DAY(CAST(@day_cursor AS DATE)) <= 22 AND MONTH(CAST(@day_cursor AS DATE)) = 9) THEN '08 Virgo'
                    WHEN (DAY(CAST(@day_cursor AS DATE)) >= 23 AND MONTH(CAST(@day_cursor AS DATE)) = 9 OR
                          DAY(CAST(@day_cursor AS DATE)) <= 22 AND MONTH(CAST(@day_cursor AS DATE)) = 10) THEN '09 Libra'
                    WHEN (DAY(CAST(@day_cursor AS DATE)) >= 23 AND MONTH(CAST(@day_cursor AS DATE)) = 10 OR
                          DAY(CAST(@day_cursor AS DATE)) <= 21 AND MONTH(CAST(@day_cursor AS DATE)) = 11) THEN '10 Scorpio'
                    WHEN (DAY(CAST(@day_cursor AS DATE)) >= 22 AND MONTH(CAST(@day_cursor AS DATE)) = 11 OR
                          DAY(CAST(@day_cursor AS DATE)) <= 21 AND MONTH(CAST(@day_cursor AS DATE)) = 12) THEN '11 Sagittarius'
                    WHEN (DAY(CAST(@day_cursor AS DATE)) >= 22 AND MONTH(CAST(@day_cursor AS DATE)) = 12 OR
                          DAY(CAST(@day_cursor AS DATE)) <= 20 AND MONTH(CAST(@day_cursor AS DATE)) = 1) THEN '12 Capricorn'
                    WHEN (DAY(CAST(@day_cursor AS DATE)) >= 21 AND MONTH(CAST(@day_cursor AS DATE)) = 1 OR
                          DAY(CAST(@day_cursor AS DATE)) <= 18 AND MONTH(CAST(@day_cursor AS DATE)) = 2) THEN '01 Aquarius'
                    ELSE '02 Pisces' END,
                @is_public_holiday,
                FORMAT(CAST(@day_cursor AS DATE), 'dd MMMM yyyy (ww)'),
                CASE WHEN @week_day_number = 0 THEN 1 ELSE 0 END,
                CASE WHEN DAY(DATEADD(DAY, 1, CAST(@day_cursor AS DATE))) = 1 THEN 1 ELSE 0 END,
                CASE WHEN MONTH(DATEADD(DAY, 1, CAST(@day_cursor AS DATE))) IN (1, 4, 7, 10) AND DAY(DATEADD(DAY, 1, CAST(@day_cursor AS DATE))) = 1 THEN 1 ELSE 0 END,
                CASE WHEN MONTH(DATEADD(DAY, 1, CAST(@day_cursor AS DATE))) = 1 AND DAY(DATEADD(DAY, 1, CAST(@day_cursor AS DATE))) = 1 THEN 1 ELSE 0 END,
                DATEADD(DAY, CASE WHEN (@week_day_number = 0) THEN -6 ELSE -@week_day_number + 1 END, CAST(@day_cursor AS DATE)),
                DATEADD(DAY, CASE WHEN (@week_day_number = 0) THEN 0 ELSE 7 - @week_day_number END, CAST(@day_cursor AS DATE)),
                CAST(FORMAT(CAST(@day_cursor AS DATE), 'yyyy-MM-01') AS DATE),
                EOMONTH(CAST(@day_cursor AS DATE)),
                @begin_of_period,
                @end_of_period,
                CAST(FORMAT(CAST(@day_cursor AS DATE), 'yyyy-01-01') AS DATE),
                CAST(FORMAT(CAST(@day_cursor AS DATE), 'yyyy-12-31') AS DATE),
                DATEADD(DAY, -7, CAST(@day_cursor AS DATE)),
                DATEADD(DAY, 7, CAST(@day_cursor AS DATE)),
                DATEADD(MONTH, -1, CAST(@day_cursor AS DATE)),
                DATEADD(MONTH, 1, CAST(@day_cursor AS DATE)),
                DATEADD(MONTH, -3, CAST(@day_cursor AS DATE)),
                DATEADD(MONTH, 3, CAST(@day_cursor AS DATE)),
                DATEADD(YEAR, -1, CAST(@day_cursor AS DATE)),
                DATEADD(YEAR, 1, CAST(@day_cursor AS DATE)),
                @special,
                @is_working_day,
                @day_num_since_2020,
                @week_num_since_2020,
                @month_num_since_2020,
                @quarter_num_since_2020,
                @year_num_since_2020,
                FORMAT(CAST(@day_cursor AS DATE), 'yyyy-MM'),
                DATEADD(DAY, 1, CAST(@day_cursor AS DATE)),
                DATEADD(DAY, -1, CAST(@day_cursor AS DATE)),
                FORMAT(CAST(@day_cursor AS DATE), 'MM-dd'),
                CONCAT(FORMAT(DATEADD(DAY, CASE WHEN (@week_day_number = 0) THEN -6 ELSE -@week_day_number + 1 END, CAST(@day_cursor AS DATE)), 'yy-MM-dd - '),
                       FORMAT(DATEADD(DAY, CASE WHEN (@week_day_number = 0) THEN 0 ELSE 7 - @week_day_number END, CAST(@day_cursor AS DATE)), 'yy-MM-dd')));

        SET @day_cursor = DATEADD(DAY, 1, @day_cursor);

        SET @day_of_period = @day_of_period + 1;

        SET @day_num_since_2020 = @day_num_since_2020 + 1;
    END;

    BEGIN TRANSACTION [calendar_dates]

    DROP TABLE IF EXISTS [calendar_dates]

    EXEC [sp_rename] 'calendar_dates_swap', 'calendar_dates'
    COMMIT TRANSACTION [calendar_dates]

GO

/*
 STEP 3.

 RUN IT!

 It takes up to 10 seconds.
 */

EXEC [service_calendar_dates_population];

/*
 Check it..
 */
SELECT *
FROM [calendar_dates];

SELECT COUNT(*) AS [d]
FROM [calendar_dates];
-- result: 6211

SELECT (COUNT(*) / 356) AS [y]
FROM [calendar_dates];
-- 17

SELECT *
FROM [calendar_dates]
WHERE [date] IN (CAST(GETDATE() AS DATE), '2023.12.01', '2024.01.01', '2023-02-25', '2022-12-31', '2023-03-31')
ORDER BY [date];
/*
result:

date,date8,date_ymd,date_dmy,date_mdy,date_ddmm,date_mmdd,date_dmmmy,date_dmmmmy,day_of_week,day_of_week_char,is_weekday,is_weekend,is_last_day_of_week,is_last_day_of_month,is_last_day_of_quarter,is_last_day_of_year,day_name,day_name3,day_of_month,day_of_month2,day_of_quarter,day_of_year,week,week_num,week_finance,week_fullname,month,month2,year_month2,month_name,month_name3,quarter,year,year2,year2c,days_in_year,next_date,prev_date,day_num_since_2020,week_num_since_2020,month_num_since_2020,quarter_num_since_2020,year_num_since_2020,week_begin,week_end,month_begin,month_end,quarter_begin,quarter_end,year_begin,year_end,week_before,week_after,month_before,month_after,quarter_before,quarter_after,year_before,year_after,is_working_day,is_public_holiday,special_date,zodiac,created_at,updated_at,fullname,DESCRIPTION
2022-12-31,20221231,2022-12-31,31.12.2022,12/31/2022,31.12,12-31,31 Dec 22  ,31 December 22,7,Saturday,true,false,false,true,true,true,7,Sat,31,31,92,365,52,53,52,22-12-25 - 22-12-31    ,12,12,2022-12,December,DEC,7,2022,22,22,365,2023-01-01,2022-12-30,1097,157,36,12,3,2022-12-25,2022-12-31,2022-12-01,2022-12-31,2022-10-01,2023-01-31,2022-01-01,2022-12-31,2022-12-24,2023-01-07,2022-11-30,2023-01-31,2022-09-30,2023-03-31,2021-12-31,2023-12-31,true,false,,12 Capricorn,2023-11-18 02:39:44.819917,,31 December 2022 (ww),
2023-02-25,20230225,2023-02-25,25.02.2023,02/25/2023,25.02,02-25,25 Feb 23  ,25 February 23,7,Saturday,true,false,false,false,false,false,7,Sat,25,25,56,56,8,8,8,23-02-19 - 23-02-25    ,2,02,2023-02,February,FEB,1,2023,23,23,365,2023-02-26,2023-02-24,1153,165,38,13,4,2023-02-19,2023-02-25,2023-02-01,2023-02-28,2023-01-01,2023-04-30,2023-01-01,2023-12-31,2023-02-18,2023-03-04,2023-01-25,2023-03-25,2022-11-25,2023-05-25,2022-02-25,2024-02-25,true,false,,02 Pisces,2023-11-18 02:39:44.835547,,25 February 2023 (ww),
2023-03-31,20230331,2023-03-31,31.03.2023,03/31/2023,31.03,03-31,31 Mar 23  ,31 March 23,6,Friday,false,true,false,true,true,false,6,Fri,31,31,90,90,13,13,13,23-03-26 - 23-04-01    ,3,03,2023-03,March,MAR,1,2023,23,23,365,2023-04-01,2023-03-30,1187,170,39,13,4,2023-03-26,2023-04-01,2023-03-01,2023-03-31,2023-01-01,2023-04-30,2023-01-01,2023-12-31,2023-03-24,2023-04-07,2023-02-28,2023-04-30,2022-12-31,2023-06-30,2022-03-31,2024-03-31,false,false,,03 Aries,2023-11-18 02:39:44.835547,,31 March 2023 (ww),
2023-11-18,20231118,2023-11-18,18.11.2023,11/18/2023,18.11,11-18,18 Nov 23  ,18 November 23,7,Saturday,true,false,false,false,false,false,7,Sat,18,18,49,322,46,46,46,23-11-12 - 23-11-18    ,11,11,2023-11,November,NOV,7,2023,23,23,365,2023-11-19,2023-11-17,1419,203,47,16,4,2023-11-12,2023-11-18,2023-11-01,2023-11-30,2023-10-01,2024-01-31,2023-01-01,2023-12-31,2023-11-11,2023-11-25,2023-10-18,2023-12-18,2023-08-18,2024-02-18,2022-11-18,2024-11-18,true,false,,10 Scorpio,2023-11-18 02:39:44.882793,,18 November 2023 (ww),
2023-12-01,20231201,2023-12-01,01.12.2023,12/01/2023,01.12,12-01,1 Dec 23   ,1 December 23,6,Friday,false,true,false,false,false,false,6,Fri,1,01,62,335,48,48,48,23-11-26 - 23-12-02    ,12,12,2023-12,December,DEC,7,2023,23,23,365,2023-12-02,2023-11-30,1432,205,48,16,4,2023-11-26,2023-12-02,2023-12-01,2023-12-31,2023-10-01,2024-01-31,2023-01-01,2023-12-31,2023-11-24,2023-12-08,2023-11-01,2024-01-01,2023-09-01,2024-03-01,2022-12-01,2024-12-01,false,false,,11 Sagittarius,2023-11-18 02:39:44.882793,,01 December 2023 (ww),
2024-01-01,20240101,2024-01-01,01.01.2024,01/01/2024,01.01,01-01,1 Jan 24   ,1 January 24,2,Monday,true,false,false,false,false,false,2,Mon,1,01,1,1,53,1,1,23-12-31 - 24-01-06    ,1,01,2024-01,January,JAN,1,2024,24,24,366,2024-01-02,2023-12-31,1463,210,49,17,5,2023-12-31,2024-01-06,2024-01-01,2024-01-31,2024-01-01,2024-04-30,2024-01-01,2024-12-31,2023-12-25,2024-01-08,2023-12-01,2024-02-01,2023-10-01,2024-04-01,2023-01-01,2025-01-01,false,true,New Year Day,12 Capricorn,2023-11-18 02:39:44.898424,,01 January 2024 (ww),
 */

-- NEXT: calendar_hours presented in separated sql file

/*
 sza(c)
 */
