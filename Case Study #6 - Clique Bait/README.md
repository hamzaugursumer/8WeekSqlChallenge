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

````sql
with table1 as 
(
select 
	product_category,
	view_count,
	add_to_cart_count
from clique_bait_new_table
)
select 
	ROUND(AVG((add_to_cart_count*1.0/view_count*1.0)),2)*100 AS average_conversion_rate
from table1 
````
|       | average_conversion_rate |
|-------|-------------------------|
|   1   |           61.00         |


5. What is the average conversion rate from cart add to purchase?

(Sepete ekleme işleminden satın alma işlemine ortalama dönüşüm oranı nedir?)
````sql
with table1 as 
(
select 
	product_category,
	purchase,
	add_to_cart_count
from clique_bait_new_table
)
select 
	ROUND(AVG((purchase*1.0/add_to_cart_count*1.0)),2) AS average_conversion_rate
from table1 
````

|       | average_conversion_rate |
|-------|-------------------------|
|   1   |           0.76          |


## :pushpin: C. Campaigns Analysis


### Generate a table that has 1 single row for every unique visit_id record and has the following columns:

* user_id
* visit_id
* visit_start_time: the earliest event_time for each visit
* page_views: count of page views for each visit
* cart_adds: count of product cart add events for each visit
* purchase: 1/0 flag if a purchase event exists for each visit
* campaign_name: map the visit to a campaign if the visit_start_time falls between the start_date and end_date
* impression: count of ad impressions for each visit
* click: count of ad clicks for each visit
* (Optional column) cart_products: a comma separated text value with products added to the cart sorted by the order they were added to the cart (hint: use the sequence_number)
````sql
select 
	distinct user_id,
	visit_id,
	campaign_name,
	min(e.event_time) as min_event_time,
	count(e.page_id) as page_views_count,
	sum(case 
			when ei.event_name = 'Add to Cart' then 1 else 0 end) as count_cart_add,
	sum(case
	    	when ei.event_name = 'Purchase' then 1 else 0 end) as count_purchase,
	sum(case
	   		when ei.event_name = 'Ad Impression' then 1 else 0 end) as count_ad_impression,
	sum(case
	   		when ei.event_name = 'Ad Click' then 1 else 0 end) as count_ad_click,
	string_agg(case
			  	   when ph.product_id is not null and ei.event_name = 'Add to Cart' then ph.page_name else null end , 
			       ', ' order by e.sequence_number)
from users as u
left join events as e 
ON e.cookie_id = u.cookie_id
left join page_hierarchy as ph
ON ph.page_id = e.page_id
left join event_identifier as ei
ON ei.event_type = e.event_type
left join campaign_identifier as ci
ON e.event_time BETWEEN ci.start_date and ci.end_date
group by 1,2,3
order by 1 
````
|       | user_id | visit_id | campaign_name                      | min_event_time           | page_views_count | count_cart_add | count_purchase | count_ad_impression | count_ad_click | string_agg                                                |
|-------|---------|----------|------------------------------------|--------------------------|------------------|----------------|----------------|---------------------|----------------|-----------------------------------------------------------|
| 1     | 1       | "02a5d5"  | Half Off - Treat Your Shellf(ish) | 2020-02-26 16:57:26.260871 | 4                | 0              | 0              | 0                   | 0              |                                                           |
| 2     | 1       | "0826dc"  | Half Off - Treat Your Shellf(ish) | 2020-02-26 05:58:37.918618 | 1                | 0              | 0              | 0                   | 0              |                                                           |
| 3     | 1       | "0fc437"  | Half Off - Treat Your Shellf(ish) | 2020-02-04 17:49:49.602976 | 19               | 6              | 1              | 1                   | 1              | Tuna, Russian Caviar, Black Truffle, Abalone, Crab, Oyster |
| 4     | 1       | "30b94d"  | Half Off - Treat Your Shellf(ish) | 2020-03-15 13:12:54.023936 | 19               | 7              | 1              | 1                   | 1              | Salmon, Kingfish, Tuna, Russian Caviar, Abalone, Lobster, Crab |
| 5     | 1       | "41355d"  | Half Off - Treat Your Shellf(ish) | 2020-03-25 00:11:17.860655 | 7                | 1              | 0              | 0                   | 0              | Lobster                                                   |
| 6     | 1       | "ccf365"  | Half Off - Treat Your Shellf(ish) | 2020-02-04 19:16:09.182546 | 11               | 3              | 1              | 0                   | 0              | Lobster, Crab, Oyster                                     |
| 7     | 1       | "eaffde"  | Half Off - Treat Your Shellf(ish) | 2020-03-25 20:06:32.342989 | 21               | 8              | 1              | 1                   | 1              | Salmon, Tuna, Russian Caviar, Black Truffle, Abalone, Lobster, Crab, Oyster |
| 8     | 1       | "f7c798"  | Half Off - Treat Your Shellf(ish) | 2020-03-15 02:23:26.312543 | 13               | 3              | 1              | 0                   | 0              | Russian Caviar, Crab, Oyster                              |
| 9     | 2       | "0635fb"  | Half Off - Treat Your Shellf(ish) | 2020-02-16 06:42:42.73573  | 14               | 4              | 1              | 0                   | 0              | Salmon, Kingfish, Abalone, Crab                            |
| 10    | 2       | "1f1198"  | Half Off - Treat Your Shellf(ish) | 2020-02-01 21:51:55.078775 | 1                | 0              | 0              | 0                   | 0              |                                                           |
| 11    | 2       | "3b5871"  | 25% Off - Living The Lux Life    | 2020-01-18 10:16:32.158475 | 18               | 6              | 1              | 1                   | 1              | Salmon, Kingfish, Russian Caviar, Black Truffle, Lobster, Oyster |
* The first 11 lines of 3564 lines are shown


