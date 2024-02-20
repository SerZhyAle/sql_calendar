-- SELECT DATE(CONVERT_TZ('2024-02-20 00:00:00', 'UTC', 'Japan'));

DROP TABLE gear.calendar_hours_j;
CREATE TABLE gear.calendar_hours_j
(
    -- original uniq combination
    date_hour              char(13) PRIMARY KEY COMMENT 'UTC Date and hour YYYY-MM-DD hh -char(13)',

    -- data timezone respect
    date_hour_cet          char(13)     NOT NULL COMMENT 'Date and hour YYYY-MM-DD hh in CET -char(13)',
    date_hour_jst          char(13)     NOT NULL COMMENT 'Date and hour YYYY-MM-DD hh in JST -char(13)',
    date_hour10            int          NOT NULL COMMENT 'UTC YYYYMMDDhh -int',
    date_hour_cet10        int          NOT NULL COMMENT 'CET YYYYMMDDhh -int',
    date_hour_jst10        int          NOT NULL COMMENT 'JST YYYYMMDDhh -int',
    date                   date         NOT NULL COMMENT 'UTC date YYYY-MM-DD -date',
    date_cet               date         NOT NULL COMMENT 'CET date YYYY-MM-DD -date',
    date_jst               date         NOT NULL COMMENT 'JST date YYYY-MM-DD -date',
    hour                   tinyint      NOT NULL COMMENT 'Hour UTC -tinyint',
    hour_cet               tinyint      NOT NULL COMMENT 'Hour CET -tinyint',
    hour_jst               tinyint      NOT NULL COMMENT 'Hour JST -tinyint',
    year_month2            char(7)      NOT NULL COMMENT 'Year - Month2 UTC YYYY-MM -char(7)',
    year_month2_cet        char(7)      NOT NULL COMMENT 'Year - Month2 CET YYYY-MM -char(7)',
    year_month2_jst        char(7)      NOT NULL COMMENT 'Year - Month2 JST YYYY-MM -char(7)',
    hour2                  char(2)      NOT NULL COMMENT 'Hour UTC -char(2)',
    hour2_cet              char(2)      NOT NULL COMMENT 'Hour CET -char(2)',
    hour2_jst              char(2)      NOT NULL COMMENT 'Hour JST -char(2)',
    is_last_in_week        boolean      NOT NULL COMMENT 'Hour is last in week UTC -boolean',
    is_last_in_week_cet    boolean      NOT NULL COMMENT 'Hour is last in week CET -boolean',
    is_last_in_week_jst    boolean      NOT NULL COMMENT 'Hour is last in week JST -boolean',
    is_last_in_month       boolean      NOT NULL COMMENT 'Hour is last in month UTC -boolean',
    is_last_in_month_cet   boolean      NOT NULL COMMENT 'Hour is last in month CET -boolean',
    is_last_in_month_jst   boolean      NOT NULL COMMENT 'Hour is last in month JST -boolean',
    is_last_in_quarter     boolean      NOT NULL COMMENT 'Hour is last in quarter UTC -boolean',
    is_last_in_quarter_cet boolean      NOT NULL COMMENT 'Hour is last in quarter CET -boolean',
    is_last_in_quarter_jst boolean      NOT NULL COMMENT 'Hour is last in quarter JST -boolean',
    is_last_in_year        boolean      NOT NULL COMMENT 'Hour is last in year UTC -boolean',
    is_last_in_year_cet    boolean      NOT NULL COMMENT 'Hour is last in year CET -boolean',
    is_last_in_year_jst    boolean      NOT NULL COMMENT 'Hour is last in year JST -boolean',
    is_lunch_hour          boolean      NOT NULL COMMENT 'Hour 12, 13 for weekdays not special UTC -boolean',
    is_lunch_hour_cet      boolean      NOT NULL COMMENT 'Hour 12, 13 for weekdays not special CET -boolean',
    is_lunch_hour_jst      boolean      NOT NULL COMMENT 'Hour 12, 13 for weekdays not special JST -boolean',
    is_night               boolean      NOT NULL COMMENT 'Hour between 22 and 05 UTC -boolean',
    is_night_cet           boolean      NOT NULL COMMENT 'Hour between 22 and 05 CET -boolean',
    is_night_jst           boolean      NOT NULL COMMENT 'Hour between 22 and 05 JST -boolean',
    is_morning             boolean      NOT NULL COMMENT 'Hour between 06 and 09 UTC -boolean',
    is_morning_cet         boolean      NOT NULL COMMENT 'Hour between 06 and 09 CET -boolean',
    is_morning_jst         boolean      NOT NULL COMMENT 'Hour between 06 and 09 JST -boolean',
    is_daylight            boolean      NOT NULL COMMENT 'Hour between 10 and 18 UTC -boolean',
    is_daylight_cet        boolean      NOT NULL COMMENT 'Hour between 10 and 18 CET -boolean',
    is_daylight_jst        boolean      NOT NULL COMMENT 'Hour between 10 and 18 JST -boolean',
    is_evening             boolean      NOT NULL COMMENT 'Hour between 19 and 22 UTC -boolean',
    is_evening_cet         boolean      NOT NULL COMMENT 'Hour between 19 and 22 CET -boolean',
    is_evening_jst         boolean      NOT NULL COMMENT 'Hour between 19 and 22 JST -boolean',
    is_working_hour        boolean      NOT NULL COMMENT 'Hour 8-11 / 14-18 for weekdays not special UTC -boolean',
    is_working_hour_cet    boolean      NOT NULL COMMENT 'Hour 8-11 / 14-18 for weekdays not special CET -boolean',
    is_working_hour_jst    boolean      NOT NULL COMMENT 'Hour 8-11 / 14-18 for weekdays not special JST -boolean',
    is_working_day         boolean      NOT NULL COMMENT 'Day of hour is working not special UTC -boolean',
    is_working_day_cet     boolean      NOT NULL COMMENT 'Day of hour is working not special CET -boolean',
    is_working_day_jst     boolean      NOT NULL COMMENT 'Day of hour is working not special JST -boolean',
    is_public_holiday      boolean      NOT NULL COMMENT 'Is public holiday in UTC -boolean',
    is_public_holiday_cet  boolean      NOT NULL COMMENT 'Is public holiday in CET -boolean',
    is_public_holiday_jst  boolean      NOT NULL COMMENT 'Is public holiday in JST -boolean',
    special_hour           varchar(255) NULL DEFAULT NULL COMMENT 'Special note for hour UTC -varchar(255)',
    special_hour_cet       varchar(255) NULL DEFAULT NULL COMMENT 'Special note for hour CET -varchar(255)',
    special_hour_jst       varchar(255) NULL DEFAULT NULL COMMENT 'Special note for hour JST -varchar(255)',

    -- short
    date_hour_short        char(11)     NOT NULL COMMENT 'Date and hour YY-MM-DD hh in UTC -char(11)',
    date_hour_cet_short    char(11)     NOT NULL COMMENT 'Date and hour YY-MM-DD hh in CET -char(11)',
    date_hour_jst_short    char(11)     NOT NULL COMMENT 'Date and hour YY-MM-DD hh in JST -char(11)',
    date_hour8             int          NOT NULL COMMENT 'UTC YYMMDDhh -int',
    date_hour8_cet         int          NOT NULL COMMENT 'CET YYMMDDhh -int',
    date_hour8_jst         int          NOT NULL COMMENT 'JST YYMMDDhh -int',
    date_short             char(8)      NOT NULL COMMENT 'UTC date YY-MM-DD -char(8)',
    date_cet_short         char(8)      NOT NULL COMMENT 'CET date YY-MM-DD -char(8)',
    date_jst_short         char(8)      NOT NULL COMMENT 'JST date YY-MM-DD -char(8)',
    year_month2_short      char(5)      NOT NULL COMMENT 'Year - Month2 UTC YY-MM -char(5)',
    year_month2_cet_short  char(5)      NOT NULL COMMENT 'Year - Month2 CET YY-MM -char(5)',
    year_month2_jst_short  char(5)      NOT NULL COMMENT 'Year - Month2 JST YY-MM -char(5)',

    -- common fields
    first_second           datetime(6)  NOT NULL COMMENT 'first second -datetime(6)',
    last_second            datetime(6)  NOT NULL COMMENT 'last second -datetime(6)',
    dd_hh                  char(5)      NOT NULL COMMENT 'DD.hh -char(5)',

    fullname               varchar(255) NOT NULL COMMENT 'DD MMMM YYYY (DayName) UTC -varchar(255)',
    description            varchar(1000)     DEFAULT NULL COMMENT 'Commentary for hour of date -varchar(1000)'
) COMMENT = 'Hours of calendar dates';

