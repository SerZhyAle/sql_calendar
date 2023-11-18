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
   FROM sys.time_zone_info
   WHERE name in ('UTC', 'Central European Standard Time');

 If you DON'T have two lines, but NULL result, then something wrong with your server.

 If you have two timezones, then check next two:

select (cast('2023-01-01' as datetime) at time zone 'UTC') at time zone 'Central European Standard Time' as time_zone_cet;
-- must be: 2023-01-01 01:00:00.000 +01:00

select (cast('2023-06-01' as datetime) at time zone 'UTC') at time zone 'Central European Standard Time' as time_zone_cet;
-- must be: 2023-06-01 02:00:00.000 +02:00

 In this case we have summer time shift, so we can create the calendar_hours..

   Code here for Microsoft SQL 2016 and higher
 --
 STEP 1.
 Create the _swap table to be able switch the table in one transaction:

   run one by one..
 */
-- ALTER TABLE [calendar_hours_swap]    DROP CONSTRAINT IF EXISTS [DF_calendar_hours_created];
-- ALTER TABLE [calendar_hours]    DROP CONSTRAINT IF EXISTS [DF_calendar_hours_created];

DROP TABLE IF EXISTS [calendar_hours_swap];

CREATE TABLE [calendar_hours_swap] (
    -- original uniq combination
    [date_hour]             CHAR(13) PRIMARY KEY,                             --  'Date and hour YYYY-MM-DD hh -char(13)'
    [date_hour10]           INT CHECK ([date_hour10] > 0)  NOT NULL,          --  'YYYYMMDDhh -int'
    [date]                  DATE                           NOT NULL,          --  'UTC date YYYY-MM-DD -date'
    [hour]                  TINYINT CHECK ([hour] >= 0)     NOT NULL,          --  'Hour UTC -tinyint'
    [hour_cet]              TINYINT CHECK ([hour_cet] >= 0) NOT NULL,          --  'Hour CET -tinyint'

    -- data
    [date_hour_cet]         CHAR(13)                       NOT NULL,          --  'Date and hour YYYY-MM-DD hh in CET -char(13)'
    [date_cet]              DATE                           NOT NULL,          --  'CET date YYYY-MM-DD -date'
    [year_month2]           CHAR(7)                        NOT NULL,          --  'Year - Month2 UTC YYYY-MM -char(7)'
    [year_month2_cet]       CHAR(7)                        NOT NULL,          --  'Year - Month2 CET YYYY-MM -char(7)'
    [first_second]          DATETIME2(6)                   NOT NULL,          --  'first second -datetime(6)'
    [last_second]           DATETIME2(6)                   NOT NULL,          --  'last second -datetime(6)'
    [hour2]                 CHAR(2)                        NOT NULL,          --  'Hour UTC -char(2)'
    [hour2_cet]             CHAR(2)                        NOT NULL,          --  'Hour CET -char(2)'
    [dd_hh]                 CHAR(5)                        NOT NULL,          --  'DD.hh -char(5)'
    [is_last_in_week]       BIT                            NOT NULL,          --  'Hour is last in week -bit'
    [is_last_in_month]      BIT                            NOT NULL,          --  'Hour is last in month -bit'
    [is_last_in_quarter]    BIT                            NOT NULL,          --  'Hour is last in quarter -bit'
    [is_last_in_year]       BIT                            NOT NULL,          --  'Hour is last in year -bit'

    [is_lunch_hour]         BIT                            NOT NULL,          --  'Hour 12 13 for weekdays not special -bit'
    [is_night]              BIT                            NOT NULL,          --  'Hour between 22 and 05 -bit'
    [is_morning]            BIT                            NOT NULL,          --  'Hour between 06 and 09 -bit'
    [is_daylight]           BIT                            NOT NULL,          --  'Hour between 10 and 18 -bit'
    [is_evening]            BIT                            NOT NULL,          --  'Hour between 19 and 22 -bit'

    [is_working_hour]       BIT                            NOT NULL,          --  'Hour 8-11 / 14-18 for weekdays not special -bit'
    [is_working_day]        BIT                            NOT NULL,          --  'Day of hour is working not special -bit'
    [is_public_holiday]     BIT                            NOT NULL,          --  'Is public holiday in -bit'
    [special_hour]          VARCHAR(255)                   NULL DEFAULT NULL, --  'Special note for hour -varchar(255)'

    -- short
    [date_hour_short]       CHAR(11)                       NOT NULL,          --  'Date and hour YY-MM-DD hh -char(11)'
    [date_hour8]            INT CHECK ([date_hour8] > 0)   NOT NULL,          --  'YYMMDDhh -int'
    [date_short]            CHAR(8)                        NOT NULL,          --  'UTC date YY-MM-DD -char(8)'
    [date_hour_cet_short]   CHAR(11)                       NOT NULL,          --  'Date and hour YY-MM-DD hh in CET -char(11)'
    [date_cet_short]        CHAR(8)                        NOT NULL,          --  'CET date YY-MM-DD -char(8)'
    [year_month2_short]     CHAR(5)                        NOT NULL,          --  'Year - Month2 UTC YY-MM -char(5)'
    [year_month2_cet_short] CHAR(5)                        NOT NULL,          --  'Year - Month2 CET YY-MM -char(5)'

    -- row activity fields
    [created_at]            DATETIME2(6)                   NOT NULL CONSTRAINT [DF_calendar_hours_created] DEFAULT (SYSDATETIME()),
    [updated_at]            DATETIME2(6)                   NULL DEFAULT NULL, --  'Updated -datetime(6)'

    -- common fields
    [fullname]              VARCHAR(255)                   NOT NULL,          --  'DD MMMM YYYY (DayName) -varchar(255)'
    [description]           VARCHAR(1000)                       DEFAULT NULL  --  ', -- ary for hour of date -varchar(1000)'

) -- 'Hours of calendar dates';

