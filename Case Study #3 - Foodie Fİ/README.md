# :heavy_check_mark: Case Study #3 Foodie-Fi
![Case Study 2 Image](https://8weeksqlchallenge.com/images/case-study-designs/3.png)

## A. Customer Journey

1. Based off the 8 sample customers provided in the sample from the subscriptions table, write a brief description about each customer’s onboarding journey.
Try to keep it as short as possible - you may also want to run some sort of join to make your explanations a bit easier!

Abonelikler tablosundaki örnekte verilen 8 örnek müşteriyi temel alarak, her bir müşterinin ilk katılım yolculuğu hakkında kısa bir açıklama yazın.
Mümkün olduğunca kısa tutmaya çalışın - açıklamalarınızı biraz daha kolaylaştırmak için bir tür birleştirme yapmak da isteyebilirsiniz!)
````sql
select customer_id,
	   plan_name,
	   p.plan_id,
	   price,
	   start_date
from plans as p
left join subscriptions as sub
ON sub.plan_id = p.plan_id
order by customer_id 
limit 20
 `````
