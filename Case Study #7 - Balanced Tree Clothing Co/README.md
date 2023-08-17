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
