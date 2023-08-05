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


3. How many total transactions were there for each year in the dataset?
(Veri setindeki her yıl için toplam kaç işlem vardı?)
````sql
select distinct extract(year from (week_date)) as years,
       to_char(sum(transactions), 'FM999,999,999') as total_transactions
from clean_weekly_sales
group by 1
````
|         |   years | total_transactions |
|---------|---------|--------------------|
|      1  |    2018 |       346,406,460  |
|      2  |    2019 |       365,639,285  |
|      3  |    2020 |       375,813,651  |

4. What is the total sales for each region for each month?
(Her ay için her bölgenin toplam satışları ne kadardır?)
````sql
select extract(month from (week_date)) as months,
	   region,
	   sum(sales) as total_sales
from clean_weekly_sales
group by 1,2
order by 1
````
|   months |region        |total_sales  |
|----------|--------------|-------------|
|        3 | USA          |   225353043 |
|        3 | OCEANIA      |   783282888 |
|        3 | SOUTH AMERICA|    71023109 |
|        3 | ASIA         |   529770793 |
|        3 | AFRICA       |   567767480 |
|        3 | EUROPE       |    35337093 |
|        3 | CANADA       |   144634329 |
|        4 | CANADA       |   484552594 |
|        4 | SOUTH AMERICA|   238451531 |
|        4 | AFRICA       |  1911783504 |
|        4 | USA          |   759786323 |

* The first 11 lines of the 49-line output.