1. Identifying users who have received impressions during each campaign period and comparing each metric with other users who did not have an impression event.

(Her kampanya döneminde gösterim alan kullanıcıların belirlenmesi ve her bir metriğin gösterim olayı yaşamayan diğer kullanıcılarla karşılaştırılması)

````sql
with table1 as 
(
select 
	distinct user_id,
	visit_id,
	campaign_name,
	min(e.event_time) as min_event_time,
	count(e.page_id) as page_views_count,
	sum(case 
			when ei.event_name = 'Add to Cart' then 1 else 0 end) as count_cart_add,
	sum(case
	    	when ei.event_name = 'Purchase' then 1 else 0 end) as count_purchase,
	sum(case
	   		when ei.event_name = 'Ad Impression' then 1 else 0 end) as count_ad_impression,
	sum(case
	   		when ei.event_name = 'Ad Click' then 1 else 0 end) as count_ad_click,
	string_agg(case
			  	   when ph.product_id is not null and ei.event_name = 'Add to Cart' then ph.page_name else null end , 
			       ', ' order by e.sequence_number)
from users as u
left join events as e 
ON e.cookie_id = u.cookie_id
left join page_hierarchy as ph
ON ph.page_id = e.page_id
left join event_identifier as ei
ON ei.event_type = e.event_type
left join campaign_identifier as ci
ON e.event_time BETWEEN ci.start_date and ci.end_date
group by 1,2,3
order by 1 
)
select
    t1.user_id,
    t1.campaign_name,
    sum(case when t1.count_ad_impression > 0 then 1 else 0 end) as impression_received,
    count(distinct case when t1.count_ad_impression > 0 then t1.visit_id else null end) as distinct_visits_with_impression,
    sum(t1.page_views_count) as total_page_views,
    sum(t1.count_cart_add) as total_cart_add,
    sum(t1.count_purchase) as total_purchase,
    sum(case when t1.count_ad_impression > 0 then t1.count_ad_impression else 0 end) as total_ad_impressions_with_impression,
    sum(case when t1.count_ad_impression = 0 then t1.count_ad_impression else 0 end) as total_ad_impressions_without_impression,
    sum(t1.count_ad_click) as total_ad_click
from table1 t1
group by t1.user_id, 
		 t1.campaign_name
````

