# :heavy_check_mark: Case Study #2 Pizza Runner

## CLEANED DATA (customer_orders)

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
## A. Pizza Metrics--

1 How many pizzas were ordered?

(Kaç pizza sipariş edildi?)

````sql
select count(order_id) as ordered_pizza 
from customer_orders
`````
