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


