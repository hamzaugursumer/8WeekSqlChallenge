Case Study Questions

A. Data Exploration and Cleansing

1. Update the fresh_segments.interest_metrics table by modifying the month_year column to be a date data type with the start of the month

(month_year sütununu ayın başlangıcını içeren bir tarih veri türü olacak şekilde değiştirerek fresh_segments.interest_metrics tablosunu güncelleyin)


ALTER TABLE interest_metrics
ALTER COLUMN month_year TYPE DATE USING TO_DATE(month_year || '-01', 'MM-YYYY-DD');


2. What is count of records in the fresh_segments.interest_metrics for each month_year value sorted in chronological order 
(earliest to latest) with the null values appearing first?

(fresh_segments.interest_metrics dosyasında kronolojik sıraya göre (en eskiden en yeniye) sıralanmış her ay_yıl değeri 
için kayıt sayısı kaçtır ve null değerler önce görünür?)


select 
	month_year,
	count(*) as count_month_year
from interest_metrics
group by 1
order by month_year NULLS FIRST

"month_year"	"count_month_year"
[null]	        1194
"2018-07-01"	729
"2018-08-01"	767
"2018-09-01"	780
"2018-10-01"	857
"2018-11-01"	928
"2018-12-01"	995
"2019-01-01"	973
"2019-02-01"	1121
"2019-03-01"	1136
"2019-04-01"	1099
"2019-05-01"	857
"2019-06-01"	824
"2019-07-01"	864
"2019-08-01"	1149


3. What do you think we should do with these null values in the fresh_segments.interest_metrics

(fresh_segments.interest_metrics dosyasındaki bu null değerlerle ne yapmamız gerektiğini düşünüyorsunuz?)

select 
	round(sum(case 
			when interest_id is null then 1 else 0 end) * 1.0 / count(*) * 100, 2) as null_percentage
from interest_metrics

"null_percentage"
	8.36

Eksik değerlerle başa çıkmak için bazı olası yaklaşımlar ;
1. Eksik Değerleri Doldurma (Imputation).
2. Eksik Veri Analizi ve Tahmin Edici Modeller.
3. Null Değerleri Bir Kategori Olarak İşaretleme.
4. Eksik Verileri Dışlama.
5. Birleştirme ve Haritalama.
6. Uyarı ve İzleme - Eksik verileri analiz yaparken dikkate alın ve sonuçları değerlendirirken eksik verilerin potansiyel etkilerini göz önünde bulundurun. 

interest_metrics tablosunda, bazı alanlarda (örneğin _month, _year, month_year ve interest_id) eksik veya boş değerler gözlenmektedir. 
Bu eksik değerler, tarih ve ilgi alanı bilgilerinin tam olarak mevcut olmadığı durumlarda ortaya çıkabilir. 
Diğer taraftan, composition, index_value, ranking ve percentile_ranking alanlarındaki veriler, ilgi alanı ve 
tarih hakkında daha fazla ayrıntıya dayanmadan anlamlı sonuçlar üretemeyebilir.
Öncelikle, tablodaki eksik değerlerin yüzdesini belirlemek, veri bütünlüğünü değerlendirmek için önemlidir. 
Bu analiz, eksik değerlerin tablodaki genel durumunu anlamada rehberlik edebilir. Bu değerlendirme sonucunda, 
eksik değerlerin tablodaki toplam kayıt sayısına göre %10 dan az olduğu tespit edilmiştir.

Eksik değerlerin oranının düşük olması ve analizlerinizi daha sağlam hale getirmek amacıyla, bu eksik değerleri çıkarmak iyi bir yaklaşım olabilir. 
Bu sayede, analiz sonuçlarınızın güvenilirliğini artırarak, daha kesin ve anlamlı sonuçlara ulaşabilirsiniz. 
Bu yaklaşım, eksik veri yönetimi konusunda daha iyi bir veri kalitesi sağlamak için uygun bir adımdır.

DELETE FROM interest_metrics
WHERE interest_id IS NULL

