-- Case Study Questions



-- A. High Level Sales Analysis

-- 1. What was the total quantity sold for all products?
-- (Tüm ürünler için satılan toplam miktar ne kadardı?)

select 
	product_name,
	sum(qty) as total_quantity
from sales as s
left join product_details as pd
ON pd.product_id = s.prod_id
group by 1
order by 2 desc

-- 2. What is the total generated revenue for all products before discounts?
-- (İndirimlerden önce tüm ürünler için elde edilen toplam gelir nedir?)

select 
	product_name,
	sum(qty) * sum(s.price) as total_price
from sales as s
left join product_details as pd
ON pd.product_id = s.prod_id
group by 1

-- 3. What was the total discount amount for all products?
-- (Tüm ürünler için toplam indirim tutarı ne kadardı?)

select 
	product_name,
	sum(qty * s.price * discount/100) as amount_of_discount
from sales as s
left join product_details as pd
ON pd.product_id = s.prod_id
group by 1
order by 2 desc




-- B. Transaction Analysis


-- 1. How many unique transactions were there?
-- (Kaç tane benzersiz işlem vardı?)

select 
	count(distinct txn_id) as transaction_count
from sales


-- 2. What is the average unique products purchased in each transaction?
-- (Her işlemde satın alınan ortalama benzersiz ürün sayısı nedir?)

with table1 as 
(
select 
	txn_id,
	sum(qty) as total_quantity
from sales as s
left join product_details as pd
ON pd.product_id = s.prod_id
group by 1
)
select 
	round(avg(total_quantity)) as avg_total_quantity
from table1 

-- 3. What are the 25th, 50th and 75th percentile values for the revenue per transaction?
-- (İşlem başına gelir için 25., 50. ve 75. yüzdelik değerler nedir?)

with table1 as 
(
select 
	txn_id,
	sum(price * qty) as total_revenue
from sales
group by 1
)
select 
 	PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY total_revenue) AS median_25th,
    PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY total_revenue) AS median_50th,
	PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY total_revenue) AS median_75th
from table1 


-- 4. What is the average discount value per transaction?
-- (İşlem başına ortalama indirim değeri nedir?)

with table1 as 
(
select 
	txn_id,
	sum(qty * price * discount/100) as total_discount
from sales
group by 1
)
select 
	round(avg(total_discount)) as avg_total_discount
from table1 

-- 5. What is the percentage split of all transactions for members vs non-members?
-- (Üyeler ve üye olmayanlar için tüm işlemlerin yüzde dağılımı nedir?)

select 
	member,
	count(distinct txn_id) as grouped_count_transactions,
	(select count(distinct txn_id) from sales) as total_transaction,
	round(count(distinct txn_id)*1.0 / (select count(distinct txn_id) from sales)*1.0,2) as percentage
from sales
group by 1

-- 6. What is the average revenue for member transactions and non-member transactions?
-- (Üye işlemleri ve üye olmayan işlemler için ortalama gelir nedir?)

with table1 as 
(
select 
	member,
	txn_id,
	sum(qty * price) as total_reveue
from sales 
group by 1,2
order by 1
)
select 
	member,
	round(avg(total_reveue),2) as avg_total_reveue
from table1
group by 1



-- C. Product Analysis


-- 1. What are the top 3 products by total revenue before discount?
-- (İndirim öncesi toplam gelire göre ilk 3 ürün hangileridir?)

select 
	product_name,
	sum(s.price) * sum(s.qty) as total_revenue
from sales as s
left join product_details as pd
ON pd.product_id = s.prod_id
group by 1
order by 2 desc
limit 3

-- 2. What is the total quantity, revenue and discount for each segment?
-- (Her bir segment için toplam miktar, gelir ve indirim nedir?)


select 
	segment_name,
	sum(qty) as total_quantity,
	sum(s.price * qty) as total_revenue,
	sum((s.price * qty) * discount / 100) as total_discount
from sales as s
left join product_details as pd
ON pd.product_id = s.prod_id
group by 1

-- 3. What is the top selling product for each segment?
-- (Her segment için en çok satan ürün nedir?)

