# :heavy_check_mark: Case Study #3 Foodie-Fi
![Case Study 2 Image](https://8weeksqlchallenge.com/images/case-study-designs/3.png)

## :pushpin: A. Customer Journey

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

/*
İlk 8 müşterinin hareketlerini baz alınacak olursa;
İlk 3 müşteri, deneme sürecini tamamladıktan sonra aboneliğe geçerek hizmeti kullanmaya devam etmişlerdir. 
Bu müşterilerin deneme sürecinden sonra aboneliklere dönüşüm oranı olumlu görünmektedir.
4 ve 6 numaralı müşteriler, deneme sürecini tamamladıktan sonra aylık plana geçiş yapmışlardır. 
Ancak bu müşteriler, 3 aylık kullanımdan sonra aboneliklerini iptal etmişlerdir. 
Bu durum, aylık plana geçen müşterilerin uzun vadeli bağlılığını sağlamak için önlemler alınması gerektiğini göstermektedir.
5 numaralı müşteri, deneme sürecini tamamladıktan sonra aylık plana geçmiştir. 
Şu an için bu müşterinin aboneliğini sürdürdüğü bilgisi mevcut değildir.
7 ve 8 numaralı müşteriler, deneme sürecini tamamladıktan sonra aylık plana geçiş yapmışlardır. 
Bu müşteriler, aboneliklerini ortalama 2.5 ay sonra yükselterek daha üst düzey bir plana geçiş yapmışlardır. 
Bu durum, bazı müşterilerin hizmeti başlangıçta denemek ve ardından daha yüksek planlara geçmek isteyebileceğini göstermektedir.
Churn olan müşterileri tekrar kazanmak ve mevcut müşterileri geri kazanmak için kampanyalar ve fırsatlar sunulabilir. 
Örneğin, churn olan müşterilere özel indirimler veya hizmet geliştirmeleri sunularak geri dönüşümleri teşvik edilebilir. 
Aynı zamanda, mevcut müşterilere de sadakat programları veya plan yükseltme teklifleri gibi teşvikler sunularak bağlılıkları artırılabilir.
*/

 `````

## :pushpin: B. Data Analysis Questions

1. How many customers has Foodie-Fi ever had?

(Foodie-Fi'nin şimdiye kadar kaç müşterisi oldu?)
````sql
select count(distinct customer_id) as customer_count
from subscriptions 
 `````
2. What is the monthly distribution of trial plan start_date values for our dataset - use the start of the month as the group by value

(Veri kümemiz için deneme planı başlangıç_tarihi değerlerinin aylık dağılımı nedir - group by değeri olarak ayın başlangıcını kullanın)
````sql
select to_char(start_date,'Month') as start_month,
	   count(distinct customer_id) as count_customer
from subscriptions as sub
left join plans as p
ON p.plan_id = sub.plan_id
where p.plan_name = 'trial'
group by 1
order by 2 desc
 `````
3. What plan start_date values occur after the year 2020 for our dataset? Show the breakdown by count of events for each plan_name

(Veri setimiz için 2020 yılından sonra hangi plan başlangıç_tarihi değerleri ortaya çıkıyor? Her plan_adı için olay sayısına göre dağılımı gösterin)
````sql
select plan_name,
	   count(distinct customer_id) as customer_count
from subscriptions as sub
left join plans as p ON
p.plan_id = sub.plan_id
where start_date >= '2021-01-01'
group by 1
order by 2 desc
`````

4. What is the customer count and percentage of customers who have churned rounded to 1 decimal place?

(Müşteri sayısı ve kayıp müşterilerin 1 ondalık basamağa yuvarlanmış yüzdesi nedir?)
````sql
with table1 as 
(
select count(distinct customer_id) as total_customer_count,
	   (select count(distinct customer_id) as churn_customer_count
	    from subscriptions as sub 
		left join plans as p 
		ON sub.plan_id = p.plan_id 
		where p.plan_id = 4 )
from subscriptions as sub
left join plans as p ON
p.plan_id = sub.plan_id
)
select total_customer_count,
	   churn_customer_count,
	   round(100*churn_customer_count*1.0/total_customer_count*1.0,1) as churn_percentage
from table1
`````

5. How many customers have churned straight after their initial free trial - what percentage is this rounded to the nearest whole number?

(Kaç müşteri ilk ücretsiz denemeden hemen sonra vazgeçti - bu en yakın tam sayıya yuvarlanmış yüzde kaçtır?)
````sql
with ranking as 
(
select s.customer_id,  
       p.plan_id,
	   plan_name,
       row_number() over (partition by s.customer_id order by p.plan_id) as plan_rank 
from subscriptions as s
left join plans as p
ON s.plan_id = p.plan_id
) 
select count(customer_id) as churn_count,
       round(100 * count(customer_id) / (select count(distinct customer_id) from subscriptions), 0) as churn_percentage
from ranking
where plan_id = 4 
and plan_rank = 2
`````

6. What is the number and percentage of customer plans after their initial free trial?

(İlk ücretsiz denemelerinden sonra müşteri planlarının sayısı ve yüzdesi nedir?)
````sql
with table1 as 
(
select customer_id,
	   plan_name,
	   p.plan_id,
	   rank() over (partition by customer_id order by start_date) as rank
from subscriptions as sub
left join plans as p
ON p.plan_id = sub.plan_id
)
select 
	plan_name,
	count(distinct customer_id) as customer_count,
	ROUND((count(distinct customer_id)*1.0 /
	(select count(distinct customer_id) from subscriptions as sub left join plans as p ON p.plan_id = sub.plan_id where p.plan_name != 'churn')*1.0)*100,1)
    as customer_percentage
from table1 
where rank = 2
group by 1
order by customer_count desc
`````

7. What is the customer count and percentage breakdown of all 5 plan_name values at 2020-12-31?

(2020-12-31'de tüm 5 plan_adı değerinin müşteri sayısı ve yüzde dağılımı nedir?)
````sql
with table1 as 
(
select distinct customer_id,
	   p.plan_id,
	   start_date,
	   plan_name,
	   rank() over (partition by customer_id order by start_date desc)
from subscriptions as sub
left join plans as p 
ON p.plan_id = sub.plan_id
where start_date <= '2020-12-31'
)
select plan_name,
	   count(customer_id) as count_customer,
	   ROUND((count(customer_id)*1.0 /
	   (select count(distinct customer_id) from subscriptions as sub left join plans as p ON p.plan_id = sub.plan_id where p.plan_name != 'churn')*1.0)*100,1)
    as customer_percentage
from table1 as t1
where rank = 1
group by 1
order by 2 desc
`````

8. How many customers have upgraded to an annual plan in 2020?

(2020'de kaç müşteri yıllık plana geçiş yaptı?)
````sql
with table1 as 
(
select distinct customer_id,
	   p.plan_id,
	   start_date,
	   plan_name
from subscriptions as sub
left join plans as p
ON p.plan_id = sub.plan_id
where start_date between '2020-01-01' and '2020-12-30'
)
select count(distinct customer_id) as customer_count
from table1 
where plan_name = 'pro annual'
`````

9. How many days on average does it take for a customer to an annual plan from the day they join Foodie-Fi?

(Bir müşterinin Foodie-Fi'ye katıldığı günden itibaren yıllık plana geçmesi ortalama kaç gün sürüyor?)
````sql
with table_trial as
	(
select customer_id,
	   start_date as trial_start_date
from subscriptions as sub
left join plans as p
ON p.plan_id = sub.plan_id
where plan_name = 'trial'
	),
table_pro_annual as 
	(
select customer_id,
	   start_date as pro_annual_start_date
from subscriptions as sub
left join plans as p
ON p.plan_id = sub.plan_id
where plan_name = 'pro annual'
	)
select ROUND(AVG(pro_annual_start_date - trial_start_date),0) as avg_plan_time
from table_trial as tt
inner join table_pro_annual as tpa
ON tpa.customer_id = tt.customer_id
`````
10. Can you further breakdown this average value into 30 day periods (i.e. 0-30 days, 31-60 days etc)

(Bu ortalama değeri 30 günlük dönemlere ayırabilir misiniz (yani 0-30 gün, 31-60 gün vb.))
````sql
with table_trial as
	(
select customer_id,
	   start_date as trial_start_date
from subscriptions as sub
left join plans as p
ON p.plan_id = sub.plan_id
where plan_name = 'trial'
	),
table_pro_annual as 
	(
select customer_id,
	   start_date as pro_annual_start_date
from subscriptions as sub
left join plans as p
ON p.plan_id = sub.plan_id
where plan_name = 'pro annual'
	),
bins as 
(
select 
	width_bucket(table_pro_annual.pro_annual_start_date-table_trial.trial_start_date, 0, 365, 12) as wb
from table_trial 
inner join table_pro_annual
ON table_trial.customer_id = table_pro_annual.customer_id
)
select wb,
	   count(*) as num_customers
from bins 
group by wb
````

11. How many customers downgraded from a pro monthly to a basic monthly plan in 2020?

(2020'de kaç müşteri aylık profesyonel plandan aylık temel plana geçiş yaptı?)
````sql
with table_pro_monthly as
	(
select customer_id,
	   start_date as pro_monthly_start_date
from subscriptions as sub
left join plans as p
ON p.plan_id = sub.plan_id
where plan_name = 'pro monthly'
and start_date between '2020-01-01' and '2020-12-30'
	),
table_basic_monthly as 
	(
select customer_id,
	   start_date as basic_monthly_start_date
from subscriptions as sub
left join plans as p
ON p.plan_id = sub.plan_id
where plan_name = 'basic monthly'
and start_date between '2020-01-01' and '2020-12-30'
	)
select count(*) as count_customer
from table_pro_monthly as tpm
inner join table_basic_monthly as tbm
ON tpm.customer_id = tbm.customer_id
where tpm.pro_monthly_start_date - tbm.basic_monthly_start_date < 0
````

## :pushpin: C. Challenge Payment Question

1. The Foodie-Fi team wants you to create a new payments table for the year 2020 that includes amounts paid by each customer in the subscriptions table with the following requirements:

monthly payments always occur on the same day of month as the original start_date of any monthly paid plan
upgrades from basic to monthly or pro plans are reduced by the current paid amount in that month and start immediately
upgrades from pro monthly to pro annual are paid at the end of the current billing period and also starts at the end of the month period
once a customer churns they will no longer make payments

(Foodie-Fi ekibi, 2020 yılı için abonelikler tablosundaki her bir müşteri tarafından ödenen tutarları içeren ve aşağıdaki gereksinimleri karşılayan yeni bir ödeme tablosu oluşturmanızı istiyor:

Aylık ödemeler her zaman herhangi bir aylık ücretli planın orijinal başlangıç tarihi ile ayın aynı gününde gerçekleşir,
temel planlardan aylık veya profesyonel planlara yükseltmeler, o ay içinde ödenen mevcut tutar kadar azaltılır ve hemen başlar,
Pro aylıktan pro yıllığa yükseltmeler mevcut fatura döneminin sonunda ödenir ve ayrıca ay döneminin sonunda başlar,
bir müşteri bir kez churn olursa artık ödeme yapmayacaktır.)
````sql
with RECURSIVE table1 as 
	(
select customer_id,
	   p.plan_id,
	   start_date,
	   plan_name,
	   price,
	   lead(start_date,1) over (partition by customer_id order by start_date, sub.plan_id) as cutoff_date
from subscriptions as sub
left join plans as p
ON p.plan_id = sub.plan_id
where plan_name not in ('trial', 'churn')
and start_date between '2020-01-01' and '2020-12-31'
	),
table2 as 
	(
select customer_id,
	   plan_id,
	   start_date,
	   plan_name,
	   coalesce (cutoff_date, '2020-12-31') as cutoff_date,
	   price
from table1
	),
table3 as 
	(
select customer_id,
	   plan_id,
	   plan_name,
	   start_date,
	   cutoff_date,
	   price
from table2 
		
UNION ALL	

select customer_id,
	   plan_id,
	   plan_name,
	   (start_date + interval '1 month')::Date as start_date,
	   cutoff_date,
	   price
from table3
where cutoff_date > (start_date + interval '1 month')::Date
and plan_name != 'pro annual'
	),
table4 as 
	(
select *,
	   lag(plan_id, 1) over (partition by customer_id order by start_date) as last_payment_date,
	   lag(price, 1) over (partition by customer_id order by start_date) as last_price_num,
	   rank() over (partition by customer_id order by start_date) as order_price
from table3
order by customer_id,
		 start_date
	)
select customer_id, 
	   plan_id,
	   plan_name,
	   start_date as payment_date,
	   CASE 
	   		WHEN plan_id in (2,3) and last_payment_date = 1 then price - last_price_num
	   ELSE price
	   END 
	   as price,
	   order_price
from table4
````

## :pushpin: D. Outside The Box Questions

## 1. How would you calculate the rate of growth for Foodie-Fi?

(Foodie-Fi için büyüme oranını nasıl hesaplarsınız?)

````sql
-- growth ratio for pro monthly : 
with monthly_growth_pro_monthly as
(
select  
    plan_name,
    to_char(start_date, 'MM') as month,
    sum(price) as received_price
from subscriptions as sub
left join plans as p on p.plan_id = sub.plan_id
where plan_name = 'pro monthly'
and start_date between '2020-01-01' and '2020-12-31'
group by 1,2
order by 2   
)
select  plan_name,
        month,
        received_price,
        round(((received_price - LAG(received_price) OVER (ORDER BY month)) / LAG(received_price) OVER (ORDER BY month))*100,2) AS growth_ratio
from monthly_growth_pro_monthly


-- growth ratio for basic monthly :
with monthly_growth_basic_monthly as
(
select  
    plan_name,
    to_char(start_date, 'MM') as month,
    sum(price) as received_price
from subscriptions as sub
left join plans as p on p.plan_id = sub.plan_id
where plan_name = 'basic monthly'
and start_date between '2020-01-01' and '2020-12-31'
group by 1,2
order by 2   
)
select  plan_name,
        month,
        received_price,
        round(((received_price - LAG(received_price) OVER (ORDER BY month)) / LAG(received_price) OVER (ORDER BY month))*100,2) AS growth_ratio
from monthly_growth_basic_monthly


-- growth ratio for pro annual:
with monthly_growth_pro_annual as
(
select  
    plan_name,
    to_char(start_date, 'MM') as month,
    sum(price) as received_price
from subscriptions as sub
left join plans as p on p.plan_id = sub.plan_id
where plan_name = 'pro annual'
and start_date between '2020-01-01' and '2020-12-31'
group by 1,2
order by 2   
)
select  plan_name,
        month,
        received_price,
        round(((received_price - LAG(received_price) OVER (ORDER BY month)) / LAG(received_price) OVER (ORDER BY month))*100,2) AS growth_ratio
from monthly_growth_pro_annual



-- growth ratio for all plans:
with monthly_growth as
(
select  
    plan_name,
    to_char(start_date, 'MM') as month,
    sum(price) as received_price
from subscriptions as sub
left join plans as p on p.plan_id = sub.plan_id
where plan_name not in ('trial','churn')
and start_date between '2020-01-01' and '2020-12-31'
group by 1,2
order by 2   
)
select  plan_name,
        month,
        received_price,
        round(((received_price - LAG(received_price) OVER (ORDER BY month)) / LAG(received_price) OVER (ORDER BY month))*100,2) AS growth_ratio
from monthly_growth
````

## 2. What key metrics would you recommend Foodie-Fi management to track over time to assess performance of their overall business?

### (Foodie-Fi yönetimine, genel işlerinin performansını değerlendirmek için zaman içinde hangi temel ölçütleri takip etmelerini önerirsiniz?)

* MONTHLY RECURRING REVENUE (MRR):
	
	Aylık Yinelenen Gelir (MRR), abonelik tabanlı bir iş modeline sahip şirketler için önemli bir işletme metriğidir. 
	MRR, işletmelerin her ay almayı bekledikleri geliri gösterir ve bu nedenle öngörülebilir bir gelirdir. 
	Müşterilerinizin hizmetinizi ne kadar kullandığına ve her ay ödedikleri fiyata göre hesaplanır.
	
	MRR, genellikle iki şekilde hesaplanabilir:
	
	1- Müşteri Başına Gelirden: 
	Aylık yinelenen geliri hesaplamanın en kolay yöntemi, her müşteri için aylık yinelenen geliri belirlemektir. 
	İlk olarak, her müşterinin aylık gelirini hesaplıyoruz. Ardından müşterilerden elde ettiğimiz tüm gelirlerin toplamını buluyoruz2.
	
	2- Kişi Başına Ortalama Gelirden (ARPU) x toplam müşteri sayısı: 
	Örneğin, ARPU’nuz 50 ve 300 aylık müşteriniz varsa, MRR′niz 50 x 300 = 15.000 $ olacaktır.
	
	
* CHURN RATE:
	
	Yıpranma oranı olarak da bilinen kayıp oranı, müşterilerin belirli bir süre içinde bir şirketle iş yapmayı bırakma oranıdır. 
	En yaygın olarak, belirli bir süre içinde aboneliklerini sonlandıran hizmet abonelerinin yüzdesi olarak ifade edilir. 
	Aynı zamanda çalışanların belirli bir süre içinde işlerinden ayrılma oranıdır. 
	Bir şirketin müşteri portföyünü genişletebilmesi için büyüme oranının (yeni müşteri sayısıyla ölçülür) kayıp oranını aşması gerekir.

	İşten ayrılma oranını hesaplamak için aşağıdaki adımları takip edebilirsiniz2:

    1-Bir zaman aralığı belirleyin: aylık, yıllık veya üç aylık.
    2-Dönemin başında sahip olduğunuz müşteri sayısını belirleyin.
    3-Dönemin sonuna kadar ayrılan müşteri sayısını belirleyin.
    4-Kaybedilen müşteri sayısını, kayıptan önce sahip olduğunuz müşteri sayısına bölün.
    5-Bu sayıyı 100 ile çarpın.
	
	Örneğin; 
	işletmenizin ay başında 250 müşterisi varsa ve ay sonunda 10 müşteri kaybettiyseniz, 10'u 250'ye bölersiniz. 
	Cevap 0,04'tür. Daha sonra 0,04'ü 100 ile çarparsınız ve aylık %4 kayıp oranı elde edersiniz.
	
	
	
* CUSTOMER ACQUISITION COST (CAC):
 	
	Müşteri Edinme Maliyeti (CAC), bir şirketin yeni bir müşteri edinme sürecinde harcanacak olan toplam maliyetin hesaplanmasıdır. 
	Bu tahminlerin içerisinde; pazarlamacıların maaşı, reklam maliyetleri, satış elemanlarının maliyeti hesaplanır 
	ve kazanılan müşteri sayısına bölünerek sonuç elde edilir.

	CAC’nin hesaplanması oldukça basittir;
	Bir işletmenin belirli bir dönemdeki toplam satış ve pazarlama maliyetinin o dönemde kazanılan müşteri sayısına bölünmesiyle elde edilir. 
	CAC formülü şu şekildedir: CAC = (Satış Maliyeti + Pazarlama Maliyeti) / Yeni Müşteri Sayısı.

	CAC, işletmeler için önemli bir metriktir çünkü müşterilerini iyi tanımalı ve müşteri edinme maliyeti optimizasyonu stratejileri geliştirmelidir. 
	CAC maliyetlerinin düşürmeye başladığınızda ise reklam maliyetleriniz düşecektir. Buna bağlı olarak da yatırım gelirleriniz artar. 
	Sonuç olarak şirket karlılık oranı artacak ve daha fazla kazanç elde etmek mümkün olacaktır.
	
	
	
* CUSTOMER LIFETIME VALUE (CLV):

	Müşteri Yaşam Boyu Değeri (CLV), bir işletmenin müşterilerinden, kendilerinin veya kullanıcı hesaplarının müşteri olarak kaldığı sürece 
	elde edeceği toplam gelirin bir ölçüsüdür. CLV’yi ölçerken, müşteri tarafından elde edilen toplam ortalama gelire ve toplam ortalama kâra bakmak gerekir.

	CLV’yi hesaplamak için, geçmişteki müşteri yaşam boyu değerini (Historical CLV) kullanabilirsiniz. 
	Historical CLV, bir müşterinin geçmişteki tüm satın alımlarından elde edilen brüt karın toplamıdır. 
	Bunu hesaplamak için, son işlem (N) yaptığı tarihe kadar tüm brüt kar değerlerini toplamanız gerekir. 
	CLV’yi net kar üzerinden ölçerek, belirli bir müşterinin gerçek karını elde edebilirsiniz.

	CLV, işletmeler için önemli bir metriktir çünkü müşterilerini iyi tanımalı ve müşteri edinme maliyeti optimizasyonu stratejileri geliştirmelidir. 
	CLV maliyetlerinin düşürmeye başladığınızda ise reklam maliyetleriniz düşecektir. Buna bağlı olarak da yatırım gelirleriniz artar. 
	Sonuç olarak şirket karlılık oranı artacak ve daha fazla kazanç elde etmek mümkün olacaktır.
	
	Basit bir CLV formülü şu şekildedir: CLV = Müşteri Değeri x Ortalama Müşteri Ömrü.



* PLAN CONVERSION RATES:

	Plan conversion rate, bir işletmenin belirli bir planına abone olan müşterilerin yüzdesini ifade eder. 
	Örneğin, bir işletmenin 100 müşterisi varsa ve bunların 20’si “Pro” planına abone olmuşsa, “Pro” planının dönüşüm oranı %20’dir.

	Plan dönüşüm oranını hesaplamak için, belirli bir zaman aralığında belirli bir plana abone olan müşteri sayısını, toplam müşteri sayısına bölerek bulabilirsiniz. 
	Örneğin, bir ay boyunca 10 müşteri “Pro” planına abone olmuşsa ve toplam müşteri sayısı 50 ise, “Pro” planının aylık dönüşüm oranı %20’dir (10/50 = 0.2).

	Plan dönüşüm oranı, işletmeler için önemli bir metriktir çünkü hangi planların daha popüler olduğunu ve hangilerinin daha fazla müşteri çektiğini gösterir. 
	Bu metrik, işletmelerin pazarlama stratejilerini geliştirmelerine ve daha fazla müşteri kazanmalarına yardımcı olabilir.

	
	
* ENGAGEMENT METRICS:
	
	Etkileşim ölçümleri, kullanıcıların web siteniz, sosyal medya profilleriniz, uygulamanız, portalınız, yazılımınız veya içeriğiniz gibi medya 
	varlıklarınızla nasıl etkileşimde bulunduğunun göstergeleridir. 
	Bu metrikler, kullanıcıların çevrimiçi yayınladığınız içerikle nasıl ve ne kadar etkileşime girdiğini ölçer.
	
	Takip edilip analiz edilebilecek birçok etkileşim metriği vardır ve bunlar genellikle çeşitli isimlerle anılır. 
	Bazı yaygın etkileşim metrikleri arasında sayfa görüntülemeleri, oturum başına sayfa sayısı, ortalama oturum süresi, tekil ziyaretçiler, 
	hemen çıkma oranı, sayfada ortalama kalma süresi, sitede kalma süresi, trafik kaynağı, etkinlik takibi, dönüşüm oranı, kaydırma derinliği, 
	bekleme süresi ve terk etme oranı yer almaktadır.
	

* NET PROMOTER SCORE (NPS):

	Net Promoter Score (NPS), bir işletmenin müşterilerinin işletmeyi tavsiye etme olasılığını ölçen bir müşteri sadakati metriğidir. 
	NPS, müşterilerinize “Şirketimizi bir arkadaşınıza tavsiye etme ihtimaline 0 ila 10 arasında bir puan verecek olsaydınız, kaç puan verirdiniz?” 
	gibi bir soru sorarak hesaplanır.

	Müşterilerinizin verdiği yanıtlara göre, onları üç gruba ayırabilirsiniz:

	1- Destekçiler: 9 veya 10 puan veren müşteriler. Bu grup, işletmenizi başkalarına tavsiye etme olasılığı en yüksek olan müşterilerdir.
	2- Pasifler: 7 veya 8 puan veren müşteriler. Bu grup, işletmenizle ilgili nötr olan müşterilerdir.
	3- Kötüleyenler: 0 ile 6 arasında puan veren müşteriler. Bu grup, işletmenizi başkalarına tavsiye etme olasılığı en düşük olan müşterilerdir.
	
	NPS’yi hesaplamak için aşağıdaki formülü kullanabilirsiniz: NPS = (Destekçilerin Sayısı - Kötüleyenlerin Sayısı) / (Yanıtlayan Sayısı) x 100
	Bu formül ile elde edilen NPS değeri, -100 ile +100 arasında bir skorla gösterilir ve işletmenizin müşteri sadakatini ölçer.


## 3. What are some key customer journeys or experiences that you would analyse further to improve customer retention?

### (Müşteriyi elde tutmayı iyileştirmek için daha fazla analiz edeceğiniz bazı önemli müşteri yolculukları veya deneyimleri nelerdir?)

1- Müşteri ile ilk etkileşime geçme ve tanışma deneyiminin nasıl ve ne aracılığıyla olduğunu öğrenmek.
	
2- Hangi ürünlerin veya planların en popüler olduğu ve bunların kullanım sıklıkları, kullanılan planların ve içeriklerin 
hangi yaş grubuna, kesime, coğrafi bölgeye hitap ettiği Foodie-Fi için önemli unsurlar olabilir.
	   
3- Müşterilerden geri bildirim alarak süreçlerin iyileştirilmesi, müşterilerden gelen önerilere veya eleştirilere göre 
farklı içgörüler oluşturulması ve müşteri eğilimine göre aksiyon almak sorunları ortadan kaldırmak için önemli rol oynayabilir.
	   
4- Müşteri kayıp analizi yaparak müşterilerin ne oranda churn oldukları ve ne kadar sürede elde tutulduğunun bilinmesi ve ona göre aksiyon
   	   alınması çok önemlidir. Bu bilgiler ışığında kayıp edilmek üzere olan müşteriler veya diğer segmentler farklı aksiyon ve kampanyalarla
elde tutulabilir ve daha fazla getiri sağlayabilir.

## 4. If the Foodie-Fi team were to create an exit survey shown to customers who wish to cancel their subscription, what questions would you include in the survey?

### (Foodie-Fi ekibi, aboneliklerini iptal etmek isteyen müşterilere gösterilen bir çıkış anketi oluşturacak olsaydı, ankete hangi soruları dahil ederdiniz?)

1-Abonelik iptal nedeniniz nedir ? 
2-Abonelik iptalinizde fiyat faktörü önemli mi ?
3-Foodie Fi kullanımınız süresince teknik destek sorunuyla karşılaştınız mı ?
4-Tekrar abonelik düşünmek için beklentiniz nedir ?
5-Foodie Fi kullanımınıızı 1-5 arasında puanlasanız kaç verirsiniz ?

