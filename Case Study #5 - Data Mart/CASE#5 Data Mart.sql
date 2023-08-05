-- Case Study Questions

-- 1. Data Cleansing Steps

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
);


-- 2. Data Exploration

-- 1. What day of the week is used for each week_date value?
-- (Her week_date değeri için haftanın hangi günü kullanılır?)

select distinct to_char(week_date, 'Day') as day_of_the_week
from clean_weekly_sales

-- 2. What range of week numbers are missing from the dataset?
-- (Veri kümesinde hangi aralıktaki hafta sayıları eksiktir?)

select distinct extract(week from (week_date)) as week_num
from clean_weekly_sales
order by 1

-- 3. How many total transactions were there for each year in the dataset?
-- (Veri setindeki her yıl için toplam kaç işlem vardı?)

select distinct extract(year from (week_date)) as years,
       to_char(sum(transactions), 'FM999,999,999') as total_transactions
from clean_weekly_sales
group by 1


-- 4. What is the total sales for each region for each month?
-- (Her ay için her bölgenin toplam satışları ne kadardır?)

select extract(month from (week_date)) as months,
	   region,
	   sum(sales) as total_sales
from clean_weekly_sales
group by 1,2
order by 1

-- 5. What is the total count of transactions for each platform?
-- (Her bir platform için toplam işlem sayısı nedir?)

select platform,
	   sum(transactions) as total_transactions
from clean_weekly_sales
group by 1

-- 6. What is the percentage of sales for Retail vs Shopify for each month?
-- (Her ay için Perakende ve Shopify satışlarının yüzdesi nedir?)

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


-- 7. What is the percentage of sales by demographic for each year in the dataset?
-- (Veri setindeki her bir yıl için demografiye göre satışların yüzdesi nedir?)

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


-- 8. Which age_band and demographic values contribute the most to Retail sales?
-- (Perakende satışlara en çok hangi yaş_bandı ve demografik değerler katkıda bulunuyor?)

select 
	   demographic,
	   age_band,
	   sum(sales) as sum_sales,
	   round(sum(sales)*1.0 / (select sum(sales) from clean_weekly_sales where platform = 'Retail')*1.0,2)*100 as retail_percentage
from clean_weekly_sales
where platform = 'Retail'
group by 1,2
order by 3 desc

-- 9. Can we use the avg_transaction column to find the average transaction size for each year for Retail vs Shopify? If not - how would you calculate it instead?
-- (Retail ve Shopify için her yılın ortalama işlem boyutunu bulmak üzere avg_transaction sütununu kullanabilir miyiz? Değilse bunun yerine nasıl hesaplarsınız?)

-- We can't use it because if we try to average again based on the platform, it will be like averaging the average and we will mislead our data.
-- (Kullanamayız çünkü, eğer platform bazlı tekrar ortalama almaya çalırsak ortalamanın ortalamasını almıs gibi oluruz ve verimizi yanıltırız.)

select platform,
	   extract(year from (week_date)) as year,
	   round(sum(sales)*1.0 / sum(transactions)*1.0,2) as avg_transaction,
	   round(avg(avg_transaction),2) as incorrect_avg
from clean_weekly_sales
group by 1,2
order by 2


-- 3. Before & After Analysis

-- This technique is usually used when we inspect an important event and want to inspect the impact before and after a certain point in time.
-- Taking the week_date value of 2020-06-15 as the baseline week where the Data Mart sustainable packaging changes came into effect.
-- We would include all week_date values for 2020-06-15 as the start of the period after the change and the previous week_date values would be before.

-- (Bu teknik genellikle önemli bir olayı incelediğimizde ve zaman içinde belirli bir noktadan önceki ve sonraki etkiyi incelemek istediğimizde kullanılır.
-- Data Mart sürdürülebilir paketleme değişikliklerinin yürürlüğe girdiği temel hafta olarak 2020-06-15 week_date değeri alınır.
-- Değişiklikten sonraki dönemin başlangıcı olarak 2020-06-15 için tüm week_date değerlerini dahil edeceğiz ve önceki week_date değerleri daha önce olacaktır.)


-- 1. What is the total sales for the 4 weeks before and after 2020-06-15? What is the growth or reduction rate in actual values and percentage of sales?
-- (2020-06-15'ten önceki ve sonraki 4 hafta için toplam satışlar nedir? Gerçek değerlerdeki büyüme veya azalma oranı ve satışların yüzdesi nedir?)


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



-- 2. What about the entire 12 weeks before and after?
-- (Peki ya öncesi ve sonrasındaki 12 haftanın tamamı?)



-- !! The date 2020-06-15 corresponds to week 24. The 12 weeks before and the 12 weeks after that are included in the process
-- !! (2020-06-15 tarihi 24. haftaya karşılık gelmektedir. Bundan önceki 12 hafta ve sonraki 12 hafta sürece dahil edilir.)

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


-- 3. How do the sale metrics for these 2 periods before and after compare with the previous years in 2018 and 2019?
-- (Bu 2 dönem öncesi ve sonrası için satış metrikleri 2018 ve 2019'da önceki yıllarla nasıl karşılaştırılıyor?)


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


-- 4. Bonus Question

-- Which areas of the business have the highest negative impact in sales metrics performance in 2020 for the 12 week before and after period?
-- region
-- platform
-- age_band
-- demographic
-- customer_type
-- Do you have any further recommendations for Danny’s team at Data Mart or any interesting insights based off this analysis?


-- 2020'de 12 hafta öncesi ve sonrası dönem için satış metrikleri performansında en yüksek olumsuz etkiye sahip iş alanları hangileridir?
-- bölge
-- platform
-- age_band
-- demografik
-- customer_type
-- Danny'nin Data Mart'taki ekibine başka tavsiyeleriniz veya bu analize dayanan ilginç görüşleriniz var mı?





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