select 
	round(sum(case 
			when interest_id is null then 1 else 0 end) * 1.0 / count(*) * 100, 2) as null_percentage
from interest_metrics

"null_percentage"
	0.00


4. How many interest_id values exist in the fresh_segments.interest_metrics table but not in the fresh_segments.interest_map table? 
What about the other way around?

(fresh_segments.interest_metrics tablosunda olup da fresh_segments.interest_map tablosunda olmayan kaç tane interest_id değeri var? Peki ya tam tersi?)

select 
	count(distinct inmap.id) as distinct_id_count,
	count(distinct im.interest_id) as distinct_metrics_id_count,
	sum(case 
			when inmap.id is NULL then 1 else 0 end) AS not_in_metric,
    sum(case 
			when im.interest_id is NULL then 1 else 0 end) AS not_in_map
from interest_metrics as im
full outer join interest_map as inmap 
ON inmap.id = im.interest_id::integer


5. Summarise the id values in the fresh_segments.interest_map by its total record count in this table

(interest_map teki kimlik değerlerini bu tablodaki toplam kayıt sayısına göre özetleyin)

select 
	count(distinct id) as distinct_id,
	count(*) as total_record
from interest_map as im
left join interest_metrics as metric
ON metric.interest_id::integer = im.id


6. What sort of table join should we perform for our analysis and why? Check your logic by checking the rows where interest_id = 21246 in your 
joined output and include all columns from fresh_segments.interest_metrics and all columns from fresh_segments.interest_map except from the id column.

