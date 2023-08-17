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