TRUNCATE TABLE gear.calendar_hours_j;
INSERT INTO gear.calendar_hours_j(date_hour, date_hour_cet, date_hour_jst, date_hour10, date_hour_cet10,
                                  date_hour_jst10, date, date_cet, date_jst, hour, hour_cet, hour_jst,
                                  year_month2, year_month2_cet, year_month2_jst, hour2, hour2_cet, hour2_jst,
                                  is_last_in_week, is_last_in_week_cet, is_last_in_week_jst,
                                  is_last_in_month, is_last_in_month_cet, is_last_in_month_jst, is_last_in_quarter,
                                  is_last_in_quarter_cet, is_last_in_quarter_jst, is_last_in_year,
                                  is_last_in_year_cet, is_last_in_year_jst, is_lunch_hour, is_lunch_hour_cet,
                                  is_lunch_hour_jst, is_night, is_night_cet, is_night_jst, is_morning,
                                  is_morning_cet, is_morning_jst, is_daylight, is_daylight_cet, is_daylight_jst,
                                  is_evening, is_evening_cet, is_evening_jst, is_working_hour,
                                  is_working_hour_cet, is_working_hour_jst, is_working_day, is_working_day_cet,
                                  is_working_day_jst, is_public_holiday, is_public_holiday_cet,
                                  is_public_holiday_jst, special_hour, special_hour_cet, special_hour_jst,
                                  date_hour_short, date_hour_cet_short, date_hour_jst_short, date_hour8,
                                  date_hour8_cet, date_hour8_jst, date_short, date_cet_short, date_jst_short,
                                  year_month2_short, year_month2_cet_short, year_month2_jst_short,
                                  first_second, last_second, dd_hh, fullname, description)