(Analizimiz için ne tür bir tablo birleştirme gerçekleştirmeliyiz ve neden? Birleştirilmiş çıktınızda interest_id = 21246 
 olan satırları kontrol ederek mantığınızı kontrol edin ve fresh_segments.interest_metrics'teki tüm 
sütunları ve id sütunu hariç fresh_segments.interest_map'teki tüm sütunları dahil edin.)

select 
*
from interest_map as im
left join interest_metrics as metric
ON metric.interest_id::integer = im.id
where metric.interest_id::integer = 21246

-- left join veya inner join kullanılabilir. Sadece ortak alanlar veya fromdan sonra yazılan tablonun tamamı görüntülenmek istenebilir. 
-- Id ler üzerinden gerçekleştirilen join işleminde 21246 Idli kişinin bütün bilgileri gelmiş oldu.

7. Are there any records in your joined table where the month_year value is before the created_at value from 
the fresh_segments.interest_map table? Do you think these values are valid and why?

(Birleştirilmiş tablonuzda, month_year değerinin fresh_segments.interest_map tablosundaki created_at değerinden önce olduğu herhangi bir 
kayıt var mı? Bu değerlerin geçerli olduğunu düşünüyor musunuz ve neden?)

select 
id,
month_year,
created_at,
interest_name
from interest_map as im
left join interest_metrics as metric
ON metric.interest_id::integer = im.id
where month_year < created_at
order by 1

-- 188 tane kayıt bulunmaktadır ve bu değerler geçerlidir. Çünkü month_year alanı için yapılan ön işlemde ayın ilk günü için bir işlem yapılmıstır.
-- müşteri o ay için de created at tarihi için sonra da işlem gerçekleştirmiş olabilir ve bunu veriye göre bilemeyebiliriz.



B. Interest Analysis

1. Which interests have been present in all month_year dates in our dataset?

(Veri setimizdeki tüm ay_yıl tarihlerinde hangi ilgi alanları mevcuttu?)

select 
	count(distinct month_year) as unique_month_year,
	count(distinct interest_id) as unique_interest_id
from interest_map as im
left join interest_metrics as metric
ON metric.interest_id::integer = im.id

select 
	distinct month_year,
	count(distinct interest_id) as count_interest
from interest_map as im
left join interest_metrics as metric
ON metric.interest_id::integer = im.id
where month_year is not null
group by 1


2. Using this same total_months measure - calculate the cumulative percentage of all records starting at 14 
months - which total_months value passes the 90% cumulative percentage value?

(Aynı total_months hesaplamasını kullanarak - 14 aydan başlayarak tüm kayıtların kümülatif yüzdesini hesaplayın - 
hangi total_months değeri %90 kümülatif yüzde değerini geçer?)


with
table1 as
(
select 
	interest_name,
	count(distinct month_year) as count_month_year
from interest_map as im
left join interest_metrics as metric
ON metric.interest_id::integer = im.id
where interest_id is not null
group by 1
order by 2
),
table2 as 
(
select  
	count_month_year,
	count(distinct interest_name) as interest_count
from table1
group by 1
),
table3 as 
(
select 
	count_month_year,
	interest_count,
	sum(interest_count) over (order by count_month_year desc) as cumulative_sum,
	(
		select 
			count(distinct interest_name) 
		from interest_map as im
		left join interest_metrics as metric
		ON metric.interest_id::integer = im.id
		where interest_id is not null
	) as total_interest_count

from table2
)
select 
	*,
	round((cumulative_sum / total_interest_count)*100,2) as cumulative_percentage
from table3
where round((cumulative_sum / total_interest_count)*100,2) > 90


3. If we were to remove all interest_id values which are lower than the total_months value we found in the 
previous question - how many total data points would we be removing?

(Önceki soruda bulduğumuz total_months değerinden daha düşük olan tüm interest_id değerlerini kaldıracak olsaydık - toplam kaç veri noktasını kaldırmış olurduk?)

with 
table1 as 
(
select 
	interest_name,
	count(distinct month_year) as count_month_year
from interest_metrics as im
left join interest_map as inmap
ON inmap.id = im.interest_id::integer
group by 1
)
select 
	sum(count_month_year) total_month_year
from table1
where count_month_year in (5,4,3,2,1)



4. Does this decision make sense to remove these data points from a business perspective? Use an example where there are all 14 
months present to a removed interest example for your arguments - think about what it means to have less

(İş perspektifinden bakıldığında bu veri noktalarını kaldırma kararı mantıklı mı? Argümanlarınız için kaldırılmış bir faiz örneğinde 14 
ayın tamamının mevcut olduğu bir örnek kullanın - daha azına sahip olmanın ne anlama geldiğini düşünün)

with 
month_counts as 
(
    select 
		interest_name, 
		count(distinct month_year) as month_count
    from interest_metrics as im
	left join interest_map as inmap
	ON inmap.id = im.interest_id::integer
    group by interest_name
    having count(distinct month_year) < 6
),
removed as 
(
    select 
		im.month_year, 
		count(*) as removed_interest
    from interest_metrics as im
	left join interest_map as inmap
	ON inmap.id = im.interest_id::integer
    where inmap.interest_name in (select interest_name from month_counts) 
    group by im.month_year
),
not_removed as 
(
    select 
		im.month_year, 
		count(*) as not_removed_interest
    from interest_metrics as im
	left join interest_map as inmap
	ON inmap.id = im.interest_id::integer
    where inmap.interest_name not in (select interest_name from month_counts) 
    group by im.month_year
)
select 
	r.month_year, 
	r.removed_interest, 
	nr.not_removed_interest,
	removed_interest + not_removed_interest as total_interest,
	round(
		 (removed_interest*1.0 / (removed_interest + not_removed_interest)*1.0)*100
	   ,2) as removed_percentage
from removed r
join not_removed nr on r.month_year=nr.month_year
order by r.month_year

-- Kaldırmak mantıklı cunku bu alanlar genel ilgi alanlarına oranlandıgında cok dusuk bir yuzde vermektedir.
-- Bundan dolayı veriden kaldırılması bir problem yaratmayacaktır.

5. After removing these interests - how many unique interests are there for each month?

(Bu ilgi alanlarını çıkardıktan sonra - her ay için kaç tane benzersiz ilgi alanı var?)

with table1 as 
(
select 
	interest_name, 
	count(distinct month_year) as month_count
from interest_metrics as im
left join interest_map as inmap
ON inmap.id = im.interest_id::integer
group by interest_name
having count(distinct month_year) < 6
)
select 
	month_year,
	count(distinct interest_name) as removed_interest
from interest_metrics as im
left join interest_map as inmap
ON inmap.id = im.interest_id::integer
where interest_name not in (select interest_name from table1)
and month_year is not null
group by 1
order by 1


C. Segment Analysis

1. Using our filtered dataset by removing the interests with less than 6 months worth of data, which are the top 10 and bottom 10 interests 
which have the largest composition values in any month_year? 
Only use the maximum composition value for each interest but you must keep the corresponding month_year

(Filtrelenmiş veri setimizi kullanarak, 6 aydan daha az veriye sahip ilgi alanlarını çıkararak, herhangi bir ay_yılda en büyük 
 kompozisyon değerlerine sahip ilk 10 ve en alt 10 ilgi alanı hangileridir? 
 Her bir ilgi alanı için yalnızca maksimum bileşim değerini kullanın ancak ilgili ay_yılı saklamanız gerekir)

-- filtrelenmiş yeni tablo ; 
with table1 as
(
    select 
        interest_id, 
		interest_name,
        count(distinct month_year) as month_count
    from interest_metrics as im
	left join interest_map as inmap
	ON inmap.id = im.interest_id::integer
    group by 1,2
    having count(distinct month_year) < 6 
)
select 
	interest_name,
	im.*
into filtered_table
from interest_metrics as im 
left join interest_map as inmap
ON inmap.id = im.interest_id::integer
where im.interest_id not in (select interest_id from table1)


-- top 10
select 
	month_year,
	interest_id,
	ft.interest_name,
	composition as max_composition
from filtered_table as ft
left join interest_map as im
ON im.id = ft.interest_id::integer
order by 4 desc
limit 10


-- bottom 10
select 
	month_year,
	interest_id,
	ft.interest_name,
	composition as min_composition
from filtered_table as ft
left join interest_map as im
ON im.id = ft.interest_id::integer
order by 4 asc
limit 10

-- aynı sorguları tekrar bir tablo olusturmadan yapmak istersek ; 

-- top 10

with table1 as
(
    select 
        interest_id, 
		interest_name,
        count(distinct month_year) as month_count
    from interest_metrics as im
	left join interest_map as inmap
	ON inmap.id = im.interest_id::integer
    group by 1,2
    having count(distinct month_year) < 6 
),
filtered_data as (
    select 
        im.interest_id,
        inmap.interest_name,
        im.month_year,
	    im.*
    from interest_metrics as im 
    left join interest_map as inmap
        ON inmap.id = im.interest_id::integer
    where im.interest_id not in (select interest_id from table1)
)
select 
	month_year,
	interest_name,
	composition as max_composition
from filtered_table as ft
order by 3 desc
limit 10


-- bottom 10

with table1 as
(
    select 
        interest_id, 
		interest_name,
        count(distinct month_year) as month_count
    from interest_metrics as im
	left join interest_map as inmap
	ON inmap.id = im.interest_id::integer
    group by 1,2
    having count(distinct month_year) < 6 
),
filtered_data as (
    select 
        im.interest_id,
        inmap.interest_name,
        im.month_year,
	    im.*
    from interest_metrics as im 
    left join interest_map as inmap
        ON inmap.id = im.interest_id::integer
    where im.interest_id not in (select interest_id from table1)
)
select 
	month_year,
	interest_name,
	composition as max_composition
from filtered_table as ft
order by 3 
limit 10


2. Which 5 interests had the lowest average ranking value?

(Hangi 5 ilgi alanı en düşük ortalama sıralama değerine sahipti?)

select 
	interest_name,
	round(avg(ranking),0) as avg_ranking
from filtered_table
group by 1
order by 2 
limit 5



-- yeni bir tablo olusturmadan sorgu ; 
with table1 as
(
    select 
        interest_id, 
		interest_name,
        count(distinct month_year) as month_count
    from interest_metrics as im
	left join interest_map as inmap
	ON inmap.id = im.interest_id::integer
    group by 1,2
    having count(distinct month_year) < 6 
),
filtered_data as (
    select 
        im.interest_id,
        inmap.interest_name,
        im.month_year,
	    im.*
    from interest_metrics as im 
    left join interest_map as inmap
        ON inmap.id = im.interest_id::integer
    where im.interest_id not in (select interest_id from table1)
)
select 
	interest_name,
	round(avg(ranking),0) as avg_ranking
from filtered_data
group by 1
order by 2 
limit 5



3. Which 5 interests had the largest standard deviation in their percentile_ranking value?

(Hangi 5 ilgi alanı yüzdelik_sıralama değerlerinde en büyük standart sapmaya sahipti?)


select 
	interest_name,
	round(stddev(percentile_ranking)::numeric,2) as percentile_std
from filtered_table
group by 1
order by 2 desc
limit 5



-- yeni bir tablo olusturmadan sorgu ; 
with table1 as
(
    select 
        interest_id, 
		interest_name,
        count(distinct month_year) as month_count
    from interest_metrics as im
	left join interest_map as inmap
	ON inmap.id = im.interest_id::integer
    group by 1,2
    having count(distinct month_year) < 6 
),
filtered_data as (
    select 
        inmap.interest_name,
	    im.*
    from interest_metrics as im 
    left join interest_map as inmap
        ON inmap.id = im.interest_id::integer
    where im.interest_id not in (select interest_id from table1)
)
select 
	interest_name,
	round(stddev(percentile_ranking)::numeric,2) as percentile_ranking
from filtered_data
group by 1
order by 2 desc
limit 5


4.For the 5 interests found in the previous question - what was minimum and maximum percentile_ranking values for each interest 
and its corresponding year_month value? Can you describe what is happening for these 5 interests?

(Önceki soruda bulunan 5 ilgi alanı için - her bir ilgi alanı ve buna karşılık gelen yıl_ay değeri için minimum ve 
 maksimum yüzdelik_sıralama değerleri neydi? Bu 5 ilgi alanı için neler olduğunu açıklayabilir misiniz?)


with interests as
(
	select 
		interest_id, 
		f.interest_name,
		round(stddev(percentile_ranking)::numeric,2) as stdev_ranking
	from filtered_table f
	join interest_map as ma on
 	f.interest_id::integer = ma.id
	group by 1,2
 	order by 3 desc
	limit 5
),
percentiles as(
	select 
		i.interest_id, 
		f.interest_name, 
		max(percentile_ranking) as max_percentile,
		min(percentile_ranking) as min_percentile
	from filtered_table as f 
	left join interests as i
	on i.interest_id=f.interest_id
	group by 1,2
), 
max_per as (
	select 
		p.interest_id, 
		f.interest_name,
		month_year as max_year, 
		max_percentile
    from  filtered_table as f 
	left join percentiles as p
    on p.interest_id=f.interest_id
    where  max_percentile = percentile_ranking
),
min_per as ( 
	select 
		p.interest_id, 
		f.interest_name,
		month_year as min_year, 
		min_percentile
	from  filtered_table as f 
	left join percentiles as  p
	on p.interest_id=f.interest_id
	where  min_percentile = percentile_ranking
)
	select 
		mi.interest_id,
		mi.interest_name,
		min_year,
		min_percentile, 
		max_year, 
		max_percentile
	from min_per as mi 
	left join max_per as ma 
	on mi.interest_id= ma.interest_id


5. How would you describe our customers in this segment based off their composition and ranking values? What sort of 
products or services should we show to these customers and what should we avoid?

(Bu segmentteki müşterilerimizi yapılarına ve sıralama değerlerine göre nasıl tanımlarsınız? 
 Bu müşterilere ne tür ürün veya hizmetler sunmalı ve nelerden kaçınmalıyız?)


Bu segmentteki müşterilerimizi yapılarına ve sıralama değerlerine göre şu şekilde tanımlayabiliriz:

*Eğlence Sektörü Karar Vericileri: 
Bu müşteriler, eğlence sektöründe çalışan ve karar verme yetkisine sahip kişilerdir. Genellikle yeni teknolojilere ve trendlere açıktır.

*Teknoloji Meraklıları: 
Bu müşteriler, teknolojiye ilgi duyan ve yeni ürünler ve hizmetleri takip eden kişilerdir. 
Genellikle yüksek gelire sahiptir ve teknolojik ürünlere yatırım yapmaya isteklidir.

*Tampa ve St Petersburg Seyahat Planlayıcıları: 
Bu müşteriler, Tampa ve St Petersburg'a seyahat planlayan kişilerdir. Genellikle kültürel etkinliklere ve doğaya ilgi duyar.

*Oregon Seyahat Planlayıcıları: 
Bu müşteriler, Oregon'a seyahat planlayan kişilerdir. Genellikle açık hava etkinliklerine ve doğaya ilgi duyar.

*Kişiselleştirilmiş Hediye Alıcıları: 
Bu müşteriler, sevdiklerine kişiselleştirilmiş hediyeler almak isteyen kişilerdir. Genellikle yeni fikirlere ve trendlere açıktır.

* Bu müşterilere ne tür ürün veya hizmetler sunmalı ? 
Örneğin, eğlence sektöründe çalışan karar vericilere, yeni teknolojiler ve trendler hakkında bilgi sunan ürünler ve hizmetler sunabiliriz. 
Teknoloji meraklıları için, yeni ürünler ve hizmetleri tanıtan ve deneysel olan ürünler ve hizmetler sunabiliriz. 
Tampa ve St Petersburg'a seyahat planlayanlar için, kültürel etkinlikler ve doğa hakkında bilgi sunan ve konaklama ve ulaşım gibi seyahat 
planlama hizmetlerini sunabiliriz. 
Oregon'a seyahat planlayanlar için, açık hava etkinlikleri ve doğa hakkında bilgi sunan ve konaklama ve ulaşım gibi seyahat planlama hizmetlerini sunabiliriz. 
Kişiselleştirilmiş hediye alıcıları için, sevdiklerine kişiselleştirilmiş hediyeler seçmekte yardımcı olan ürünler ve hizmetler sunabiliriz.

Müşteri segmentlerinin yapıları ve sıralama değerleri dikkate alınarak sunduğumuz ürünler ve hizmetler, 
müşterilerimizin ihtiyaçlarını ve beklentilerini karşılayacak ve onları memnun edecektir.



D. Index Analysis

*The index_value is a measure which can be used to reverse calculate the average composition for Fresh Segments’ clients.
Average composition can be calculated by dividing the composition column by the index_value column rounded to 2 decimal places.

(Index_value, Fresh Segments müşterilerinin ortalama kompozisyonunu tersine hesaplamak için kullanılabilecek bir ölçüdür.
Ortalama bileşim, bileşim sütununun 2 ondalık basamağa yuvarlanmış index_value sütununa bölünmesiyle hesaplanabilir.)

1. What is the top 10 interests by the average composition for each month?

(Her ay için ortalama bileşime göre ilk 10 ilgi alanı nedir?)

with 
table1 as (
	select 
		inmap.interest_name as interest_name1,
    	*,
    	round((composition / index_value)::numeric, 2) AS avg_composition
	from interest_metrics as im
	left join interest_map as inmap 
	ON inmap.id = im.interest_id::integer
),
top10 as (
select
	interest_name1,
	month_year,
	avg_composition,
	rank() over (partition by month_year order by avg_composition desc) as rn
from table1
)
select * from top10
where rn <=10



2. For all of these top 10 interests - which interest appears the most often?

(Tüm bu ilk 10 ilgi alanı için - en sık hangi ilgi alanı ortaya çıkıyor?)

with 
table1 as (
	select 
		inmap.interest_name as interest_name1,
    	*,
    	round((composition / index_value)::numeric, 2) AS avg_composition
	from interest_metrics as im
	left join interest_map as inmap 
	ON inmap.id = im.interest_id::integer
),
top10 as (
select
	interest_name1,
	month_year,
	avg_composition,
	rank() over (partition by month_year order by avg_composition desc) as rn
from table1
)
select 
	interest_name1,
	count(interest_name1) as count_interest
from top10
where rn <= 10
group by 1
order by 2 desc

3. What is the average of the average composition for the top 10 interests for each month?

(Her ay için ilk 10 ilgi alanı için ortalama bileşimin ortalaması nedir?)

with 
table1 as (
	select 
		inmap.interest_name as interest_name1,
    	*,
    	round((composition / index_value)::numeric, 2) AS avg_composition
	from interest_metrics as im
	left join interest_map as inmap 
	ON inmap.id = im.interest_id::integer
),
top10 as (
select
	interest_name1,
	month_year,
	avg_composition,
	rank() over (partition by month_year order by avg_composition desc) as rn
from table1
)
select 
	month_year,
	round(avg(avg_composition),2) as avg_monthly_composition
from top10
where rn <= 10
and month_year is not null
group by 1


4. What is the 3 month rolling average of the max average composition value from September 2018 to August 2019 and include 
the previous top ranking interests in the same output shown below.

(Eylül 2018'den Ağustos 2019'a kadar maksimum ortalama kompozisyon değerinin 3 aylık yuvarlanan ortalaması nedir ve 
 aşağıda gösterilen aynı çıktıya önceki en üst sıradaki ilgi alanlarını dahil edin.)

with 
interest_data as (
    select 
        inmap.interest_name,
        im.interest_id,
        month_year,
        round((composition / index_value)::numeric, 2) AS avg_composition
    from interest_metrics as im
    left join interest_map as inmap 
    ON inmap.id = im.interest_id::integer
),
max_avg_per_month as (
    select  
        month_year,
        round(max(avg_composition), 2) as max_avg_comp
    from interest_data
    group by month_year
),
rolling_avg as (
    select 
        i.month_year,
        i.interest_id,
        i.interest_name,
        max_avg_comp as max_index_composition, 
        round(avg(max_avg_comp) over (order by i.month_year), 2) as "3_month_moving_avg"
    from interest_data as i 
    join max_avg_per_month m on i.month_year = m.month_year
    where avg_composition = max_avg_comp 
),
month_1_lag as (
    select 
        *, 
        concat(lag(interest_name) over (order by month_year), ' : ', lag(max_index_composition) over (order by month_year)) as "1_month_ago"
    from rolling_avg
),
month_2_lag as (
    select 
        *, 
        lag("1_month_ago") over (order by month_year) as "2_month_ago"
    from month_1_lag
)
select 
    *
from month_2_lag
where month_year between '2018-09-01' and '2019-08-01';


5. Provide a possible reason why the max average composition might change from month to month? Could it signal something 
is not quite right with the overall business model for Fresh Segments?

(Maksimum ortalama bileşimin aydan aya değişmesinin olası bir nedenini açıklayabilir misiniz? 
 Bu, Fresh Segments için genel iş modelinde bir şeylerin doğru gitmediğine işaret ediyor olabilir mi?)
 
*Tablodaki maksimum ortalama bileşimdeki aylık değişimlerin temel nedenleri çeşitli faktörlere dayanabilir. 
Öncelikle, sektörün mevsimsel dalgalanmaları bu değişimlerde rol oynayabilir; bazı aylar daha yoğun ilgi çekerken diğer aylarda talep düşebilir. 
Aynı şekilde, tatil dönemleri veya özel etkinlikler gibi faktörler de ilgi düzeyini etkileyebilir. 
Pazarlama kampanyalarının yoğun olduğu dönemlerde talepte artış gözlenebilirken, kampanya sonlarına doğru düşebilir. 
Bunun yanı sıra, ekonomik durum ve rekabet gibi makroekonomik faktörler de ilgi alanındaki değişimleri etkileyebilir. 
Bu dalgalanmalar, genel iş modelinin yanlış olduğunu göstermeyebilir, ancak pazarlama stratejilerinin ve iş modelinin ayarlanması gerekebilir.

*Genel olarak maddeleri sıralayacak olursak;

*Trend Değişiklikleri
*Konkurens Etkiler
*Sezonluk Etkiler
*Makroekonomik Faktörler
*Tatil Dönemleri
*Pazarlama Etkisi