CREATE UNIQUE INDEX [uniq_index_calendar_hours_date_hour] ON [calendar_hours_swap] ([date_hour])

CREATE INDEX [index__calendar_hours_date_hour_cet] ON [calendar_hours_swap] ([date_hour_cet])

CREATE INDEX [index_calendar_hours_date] ON [calendar_hours_swap] ([date])

CREATE INDEX [index_calendar_hours_year_month2] ON [calendar_hours_swap] ([year_month2])

CREATE INDEX [index_calendar_hours_year_month2_cet] ON [calendar_hours_swap] ([year_month2_cet])

CREATE INDEX [i_hours_year_month2_cet] ON [calendar_hours_swap] ([year_month2_cet]);

CREATE INDEX [i_hours_10] ON [calendar_hours_swap] ([date_hour10]);

/*
 STEP 2.

 Create procedure to populate the calendar_hours for calendar_dates:

  */

CREATE or alter PROCEDURE [service_calendar_hours_population] AS

    DECLARE @special VARCHAR(50), @day_cursor DATE, @hour_cursor TINYINT, @hour2 CHAR(2), @dd DATE, @last_day_of_week BIT, @last_day_of_month BIT, @last_day_of_period BIT, @last_day_of_year BIT, @is_public_holiday BIT, @is_working_day BIT, @calculated_date_hour CHAR(13), @first_sec DATETIME2(6), @cet DATETIME2(6), @date_cet DATE, @cet_char varchar(10);

    SET @special = NULL;
    SET @day_cursor = (SELECT MIN([date]) AS [md] FROM [calendar_dates]);
    SET @hour_cursor = 0;
    SET @hour2 = 'XX';
    SET @dd = (SELECT MAX([date]) AS [md] FROM [calendar_dates])

    WHILE @day_cursor <= @dd BEGIN

        SET @last_day_of_week = (SELECT [is_last_day_of_week] FROM [calendar_dates] WHERE [date] = @day_cursor)
        SET @last_day_of_month = (SELECT [is_last_day_of_month] FROM [calendar_dates] WHERE [date] = @day_cursor)
        SET @last_day_of_period = (SELECT [is_last_day_of_quarter] FROM [calendar_dates] WHERE [date] = @day_cursor)
        SET @last_day_of_year = (SELECT [is_last_day_of_year] FROM [calendar_dates] WHERE [date] = @day_cursor)
        SET @is_public_holiday = (SELECT [is_public_holiday] FROM [calendar_dates] WHERE [date] = @day_cursor)

        SET @is_working_day =
                (SELECT CASE WHEN ([is_weekend] = 0 AND [is_public_holiday] = 0) THEN 1 ELSE 0 END AS [is_working_day] FROM [calendar_dates] WHERE [date] = @day_cursor)

        SET @hour_cursor = 0;

        WHILE @hour_cursor <= 23 BEGIN
            IF @hour_cursor < 10 SET @hour2 = CONCAT('0', @hour_cursor); ELSE SET @hour2 = @hour_cursor

            SET @calculated_date_hour = CONCAT(@day_cursor, ' ', @hour2);
            SET @first_sec = CONCAT(@calculated_date_hour, ':00:00');
            -- UTC to CET
            SET @cet = CAST(LEFT((CAST(@first_sec AS DATETIME) AT TIME ZONE 'UTC') AT TIME ZONE 'Central European Standard Time', 19) AS DATETIME2);
            SET @cet_char = cast(@cet as varchar(10));
            SET @date_cet = CAST(LEFT(@cet, 10) AS DATE);

            INSERT INTO [calendar_hours_swap]([date],
                                              [date_cet],
                                              [date_hour_cet],
                                              [year_month2],
                                              [year_month2_cet],
                                              [first_second],
                                              [last_second],
                                              [date_hour],
                                              [date_hour10],
                                              [hour],
                                              [hour_cet],
                                              [hour2],
                                              [hour2_cet],
                                              [special_hour],
                                              [fullname],
                                              [dd_hh],
                                              [is_last_in_week],
                                              [is_last_in_month],
                                              [is_last_in_quarter],
                                              [is_last_in_year],
                                              [is_night],
                                              [is_lunch_hour],
                                              [is_working_hour],
                                              [is_working_day],
                                              [is_public_holiday],
                                              [is_morning],
                                              [is_daylight],
                                              [is_evening],
                                              [date_hour_short],
                                              [date_hour8],
                                              [date_short],
                                              [date_hour_cet_short],
                                              [date_cet_short],
                                              [year_month2_short],
                                              [year_month2_cet_short])
            VALUES (@day_cursor,
                    @date_cet,
                    LEFT(@cet, 13),
                    LEFT(@day_cursor, 7),
                    LEFT(@cet, 7),
                    @first_sec,
                    CONCAT(@calculated_date_hour, ':59:59.999999'),
                    @calculated_date_hour,
                    CONCAT(FORMAT(@day_cursor, 'yyyyMMdd'), @hour2),
                    @hour_cursor,
                    datepart(hour, @cet),
                    @hour2,
                    SUBSTRING(@cet_char, 12, 2),
                    @special, CONCAT(@calculated_date_hour, ' UTC'),
                    CONCAT(FORMAT(@day_cursor, 'dd'), @hour2),
                    CASE WHEN @last_day_of_week = 1 AND @hour_cursor = 23 THEN 1 ELSE 0 END,
                    CASE WHEN @last_day_of_month = 1 AND @hour_cursor = 23 THEN 1 ELSE 0 END,
                    CASE WHEN @last_day_of_period = 1 AND @hour_cursor = 23 THEN 1 ELSE 0 END,
                    CASE WHEN @last_day_of_year = 1 AND @hour_cursor = 23 THEN 1 ELSE 0 END,
                    CASE WHEN @hour_cursor > 22 OR @hour_cursor < 6 THEN 1 ELSE 0 END,
                    CASE WHEN @hour_cursor = 12 OR @hour_cursor = 13 THEN 1 ELSE 0 END,
                    CASE WHEN ((@hour_cursor > 7 AND @hour_cursor < 12) OR (@hour_cursor > 13 AND @hour_cursor < 19)) AND @is_working_day = 1 THEN 1 ELSE 0 END,
                    @is_working_day,
                    @is_public_holiday,
                    CASE WHEN @hour_cursor BETWEEN 6 AND 9 THEN 1 ELSE 0 END,
                    CASE WHEN @hour_cursor BETWEEN 10 AND 18 THEN 1 ELSE 0 END,
                    CASE WHEN @hour_cursor BETWEEN 19 AND 22 THEN 1 ELSE 0 END,
                    RIGHT(@calculated_date_hour, 11),
                    RIGHT(CONCAT(FORMAT(@day_cursor, 'yyMMdd'), @hour2), 8),
                    RIGHT(@day_cursor, 8),
                    SUBSTRING(@cet_char, 3, 11),
                    RIGHT(@date_cet, 8),
                    SUBSTRING(cast(@day_cursor as varchar(10)), 3, 5),
                    SUBSTRING(@cet_char, 3, 5));

            SET @hour_cursor = @hour_cursor + 1;
        END;

        SET @day_cursor = DATEADD(DAY, 1, @day_cursor);
    END;

    BEGIN TRANSACTION [calendar_hours]

        DROP TABLE IF EXISTS [calendar_hours]
        EXEC [sp_rename] 'calendar_hours_swap', 'calendar_hours';
    COMMIT TRANSACTION [calendar_hours];

