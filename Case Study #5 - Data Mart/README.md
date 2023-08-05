# :heavy_check_mark: Case Study #5 - Data Mart
![Case Study 2 Image](https://8weeksqlchallenge.com/images/case-study-designs/5.png)

# Case Study Questions

## :pushpin: 1. Data Cleaning Steps 
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

5. What is the total count of transactions for each platform?

(Her bir platform için toplam işlem sayısı nedir?)
````sql
select platform,
	   sum(transactions) as total_transactions
from clean_weekly_sales
group by 1
````
|        |platform  |total_transactions|
|--------|----------|------------------|
|      1 | Shopify  |           5925169|
|      2 | Retail   |        1081934227|


6. What is the percentage of sales for Retail vs Shopify for each month?

(Her ay için Perakende ve Shopify satışlarının yüzdesi nedir?)
````sql
with retail_sales as (
  select
    extract(month from week_date) as month,
    sum(sales) as total_sales
  from clean_weekly_sales
  where platform = 'Retail'
  group by month
),
shopify_sales as (
  select
    extract(month from week_date) as month,
    sum(sales) as total_sales
  from clean_weekly_sales
  where platform = 'Shopify'
  group by month
),
total_sales as (
  select
    extract(month from week_date) as month,
    sum(sales) as total_sales
  from clean_weekly_sales
  group by month
)
select
  total_sales.month,
  round((retail_sales.total_sales*1.0/ total_sales.total_sales*1.0) * 100, 2) as retail_percentage,
  round((shopify_sales.total_sales*1.0 / total_sales.total_sales*1.0) * 100, 2) as shopify_percentage
from total_sales
join retail_sales on total_sales.month = retail_sales.month
join shopify_sales on total_sales.month = shopify_sales.month
order by total_sales.month
````

|        |  month | retail_percentage | shopify_percentage |
|--------|--------|------------------ |--------------------|
|      1 |      3 |            97.54  |              2.46  |
|      2 |      4 |            97.59  |              2.41  |
|      3 |      5 |            97.30  |              2.70  |
|      4 |      6 |            97.27  |              2.73  |
|      5 |      7 |            97.29  |              2.71  |
|      6 |      8 |            97.08  |              2.92  |
|      7 |      9 |            97.38  |              2.62  |

7. What is the percentage of sales by demographic for each year in the dataset?

(Veri setindeki her bir yıl için demografiye göre satışların yüzdesi nedir?)
````sql
with 
couples_demographic as (
  select
    extract(year from week_date) as year,
    sum(sales) as total_sales
  from clean_weekly_sales
  where demographic = 'Couples'
  group by year
),
families_demographic as (
  select
    extract(year from week_date) as year,
    sum(sales) as total_sales
  from clean_weekly_sales
  where demographic = 'Families'
  group by year
),
unknown_demographic as (
  select
    extract(year from week_date) as year,
    sum(sales) as total_sales
  from clean_weekly_sales
  where demographic = 'unknown'
  group by year	
),
total_sales as (
  select
    extract(year from week_date) as year,
    sum(sales) as total_sales
  from clean_weekly_sales
  group by year
)
select
  total_sales.year,
  round((couples_demographic.total_sales*1.0/ total_sales.total_sales*1.0) * 100, 2) as couples_demographic_percentage,
  round((families_demographic.total_sales*1.0 / total_sales.total_sales*1.0) * 100, 2) as families_demographic_percentage,
  round((unknown_demographic.total_sales*1.0 / total_sales.total_sales*1.0) * 100, 2) as unknown_demographic_percentage
from total_sales
join couples_demographic on total_sales.year = couples_demographic.year
join families_demographic on total_sales.year = families_demographic.year
join unknown_demographic on total_sales.year = unknown_demographic.year
order by total_sales.year
````
|        |  year  | couples_demographic_percentage | families_demographic_percentage | unknown_demographic_percentage |
|--------|--------|--------------------------------|---------------------------------|--------------------------------|
|      1 |   2018 |                        26.38   |                          31.99  |                        41.63   |
|      2 |   2019 |                        27.28   |                          32.47  |                        40.25   |
|      3 |   2020 |                        28.72   |                          32.73  |                        38.55   |


8. Which age_band and demographic values contribute the most to Retail sales?

(Perakende satışlara en çok hangi yaş_bandı ve demografik değerler katkıda bulunuyor?)
````sql
select 
	   demographic,
	   age_band,
	   sum(sales) as sum_sales,
	   round(sum(sales)*1.0 / (select sum(sales) from clean_weekly_sales where platform = 'Retail')*1.0,2)*100 as retail_percentage
from clean_weekly_sales
where platform = 'Retail'
group by 1,2
order by 3 desc
````

|        |  demographic  |    age_band    |  sum_sales   | retail_percentage |
|--------|---------------|--------------  |--------------|-------------------|
|      1 |  unknown      |   unknown      |  16067285533 |             41.00 |
|      2 | Families      |   Retirees     |   6634686916 |             17.00 |
|      3 |  Couples      |   Retirees     |   6370580014 |             16.00 |
|      4 | Families      | Middle Aged    |   4354091554 |             11.00 |
|      5 |  Couples      | Young Adults   |   2602922797 |              7.00 |
|      6 |  Couples      | Middle Aged    |   1854160330 |              5.00 |
|      7 | Families      | Young Adults   |   1770889293 |              4.00 |


9. Can we use the avg_transaction column to find the average transaction size for each year for Retail vs Shopify? If not - how would you calculate it instead?

(Retail ve Shopify için her yılın ortalama işlem boyutunu bulmak üzere avg_transaction sütununu kullanabilir miyiz? Değilse bunun yerine nasıl hesaplarsınız?)

We can't use it because if we try to average again based on the platform, it will be like averaging the average and we will mislead our data.
(Kullanamayız çünkü, eğer platform bazlı tekrar ortalama almaya çalırsak ortalamanın ortalamasını almıs gibi oluruz ve verimizi yanıltırız.)
````sql
select platform,
	   extract(year from (week_date)) as year,
	   round(sum(sales)*1.0 / sum(transactions)*1.0,2) as avg_transaction,
	   round(avg(avg_transaction),2) as incorrect_avg
from clean_weekly_sales
group by 1,2
order by 2
````

|        |  platform |  year | avg_transaction | incorrect_avg |
|--------|-----------|-------|-----------------|---------------|
|      1 | Retail    |  2018 |           36.56 |         42.91 |
|      2 | Shopify   |  2018 |          192.48 |        188.28 |
|      3 | Retail    |  2019 |           36.83 |         41.97 |
|      4 | Shopify   |  2019 |          183.36 |        177.56 |
|      5 | Retail    |  2020 |           36.56 |         40.64 |
|      6 | Shopify   |  2020 |          179.03 |        174.87 |



## :pushpin: 3. Before & After Analysis

This technique is usually used when we inspect an important event and want to inspect the impact before and after a certain point in time.
Taking the week_date value of 2020-06-15 as the baseline week where the Data Mart sustainable packaging changes came into effect.
We would include all week_date values for 2020-06-15 as the start of the period after the change and the previous week_date values would be before.

(Bu teknik genellikle önemli bir olayı incelediğimizde ve zaman içinde belirli bir noktadan önceki ve sonraki etkiyi incelemek istediğimizde kullanılır.
Data Mart sürdürülebilir paketleme değişikliklerinin yürürlüğe girdiği temel hafta olarak 2020-06-15 week_date değeri alınır.
Değişiklikten sonraki dönemin başlangıcı olarak 2020-06-15 için tüm week_date değerlerini dahil edeceğiz ve önceki week_date değerleri daha önce olacaktır.)


1. What is the total sales for the 4 weeks before and after 2020-06-15? What is the growth or reduction rate in actual values and percentage of sales?

(2020-06-15'ten önceki ve sonraki 4 hafta için toplam satışlar nedir? Gerçek değerlerdeki büyüme veya azalma oranı ve satışların yüzdesi nedir?)
````sql
-- solution 1:

with weekly_sales as 
-- filtered data
(
select week_date,
	   week_number,
	   sum(sales) as total_sales
from clean_weekly_sales
where week_number between 21 and 28
and calendar_year = 2020
group by 1,2
),
before_after_tables as 
(
select 
	sum(case
			when week_number in (21,22,23,24) then total_sales end) as before_sales,
	sum(case
			when week_number in (25,26,27,28) then total_sales end) as after_sales
from weekly_sales  	
)
select after_sales - before_sales as sales_diff,
	  round((after_sales - before_sales)/before_sales*100,2) as sales_diff_percent
from before_after_tables


-- solution 2:

with week_sales as 
(
select 
      week_date,
      week_number,
      sum(sales) as total_sales
from clean_weekly_sales 
where week_number between 21 and 28  
and calendar_year = 2020
group by 1,2
),
lag_lead_sales as 
(
select 
      week_date,
      week_number,
      total_sales,
      lag(total_sales, 4) over (order by week_number) as before_sales,
      lead(total_sales, 4) over (order by week_number) as after_sales
from week_sales 
),
total_lag_lead as 
( 
select 
      sum(before_sales) as before_changes_sales,
      sum(after_sales) as after_changes_sales
from lag_lead_sales 
)
select
    after_changes_sales - before_changes_sales as diff_week_sales,
    round((after_changes_sales - before_changes_sales)/before_changes_sales*100,2) as growth_percentage
from total_lag_lead
````
|       | sales_diff | sales_diff_percent |
|-------|------------|--------------------|
|    1  | -26884188  |             -1.15  |


2. What about the entire 12 weeks before and after?

(Peki ya öncesi ve sonrasındaki 12 haftanın tamamı?)

* The date 2020-06-15 corresponds to week 24. The 12 weeks before and the 12 weeks after that are included in the process
* (2020-06-15 tarihi 24. haftaya karşılık gelmektedir. Bundan önceki 12 hafta ve sonraki 12 hafta sürece dahil edilir.)
````sql
with weekly_sales as 
-- filtered data
(
select week_date,
	   week_number,
	   sum(sales) as total_sales
from clean_weekly_sales
where week_number between 13 and 37
and calendar_year = 2020
group by 1,2
),
before_after_tables as 
(
select 
	sum(case
			when week_number in (13,14,15,16,17,18,19,20,21,22,23,24) then total_sales end) as before_sales,
	sum(case
			when week_number in (25,26,27,28,29,30,31,32,33,34,35,36) then total_sales end) as after_sales
from weekly_sales  	
)
select after_sales - before_sales as sales_diff,
	  round((after_sales - before_sales)/before_sales*100,2) as sales_diff_percent
from before_after_tables
````

|        | sales_diff | sales_diff_percent |
|--------|------------|--------------------|
|      1 | -152325394 |             -2.14  |

3. How do the sale metrics for these 2 periods before and after compare with the previous years in 2018 and 2019?

(Bu 2 dönem öncesi ve sonrası için satış metrikleri 2018 ve 2019'da önceki yıllarla nasıl karşılaştırılıyor?)

````sql
-- solution for 4 weeks after_before:
with weekly_sales as 
-- filtered data
(
select calendar_year,
	   week_number,
	   sum(sales) as total_sales
from clean_weekly_sales
where week_number between 21 and 28
group by 1,2
),
before_after_tables as 
(
select 
	calendar_year,
	sum(case
			when week_number in (21,22,23,24) then total_sales end) as before_sales,
	sum(case
			when week_number in (25,26,27,28) then total_sales end) as after_sales
from weekly_sales 
group by 1
)
select
	  calendar_year,
	  after_sales - before_sales as sales_diff,
	  round((after_sales - before_sales)/before_sales*100,2) as sales_diff_percent
from before_after_tables
````
|        | calendar_year | sales_diff | sales_diff_percent |
|--------|---------------|------------|--------------------|
|      1 |          2018 |    4102105 |              0.19  |
|      2 |          2019 |    2336594 |              0.10  |
|      3 |          2020 |  -26884188 |             -1.15  |

````sql
-- solution for 12 weeks after_before:

with weekly_sales as 
-- filtered data
(
select calendar_year,
	   week_number,
	   sum(sales) as total_sales
from clean_weekly_sales
where week_number between 13 and 37
group by 1,2
),
before_after_tables as 
(
select 
	calendar_year,
	sum(case
			when week_number in (13,14,15,16,17,18,19,20,21,22,23,24) then total_sales end) as before_sales,
	sum(case
			when week_number in (25,26,27,28,29,30,31,32,33,34,35,36) then total_sales end) as after_sales
from weekly_sales  
group by 1
)
select 
	  calendar_year,
	  after_sales - before_sales as sales_diff,
	  round((after_sales - before_sales)/before_sales*100,2) as sales_diff_percent
from before_after_tables
````
|                | sales_diff | sales_diff_percent |
|----------------|------------|--------------------|
|          2018  |  104256193 |              1.63  |
|          2019  |  -20740294 |             -0.30  |
|          2020  | -152325394 |             -2.14  |


## :pushpin: 4. Bonus Question

1. Which areas of the business have the highest negative impact in sales metrics performance in 2020 for the 12 week before and after period?

* region

* platform

* age_band

* demographic

* customer_type

Do you have any further recommendations for Danny’s team at Data Mart or any interesting insights based off this analysis?

(2020'de 12 hafta öncesi ve sonrası dönem için satış metrikleri performansında en yüksek olumsuz etkiye sahip iş alanları hangileridir?

* bölge

* platform

* age_band

* demografik

* customer_type

Danny'nin Data Mart'taki ekibine başka tavsiyeleriniz veya bu analize dayanan ilginç görüşleriniz var mı?)


````sql
-- region based before after metric:

with weekly_sales as 
-- filtered data
(
select 
	   region,
	   week_number,
	   sum(sales) as total_sales
from clean_weekly_sales
where week_number between 13 and 37
group by 1,2
),
before_after_tables as 
(
select 
	region,
	sum(case
			when week_number in (13,14,15,16,17,18,19,20,21,22,23,24) then total_sales end) as before_sales,
	sum(case
			when week_number in (25,26,27,28,29,30,31,32,33,34,35,36) then total_sales end) as after_sales
from weekly_sales  
group by 1
)
select 
	  region,
	  after_sales - before_sales as sales_diff,
	  round((after_sales - before_sales)/before_sales*100,2) as sales_diff_percent
from before_after_tables

-- The region with the most negative impact in the data is "Asia".
````
|        |    region    | sales_diff| sales_diff_percent |
|------- |--------------|---------- |--------------------|
|      1 | SOUTH AMERICA|  -2075531 |             -0.34  |
|      2 |     CANADA   | -10637499 |             -0.85  |
|      3 |    OCEANIA   | -58341540 |             -0.87  |
|      4 |      ASIA    | -61315418 |             -1.33  |
|      5 |       USA    |  -7257385 |             -0.37  |
|      6 |     EUROPE   |  16278629 |              4.96  |
|      7 |     AFRICA   |  54539249 |              1.10  |


````sql
-- platform based before after metric:

with weekly_sales as 
-- filtered data
(
select 
	   platform,
	   week_number,
	   sum(sales) as total_sales
from clean_weekly_sales
where week_number between 13 and 37
group by 1,2
),
before_after_tables as 
(
select 
	platform,
	sum(case
			when week_number in (13,14,15,16,17,18,19,20,21,22,23,24) then total_sales end) as before_sales,
	sum(case
			when week_number in (25,26,27,28,29,30,31,32,33,34,35,36) then total_sales end) as after_sales
from weekly_sales  
group by 1
)
select 
	  platform,
	  after_sales - before_sales as sales_diff,
	  round((after_sales - before_sales)/before_sales*100,2) as sales_diff_percent
from before_after_tables

-- The retail space has a negative impact.
````
|        |  platform | sales_diff | sales_diff_percent |
|--------|----------|-------------|--------------------|
|      1 |   Retail  | -117464107 |             -0.59  |
|      2 |  Shopify  |   48654612 |              9.35  |

````sql
-- age_band based before after metric:

with weekly_sales as 
-- filtered data
(
select 
	   age_band,
	   week_number,
	   sum(sales) as total_sales
from clean_weekly_sales
where week_number between 13 and 37
group by 1,2
),
before_after_tables as 
(
select 
	age_band,
	sum(case
			when week_number in (13,14,15,16,17,18,19,20,21,22,23,24) then total_sales end) as before_sales,
	sum(case
			when week_number in (25,26,27,28,29,30,31,32,33,34,35,36) then total_sales end) as after_sales
from weekly_sales  
group by 1
)
select 
	  age_band,
	  after_sales - before_sales as sales_diff,
	  round((after_sales - before_sales)/before_sales*100,2) as sales_diff_percent
from before_after_tables

-- The unknown age_band category has the highest negative impact. 
````
|        |    age_band    | sales_diff | sales_diff_percent |
|--------|----------------|------------|--------------------|
|      1 |   Middle Aged  |  -7143725  |             -0.22  |
|      2 |     Retirees   | -12158442  |             -0.18  |
|      3 |     unknown    | -44645418  |             -0.55  |
|      4 |   Young Adults |  -4861910  |             -0.21  |


````sql
-- demographic based before after metric:

with weekly_sales as 
-- filtered data
(
select 
	   demographic,
	   week_number,
	   sum(sales) as total_sales
from clean_weekly_sales
where week_number between 13 and 37
group by 1,2
),
before_after_tables as 
(
select 
	demographic,
	sum(case
			when week_number in (13,14,15,16,17,18,19,20,21,22,23,24) then total_sales end) as before_sales,
	sum(case
			when week_number in (25,26,27,28,29,30,31,32,33,34,35,36) then total_sales end) as after_sales
from weekly_sales  
group by 1
)
select 
	  demographic,
	  after_sales - before_sales as sales_diff,
	  round((after_sales - before_sales)/before_sales*100,2) as sales_diff_percent
from before_after_tables

-- Unknown demographic group has the most negative impact.
````
|        |  demographic | sales_diff | sales_diff_percent |
|--------|--------------|------------|--------------------|
|      1 |    Couples   |  -16524711 |             -0.29  |
|      2 |   Families   |   -7639366 |             -0.12  |
|      3 |    unknown   |  -44645418 |             -0.55  |

````sql
-- customer_type based before after metric:

with weekly_sales as 
-- filtered data
(
select 
	   customer_type,
	   week_number,
	   sum(sales) as total_sales
from clean_weekly_sales
where week_number between 13 and 37
group by 1,2
),
before_after_tables as 
(
select 
	customer_type,
	sum(case
			when week_number in (13,14,15,16,17,18,19,20,21,22,23,24) then total_sales end) as before_sales,
	sum(case
			when week_number in (25,26,27,28,29,30,31,32,33,34,35,36) then total_sales end) as after_sales
from weekly_sales  
group by 1
)
select 
	  customer_type,
	  after_sales - before_sales as sales_diff,
	  round((after_sales - before_sales)/before_sales*100,2) as sales_diff_percent
from before_after_tables

-- Existing customer type group has the highest negative impact.
````
|        |  customer_type | sales_diff | sales_diff_percent |
|--------|----------------|------------|--------------------|
|      1 |    Existing    |  -51510403 |             -0.51  |
|      2 |      Guest     |  -35202995 |             -0.46  |
|      3 |      New       |   17903903 |              0.69  |

