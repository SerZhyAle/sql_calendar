# sql_calendar

Physical Calendar for MySQL and MS SQL (hours, dates, weeks, months, quarters, years)

In this package code for:

The tables:
- **calendar_dates**
- **calendar_hours**

The views:
- **calendar_weeks**
- **calendar_months**
- **calendar_quarters**
- **calendar_years**

 **calendar_dates** (68 columns)
 The table pointing each date in period.

 The idea to have the real table with already calculated information and use it in joining for any daily aggregations.
 The fields date and date8 (int 8) can be key to dimensions in aggregated tables.
 Columns week_begin, year_month2, year - pointing its views.
 
 
 **calendar_hours** (38 columns)
 The table pointing each hour for every date in period.
 
 The idea to have the real table with already calculated information to use it in joining for any hourly aggregations.
 The fields date_hour (char 13) and date_hour10 (int 10) can be key to dimensions in aggregated tables.
 Columns date, year_month2 - pointing its views.
 
 Also can help to join data with hours in different timezones.
 In this example table store information about UTC hour for CET. To aggregate UTC-stored data for CET calendar dates. 
 The fields date_hour_cet (char 13) and date_hour_cet10 (int 10) can be key to dimensions in aggregated tables.
 Columns date_cet, year_month2_cet - pointing CET timezone.
 
 Also presented 3 short-versions of this table for fast indexing for big data selections.
 

 **calendar_weeks** (28 columns)
 The view to aggregate daily-presented data by its weeks. 


 **calendar_months** (29 columns)
 The view to aggregate daily-presented data by its calendar months. 

 **calendar_quarters** (16 columns)
 The view to aggregate daily/monthly-presented data by its calendar quartals. 

 **calendar_years** (16 columns)
 The view to aggregate daily/monthly-presented data by its calendar year.


Please choose your SQL version and pay attention to the details written in comments in the code files (.sql)
  
/*
 sza(c)
 */