GO;

/*
  STEP 3.
  RUN IT!

  It can take  up to 30 seconds
 */
-- _________________________________________________________________ --

exec service_calendar_hours_population;

/*
   check..

   SELECT * FROM calendar_hours;
   SELECT COUNT(*) as h FROM calendar_hours;
   -- 149064

   SELECT COUNT(*)/24 as d FROM calendar_hours;
   -- 6211

   SELECT (COUNT(*)/24)/356 as y FROM calendar_hours;
   -- 17

#check..
SELECT *
FROM calendar_hours
WHERE date IN (cast(getdate() as date), '2023.12.01', '2022-12-31')
ORDER BY date_hour;

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


DROP TABLE IF EXISTS [calendar_hours_short];

CREATE TABLE [calendar_hours_short] (
    [date_hour]   CHAR(13) PRIMARY KEY, -- 'Date and hour YYYY-MM-DD hh -char(13)',
    [date]        DATE    NOT NULL, --  'UTC date YYYY-MM-DD -date',
    [year_month2] CHAR(7) NOT NULL, -- 'Year - Month2 YYYY-MM -char(7)',
    [hour]        TINYINT CHECK ([hour] >= 0) NOT NULL -- 'Hour -tinyint'
) -- 'Hours of calendar dates Short version'

INSERT INTO [calendar_hours_short]([date_hour], [date], [year_month2], [hour])
SELECT [date_hour], [date], [year_month2], [hour]
FROM [calendar_hours] AS [hours];

CREATE INDEX [index_calendar_hours_short_date] ON [calendar_hours_short] ([date]);

CREATE INDEX [index_calendar_hours_short_hour] ON [calendar_hours_short] ([hour]);

CREATE INDEX [index_calendar_hours_short_year_month2] ON [calendar_hours_short] ([year_month2]);

SELECT *
FROM [calendar_hours_short];


-- _________________________________________________________________ --
/* short version to gain CET hour/date/year from data's UTC original hour

 for example:

SELECT h.date_hour_cet,
   src.*
FROM data_table AS src
    JOIN calendar_hours_cet_short AS h
        ON h.date_hour = src.date_hour;
  */

