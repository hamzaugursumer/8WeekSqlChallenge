# :heavy_check_mark: Case Study #5 - Data Mart
![Case Study 2 Image](https://8weeksqlchallenge.com/images/case-study-designs/5.png)

# Case Study Questions

## :pushpin: 1. Data Cleansing Steps 
````sql
-- Drop the table if it exists;
-- (Eğer Tablo varsa düşür)
DROP TABLE IF EXISTS clean_weekly_sales;

-- Create the table with required columns and transformations;
-- (Gerekli sütunlar ve dönüşümlerle tabloyu oluşturun)
CREATE TABLE clean_weekly_sales AS (
  SELECT
    TO_DATE(week_date, 'DD/MM/YY') AS week_date,
    DATE_PART('week', TO_DATE(week_date, 'DD/MM/YY')) AS week_number,
    DATE_PART('month', TO_DATE(week_date, 'DD/MM/YY')) AS month_number,
    DATE_PART('year', TO_DATE(week_date, 'DD/MM/YY')) AS calendar_year,
    region,
    platform,
    segment,
	customer_type,
    CASE
      WHEN RIGHT(segment, 1) = '1' THEN 'Young Adults'
      WHEN RIGHT(segment, 1) = '2' THEN 'Middle Aged'
      WHEN RIGHT(segment, 1) IN ('3', '4') THEN 'Retirees'
      ELSE 'unknown'
    END AS age_band,
    CASE
      WHEN LEFT(segment, 1) = 'C' THEN 'Couples'
      WHEN LEFT(segment, 1) = 'F' THEN 'Families'
      ELSE 'unknown'
    END AS demographic,
    transactions,
    ROUND((sales::NUMERIC / transactions), 2) AS avg_transaction,
    sales
  FROM public.weekly_sales
)
````

## :pushpin: 2. Data Exploration

1. What day of the week is used for each week_date value?

(Her week_date değeri için haftanın hangi günü kullanılır?)
````sql
select distinct to_char(week_date, 'Day') as day_of_the_week
from clean_weekly_sales
````
| day_of_the_week | 
|-----------------| 
| Monday          | 


2. What range of week numbers are missing from the dataset?

(Veri kümesinde hangi aralıktaki hafta sayıları eksiktir?)
````sql
select distinct extract(week from (week_date)) as week_num
from clean_weekly_sales
order by 1
````

|       | week_num |
|-------|----------|
| 1     | 13       |
| 2     | 14       |
| 3     | 15       |
| 4     | 16       |
| 5     | 17       |
| 6     | 18       |
| 7     | 19       |
| 8     | 20       |
| 9     | 21       |
| 10    | 22       |
| 11    | 23       |
| 12    | 24       |
| 13    | 25       |
| 14    | 26       |
| 15    | 27       |
| 16    | 28       |
| 17    | 29       |
| 18    | 30       |
| 19    | 31       |
| 20    | 32       |
| 21    | 33       |
| 22    | 34       |
| 23    | 35       |
| 24    | 36       |

