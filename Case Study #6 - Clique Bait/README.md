# :heavy_check_mark: Case Study #6 - Clique Bait
![Case Study 2 Image](https://8weeksqlchallenge.com/images/case-study-designs/6.png)

# Case Study Questions

## :pushpin: A. Digital Analysis

1. How many users are there?

(Kaç kullanıcı var?)
````sql
select 
      count(distinct user_id) as user_count 
from users
````
|       | user_count |
|-------|------------|
|   1   |    500     |

2. How many cookies does each user have on average?

(Her kullanıcının ortalama kaç çerezi var?)
````sql
with table1 as 
(
select 
	user_id,
	count(cookie_id) as count_cookie	
from users 
group by 1
)
select 
	round(avg(count_cookie),0) as avg_cookie
from table1
````
|       | avg_cookie |
|-------|------------|
|   1   |     4      |

3. What is the unique number of visits by all users per month?

(Tüm kullanıcıların aylık tekil ziyaret sayısı nedir?)
````sql
select 
	to_char(event_time, 'Month') as monthly_unique_visit,
	count(distinct visit_id) as visit_count
from users as u
left join events as e
ON e.cookie_id = u.cookie_id
group by 1
order by 2 desc
````

|       | monthly_unique_visit | visit_count |
|-------|----------------------|-------------|
|   1   |      February        |     1488    |
|   2   |      March           |     916     |
|   3   |      January         |     876     |
|   4   |      April           |     248     |
|   5   |      May             |     36      |

4. What is the number of events for each event type?

(Her bir etkinlik türü için etkinlik sayısı nedir?)
````sql
select 
	event_name,
	count(visit_id) as count_visit
from events as e
left join event_identifier as ei
ON ei.event_type = e.event_type
group by 1
````
|       |  event_name   | count_visit |
|-------|---------------|-------------|
|   1   |   Purchase    |     1777    |
|   2   | Ad Impression |     876     |
|   3   | Add to Cart   |     8451    |
|   4   |  Page View    |    20928    |
|   5   |   Ad Click    |     702     |

5. What is the percentage of visits which have a purchase event?

(Satın alma etkinliği olan ziyaretlerin yüzdesi nedir?)
````sql
with table1 as 
	(
select  
		count(visit_id) as purhcase_visit_count,
		(select count(visit_id) from events as e left join event_identifier as ei ON ei.event_type = e.event_type) as all_event
from events as e
left join event_identifier as ei
ON ei.event_type = e.event_type
where event_name = 'Purchase'
	)
select purhcase_visit_count,
	   all_event,
	   round((purhcase_visit_count*1.0/all_event*1.0)*100,2) as percentage_purchase_event
from table1 
````
|       | purhcase_visit_count | all_event | percentage_purchase_event |
|-------|----------------------|-----------|---------------------------|
|   1   |        1777          |   32734   |           5.43            |

6. What is the percentage of visits which view the checkout page but do not have a purchase event?

(Ödeme sayfasını görüntüleyen ancak bir satın alma olayı gerçekleşmeyen ziyaretlerin yüzdesi nedir?)
````sql
with table1 as 
(
select 
	event_name,
	visit_id,
	page_name
from event_identifier as ei
left join events as e 
ON ei.event_type = e.event_type  
left join page_hierarchy as ph
ON ph.page_id = e.page_id	
),
table2 as 
(
select 
	visit_id,
	MAX(CASE 
			  when page_name = 'Checkout' and event_name != 'Purchase' then 1 else 0 end) as checkout,
	MAX(CASE 
			  when event_name = 'Purchase' then 1 else 0 end) as purchase 
from table1
group by 1
)
select sum(checkout) as checkout_visit,
	   sum(purchase) as purchase_visit,
	   round((1-(sum(purchase)*1.0/sum(checkout)*1.0))*100,2) as ratio
from table2 
````
|       | checkout_visit | purchase_visit |  ratio  |
|-------|----------------|----------------|---------|
|   1   |      2103      |      1777      |  15.50  |

7. What are the top 3 pages by number of views?

(Görüntülenme sayısına göre ilk 3 sayfa hangileridir?)
````sql
select 
	page_name,
	count(distinct visit_id) as count_visit
from event_identifier as ei
left join events as e 
ON ei.event_type = e.event_type  
left join page_hierarchy as ph
ON ph.page_id = e.page_id	
group by 1
order by 2 desc
limit 3
````
|       |  page_name   | count_visit |
|-------|--------------|-------------|
|   1   | All Products |     3174    |
|   2   |   Checkout   |     2103    |
|   3   |   Home Page  |     1782    |

8. What is the number of views and cart adds for each product category?

(Her bir ürün kategorisi için görüntülenme ve sepete eklenme sayısı nedir?)

* Solution 1 
````sql
select 
	product_category,
	event_name,
	count(e.visit_id) as view_count
from page_hierarchy ph
left join events as e 
ON ph.page_id = e.page_id
left join event_identifier as ei
ON ei.event_type = e.event_type
where event_name in ('Page View', 'Add to Cart')
group by 1,2
order by product_category
````
|       | product_category |  event_name  | view_count |
|-------|------------------|--------------|------------|
|   1   |       Fish       |   Page View  |    4633    |
|   2   |       Fish       | Add to Cart  |    2789    |
|   3   |      Luxury      |   Page View  |    3032    |
|   4   |      Luxury      | Add to Cart  |    1870    |
|   5   |    Shellfish     | Add to Cart  |    3792    |
|   6   |    Shellfish     |   Page View  |    6204    |
|   7   |     [null]       |   Page View  |    7059    |

* Solution 2
````sql
select 
	product_category,
	count(case 
	 		when ei.event_name = 'Page View' then 'page_view' end) as page_view_count,
	count(case
		 	when ei.event_name = 'Add to Cart' then 'add_to_cart' end) as add_to_card_count
from page_hierarchy ph
left join events as e 
ON ph.page_id = e.page_id
left join event_identifier as ei
ON ei.event_type = e.event_type
where event_name in ('Page View', 'Add to Cart')
group by 1
````
|       | product_category | page_view_count | add_to_card_count |
|-------|------------------|-----------------|-------------------|
|   1   |      [null]      |       7059      |         0         |
|   2   |      Luxury      |       3032      |        1870       |
|   3   |    Shellfish     |       6204      |        3792       |
|   4   |       Fish       |       4633      |        2789       |


## :pushpin: B. Product Funnel Analysis


1. Using a single SQL query - create a new output table which has the following details:

* How many times was each product viewed?
* How many times was each product added to cart?
* How many times was each product added to a cart but not purchased (abandoned)?
* How many times was each product purchased?


1. Tek bir SQL sorgusu kullanarak - aşağıdaki ayrıntılara sahip yeni bir çıktı tablosu oluşturun:

* Her bir ürün kaç kez görüntülendi?
* Her bir ürün kaç kez sepete eklendi?
* Her bir ürün kaç kez sepete eklendi ancak satın alınmadı (terk edildi)?
* Her bir ürün kaç kez satın alındı?
````sql
with 
table1 as 
	(
	select e.visit_id,
		   ph.product_id,
		   ph.page_name as product_name,
		   ph.product_category,
		   SUM(CASE
			  		WHEN ei.event_name = 'Page View' then 1 else 0 end) as page_view,
		   SUM(CASE
			  		WHEN ei.event_name = 'Add to Cart' then 1 else 0 end) as add_to_cart
	from events as e
	left join page_hierarchy as ph 
	ON e.page_id = ph.page_id
	left join event_identifier as ei
	ON e.event_type = ei.event_type
	where product_id is not null
	group by 1,2,3,4
	),
table2 as 
	(
	select 
			distinct visit_id
	from events as e	
	left join event_identifier as ei
	ON ei.event_type = e.event_type
	where event_name = 'Purchase'
	),
table3 as 
	(	
	select table1.visit_id,
		   table1.product_id,
		   table1.product_name,
		   table1.product_category,
		   table1.page_view,
		   table1.add_to_cart,
		   (CASE
				WHEN table2.visit_id is not null then 1 else 0 end) as purchase
	from table1 
	left join table2 
	ON table2.visit_id = table1.visit_id
	),
table4 as
	(
	select 
		   product_category,
		   SUM(page_view) AS view_count,
		   SUM(add_to_cart) as add_to_cart_count,
		   SUM(CASE WHEN add_to_cart = 1 AND purchase = 0 THEN 1 ELSE 0 END) AS cancel,
    	   SUM(CASE WHEN add_to_cart = 1 AND purchase = 1 THEN 1 ELSE 0 END) AS purchase
	from table3	
	group by 1
	)
select * 
from table4
````
|       | product_category | view_count | add_to_cart_count | cancel | purchase |
|-------|------------------|------------|-------------------|--------|----------|
|   1   |      Luxury      |    3032    |       1870        |  466   |   1404   |
|   2   |    Shellfish     |    6204    |       3792        |  894   |   2898   |
|   3   |       Fish       |    4633    |       2789        |  674   |   2115   |

* !! We create a new table using the query given above;

(Yukarıda verilen sorguyu kullanarak yeni bir tablo oluşturuyoruz);
````sql
CREATE TABLE clique_bait_new_table AS
(
with 
table1 as 
	(
	select e.visit_id,
		   ph.product_id,
		   ph.page_name as product_name,
		   ph.product_category,
		   SUM(CASE
			  		WHEN ei.event_name = 'Page View' then 1 else 0 end) as page_view,
		   SUM(CASE
			  		WHEN ei.event_name = 'Add to Cart' then 1 else 0 end) as add_to_cart
	from events as e
	left join page_hierarchy as ph 
	ON e.page_id = ph.page_id
	left join event_identifier as ei
	ON e.event_type = ei.event_type
	where product_id is not null
	group by 1,2,3,4
	),
table2 as 
	(
	select 
			distinct visit_id
	from events as e	
	left join event_identifier as ei
	ON ei.event_type = e.event_type
	where event_name = 'Purchase'
	),
table3 as 
	(	
	select table1.visit_id,
		   table1.product_id,
		   table1.product_name,
		   table1.product_category,
		   table1.page_view,
		   table1.add_to_cart,
		   (CASE
				WHEN table2.visit_id is not null then 1 else 0 end) as purchase
	from table1 
	left join table2 
	ON table2.visit_id = table1.visit_id
	),
table4 as
	(
	select 
		   product_category,
		   SUM(page_view) AS view_count,
		   SUM(add_to_cart) as add_to_cart_count,
		   SUM(CASE WHEN add_to_cart = 1 AND purchase = 0 THEN 1 ELSE 0 END) AS cancel,
    	   SUM(CASE WHEN add_to_cart = 1 AND purchase = 1 THEN 1 ELSE 0 END) AS purchase
	from table3	
	group by 1
	)
select * 
from table4
)
````
1. Which product had the most views, cart adds and purchases?

(En çok görüntülenen, sepete eklenen ve satın alınan ürün hangisiydi?)
````sql
select *  
from clique_bait_new_table
````
|       | product_category | view_count | add_to_cart_count | cancel | purchase |
|-------|------------------|------------|-------------------|--------|----------|
|   1   |      Luxury      |    3032    |       1870        |  466   |   1404   |
|   2   |    Shellfish     |    6204    |       3792        |  894   |   2898   |
|   3   |       Fish       |    4633    |       2789        |  674   |   2115   |


2. Which product was most likely to be abandoned?

(Hangi ürünün terk edilme olasılığı daha yüksekti?)
````sql
select 
    product_category,
    round(case 
		  	 when product_category = 'Luxury' then cancel/add_to_cart_count 
             when product_category = 'Shellfish' then cancel/add_to_cart_count 
             when product_category = 'Fish' then cancel/add_to_cart_count else 0 end,3) as abandonment_rate
from clique_bait_new_table
````
|       | product_category | abandonment_rate |
|-------|------------------|------------------|
|   1   |      Luxury      |      0.249       |
|   2   |    Shellfish     |      0.236       |
|   3   |       Fish       |      0.242       |


3. Which product had the highest view to purchase percentage?

(Hangi ürün en yüksek görüntüleme-satın alma yüzdesine sahipti?)
````sql
select 
	product_category,
	round(purchase/view_count,2)*100 as Percentage_of_views_and_purchases
from clique_bait_new_table
````

|       | product_category | percentage_of_views_and_purchases |
|-------|------------------|----------------------------------|
|   1   |      Luxury      |             46.00                |
|   2   |    Shellfish     |             47.00                |
|   3   |       Fish       |             46.00                |


4. What is the average conversion rate from view to cart add?

(Görüntülemeden sepete eklemeye kadar ortalama dönüşüm oranı nedir?)

* Conversion Rate (Dönüşüm Oranı) : Dönüşüm oranı, bir eylemin gerçekleştiği önceki bir eyleme göre yüzdesel olarak ifade edilen orandır.  
  Bu, bir hedefe ulaşanların sayısını başlangıç noktasındaki tüm katılımcıların sayısına bölerken hesaplanır.

* Cıktıya Göre ; Dönüşüm Oranı = Sepete Ekleme / Görüntüleme

* Conversion Rate: The conversion rate is the percentage ratio expressed between a subsequent action occurring after a previous action. 
It's calculated by dividing the number of those who achieve a goal by the total number of participants at the starting point.

* Based on the Output; Conversion Rate = Add to Cart / Views


* Örnek:
Bir e-ticaret web sitesi düşünelim. Bu web sitesinde ürünleri görüntüleyen ziyaretçilerin bazıları ürünü sepete ekler ve daha sonra satın alır. 
Bu süreçteki dönüşüm oranı aşağıdaki şekilde hesaplanır:

Görüntüleme sayısı: 10.000 ziyaretçi
Sepete ekleme sayısı: 1.000 kişi
Satın alma sayısı: 200 kişi

* Görüntülemeden sepete ekleme oranı: 1.000 / 10.000 = 0.1 (veya %10)
* Görüntülemeden satın alma oranı: 200 / 10.000 = 0.02 (veya %2)
* Sepete eklenenlerden satın alma oranı: 200 / 1.000 = 0.2 (veya %20)