DROP TABLE IF EXISTS [calendar_hours_cet_short];

CREATE TABLE [calendar_hours_cet_short] (
    [date_hour]       CHAR(13) PRIMARY KEY, -- 'Date and hour UTC YYYY-MM-DD hh -char(13)',
    [date_hour_cet]   CHAR(13) NOT NULL, -- 'Date and hour CET YYYY-MM-DD hh -char(13)',
    [year_month2_cet] CHAR(7)  NOT NULL, -- 'Year - Month2 CET YYYY-MM -char(7)',
    [date_cet]        DATE     NOT NULL, -- 'CET date YYYY-MM-DD -date',
    [hour_cet]        TINYINT check([hour_cet] >= 0) NOT NULL -- 'Hour -tinyint'
) -- 'Hours of calendar dates Short version'

INSERT INTO [calendar_hours_cet_short]([date_hour], [date_cet], [hour_cet], [date_hour_cet], [year_month2_cet])
SELECT [date_hour], [date_cet], [hour_cet], [date_hour_cet], [year_month2_cet]
FROM [calendar_hours] AS [hours];

CREATE INDEX [index_calendar_hours_short_date] ON [calendar_hours_cet_short] ([date_cet]);

CREATE INDEX [index_calendar_hours_short_date_hour_cet] ON [calendar_hours_cet_short] ([date_hour_cet]);

