# :heavy_check_mark: Case Study #4 Data Bank
![Case Study 2 Image](https://8weeksqlchallenge.com/images/case-study-designs/4.png)

## :pushpin: A. Customer Nodes Exploration

1. How many unique nodes are there on the Data Bank system?

(Veri Bankası sisteminde kaç tane benzersiz düğüm vardır?)
````sql
select 
	count(distinct node_id) as node_count
from customer_nodes
````

2. What is the number of nodes per region?

(Bölge başına düğüm sayısı nedir?)
````sql
select 
	   count(node_id) as node_count,
	   r.region_name
from regions as r
left join customer_nodes as cn
ON r.region_id = cn.region_id
group by 2 
order by 1 desc
````

3. How many customers are allocated to each region?

(Her bölgeye kaç müşteri tahsis edilmiştir?)
````sql
select 
	   count(distinct customer_id) as customer_count,
	   r.region_name
from regions as r
left join customer_nodes as cn
ON r.region_id = cn.region_id
group by 2 
order by 1 desc  
````

4. How many days on average are customers reallocated to a different node?

(Müşteriler ortalama kaç günde farklı bir düğüme yeniden tahsis ediliyor?)
````sql
with table1 as 
(
select customer_id,
	   end_date, 
	   start_date,
	   end_date - start_date as date_diff
from customer_nodes
WHERE start_date != '9999-12-31' AND end_date != '9999-12-31'
)
select 
		round(avg(date_diff),0) as avg_date_diff
from table1
````  

5. What is the median, 80th and 95th percentile for this same reallocation days metric for each region?

(Her bir bölge için aynı yeniden tahsis günleri metriği için medyan, 80. ve 95. yüzdelik dilimler nedir?)
````sql  
with table1 as
(
select region_name,
	   end_date,
	   start_date,
	   end_date - start_date as date_diff
from customer_nodes as cn
left join regions as r
ON r.region_id = cn.region_id
WHERE start_date != '9999-12-31' AND end_date != '9999-12-31'
)
select region_name,
	   percentile_cont(0.5) WITHIN GROUP (ORDER BY date_diff) as median,
	   percentile_cont(0.8) WITHIN GROUP (ORDER BY date_diff) as percentile_80,
	   percentile_cont(0.95) WITHIN GROUP (ORDER BY date_diff) as percentile_95
from table1 
group by 1
````

## :pushpin: B. Customer Transactions

1. What is the unique count and total amount for each transaction type?

(Her bir işlem türü için benzersiz sayı ve toplam tutar nedir?)
````sql
select txn_type,
	   count(distinct customer_id) as transaction_count,
	   sum(txn_amount) as total_amount
from customer_transactions
group by 1
````

2. What is the average total historical deposit counts and amounts for all customers?

(Tüm müşteriler için ortalama toplam geçmiş mevduat sayıları ve tutarları nedir?)
````sql
with table1 as 
(
select distinct customer_id,
	   round(sum(txn_amount),1) as avg_total_amount1,
	   count(customer_id) as deposit_count
from customer_transactions
where txn_type = 'deposit'
group by 1
order by 1 
)
select  round(avg(avg_total_amount1),1) as avg_total_amount,
		round(avg(deposit_count),0) as avg_deposit_count
from table1 
````

3. For each month - how many Data Bank customers make more than 1 deposit and either 1 purchase or 1 withdrawal in a single month?

(Her ay için - kaç Data Bank müşterisi tek bir ay içinde 1'den fazla para yatırma ve 1 satın alma veya 1 para çekme işlemi gerçekleştiriyor?)
````sql
with table1 as 
(
select 
	   distinct customer_id,
	   to_char(txn_date, 'MONTH') as months,
	   count(case when txn_type = 'deposit' then 1 end) as deposite_type_count,
	   count(case when txn_type = 'purchase' then 1 end) as purchase_type_count,
	   count(case when txn_type = 'withdrawal' then 1 end) as withdrawal_type_count
from customer_transactions as cn
group by 1,2
)
select months,
	   count(customer_id) as customer_count
from table1
where deposite_type_count > 1 
and (purchase_type_count >= 1 or withdrawal_type_count >=1)
group by 1
````

4. What is the closing balance for each customer at the end of the month?

(Ay sonunda her bir müşteri için kapanış bakiyesi nedir?)
````sql
with table1 as 
(
select distinct customer_id,
	   to_char(txn_date, 'MM') as months,
	   sum(case 
		   when txn_type = 'deposit' then txn_amount
		   						     else -txn_amount end) as net_transaction_amount
from customer_transactions as ct
group by 1,2
order by 1
)
select customer_id,
	   months,
	   net_transaction_amount,
	   sum(net_transaction_amount) over (partition by customer_id order by months) as closing_balance
from table1
````

5. What is the percentage of customers who increase their closing balance by more than 5% ?

(Kapanış bakiyesini %5'ten fazla artıran müşterilerin yüzdesi nedir?)
````sql
-- Müşterinin maksimum ve minimum kapanış bakiyesine göre ;
with table1 as 
(
select distinct customer_id,
       to_char(txn_date, 'mm') as months,
       sum(case 
           when txn_type = 'deposit' then txn_amount
                                     else -txn_amount end) as net_transaction_amount
from customer_transactions as ct
group by 1,2
order by 1
),

table2 as (
select customer_id,
       months,
       sum(net_transaction_amount) over (partition by customer_id order by months) as closing_balance
from table1
),

table3 as (
select customer_id,
       max(closing_balance) as max_closing_balance,
       min(closing_balance) as min_closing_balance
from table2
group by 1
)

select round(avg(case when min_closing_balance <> 0 and (max_closing_balance - min_closing_balance) / 
                 min_closing_balance > 0.05 then 1 else 0 end) * 100,2) as percentage_of_customers
from table3




-- Müşterinin kapanış bakiyesinin pozitif olduğu ve bir önceki kapanışına göre ;
with table1 as 
(
select distinct customer_id,
       to_char(txn_date, 'MM') as months,
       sum(case 
           when txn_type = 'deposit' then txn_amount
                                     else -txn_amount end) as net_transaction_amount
from customer_transactions as ct
group by 1,2
order by 1
),

table2 as 
(
select customer_id,
       months,
       sum(net_transaction_amount) over (partition by customer_id order by months) as closing_balance
from table1    
),

table3 as 
(
select customer_id,
       months,
       closing_balance
from table2
where closing_balance > 0    
),

table4 as 
(
select customer_id,
       months,
       closing_balance,
       lag(closing_balance) over (partition by customer_id order by months) as prev_closing_balance
from table3
),

table5 as 
(
select customer_id,
       months,
       closing_balance,
       case
           when prev_closing_balance = 0 then null
           else (closing_balance - prev_closing_balance) / prev_closing_balance * 100
       end as percent_change
from table4
)
select round(count(customer_id) * 100.0 / (select count(customer_id) from table5),2) as percent_of_customers
from table5
where percent_change > 5
````

## :pushpin: C. Data Allocation Challenge
````sql
-- müşterilerin aylık hareketleri ;

select customer_id,
       txn_date,
	   to_char(txn_date, 'Month') as months,
       txn_type,
       txn_amount,
       sum(
	   case when txn_type = 'deposit' then txn_amount
			else -txn_amount
	    	end) over(partition by customer_id order by txn_date) as running_balance
from customer_transactions;




--  Her müşteri ve ay için bakiyenin son değeri ; 


select customer_id,
       to_char(txn_date, 'MM') as months,
       to_char(txn_date, 'Month') as month_name,
       sum(
	   case when txn_type = 'deposit' then txn_amount
			else - txn_amount
	   		end) as closing_balance
from customer_transactions
group by customer_id, to_char(txn_date, 'MM'), to_char(txn_date, 'Month')
order by 1 




-- Her müşteri için bakiyenin max, min ve ortalama değerleri ; 

with table1 as 
	(
select customer_id,
       txn_date,
	   txn_type,
	   txn_amount,
       sum(
	   case when txn_type = 'deposit' then txn_amount
			else - txn_amount
	   		end) over (partition by customer_id order by txn_date) as running_balance
from customer_transactions
order by 1 
	)
select customer_id,
	  round(avg(running_balance),1) AS avg_running_balance,
      round(min(running_balance),1) AS min_running_balance,
      round(max(running_balance),1) AS max_running_balance
from table1
group by 1
````
## :pushpin: Options:

````sql
-- Option 1:

with transaction_amt_cte as
  (
select customer_id,
       txn_date,
       txn_type,
       txn_amount,
       to_char(txn_date, 'MM') as txn_month,
       sum(case
           when txn_type='deposit' then txn_amount
           else -txn_amount
           end) as net_transaction_amt
from customer_transactions
group by customer_id,
         txn_date,
         txn_type,
         txn_amount
order by customer_id,
         txn_date
  ),
running_customer_balance_cte as
  (
select customer_id,
       txn_date,
       txn_month,
       txn_type,
       txn_amount,
       sum(net_transaction_amt) over(partition by customer_id order by txn_month ) as running_customer_balance
from transaction_amt_cte
  ),
month_end_balance_cte as
  (
select distinct customer_id,
       txn_month,
       last_value(running_customer_balance) over (partition by customer_id, txn_month order by txn_month) as month_and_balance
from running_customer_balance_cte
  ),
customer_month_final_balance_cte as 
  (
select customer_id,
	   txn_month,
	   month_and_balance
from month_end_balance_cte
  )
select txn_month,
 	   sum(month_and_balance) as sum_month_and_balance
from customer_month_final_balance_cte
group by txn_month
order by txn_month



-- Option 2:

with transaction_amt_cte as
(
	select customer_id,
           date_trunc('Month',txn_date) as txn_month,
	       sum(
		   case 
			   	when txn_type = 'deposit' then txn_amount
		        else -txn_amount
		    	end) as net_transaction_amt
	from customer_transactions
	group by customer_id, date_trunc('Month',txn_date)
),

running_customer_balance_cte as
(
	select customer_id,
	       txn_month,
	       net_transaction_amt,
	       sum(net_transaction_amt) over(partition by customer_id order by txn_month) as running_customer_balance
	from transaction_amt_cte
),

avg_running_customer_balance as
(
	select customer_id,
	       avg(running_customer_balance) as avg_running_customer_balance
	from running_customer_balance_cte
	group by customer_id
)

select txn_month,
       round(sum(avg_running_customer_balance), 0) as data_required_per_month
from running_customer_balance_cte r
join avg_running_customer_balance a
on r.customer_id = a.customer_id
group by txn_month
order by data_required_per_month


-- Option 3:

with transaction_amt_cte as
(
	select customer_id,
	       txn_date,
	       extract(month from txn_date) as txn_month,
	       txn_type,
	       txn_amount,
	       case 
				when txn_type = 'deposit' then txn_amount else -txn_amount end as net_transaction_amt
	from customer_transactions
),

running_customer_balance_cte as
(
	select customer_id,
	       txn_month,
	       sum(net_transaction_amt) over (partition by customer_id order by txn_month) as running_customer_balance
	from transaction_amt_cte
)

select txn_month,
       sum(running_customer_balance) as data_required_per_month
from running_customer_balance_cte
group by txn_month
order by txn_month
````

## :pushpin: D. Extra Challenge

1. Interest calculation
(Faiz Hesaplama)

````sql
with table1 as
(
	select customer_id,
	       txn_date,
	       sum(txn_amount) as total_data,
	       date_trunc('month', txn_date) as month_start_date,
	       extract(day from txn_date - date_trunc('month', txn_date)) + 1 as days_in_month,
	       cast(sum(txn_amount) as decimal(18, 2)) * power((1 + 0.06/365), extract(day from age(txn_date, '1900-01-01'::date))) as daily_interest_data
	from customer_transactions
	group by customer_id, 
			 txn_date
)

select customer_id,
       date_trunc('month', month_start_date) as txn_month,
       round(sum(daily_interest_data * days_in_month), 2) as data_required
from table1
group by customer_id, date_trunc('month', month_start_date)
order by data_required desc
````





