# :heavy_check_mark: Case Study #7 - Balanced Tree Clothing Co.
![Case Study 2 Image](https://8weeksqlchallenge.com/images/case-study-designs/7.png)


# Case Study Questions

## :pushpin: A. High Level Sales Analysis

1. What was the total quantity sold for all products?

(Tüm ürünler için satılan toplam miktar ne kadardı?)
````sql
select 
	product_name,
	sum(qty) as total_quantity
from sales as s
left join product_details as pd
ON pd.product_id = s.prod_id
group by 1
order by 2 desc
````
|       | Product Name                    | Total Quantity |
|-------|---------------------------------|----------------|
| 1     | Grey Fashion Jacket - Womens    | 3876           |
| 2     | Navy Oversized Jeans - Womens   | 3856           |
| 3     | Blue Polo Shirt - Mens          | 3819           |
| 4     | White Tee Shirt - Mens          | 3800           |
| 5     | Navy Solid Socks - Mens         | 3792           |
| 6     | Black Straight Jeans - Womens   | 3786           |
| 7     | Pink Fluro Polkadot Socks - Mens | 3770           |
| 8     | Indigo Rain Jacket - Womens     | 3757           |
| 9     | Khaki Suit Jacket - Womens      | 3752           |
| 10    | Cream Relaxed Jeans - Womens    | 3707           |
| 11    | White Striped Socks - Mens      | 3655           |
| 12    | Teal Button Up Shirt - Mens     | 3646           |


2. What is the total generated revenue for all products before discounts?

(İndirimlerden önce tüm ürünler için elde edilen toplam gelir nedir?)
````sql
select 
	product_name,
	sum(qty) * sum(s.price) as total_price
from sales as s
left join product_details as pd
ON pd.product_id = s.prod_id
group by 1
````
|       | Product Name                    | Total Price     |
|-------|---------------------------------|-----------------|
| 1     | White Tee Shirt - Mens          | 192,736,000     |
| 2     | Navy Solid Socks - Mens         | 174,871,872     |
| 3     | Grey Fashion Jacket - Womens    | 266,862,600     |
| 4     | Navy Oversized Jeans - Womens   | 63,863,072      |
| 5     | Pink Fluro Polkadot Socks - Mens | 137,537,140     |
| 6     | Khaki Suit Jacket - Womens      | 107,611,112     |
| 7     | Black Straight Jeans - Womens   | 150,955,392     |
| 8     | White Striped Socks - Mens      | 77,233,805      |
| 9     | Blue Polo Shirt - Mens          | 276,022,044     |
| 10    | Indigo Rain Jacket - Womens     | 89,228,750      |
| 11    | Cream Relaxed Jeans - Womens    | 46,078,010      |
| 12    | Teal Button Up Shirt - Mens     | 45,283,320      |

3. What was the total discount amount for all products?

(Tüm ürünler için toplam indirim tutarı ne kadardı?)
````sql
select 
	product_name,
	sum(qty * s.price * discount/100) as amount_of_discount
from sales as s
left join product_details as pd
ON pd.product_id = s.prod_id
group by 1
order by 2 desc
````
|       | Product Name                    | Amount of Discount |
|-------|---------------------------------|-------------------|
| 1     | Blue Polo Shirt - Mens          | 26,189            |
| 2     | Grey Fashion Jacket - Womens    | 24,781            |
| 3     | White Tee Shirt - Mens          | 17,968            |
| 4     | Navy Solid Socks - Mens         | 16,059            |
| 5     | Black Straight Jeans - Womens   | 14,156            |
| 6     | Pink Fluro Polkadot Socks - Mens | 12,344            |
| 7     | Khaki Suit Jacket - Womens      | 9,660             |
| 8     | Indigo Rain Jacket - Womens     | 8,010             |
| 9     | White Striped Socks - Mens      | 6,877             |
| 10    | Navy Oversized Jeans - Womens   | 5,538             |
| 11    | Cream Relaxed Jeans - Womens    | 3,979             |
| 12    | Teal Button Up Shirt - Mens     | 3,925             |

## :pushpin: B. Transaction Analysis


1. How many unique transactions were there?

(Kaç tane benzersiz işlem vardı?)
````sql
select 
	count(distinct txn_id) as transaction_count
from sales
````
|   | transaction_count  |
|---|--------------------|
| 1 |       2500         |

2. What is the average unique products purchased in each transaction?

(Her işlemde satın alınan ortalama benzersiz ürün sayısı nedir?)
````sql
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
````
|      | avg_total_quantity |
|------|--------------------|
| 1    |           18       |

3. What are the 25th, 50th and 75th percentile values for the revenue per transaction?

(İşlem başına gelir için 25., 50. ve 75. yüzdelik değerler nedir?)
````sql
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
````
|       | median_25th | median_50th | median_75th |
|-------|-------------|-------------|-------------|
|   1   | 375.75      | 509.5       | 647         |


4. What is the average discount value per transaction?

(İşlem başına ortalama indirim değeri nedir?)
````sql
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
````
|       | avg_total_discount |
|-------|--------------------|
|   1   | 60                 |

5. What is the percentage split of all transactions for members vs non-members?

(Üyeler ve üye olmayanlar için tüm işlemlerin yüzde dağılımı nedir?)
````sql
select 
	member,
	count(distinct txn_id) as grouped_count_transactions,
	(select count(distinct txn_id) from sales) as total_transaction,
	round(count(distinct txn_id)*1.0 / (select count(distinct txn_id) from sales)*1.0,2) as percentage
from sales
group by 1
````
|       | member | grouped_count_transactions | total_transaction | percentage |
|-------|--------|---------------------------|-------------------|------------|
|    1  | false  | 995                       | 2500              | 0.40       |
|    2  | true   | 1505                      | 2500              | 0.60       |

6. What is the average revenue for member transactions and non-member transactions?

(Üye işlemleri ve üye olmayan işlemler için ortalama gelir nedir?)
````sql
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
````
|       | member | avg_total_reveue |
|-------|--------|------------------|
|   1   | false  | 515.04           |
|   2   | true   | 516.27           |

## :pushpin: C. Product Analysis

1. What are the top 3 products by total revenue before discount?

(İndirim öncesi toplam gelire göre ilk 3 ürün hangileridir?)
````sql
select 
	product_name,
	sum(s.price) * sum(s.qty) as total_revenue
from sales as s
left join product_details as pd
ON pd.product_id = s.prod_id
group by 1
order by 2 desc
limit 3
````
|       | product_name                    | total_revenue |
|-------|---------------------------------|---------------|
| 1     | Blue Polo Shirt - Mens          | 276022044     |
| 2     | Grey Fashion Jacket - Womens    | 266862600     |
| 3     | White Tee Shirt - Mens          | 192736000     |

2. What is the total quantity, revenue and discount for each segment?

(Her bir segment için toplam miktar, gelir ve indirim nedir?)
````sql
select 
	segment_name,
	sum(qty) as total_quantity,
	sum(s.price * qty) as total_revenue,
	sum((s.price * qty) * discount / 100) as total_discount
from sales as s
left join product_details as pd
ON pd.product_id = s.prod_id
group by 1
````
|       | segment_name | total_quantity | total_revenue | total_discount |
|-------|--------------|----------------|---------------|----------------|
| 1     | Shirt        | 11265          | 406143        | 48082          |
| 2     | Jeans        | 11349          | 208350        | 23673          |
| 3     | Jacket       | 11385          | 366983        | 42451          |
| 4     | Socks        | 11217          | 307977        | 35280          |

3. What is the top selling product for each segment?

(Her segment için en çok satan ürün nedir?)
````sql
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
````
|       | segment_name | product_name                    | total_quantity | rn  |
|-------|--------------|---------------------------------|----------------|-----|
| 1     | Jacket       | Grey Fashion Jacket - Womens    | 3876           | 1   |
| 2     | Jeans        | Navy Oversized Jeans - Womens   | 3856           | 1   |
| 3     | Shirt        | Blue Polo Shirt - Mens          | 3819           | 1   |
| 4     | Socks        | Navy Solid Socks - Mens         | 3792           | 1   |

4. What is the total quantity, revenue and discount for each category?

(Her bir kategori için toplam miktar, gelir ve indirim nedir?)
````sql
select 
	category_name,
	sum(qty) as total_quantity,
	sum(s.price * qty) as total_revenue,
	sum((s.price * qty) * discount / 100) as total_discount
from sales as s
left join product_details as pd
ON pd.product_id = s.prod_id
group by 1
````
|       | category_name | total_quantity | total_revenue | total_discount |
|-------|---------------|----------------|---------------|----------------|
| 1     | Mens          | 22482          | 714120        | 83362          |
| 2     | Womens        | 22734          | 575333        | 66124          |

5. What is the top selling product for each category?

(Her kategori için en çok satan ürün nedir?)
````sql
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
````
|       | category_name | product_name                    | total_quantity | rn  |
|-------|---------------|---------------------------------|----------------|-----|
| 1     | Womens        | Grey Fashion Jacket - Womens    | 3876           | 1   |
| 2     | Mens          | Blue Polo Shirt - Mens          | 3819           | 1   |

6. What is the percentage split of revenue by product for each segment?

(Her bir segment için gelirin ürüne göre yüzde dağılımı nedir?)
````sql
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
````
|       | segment_name | product_name                   | grouped_total_revenue | total_revenue | percentage |
|-------|--------------|-------------------------------|-----------------------|--------------|------------|
| 1     | Jacket       | Indigo Rain Jacket - Womens   | 71383                 | 1289453      | 5.500      |
| 2     | Jacket       | Khaki Suit Jacket - Womens    | 86296                 | 1289453      | 6.700      |
| 3     | Jacket       | Grey Fashion Jacket - Womens  | 209304                | 1289453      | 16.200     |
| 4     | Jeans        | Navy Oversized Jeans - Womens | 50128                 | 1289453      | 3.900      |
| 5     | Jeans        | Black Straight Jeans - Womens | 121152                | 1289453      | 9.400      |
| 6     | Jeans        | Cream Relaxed Jeans - Womens  | 37070                 | 1289453      | 2.900      |
| 7     | Shirt        | White Tee Shirt - Mens        | 152000                | 1289453      | 11.800     |
| 8     | Shirt        | Blue Polo Shirt - Mens        | 217683                | 1289453      | 16.900     |
| 9     | Shirt        | Teal Button Up Shirt - Mens   | 36460                 | 1289453      | 2.800      |
| 10    | Socks        | Navy Solid Socks - Mens       | 136512                | 1289453      | 10.600     |
| 11    | Socks        | White Striped Socks - Mens    | 62135                 | 1289453      | 4.800      |
| 12    | Socks        | Pink Fluro Polkadot Socks - Mens | 109330             | 1289453      | 8.500      |

7. What is the percentage split of revenue by segment for each category?

(Her bir kategori için gelirin segmentlere göre yüzde dağılımı nedir?)
````sql
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
````
|       | category_name | segment_name | grouped_total_revenue | total_revenue | percentage |
|-------|---------------|--------------|-----------------------|--------------|------------|
| 1     | Mens          | Socks        | 307977                | 1289453      | 24.00      |
| 2     | Mens          | Shirt        | 406143                | 1289453      | 31.00      |
| 3     | Womens        | Jeans        | 208350                | 1289453      | 16.00      |
| 4     | Womens        | Jacket       | 366983                | 1289453      | 28.00      |

8. What is the percentage split of total revenue by category?

(Toplam gelirin kategorilere göre yüzde dağılımı nedir?)
````sql
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
````

|       | category_name | grouped_total_revenue | total_revenue | percentage |
|-------|---------------|-----------------------|--------------|------------|
| 1     | Mens          | 714120                | 1289453      | 55.00      |
| 2     | Womens        | 575333                | 1289453      | 45.00      |


9. What is the total transaction “penetration” for each product? 
(hint: penetration = number of transactions where at least 1 quantity of a product was 
purchased divided by total number of transactions)

(Her bir ürün için toplam işlem "penetrasyonu" nedir? 
(ipucu: penetrasyon = bir üründen en az 1 adet satın alınan işlem sayısının toplam işlem sayısına bölünmesi))

````sql
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
````

| index | product_name                   | count_txn | total_count_txn | percentage |
|-------|--------------------------------|-----------|-----------------|------------|
| 1     | White Tee Shirt - Mens         | 1268      | 2500            | 50.720     |
| 2     | Navy Solid Socks - Mens        | 1281      | 2500            | 51.240     |
| 3     | Grey Fashion Jacket - Womens   | 1275      | 2500            | 51.000     |
| 4     | Navy Oversized Jeans - Womens  | 1274      | 2500            | 50.960     |
| 5     | Pink Fluro Polkadot Socks - Mens | 1258     | 2500            | 50.320     |
| 6     | Khaki Suit Jacket - Womens     | 1247      | 2500            | 49.880     |
| 7     | Black Straight Jeans - Womens  | 1246      | 2500            | 49.840     |
| 8     | White Striped Socks - Mens     | 1243      | 2500            | 49.720     |
| 9     | Blue Polo Shirt - Mens         | 1268      | 2500            | 50.720     |
| 10    | Indigo Rain Jacket - Womens    | 1250      | 2500            | 50.000     |
| 11    | Cream Relaxed Jeans - Womens   | 1243      | 2500            | 49.720     |
| 12    | Teal Button Up Shirt - Mens    | 1242      | 2500            | 49.680     |


10. What is the most common combination of at least 1 quantity of any 3 products in a 1 single transaction?

(Tek bir işlemde herhangi 3 üründen en az 1 adedinin en yaygın kombinasyonu nedir?)
````sql
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
````
|       | prod_id | prod_id-2 | prod_id-3 | comb |
|-------|---------|-----------|-----------|------|
| 1     | 9ec847  | 5d267b    | c8d436    | 352  |
| 2     | c8d436  | 5d267b    | 9ec847    | 352  |
| 3     | 9ec847  | c8d436    | 5d267b    | 352  |
| 4     | 5d267b  | 9ec847    | c8d436    | 352  |
| 5     | c8d436  | 9ec847    | 5d267b    | 352  |
| 6     | 5d267b  | c8d436    | 9ec847    | 352  |

## :pushpin: D. Reporting Challenge

* Write a single SQL script that combines all of the previous questions into a scheduled report that the 
Balanced Tree team can run at the beginning of each month to calculate the previous month’s values.

* Imagine that the Chief Financial Officer (which is also Danny) has asked for all of these questions at the end of every month.
He first wants you to generate the data for January only - but then he also wants you to demonstrate that you can 
easily run the samne analysis for February without many changes (if at all).

* (Feel free to split up your final outputs into as many tables as you need - but be sure to explicitly reference 
which table outputs relate to which question for full marks :)

* Dengeli Ağaç ekibinin önceki ayın değerlerini hesaplamak için her ayın başında çalıştırabileceği zamanlanmış bir 
raporda önceki soruların tümünü birleştiren tek bir SQL komut dosyası yazın.

* Mali İşler Müdürünün (aynı zamanda Danny'dir) her ayın sonunda bu soruların tümünü sorduğunu düşünün.
İlk olarak yalnızca Ocak ayı için veri oluşturmanızı istiyor - ancak daha sonra aynı analizi çok 
fazla değişiklik yapmadan (hiç değilse) Şubat ayı için de kolayca çalıştırabileceğinizi göstermenizi istiyor.

* Nihai çıktılarınızı istediğiniz kadar tabloya bölmekten çekinmeyin - ancak tam puan almak için hangi 
tablo çıktılarının hangi soruyla ilgili olduğunu açıkça belirttiğinizden emin olun.)
````sql
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
````
|      | category_name | segment_name | prod_id | product_name                   | total_quantity | total_revenue | amount_of_discount | transaction_count | penetration | member_transaction | non_member_transaction | avg_revenue_member | avg_revenue_non_member |
|-------|---------------|--------------|---------|--------------------------------|----------------|---------------|-------------------|------------------|-------------|--------------------|-----------------------|--------------------|-----------------------|
| 1     | Mens          | Shirt        | 2a2353  | Blue Polo Shirt - Mens         | 1214           | 69198         | 8317              | 413              | 16.500      | 62.23              | 37.77                 | 20.06              | 20.26                 |
| 2     | Mens          | Shirt        | 5d267b  | White Tee Shirt - Mens         | 1256           | 50240         | 6030              | 416              | 16.600      | 58.89              | 41.11                 | 15.02              | 13.74                 |
| 3     | Mens          | Shirt        | c8d436  | Teal Button Up Shirt - Mens    | 1220           | 12200         | 1393              | 411              | 16.400      | 57.18              | 42.82                 | 3.40               | 3.37                  |
| 4     | Mens          | Socks        | 2feb6b  | Pink Fluro Polkadot Socks - Mens | 1157           | 33553         | 3904              | 396              | 15.800      | 62.12              | 37.88                 | 10.20              | 9.29                  |
| 5     | Mens          | Socks        | b9a74d  | White Striped Socks - Mens     | 1150           | 19550         | 2194              | 399              | 16.000      | 60.15              | 39.85                 | 5.82               | 5.01                  |
| 6     | Mens          | Socks        | f084eb  | Navy Solid Socks - Mens        | 1264           | 45504         | 5361              | 420              | 16.800      | 58.33              | 41.67                 | 12.88              | 12.61                 |
| 7     | Womens        | Jacket       | 72f5d4  | Indigo Rain Jacket - Womens    | 1225           | 23275         | 2648              | 407              | 16.300      | 58.48              | 41.52                 | 6.58               | 6.40                  |
| 8     | Womens        | Jacket       | 9ec847  | Grey Fashion Jacket - Womens   | 1300           | 70200         | 8371              | 431              | 17.200      | 61.95              | 38.05                 | 20.07              | 18.36                 |
| 9     | Womens        | Jacket       | d5e9a6  | Khaki Suit Jacket - Womens     | 1225           | 28175         | 3254              | 402              | 16.100      | 57.96              | 42.04                 | 8.04               | 8.17                  |
| 10    | Womens        | Jeans        | c4a632  | Navy Oversized Jeans - Womens  | 1257           | 16341         | 1828              | 423              | 16.900      | 59.57              | 40.43                 | 4.44               | 4.15                  |
| 11    | Womens        | Jeans        | e31d39  | Cream Relaxed Jeans - Womens   | 1282           | 12820         | 1430              | 432              | 17.300      | 60.19              | 39.81                 | 3.33               | 3.28                  |
| 12    | Womens        | Jeans        | e83aa3  | Black Straight Jeans - Womens  | 1238           | 39616         | 4670              | 408              | 16.300      | 58.09              | 41.91                 | 11.37              | 11.56                 |

## :pushpin: E. Bonus Challenge

* Use a single SQL query to transform the product_hierarchy and product_prices datasets to the product_details table.
Hint: you may want to consider using a recursive CTE to solve this problem!

* product_hierarchy ve product_prices veri kümelerini product_details tablosuna dönüştürmek için tek bir SQL sorgusu kullanın.
İpucu: Bu sorunu çözmek için özyinelemeli bir CTE kullanmayı düşünebilirsiniz!

````sql
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
````
|       | product_id | price | product_name                   | category_id | segment_id | style_id | category_name | segment_name | style_name       |
|-------|------------|-------|--------------------------------|-------------|------------|----------|---------------|--------------|------------------|
| 1     | c4a632     | 13    | Navy Oversized Jeans - Womens  | 1           | 3          | 7        | Womens        | Jeans        | Navy Oversized   |
| 2     | e83aa3     | 32    | Black Straight Jeans - Womens  | 1           | 3          | 8        | Womens        | Jeans        | Black Straight   |
| 3     | e31d39     | 10    | Cream Relaxed Jeans - Womens   | 1           | 3          | 9        | Womens        | Jeans        | Cream Relaxed    |
| 4     | d5e9a6     | 23    | Khaki Suit Jacket - Womens     | 1           | 4          | 10       | Womens        | Jacket       | Khaki Suit       |
| 5     | 72f5d4     | 19    | Indigo Rain Jacket - Womens    | 1           | 4          | 11       | Womens        | Jacket       | Indigo Rain      |
| 6     | 9ec847     | 54    | Grey Fashion Jacket - Womens   | 1           | 4          | 12       | Womens        | Jacket       | Grey Fashion     |
| 7     | 5d267b     | 40    | White Tee Shirt - Mens         | 2           | 5          | 13       | Mens          | Shirt        | White Tee        |
| 8     | c8d436     | 10    | Teal Button Up Shirt - Mens    | 2           | 5          | 14       | Mens          | Shirt        | Teal Button Up   |
| 9     | 2a2353     | 57    | Blue Polo Shirt - Mens         | 2           | 5          | 15       | Mens          | Shirt        | Blue Polo        |
| 10    | f084eb     | 36    | Navy Solid Socks - Mens        | 2           | 6          | 16       | Mens          | Socks        | Navy Solid       |
| 11    | b9a74d     | 17    | White Striped Socks - Mens     | 2           | 6          | 17       | Mens          | Socks        | White Striped    |
| 12    | 2feb6b     | 29    | Pink Fluro Polkadot Socks - Mens | 2          | 6          | 18       | Mens          | Socks        | Pink Fluro Polkadot |