CREATE INDEX [index_calendar_hours_short_hour_cet] ON [calendar_hours_cet_short] ([hour_cet]);

CREATE INDEX [index_calendar_hours_short_date_year_month2_cet] ON [calendar_hours_cet_short] ([year_month2_cet]);

SELECT *
FROM [calendar_hours_cet_short];

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

DROP TABLE IF EXISTS [calendar_hours10_short];

CREATE TABLE [calendar_hours10_short] (
    [date_hour10]         INT check ([date_hour10] > 0) NOT NULL PRIMARY KEY, -- 'YYYYMMDDhh -int'
    [date_hour]           CHAR(13) NOT NULL, -- 'Date and hour UTC YYYY-MM-DD hh -char(13)'
    [date_hour_cet]       CHAR(13) NOT NULL, -- 'Date and hour CET YYYY-MM-DD hh -char(13)'
    [year_month2]         CHAR(7)  NOT NULL, -- 'Year - Month2 YYYY-MM -char(7)'
    [hour]                TINYINT check ([hour] >= 0) NOT NULL, -- 'Hour UTC -tinyint'
    [hour_cet]            TINYINT check ([hour_cet] >= 0) NOT NULL, -- 'Hour CET -tinyint'
    [date]                DATE     NOT NULL, -- 'UTC date YYYY-MM-DD -date'
    [date_hour_cet_short] CHAR(11) NOT NULL, -- 'Date and hour YY-MM-DD hh in CET -char(11)'
    [date_cet]            DATE     NOT NULL -- 'CET date YYYY-MM-DD -date'
) -- 'Hours of calendar dates int10 Short version'

INSERT INTO [calendar_hours10_short]([date_hour10], [date_hour], [date_hour_cet],
                                     [year_month2], [date], [date_hour_cet_short],
                                     [date_cet], [hour], [hour_cet])
SELECT [date_hour10],
       [date_hour],
       [date_hour_cet],
       [year_month2],
       [date],
       [date_hour_cet_short],
       [date_cet],
       [hour],
       [hour_cet]
FROM [calendar_hours] AS [hours];

CREATE INDEX [index_calendar_hours_short_date] ON [calendar_hours10_short] ([date_hour10]);

CREATE INDEX [index_calendar_hours_short_date_hour_cet] ON [calendar_hours10_short] ([date_hour_cet]);

CREATE INDEX [index_calendar_hours_short_hour_cet] ON [calendar_hours10_short] ([date_hour]);

SELECT *
FROM [calendar_hours10_short];

-- NEXT: calendar_weeks, calendar_months, calendar_years presented in separated sql files

/*
 sza(c)
 */