with table1 as 
(
select 
	segment_name,
	product_name,
	sum(qty) as total_quantity,
	rank() over (partition by segment_name order by sum(qty) desc) as rn
from sales as s
left join product_details as pd
ON pd.product_id = s.prod_id
group by 1,2
order by 3 desc
)
select * 
from table1 
where rn = 1


-- 4. What is the total quantity, revenue and discount for each category?
-- (Her bir kategori için toplam miktar, gelir ve indirim nedir?)

select 
	category_name,
	sum(qty) as total_quantity,
	sum(s.price * qty) as total_revenue,
	sum((s.price * qty) * discount / 100) as total_discount
from sales as s
left join product_details as pd
ON pd.product_id = s.prod_id
group by 1


-- 5. What is the top selling product for each category?
-- (Her kategori için en çok satan ürün nedir?)

with table1 as 
(
select 
	category_name,
	product_name,
	sum(qty) as total_quantity,
	rank() over (partition by category_name order by sum(qty) desc) as rn
from sales as s
left join product_details as pd
ON pd.product_id = s.prod_id
group by 1,2
order by 3 desc	
)
select * 
from table1 
where rn = 1


-- 6. What is the percentage split of revenue by product for each segment?
-- (Her bir segment için gelirin ürüne göre yüzde dağılımı nedir?)

with table1 as 
(
select 
	segment_name,
	product_name,
	sum(s.price * qty) as grouped_total_revenue,
	(select sum(price * qty) from sales ) as total_revenue
from sales as s
left join product_details as pd
ON pd.product_id = s.prod_id
group by 1,2
order by segment_name	
)
select 
	*,
	round(grouped_total_revenue*1.0 / total_revenue*1.0 , 3)*100 as percentage
from table1 


-- 7. What is the percentage split of revenue by segment for each category?
-- (Her bir kategori için gelirin segmentlere göre yüzde dağılımı nedir?)

with table1 as 
(
select 
	category_name,
	segment_name,
	sum(s.price * qty) as grouped_total_revenue,
	(select sum(price * qty) from sales ) as total_revenue
from sales as s
left join product_details as pd
ON pd.product_id = s.prod_id
group by 1,2
order by category_name	
)
select 
	*,
	round(grouped_total_revenue*1.0 / total_revenue*1.0 , 2)*100 as percentage
from table1 


-- 8. What is the percentage split of total revenue by category?
-- (Toplam gelirin kategorilere göre yüzde dağılımı nedir?)

with table1 as 
(
select 
	category_name,
	sum(s.price * qty) as grouped_total_revenue,
	(select sum(price * qty) from sales) as total_revenue
from sales as s
left join product_details as pd
ON pd.product_id = s.prod_id
group by 1
)
select 
	*,
	round(grouped_total_revenue*1.0 / total_revenue*1.0 ,2)*100 as percentage
from table1

-- 9. What is the total transaction “penetration” for each product? 
-- (hint: penetration = number of transactions where at least 1 quantity of a product was 
-- purchased divided by total number of transactions)

-- (Her bir ürün için toplam işlem "penetrasyonu" nedir? 
-- (ipucu: penetrasyon = bir üründen en az 1 adet satın alınan işlem sayısının toplam işlem sayısına bölünmesi))

with table1 as 
(
select 
	product_name,
	count(txn_id) as count_txn,
	(select count(distinct txn_id) from sales) as total_count_txn 
from sales as s
left join product_details as pd
ON pd.product_id = s.prod_id
where qty >= 1
group by 1	
)
select 
	*,
	round(count_txn*1.0 / total_count_txn*1.0*100,3) as percentage
from table1


-- 10. What is the most common combination of at least 1 quantity of any 3 products in a 1 single transaction?
-- (Tek bir işlemde herhangi 3 üründen en az 1 adedinin en yaygın kombinasyonu nedir?)


select 
	s1.prod_id,
	s2.prod_id,
	s3.prod_id,
	count(*) as comb
from sales as s1
left join sales as s2 
ON s1.txn_id = s2.txn_id
left join sales as s3
ON s2.txn_id = s3.txn_id
	where s1.prod_id != s2.prod_id 
	and s2.prod_id != s3.prod_id
	and s1.prod_id != s3.prod_id
