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