| index | user_id | campaign_name                   | impression_received | distinct_visits_with_impression | total_page_views | total_cart_add | total_purchase | total_ad_impressions_with_impression | total_ad_impressions_without_impression | total_ad_click |
|-------|---------|---------------------------------|---------------------|--------------------------------|------------------|----------------|----------------|-------------------------------------|----------------------------------------|---------------|
| 1     | 1       | Half Off - Treat Your Shellf(ish) | 3                   | 3                              | 95               | 28             | 5              | 3                                   | 0                                      | 3             |
| 2     | 2       | 25% Off - Living The Lux Life    | 1                   | 1                              | 40               | 12             | 2              | 1                                   | 0                                      | 1             |
| 3     | 2       | Half Off - Treat Your Shellf(ish) | 1                   | 1                              | 47               | 14             | 2              | 1                                   | 0                                      | 1             |
| 4     | 3       | Half Off - Treat Your Shellf(ish) | 0                   | 0                              | 21               | 4              | 2              | 0                                   | 0                                      | 0             |
| 5     | 3       |                                   | 3                   | 3                              | 94               | 30             | 4              | 3                                   | 0                                      | 3             |
| 6     | 4       | Half Off - Treat Your Shellf(ish) | 1                   | 1                              | 30               | 6              | 1              | 1                                   | 0                                      | 1             |
| 7     | 5       | Half Off - Treat Your Shellf(ish) | 1                   | 1                              | 55               | 17             | 1              | 1                                   | 0                                      | 1             |
| 8     | 6       | 25% Off - Living The Lux Life    | 0                   | 0                              | 14               | 3              | 1              | 0                                   | 0                                      | 0             |
| 9     | 6       | Half Off - Treat Your Shellf(ish) | 1                   | 1                              | 34               | 11             | 2              | 1                                   | 0                                      | 1             |
| 10    | 7       | Half Off - Treat Your Shellf(ish) | 1                   | 1                              | 41               | 9              | 3              | 1                                   | 0                                      | 0             |
| 11    | 7       |                                   | 1                   | 1                              | 42               | 11             | 3              | 1                                   | 0                                      | 1             |
* The first 11 lines of 895 lines are shown

2. Does clicking on an impression lead to higher purchase rates?

(Bir gösterime tıklamak daha yüksek satın alma oranlarına yol açıyor mu?)
````sql
with table1 as
(
select 
	distinct user_id,
	visit_id,
	campaign_name,
	min(e.event_time) as min_event_time,
	count(e.page_id) as page_views_count,
	sum(case 
			when ei.event_name = 'Add to Cart' then 1 else 0 end) as count_cart_add,
	sum(case
	    	when ei.event_name = 'Purchase' then 1 else 0 end) as count_purchase,
	sum(case
	   		when ei.event_name = 'Ad Impression' then 1 else 0 end) as count_ad_impression,
	sum(case
	   		when ei.event_name = 'Ad Click' then 1 else 0 end) as count_ad_click,
	string_agg(case
			  	   when ph.product_id is not null and ei.event_name = 'Add to Cart' then ph.page_name else null end , 
			       ', ' order by e.sequence_number)
from users as u
left join events as e 
ON e.cookie_id = u.cookie_id
left join page_hierarchy as ph
ON ph.page_id = e.page_id
left join event_identifier as ei
ON ei.event_type = e.event_type
left join campaign_identifier as ci
ON e.event_time BETWEEN ci.start_date and ci.end_date
group by 1,2,3
order by 1 
),
table2 as 
(
select 
	campaign_name,
	sum(count_ad_impression) as total_ad_impressions,
	sum(count_ad_click) as total_ad_click
from table1
group by 1
)
select 
	corr(total_ad_impressions, total_ad_click) as correlation_coeff
from table2
````
|       | correlation_coeff |
|-------|-------------------|
|   1   | 0.9999376947048757 |


3. What is the uplift in purchase rate when comparing users who click on a campaign impression versus users who do not receive an impression? What if we compare them with users who just an impression but do not click?