group by 1,2,3
order by 4 desc


-- D. Reporting Challenge

-- Write a single SQL script that combines all of the previous questions into a scheduled report that the 
-- Balanced Tree team can run at the beginning of each month to calculate the previous month’s values.

-- Imagine that the Chief Financial Officer (which is also Danny) has asked for all of these questions at the end of every month.
-- He first wants you to generate the data for January only - but then he also wants you to demonstrate that you can 
-- easily run the samne analysis for February without many changes (if at all).

-- Feel free to split up your final outputs into as many tables as you need - but be sure to explicitly reference 
-- which table outputs relate to which question for full marks :)




-- Dengeli Ağaç ekibinin önceki ayın değerlerini hesaplamak için her ayın başında çalıştırabileceği zamanlanmış bir 
-- raporda önceki soruların tümünü birleştiren tek bir SQL komut dosyası yazın.

-- Mali İşler Müdürünün (aynı zamanda Danny'dir) her ayın sonunda bu soruların tümünü sorduğunu düşünün.
-- İlk olarak yalnızca Ocak ayı için veri oluşturmanızı istiyor - ancak daha sonra aynı analizi çok 
-- fazla değişiklik yapmadan (hiç değilse) Şubat ayı için de kolayca çalıştırabileceğinizi göstermenizi istiyor.

-- Nihai çıktılarınızı istediğiniz kadar tabloya bölmekten çekinmeyin - ancak tam puan almak için hangi 
-- tablo çıktılarının hangi soruyla ilgili olduğunu açıkça belirttiğinizden emin olun :)

select 
	category_name,
	segment_name,
	s.prod_id,
	pd.product_name,
	sum(qty) as total_quantity,
	sum(qty * s.price) as total_revenue,
	sum(qty * s.price * discount/100) as amount_of_discount,
	count(distinct txn_id) as transaction_count,
	round(count(txn_id)*1.0 / (select count(distinct txn_id) from sales)*1.0 , 3)*100 as penetration,
	round(sum(case when member='t' then 1 else 0 end)*100.0/count(*),2) as member_transaction,
	round(sum(case when member='f' then 1 else 0 end)*100.0/count(*),2) as non_member_transaction,
	round(avg(case when member='t' then (qty*s.price*discount / 100) end),2) as avg_revenue_member,
    round(avg(case when member='f' then (qty*s.price*discount / 100) end),2) as avg_revenue_non_member
from sales as s
left join product_details as pd
ON pd.product_id = s.prod_id
where extract (month from start_txn_time) = 1
group by 1,2,3,4



-- E. Bonus Challenge


-- Use a single SQL query to transform the product_hierarchy and product_prices datasets to the product_details table.
-- Hint: you may want to consider using a recursive CTE to solve this problem!

-- product_hierarchy ve product_prices veri kümelerini product_details tablosuna dönüştürmek için tek bir SQL sorgusu kullanın.
-- İpucu: Bu sorunu çözmek için özyinelemeli bir CTE kullanmayı düşünebilirsiniz!


select * from product_details
select * from sales
select * from product_hierarchy
select * from product_prices


with gender as
	(
select 
	id as gender_id, 
	level_text as category 
from product_hierarchy 
where level_name='Category'
	),
seg as 
	(
select 
	parent_id as gender_id,
	id as seg_id, 
	level_text as Segment 
from product_hierarchy 
where level_name='Segment'
	),
style as 
	(
select 
	parent_id as seg_id,
	id as style_id, 
	level_text as Style
from product_hierarchy 
where level_name='Style'
	),
last_table as
	(
select 
	g.gender_id as category_id,
	category as category_name,
	s.seg_id as segment_id,
	segment as segment_name,
	style_id,
	style as style_name
from gender as g 
left join seg as s 
on g.gender_id = s.gender_id
left join style st 
on s.seg_id = st.seg_id
 	)
select 
	product_id, 
	price,
	concat(style_name,' ',segment_name,' - ',category_name) as product_name,
	category_id,
	segment_id,
	style_id,
	category_name,
	segment_name,
	style_name 
from last_table as lt 
left join product_prices as pp
on lt.style_id=pp.id






