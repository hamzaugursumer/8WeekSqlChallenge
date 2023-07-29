--1 Her bir müşterinin restoranda harcadığı toplam tutar nedir?

select * from sales
select * from members
select * from menu

select 
s.customer_id,
sum(price) as total_spent
from sales as s 
left join menu as m ON m.product_id = s.product_id
group by 1


--2 Her bir müşteri restoranı kaç gün ziyaret etmiştir?

select 
customer_id,
count(distinct order_date) as visit_count
from sales
group by 1 

--3 Her bir müşteri tarafından menüden satın alınan ilk ürün neydi?
select * from sales
select * from members
select * from menu

SELECT distinct s.customer_id, 
	   m.product_name, 
	   s.order_date
FROM sales AS s
LEFT JOIN menu AS m 
ON m.product_id = s.product_id
WHERE s.order_date = (SELECT MIN(order_date) FROM sales)
ORDER BY s.order_date;

--4 Menüde en çok satın alınan ürün nedir ve tüm müşteriler tarafından kaç kez satın alınmıştır?
select * from sales
select * from members
select * from menu
;

with table1 as (
select 
s.product_id,
count(s.product_id) as count_product
from sales as s
group by 1
order by count_product desc
			   )
select  
s.customer_id,
count(table1.count_product)
from table1
inner join sales as s
ON s.product_id = table1.product_id
where table1.product_id = 3
group by 1
;


select 
s.product_id,
m.product_name,
count(s.product_id) as count_product
from sales as s
left join menu as m ON m.product_id = s.product_id
group by 1,2
order by count_product desc
limit 1

--5 Her bir müşteri için en popüler ürün hangisiydi?
select * from sales
select * from members
select * from menu
;

WITH customer_product_counts AS (
  SELECT 
    s.customer_id,
    m.product_name,
    COUNT(*) AS order_count,
    RANK() OVER (PARTITION BY s.customer_id ORDER BY COUNT(*) DESC) AS rk
  FROM sales AS s
  INNER JOIN menu AS m ON s.product_id = m.product_id
  GROUP BY s.customer_id, m.product_name
)
SELECT customer_id, 
	   product_name, 
	   order_count
FROM customer_product_counts
WHERE rk = 1;

--6 Müşteri üye olduktan sonra ilk olarak hangi ürünü satın aldı?

select * from sales
select * from members
select * from menu
;

with table1 as(
select s.customer_id,
	   s.order_date,
	   m.join_date,
	   menu.product_name,
	   rank() OVER (PARTITION BY s.customer_id ORDER BY s.order_date) AS rank_
from sales as s
left join members as m ON m.customer_id = s.customer_id
left join menu ON menu.product_id = s.product_id
where join_date is not null
and join_date <= order_date
	)
select *
from table1
where rank_ = 1

--7 Müşteri üye olmadan hemen önce hangi ürünü satın aldı?
select * from sales as s
left join members as m
ON m.customer_id = s.customer_id
left join menu as mm 
ON mm.product_id = s.product_id
where join_date is not null

with table1 as (
select s.customer_id,
	   s.order_date,
	   m.join_date,
	   menu.product_name,
	   rank() over(partition by s.customer_id order by s.order_date desc) as rank_
from sales as s
left join members as m ON m.customer_id = s.customer_id
left join menu ON menu.product_id = s.product_id
where join_date is not null 
and join_date > order_date
			)
select * 
from table1
where rank_ = 1

--8 Üye olmadan önce her bir üye için toplam ürün ve harcanan miktar nedir?

select * from sales as s
left join members as m
ON m.customer_id = s.customer_id
left join menu as mm 
ON mm.product_id = s.product_id;


with table1 as (
select s.customer_id,
	   s.order_date,
	   m.join_date,
	   mm.product_name,
	   mm.price
from sales as s
left join members as m
ON m.customer_id = s.customer_id
left join menu as mm 
ON mm.product_id = s.product_id
where s.order_date < join_date 
)
select customer_id,
	   sum(price) as total_spend,
	   count(*) as count_product
from table1
group by 1


--9 Harcanan her 1 dolar 10 puana eşitse ve suşi 2 kat puan çarpanına sahipse - her müşterinin kaç puanı olur?

with table1 as 
(
select s.customer_id,
	   mm.product_name,
	   mm.price,
	   case when mm.product_name = 'sushi' then price*20 else price*10 end as customer_point,
	   case when mm.product_name = 'sushi' then price*2 else price*1 end as customer_spent
from sales as s
left join members as m
ON m.customer_id = s.customer_id
left join menu as mm 
ON mm.product_id = s.product_id
)
select 
customer_id,
sum(customer_point) as total_point,
sum(customer_spent) as customer_total_spent
from table1 
group by 1
;


--10 Bir müşteri programa katıldıktan sonraki ilk hafta (katılım tarihleri de dahil olmak üzere) 
--sadece suşi değil, tüm ürünlerde 2 kat puan kazanır - A ve B müşterilerinin Ocak ayı sonunda kaç puanları vardır?

with table1 as (
select s.customer_id,
	   s.order_date,
	   m.join_date,
	   case
           when s.order_date < m.join_date + interval '1 week' then price*20
           when mm.product_name = 'sushi' then price*20 else price*10 end as total_point
from sales as s
left join members as m
ON m.customer_id = s.customer_id
left join menu as mm 
ON mm.product_id = s.product_id
where order_date >= join_date 
)
select customer_id,
	   sum(total_point) as total_point
from table1
where order_date between '2021-01-01' and '2021-01-31'
group by 1


-- Bonus Question 1 :

with table1 as (
select s.customer_id,
	   s.order_date,
	   m.join_date,
	   mm.product_name,
	   mm.price,
	   case when s.order_date >= m.join_date then 'Y' else 'N' end as member
from sales as s
left join members as m
ON m.customer_id = s.customer_id
left join menu as mm 
ON mm.product_id = s.product_id
			  	)
select  customer_id,
	    order_date,
		join_date,
		product_name price,
		member
from table1

-- Bonus Question 2 :

WITH table1 AS (
SELECT s.customer_id,
	   s.order_date,
	   m.join_date,
	   mm.product_name,
	   mm.price,
	   CASE WHEN s.order_date >= m.join_date THEN 'Y' ELSE 'N' END AS member
FROM sales AS s
LEFT JOIN members AS m
	ON m.customer_id = s.customer_id
LEFT JOIN menu AS mm 
	ON mm.product_id = s.product_id
)
SELECT customer_id,
	   order_date,
	   join_date,
	   product_name,
	   price,
	   member,
	   CASE WHEN member = 'N' THEN NULL ELSE 
	   	  RANK() OVER (PARTITION BY customer_id,member ORDER BY order_date) END AS ranking
FROM table1
;