(Bir kampanya gösterimine tıklayan kullanıcılar ile gösterim almayan kullanıcılar karşılaştırıldığında satın alma oranındaki artış nedir? Peki ya onları sadece bir gösterim alan ancak tıklamayan kullanıcılarla karşılaştırırsak?)
````sql
with table1 as (
    select 
	distinct user_id,
	visit_id,
	campaign_name,
	min(e.event_time) as min_event_time,
	count(e.page_id) as page_views_count,
	sum(case 
			when ei.event_name = 'Add to Cart' then 1 else 0 end) as count_cart_add,
	sum(case
	    	when ei.event_name = 'Purchase' then 1 else 0 end) as count_purchase,
	sum(case
	   		when ei.event_name = 'Ad Impression' then 1 else 0 end) as count_ad_impression,
	sum(case
	   		when ei.event_name = 'Ad Click' then 1 else 0 end) as count_ad_click,
	string_agg(case
			  	   when ph.product_id is not null and ei.event_name = 'Add to Cart' then ph.page_name else null end , 
			       ', ' order by e.sequence_number)
from users as u
left join events as e 
ON e.cookie_id = u.cookie_id
left join page_hierarchy as ph
ON ph.page_id = e.page_id
left join event_identifier as ei
ON ei.event_type = e.event_type
left join campaign_identifier as ci
ON e.event_time BETWEEN ci.start_date and ci.end_date
group by 1,2,3
order by 1 
)
select
    t1.campaign_name,
    sum(case when t1.count_ad_click > 0 then t1.count_purchase else 0 end) as purchases_with_click,
    sum(case when t1.count_ad_click = 0 then t1.count_purchase else 0 end) as purchases_without_click,
    sum(t1.count_purchase) as total_purchases,
   
   (
	sum(case when t1.count_ad_click > 0 then t1.count_purchase else 0 end)::float / 
    sum(case when t1.count_ad_click = 0 then t1.count_purchase else 0 end)::float
   )
   as increase_ratio

from table1 t1
group by t1.campaign_name
````
|       | campaign_name                   | purchases_with_click | purchases_without_click | total_purchases | increase_ratio           |
|-------|---------------------------------|----------------------|-------------------------|----------------|-------------------------|
|       |                                 | 87                   | 181                     | 268            | 0.48066298342541436    |
| 1     | BOGOF - Fishing For Compliments | 50                   | 77                      | 127            | 0.6493506493506493     |
| 2     | Half Off - Treat Your Shellf(ish) | 416                  | 764                     | 1180           | 0.5445026178010471     |
| 3     | 25% Off - Living The Lux Life    | 71                   | 131                     | 202            | 0.5419847328244275     |


4. What metrics can you use to quantify the success or failure of each campaign compared to eachother?

(Her bir kampanyanın başarısını veya başarısızlığını diğerlerine kıyasla ölçmek için hangi metrikleri kullanabilirsiniz?)
````sql
/*

1. Click-Through Rate (CTR): This metric measures the percentage of people who clicked on an ad after seeing it. 
It's calculated by dividing the number of clicks by the number of impressions and multiplying by 100. Higher CTR indicates higher engagement.

2. Conversion Rate: This measures the percentage of users who took a desired action, such as making a purchase or signing up, 
after interacting with the campaign. It's calculated by dividing the number of conversions by the number of total interactions.

3. Return on Investment (ROI): ROI calculates the profitability of a campaign by comparing the revenue generated from the campaign 
to the costs of running it. It's expressed as a percentage and indicates how effective the campaign is in generating profit.

4. Cost per Conversion (CPC): This metric calculates the cost of each conversion. It's calculated by dividing the total cost of the 
campaign by the number of conversions. Lower CPC indicates more efficient spending.

5. Revenue per Impression: This metric measures how much revenue is generated on average per impression. It's calculated by 
dividing the total revenue by the total number of impressions.





1. Tıklama Oranı (CTR): Bu metrik, reklamı gördükten sonra tıklayan kişilerin yüzdesini ölçer. Tıklamaların izlenimlere bölünüp 
100 ile çarpılmasıyla hesaplanır. Daha yüksek CTR, daha yüksek etkileşimi gösterir.

2. Dönüşüm Oranı: Bu, kampanya ile etkileşimde bulunan kullanıcıların istenen bir eylemi 
(örneğin, satın alma veya kayıt olma) gerçekleştiren kullanıcıların yüzdesini ölçer. 
Dönüşümlerin toplam etkileşimlere bölünmesiyle hesaplanır.

3. Yatırım Getirisi (ROI): ROI, kampanyadan elde edilen geliri kampanyayı yürütmek için yapılan masraflarla karşılaştırarak 
kampanyanın karlılığını hesaplar. Yüzde olarak ifade edilir ve kampanyanın ne kadar etkili olduğunu gösterir.

4. Dönüşüm Başına Maliyet (CPC): Bu metrik her bir dönüşümün maliyetini hesaplar. Kampanyanın toplam maliyetini dönüşümlerin 
sayısına bölmek suretiyle hesaplanır. Daha düşük CPC, daha etkili harcama anlamına gelir.

5. İzlenim Başına Gelir: Bu metrik, her bir izlenim başına ortalama geliri ölçer. Toplam 
gelirin toplam izlenim sayısına bölünmesiyle hesaplanır.
*/
````