SELECT DATE_HOUR,
       DATE_HOUR_CET,
       LEFT((CONVERT_TZ(CONCAT(DATE_HOUR, ':00:00'), 'UTC', 'Japan')), 13)              AS date_hour_jst,
       DATE_HOUR10,
       DATE_FORMAT(CONVERT_TZ(CONCAT(DATE_HOUR, ':00:00'), 'UTC', 'CET'), '%y%m%d%h')   AS date_hour_cet10,
       DATE_FORMAT(CONVERT_TZ(CONCAT(DATE_HOUR, ':00:00'), 'UTC', 'Japan'), '%y%m%d%h') AS date_hour_jstt10,
       h.DATE,
       DATE_CET,
       DATE(CONVERT_TZ(CONCAT(DATE_HOUR, ':00:00'), 'UTC', 'Japan')),
       HOUR,
       HOUR_CET,
       DATE_FORMAT(CONVERT_TZ(CONCAT(DATE_HOUR, ':00:00'), 'UTC', 'Japan'), '%h')       AS HOUR_JST,
       h.YEAR_MONTH2,
       YEAR_MONTH2_CET,
       DATE_FORMAT(CONVERT_TZ(CONCAT(DATE_HOUR, ':00:00'), 'UTC', 'Japan'), '%Y-%m'),
       HOUR2,
       HOUR2_CET,
       DATE_FORMAT(CONVERT_TZ(CONCAT(DATE_HOUR, ':00:00'), 'UTC', 'Japan'), '%h'),

       IF(cd.day_of_week = 6 AND HOUR = 23, TRUE, FALSE),
       IF(CDcet.day_of_week = 6 AND HOUR_CET = 23, TRUE, FALSE),
       IF(CDjst.day_of_week = 6 AND DATE_FORMAT(CONVERT_TZ(CONCAT(DATE_HOUR, ':00:00'), 'UTC', 'Japan'), '%h') = 23, TRUE, FALSE),
       IF(cd.IS_LAST_DAY_OF_MONTH = TRUE AND HOUR = 23, TRUE, FALSE),
       IF(CDcet.IS_LAST_DAY_OF_MONTH = TRUE AND HOUR_CET = 23, TRUE, FALSE),
       IF(CDjst.IS_LAST_DAY_OF_MONTH = TRUE AND DATE_FORMAT(CONVERT_TZ(CONCAT(DATE_HOUR, ':00:00'), 'UTC', 'Japan'), '%h') = 23, TRUE, FALSE),
       IF(cd.IS_LAST_DAY_OF_QUARTER = TRUE AND HOUR = 23, TRUE, FALSE),
       IF(CDcet.IS_LAST_DAY_OF_QUARTER = TRUE AND HOUR_CET = 23, TRUE, FALSE),
       IF(CDjst.IS_LAST_DAY_OF_QUARTER = TRUE AND DATE_FORMAT(CONVERT_TZ(CONCAT(DATE_HOUR, ':00:00'), 'UTC', 'Japan'), '%h') = 23, TRUE, FALSE),
       IF(cd.IS_LAST_DAY_OF_YEAR = TRUE AND HOUR = 23, TRUE, FALSE),
       IF(CDcet.IS_LAST_DAY_OF_YEAR = TRUE AND HOUR_CET = 23, TRUE, FALSE),
       IF(CDjst.IS_LAST_DAY_OF_YEAR = TRUE AND DATE_FORMAT(CONVERT_TZ(CONCAT(DATE_HOUR, ':00:00'), 'UTC', 'Japan'), '%h') = 23, TRUE, FALSE),
       IF(HOUR IN (12, 13), TRUE, FALSE),
       IF(HOUR_CET IN (12, 13), TRUE, FALSE),
       IF(DATE_FORMAT(CONVERT_TZ(CONCAT(DATE_HOUR, ':00:00'), 'UTC', 'Japan'), '%h') IN (12, 13), TRUE, FALSE),
       IF(HOUR > 21 OR hour < 6, TRUE, FALSE),
       IF(HOUR_CET > 21 OR hour_cet < 6, TRUE, FALSE),
       IF(DATE_FORMAT(CONVERT_TZ(CONCAT(DATE_HOUR, ':00:00'), 'UTC', 'Japan'), '%h') > 21 OR
          DATE_FORMAT(CONVERT_TZ(CONCAT(DATE_HOUR, ':00:00'), 'UTC', 'Japan'), '%h') < 6, TRUE, FALSE),
       IF(HOUR >= 6 AND hour < 10, TRUE, FALSE),
       IF(HOUR_CET >= 6 AND hour_cet < 10, TRUE, FALSE),
       IF(DATE_FORMAT(CONVERT_TZ(CONCAT(DATE_HOUR, ':00:00'), 'UTC', 'Japan'), '%h') >= 6 AND
          DATE_FORMAT(CONVERT_TZ(CONCAT(DATE_HOUR, ':00:00'), 'UTC', 'Japan'), '%h') < 10, TRUE, FALSE),
       IF(HOUR >= 10 AND hour < 18, TRUE, FALSE),
       IF(HOUR_CET >= 10 AND hour_cet < 18, TRUE, FALSE),
       IF(DATE_FORMAT(CONVERT_TZ(CONCAT(DATE_HOUR, ':00:00'), 'UTC', 'Japan'), '%h') >= 10 AND
          DATE_FORMAT(CONVERT_TZ(CONCAT(DATE_HOUR, ':00:00'), 'UTC', 'Japan'), '%h') < 18, TRUE, FALSE),
       IF(HOUR >= 18 AND hour < 22, TRUE, FALSE),
       IF(HOUR_CET >= 18 AND hour_cet < 22, TRUE, FALSE),
       IF(DATE_FORMAT(CONVERT_TZ(CONCAT(DATE_HOUR, ':00:00'), 'UTC', 'Japan'), '%h') >= 18 AND
          DATE_FORMAT(CONVERT_TZ(CONCAT(DATE_HOUR, ':00:00'), 'UTC', 'Japan'), '%h') < 22, TRUE, FALSE),
       IF(cd.IS_WORKING_DAY = TRUE AND HOUR >= 9 AND hour <= 18, TRUE, FALSE),
       IF(cdcet.IS_WORKING_DAY = TRUE AND HOUR_CET >= 9 AND hour_cet <= 18, TRUE, FALSE),
       IF(cdjst.IS_WORKING_DAY = TRUE AND DATE_FORMAT(CONVERT_TZ(CONCAT(DATE_HOUR, ':00:00'), 'UTC', 'Japan'), '%h') >= 9 AND
          DATE_FORMAT(CONVERT_TZ(CONCAT(DATE_HOUR, ':00:00'), 'UTC', 'Japan'), '%h') <= 18, TRUE, FALSE),
       cd.IS_WORKING_DAY,
       cdcet.IS_WORKING_DAY,
       cdjst.IS_WORKING_DAY,
       cd.IS_PUBLIC_HOLIDAY,
       cdcet.IS_PUBLIC_HOLIDAY,
       cdjst.IS_PUBLIC_HOLIDAY,
       SPECIAL_HOUR,
       SPECIAL_HOUR,
       SPECIAL_HOUR,
       DATE_HOUR_SHORT,
       DATE_HOUR_CET_SHORT,
       RIGHT(LEFT((CONVERT_TZ(CONCAT(DATE_HOUR, ':00:00'), 'UTC', 'Japan')), 13), 11),
       DATE_HOUR8,
       DATE_FORMAT(CONVERT_TZ(CONCAT(DATE_HOUR, ':00:00'), 'UTC', 'CET'), '%y%m%d%h'),
       DATE_FORMAT(CONVERT_TZ(CONCAT(DATE_HOUR, ':00:00'), 'UTC', 'Japan'), '%y%m%d%h'),
       DATE_SHORT,
       DATE_CET_SHORT,
       DATE_FORMAT(CONVERT_TZ(CONCAT(DATE_HOUR, ':00:00'), 'UTC', 'Japan'), '%y-%m-%d'),
       YEAR_MONTH2_SHORT,
       YEAR_MONTH2_CET_SHORT,
       DATE_FORMAT(CONVERT_TZ(CONCAT(DATE_HOUR, ':00:00'), 'UTC', 'Japan'), '%y-%m'),

       FIRST_SECOND,
       LAST_SECOND,
       DD_HH,
       h.FULLNAME,
       h.DESCRIPTION
-- select *
FROM gear.CALENDAR_HOURS H
    JOIN GEAR.CALENDAR_DATES CD
        ON cd.DATE = H.DATE
    JOIN GEAR.CALENDAR_DATES CDcet
        ON cdcet.DATE = H.DATE_CET
    JOIN GEAR.CALENDAR_DATES CDjst
        ON cdjst.DATE = DATE(CONVERT_TZ(CONCAT(H.DATE_HOUR, ':00:00'), 'UTC', 'Japan'));

--  149,055 rows

SELECT *
FROM gear.CALENDAR_HOURS_j H;

SELECT *
FROM GEAR.CALENDAR_DATES CD;
