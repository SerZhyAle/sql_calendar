# sql_calendar

## Physical **Calendar** for *MySQL* and *Microsoft SQL* (hours, dates, weeks, months, quarters, years)

In this package code for:

The tables:
- **calendar_dates**
- **calendar_hours**

The views:
- **calendar_weeks**
- **calendar_months**
- **calendar_quarters**
- **calendar_years**

### You can check the file *examples_results.zip* with resulted csv files.   
---
 ## **calendar_dates** (68 columns)  
 The table points to each date in the period.
 Main fields can be key to dimensions in aggregated tables: *date* (date YYYY-MM-DD) and *date8* (int YYYYMMDD).  
 But all known other versions presented. 

 The idea is to have a real table with already calculated information and use it in joining any daily aggregations. 
 Columns **year_week** or **week_begin**, **year_month2**, **year_quarter**, **year** - pointing its views. 
 
--- 
 ## **calendar_hours** (38 columns)  
 The table points to each hour for every date in the period.
 
 The idea is to have a real table with already calculated information to use in joining any hourly aggregations.  
 Main fields can be key to dimensions in aggregated tables: *date_hour* (char(13) YYYY-MM-DD HH) and *date_hour10* (int YYYYMMDDHH).  
 Column **date** pointing table *calendar_dates*. Column **year_month2** - pointing its view.  
 
 Also can help to join data with hours in different timezones.
 In this example, the table stores information about UTC hours for CET. To aggregate UTC-stored data for CET calendar dates.  
 The fields **date_hour_cet** (char(13) YYYY-MM-DD HH) and **date_hour_cet10** (int YYYYMMDDHH) can be key to dimensions in aggregated tables.   
 Columns date_cet, year_month2_cet - pointing CET timezone.  
 
 Also presented 3 short versions of this table for fast indexing for usage in big data selections.  
 
---
 ## **calendar_weeks** (28 columns)  
 The view to aggregate daily-presented data by its weeks.
 Main field can be key to dimensions in aggregated tables: *year_week* (char(7) YYYY/WW)

---
 ## **calendar_months** (29 columns)  
 The view to aggregate daily-presented data by its calendar months.
 Main field can be key to dimensions in aggregated tables: *year_month2* (char(7) YYYY-MM)

---
 ## **calendar_quarters** (16 columns)  
 The view to aggregate daily/monthly-presented data by its calendar quarters.
 Main field can be key to dimensions in aggregated tables: *year_quarter* (char(6) YYYY-Q)

---
 ## **calendar_years** (16 columns)  
 The view to aggregate daily/monthly-presented data by its calendar year.
 Main field can be key to dimensions in aggregated tables: *year* (YYYY)

---
Please choose your SQL version and pay attention to the details written in comments in the code files (.sql)
--- 
/*
 sza(c)
 */
