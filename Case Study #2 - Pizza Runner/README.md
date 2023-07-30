# :heavy_check_mark: Case Study #2 Pizza Runner

## CLEANED DATA - (customer_orders)

````sql
--CLEANED DATA (customer_orders)

  CREATE TABLE customer_orders_clean AS
SELECT * 
FROM customer_orders

UPDATE customer_orders_clean
SET exclusions =
    (CASE 
        WHEN exclusions = '' OR exclusions LIKE '%null%'
            THEN NULL 
        ELSE exclusions END)
    , extras = 
    (CASE 
        WHEN extras = '' OR extras LIKE '%null%' OR extras is NULL
            THEN NULL
        ELSE extras END)
		
		
	drop table customer_orders	
	
	alter table customer_orders_clean rename to customer_orders
  `````
## DATA CLEAN

````sql
CREATE TABLE runner_orders_clean AS
SELECT *
FROM runner_orders	

UPDATE runner_orders_clean
SET pickup_time = 
    (CASE 
        WHEN pickup_time LIKE '%null%' THEN NULL
        ELSE pickup_time END)
    , distance = 
    (CASE
        WHEN distance LIKE '%null%'
            THEN NULL
        WHEN distance LIKE '%km'
            THEN TRIM(distance, 'km')
        ELSE distance END)
    , duration = 
    (CASE 
        WHEN duration LIKE '%null%'
            THEN NULL
        WHEN duration LIKE '%minutes%'
            THEN TRIM(duration, 'minutes')
        WHEN duration LIKE '%mins%'
            THEN TRIM(duration, 'mins')
        WHEN duration LIKE '%minute%'
            THEN TRIM(duration, 'minute')
        ELSE duration END)
    , cancellation =
        (CASE 
            WHEN cancellation LIKE '%null' OR cancellation = ''
                THEN NULL
            ELSE cancellation END)
			
drop table runner_orders	

alter table runner_orders_clean rename to runner_orders
`````

## SOLUTIONS
## A. Pizza Metrics

1. How many pizzas were ordered?

(Kaç pizza sipariş edildi?)
````sql
select count(order_id) as ordered_pizza 
from customer_orders
`````
2. How many unique customer orders were made?

(Kaç adet benzersiz müşteri siparişi verildi?)
````sql
select count(distinct order_id) as unique_order 
from customer_orders
`````

3. How many successful orders were delivered by each runner?

(Her bir koşucu tarafından kaç başarılı sipariş teslim edildi?)
````sql
select
	runner_id,
count(distinct co.order_id) as count_order
from customer_orders as co
left join runner_orders as ro
ON ro.order_id = co.order_id
where ro.cancellation is null
group by 1
`````

4. How many of each type of pizza was delivered?

(Her pizza türünden kaç tane teslim edildi?)
````sql
select
	pizza_id,
count(co.order_id) as count_order
from customer_orders as co
left join runner_orders as ro
ON ro.order_id = co.order_id
where ro.cancellation is null
group by 1
`````


5. How many Vegetarian and Meatlovers were ordered by each customer?

(Her bir müşteri kaç Vejetaryen ve Meatlovers sipariş etti?)
````sql
select pizza_name,
	   customer_id,
	   count(pa.pizza_id) as count_pizza
from customer_orders as co
left join pizza_names as pa
ON pa.pizza_id = co.pizza_id
group by 1,2
`````

6. What was the maximum number of pizzas delivered in a single order?

(Tek bir siparişte teslim edilen maksimum pizza sayısı ne kadardı?)
````sql
with table1 as 
(
select co.order_id,
       count(co.order_id) as order_count
from customer_orders co
left join runner_orders as ro
ON co.order_id = ro.order_id
where cancellation is null
group by 1
order by order_count desc
)
select max(order_count)
from table1
`````

7. For each customer, how many delivered pizzas had at least 1 change and how many had no changes?

(Her bir müşteri için, teslim edilen pizzaların kaç tanesinde en az 1 değişiklik yapıldı ve kaç tanesinde değişiklik yapılmadı?)
````sql
select co.customer_id,
	   count(case when co.exclusions is not null or co.extras is not null then 'change' end) as change,
	   count(case when co.exclusions is null and co.extras is null then 'not change' end) as not_change
from customer_orders as co
left join runner_orders as ro
ON ro.order_id = co.order_id
where cancellation is null
group by 1
`````

8. How many pizzas were delivered that had both exclusions and extras?

(Hem istisnaları hem de ekstraları olan kaç pizza teslim edildi?)
````sql
select
	count(case when co.exclusions is not null and co.extras is not null then 'both' end) as both_change
from customer_orders as co
left join runner_orders as ro
ON ro.order_id = co.order_id
where cancellation is null 
`````

9. What was the total volume of pizzas ordered for each hour of the day?

(Günün her saati için sipariş edilen pizzaların toplam hacmi ne kadardı?)
````sql
select to_char(co.order_time, 'hh24') as hour_of_day,
	   count(co.order_id) as order_count
from customer_orders as co
group by 1
order by 2 desc
`````

10. What was the volume of orders for each day of the week?

(Haftanın her günü için sipariş hacmi ne kadardı?)
````sql
select to_char(co.order_time, 'day') as day_of_week,
	   count(co.order_id) as order_count
from customer_orders as co
group by 1
order by 2 desc
`````

## B. Runner and Customer Experience

1. How many runners signed up for each 1 week period? (i.e. week starts 2021-01-01)

(Her 1 haftalık dönem için kaç koşucu kaydoldu? (yani hafta 2021-01-01'de başlar))
````sql
select 
	to_char(registration_date, 'w') as weeks_
	count(runner_id),
from runners
group by 2
order by 2 
`````
