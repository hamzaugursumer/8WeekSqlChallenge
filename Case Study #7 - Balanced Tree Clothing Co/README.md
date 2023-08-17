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

