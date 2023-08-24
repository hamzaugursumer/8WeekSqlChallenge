# :heavy_check_mark: Case Study #8 - Fresh Segments
![Case Study 2 Image](https://8weeksqlchallenge.com/images/case-study-designs/8.png)

# Case Study Questions

## :pushpin: A. Data Exploration and Cleansing

1. Update the fresh_segments.interest_metrics table by modifying the month_year column to be a date data type with the start of the month

(month_year sütununu ayın başlangıcını içeren bir tarih veri türü olacak şekilde değiştirerek fresh_segments.interest_metrics tablosunu güncelleyin)

````sql
ALTER TABLE interest_metrics
ALTER COLUMN month_year TYPE DATE USING TO_DATE(month_year || '-01', 'MM-YYYY-DD');
````

2. What is count of records in the fresh_segments.interest_metrics for each month_year value sorted in chronological order 
(earliest to latest) with the null values appearing first?

(fresh_segments.interest_metrics dosyasında kronolojik sıraya göre (en eskiden en yeniye) sıralanmış her ay_yıl değeri 
için kayıt sayısı kaçtır ve null değerler önce görünür?)

````sql
select 
	month_year,
	count(*) as count_month_year
from interest_metrics
group by 1
order by month_year NULLS FIRST
````
|       | month_year | count_month_year |
|-------|------------|------------------|
| 1     | [null]     | 1194             |
| 2     | 2018-07-01 | 729              |
| 3     | 2018-08-01 | 767              |
| 4     | 2018-09-01 | 780              |
| 5     | 2018-10-01 | 857              |
| 6     | 2018-11-01 | 928              |
| 7     | 2018-12-01 | 995              |
| 8     | 2019-01-01 | 973              |
| 9     | 2019-02-01 | 1121             |
| 10    | 2019-03-01 | 1136             |
| 11    | 2019-04-01 | 1099             |
| 12    | 2019-05-01 | 857              |
| 13    | 2019-06-01 | 824              |
| 14    | 2019-07-01 | 864              |
| 15    | 2019-08-01 | 1149             |

3. What do you think we should do with these null values in the fresh_segments.interest_metrics ?

(fresh_segments.interest_metrics dosyasındaki bu null değerlerle ne yapmamız gerektiğini düşünüyorsunuz?)
````sql
select 
	round(sum(case 
			when interest_id is null then 1 else 0 end) * 1.0 / count(*) * 100, 2) as null_percentage
from interest_metrics
````
|       | null_percentage |
|-------|-----------------|
| 1     | 8.36            |

* Eksik değerlerle başa çıkmak için bazı olası yaklaşımlar ;
1. Eksik Değerleri Doldurma (Imputation).
2. Eksik Veri Analizi ve Tahmin Edici Modeller.
3. Null Değerleri Bir Kategori Olarak İşaretleme.
4. Eksik Verileri Dışlama.
5. Birleştirme ve Haritalama.
6. Uyarı ve İzleme - Eksik verileri analiz yaparken dikkate alın ve sonuçları değerlendirirken eksik verilerin potansiyel etkilerini göz önünde bulundurun. 

* interest_metrics tablosunda, bazı alanlarda (örneğin _month, _year, month_year ve interest_id) eksik veya boş değerler gözlenmektedir. 
Bu eksik değerler, tarih ve ilgi alanı bilgilerinin tam olarak mevcut olmadığı durumlarda ortaya çıkabilir. 
Diğer taraftan, composition, index_value, ranking ve percentile_ranking alanlarındaki veriler, ilgi alanı ve 
tarih hakkında daha fazla ayrıntıya dayanmadan anlamlı sonuçlar üretemeyebilir.
Öncelikle, tablodaki eksik değerlerin yüzdesini belirlemek, veri bütünlüğünü değerlendirmek için önemlidir. 
Bu analiz, eksik değerlerin tablodaki genel durumunu anlamada rehberlik edebilir. Bu değerlendirme sonucunda, 
eksik değerlerin tablodaki toplam kayıt sayısına göre %10 dan az olduğu tespit edilmiştir.

* Eksik değerlerin oranının düşük olması ve analizlerinizi daha sağlam hale getirmek amacıyla, bu eksik değerleri çıkarmak iyi bir yaklaşım olabilir. 
Bu sayede, analiz sonuçlarınızın güvenilirliğini artırarak, daha kesin ve anlamlı sonuçlara ulaşabilirsiniz. 
Bu yaklaşım, eksik veri yönetimi konusunda daha iyi bir veri kalitesi sağlamak için uygun bir adımdır.

````sql
DELETE FROM interest_metrics
WHERE interest_id IS NULL

select 
	round(sum(case 
			when interest_id is null then 1 else 0 end) * 1.0 / count(*) * 100, 2) as null_percentage
from interest_metrics
````
|       | null_percentage |
|-------|-----------------|
| 1     | 0.00            |

4. How many interest_id values exist in the fresh_segments.interest_metrics table but not in the fresh_segments.interest_map table? 
What about the other way around?

(fresh_segments.interest_metrics tablosunda olup da fresh_segments.interest_map tablosunda olmayan kaç tane interest_id değeri var? Peki ya tam tersi?)

````sql
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
````
|       | distinct_id_count | distinct_metrics_id_count | not_in_metric | not_in_map |
|-------|-------------------|---------------------------|---------------|------------|
| 1     | 1209              | 1202                      | 0             | 7          |

5. Summarise the id values in the fresh_segments.interest_map by its total record count in this table

(interest_map teki kimlik değerlerini bu tablodaki toplam kayıt sayısına göre özetleyin)
````sql
select 
	count(distinct id) as distinct_id,
	count(*) as total_record
from interest_map as im
left join interest_metrics as metric
ON metric.interest_id::integer = im.id
````
|       | distinct_id | total_record |
|-------|-------------|--------------|
| 1     | 1209        | 13087        |

6. What sort of table join should we perform for our analysis and why? Check your logic by checking the rows where interest_id = 21246 in your 
joined output and include all columns from fresh_segments.interest_metrics and all columns from fresh_segments.interest_map except from the id column.

(Analizimiz için ne tür bir tablo birleştirme gerçekleştirmeliyiz ve neden? Birleştirilmiş çıktınızda interest_id = 21246 
 olan satırları kontrol ederek mantığınızı kontrol edin ve fresh_segments.interest_metrics'teki tüm 
sütunları ve id sütunu hariç fresh_segments.interest_map'teki tüm sütunları dahil edin.)
````sql
select 
*
from interest_map as im
left join interest_metrics as metric
ON metric.interest_id::integer = im.id
where metric.interest_id::integer = 21246

-- left join veya inner join kullanılabilir. Sadece ortak alanlar veya fromdan sonra yazılan tablonun tamamı görüntülenmek istenebilir. 
-- Id ler üzerinden gerçekleştirilen join işleminde 21246 Idli kişinin bütün bilgileri gelmiş oldu.
````
|       | id   | interest_name                 | interest_summary                             | created_at          | last_modified       | _month | _year | month_year  | interest_id | composition | index_value | ranking | percentile_ranking |
|-------|------|------------------------------|-----------------------------------------------|---------------------|---------------------|--------|-------|-------------|-------------|-------------|-------------|---------|-------------------|
| 1     | 21246| Readers of El Salvadoran...   | People reading news from El Salvadoran...   | 2018-06-11 17:50:04| 2018-06-11 17:50:04| 7      | 2018  | 2018-07-01  | 21246       | 2.26        | 0.65        | 722     | 0.96              |
| 2     | 21246| Readers of El Salvadoran...   | People reading news from El Salvadoran...   | 2018-06-11 17:50:04| 2018-06-11 17:50:04| 8      | 2018  | 2018-08-01  | 21246       | 2.13        | 0.59        | 765     | 0.26              |
| 3     | 21246| Readers of El Salvadoran...   | People reading news from El Salvadoran...   | 2018-06-11 17:50:04| 2018-06-11 17:50:04| 9      | 2018  | 2018-09-01  | 21246       | 2.06        | 0.61        | 774     | 0.77              |
| 4     | 21246| Readers of El Salvadoran...   | People reading news from El Salvadoran...   | 2018-06-11 17:50:04| 2018-06-11 17:50:04| 10     | 2018  | 2018-10-01  | 21246       | 1.74        | 0.58        | 855     | 0.23              |
| 5     | 21246| Readers of El Salvadoran...   | People reading news from El Salvadoran...   | 2018-06-11 17:50:04| 2018-06-11 17:50:04| 11     | 2018  | 2018-11-01  | 21246       | 2.25        | 0.78        | 908     | 2.16              |
| 6     | 21246| Readers of El Salvadoran...   | People reading news from El Salvadoran...   | 2018-06-11 17:50:04| 2018-06-11 17:50:04| 12     | 2018  | 2018-12-01  | 21246       | 1.97        | 0.7         | 983     | 1.21              |
| 7     | 21246| Readers of El Salvadoran...   | People reading news from El Salvadoran...   | 2018-06-11 17:50:04| 2018-06-11 17:50:04| 1      | 2019  | 2019-01-01  | 21246       | 2.05        | 0.76        | 954     | 1.95              |
| 8     | 21246| Readers of El Salvadoran...   | People reading news from El Salvadoran...   | 2018-06-11 17:50:04| 2018-06-11 17:50:04| 2      | 2019  | 2019-02-01  | 21246       | 1.84        | 0.68        | 1109    | 1.07              |
| 9     | 21246| Readers of El Salvadoran...   | People reading news from El Salvadoran...   | 2018-06-11 17:50:04| 2018-06-11 17:50:04| 3      | 2019  | 2019-03-01  | 21246       | 1.75        | 0.67        | 1123    | 1.14              |
| 10    | 21246| Readers of El Salvadoran...   | People reading news from El Salvadoran...   | 2018-06-11 17:50:04| 2018-06-11 17:50:04| 4      | 2019  | 2019-04-01  | 21246       | 1.58        | 0.63        | 1092    | 0.64              |
| 11    | 21246| Readers of El Salvadoran...   | People reading news from El Salvadoran...   | 2018-06-11 17:50:04| 2018-06-11 17:

7. Are there any records in your joined table where the month_year value is before the created_at value from 
the fresh_segments.interest_map table? Do you think these values are valid and why?

(Birleştirilmiş tablonuzda, month_year değerinin fresh_segments.interest_map tablosundaki created_at değerinden önce olduğu herhangi bir 
kayıt var mı? Bu değerlerin geçerli olduğunu düşünüyor musunuz ve neden?)
````sql
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
````
|       | id    | month_year  | created_at          | interest_name              |
|-------|-------|-------------|---------------------|-----------------------------|
| 1     | 32701 | 2018-07-01  | 2018-07-06 14:35:03 | Womens Equality Advocates   |
| 2     | 32702 | 2018-07-01  | 2018-07-06 14:35:04 | Romantics                   |
| 3     | 32703 | 2018-07-01  | 2018-07-06 14:35:04 | School Supply Shoppers      |
| 4     | 32704 | 2018-07-01  | 2018-07-06 14:35:04 | Major Airline Customers     |
| 5     | 32705 | 2018-07-01  | 2018-07-06 14:35:04 | Certified Events Professionals |
| 6     | 33191 | 2018-07-01  | 2018-07-17 10:40:03 | Online Shoppers             |
| 7     | 33957 | 2018-08-01  | 2018-08-02 16:05:03 | Call of Duty Enthusiasts    |
| 8     | 33958 | 2018-08-01  | 2018-08-02 16:05:03 | Astrology Enthusiasts       |
| 9     | 33959 | 2018-08-01  | 2018-08-02 16:05:03 | Boston Bruins Fans          |
| 10    | 33960 | 2018-08-01  | 2018-08-02 16:05:03 | Chicago Blackhawks Fans     |
* The first 10 out of a total of 188 rows are shown.

188 tane kayıt bulunmaktadır ve bu değerler geçerlidir. Çünkü month_year alanı için yapılan ön işlemde ayın ilk günü için bir işlem yapılmıstır.
müşteri o ay için de created at tarihi için sonra da işlem gerçekleştirmiş olabilir ve bunu veriye göre bilemeyebiliriz.

## :pushpin: B. Interest Analysis

1. Which interests have been present in all month_year dates in our dataset?

(Veri setimizdeki tüm ay_yıl tarihlerinde hangi ilgi alanları mevcuttu?)
````sql
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
````
|       | unique_month_year | unique_interest_id |
|-------|-------------------|-------------------|
| 1     | 14                | 1202              |

2. Using this same total_months measure - calculate the cumulative percentage of all records starting at 14 
months - which total_months value passes the 90% cumulative percentage value?

(Aynı total_months hesaplamasını kullanarak - 14 aydan başlayarak tüm kayıtların kümülatif yüzdesini hesaplayın - 
hangi total_months değeri %90 kümülatif yüzde değerini geçer?)

````sql
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
````
|       | count_month_year | interest_count | cumulative_sum | total_interest_count | cumulative_percentage |
|-------|------------------|----------------|----------------|---------------------|-----------------------|
| 1     | 6                | 33             | 1092           | 1201                | 90.92                 |
| 2     | 5                | 38             | 1130           | 1201                | 94.09                 |
| 3     | 4                | 31             | 1161           | 1201                | 96.67                 |
| 4     | 3                | 15             | 1176           | 1201                | 97.92                 |
| 5     | 2                | 12             | 1188           | 1201                | 98.92                 |
| 6     | 1                | 13             | 1201           | 1201                | 100.00                |

3. If we were to remove all interest_id values which are lower than the total_months value we found in the 
previous question - how many total data points would we be removing?

(Önceki soruda bulduğumuz total_months değerinden daha düşük olan tüm interest_id değerlerini kaldıracak olsaydık - toplam kaç veri noktasını kaldırmış olurduk?)
````sql
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
````
|       | total_month_year |
|-------|------------------|
| 1     | 396              |

4. Does this decision make sense to remove these data points from a business perspective? Use an example where there are all 14 
months present to a removed interest example for your arguments - think about what it means to have less

(İş perspektifinden bakıldığında bu veri noktalarını kaldırma kararı mantıklı mı? Argümanlarınız için kaldırılmış bir faiz örneğinde 14 
ayın tamamının mevcut olduğu bir örnek kullanın - daha azına sahip olmanın ne anlama geldiğini düşünün)
````sql
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
````
|       | month_year  | removed_interest | not_removed_interest | total_interest | removed_percentage |
|-------|-------------|------------------|----------------------|----------------|-------------------|
| 1     | 2018-07-01  | 20               | 709                  | 729            | 2.74              |
| 2     | 2018-08-01  | 15               | 752                  | 767            | 1.96              |
| 3     | 2018-09-01  | 6                | 774                  | 780            | 0.77              |
| 4     | 2018-10-01  | 4                | 853                  | 857            | 0.47              |
| 5     | 2018-11-01  | 3                | 925                  | 928            | 0.32              |
| 6     | 2018-12-01  | 9                | 986                  | 995            | 0.90              |
| 7     | 2019-01-01  | 7                | 966                  | 973            | 0.72              |
| 8     | 2019-02-01  | 48               | 1073                 | 1121           | 4.28              |
| 9     | 2019-03-01  | 57               | 1079                 | 1136           | 5.02              |
| 10    | 2019-04-01  | 63               | 1036                 | 1099           | 5.73              |
| 11    | 2019-05-01  | 30               | 827                  | 857            | 3.50              |
| 12    | 2019-06-01  | 20               | 804                  | 824            | 2.43              |
| 13    | 2019-07-01  | 28               | 836                  | 864            | 3.24              |
| 14    | 2019-08-01  | 86               | 1063                 | 1149           | 7.48              |

* Kaldırmak mantıklı cunku bu alanlar genel ilgi alanlarına oranlandıgında cok dusuk bir yuzde vermektedir. Bundan dolayı veriden kaldırılması bir problem yaratmayacaktır.

5. After removing these interests - how many unique interests are there for each month?

(Bu ilgi alanlarını çıkardıktan sonra - her ay için kaç tane benzersiz ilgi alanı var?)
````sql
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
````
|       | month_year  | removed_interest |
|-------|-------------|------------------|
| 1     | 2018-07-01  | 709              |
| 2     | 2018-08-01  | 752              |
| 3     | 2018-09-01  | 774              |
| 4     | 2018-10-01  | 853              |
| 5     | 2018-11-01  | 925              |
| 6     | 2018-12-01  | 986              |
| 7     | 2019-01-01  | 966              |
| 8     | 2019-02-01  | 1072             |
| 9     | 2019-03-01  | 1078             |
| 10    | 2019-04-01  | 1035             |
| 11    | 2019-05-01  | 827              |
| 12    | 2019-06-01  | 804              |
| 13    | 2019-07-01  | 836              |
| 14    | 2019-08-01  | 1062             |

## :pushpin: C. Segment Analysis

1. Using our filtered dataset by removing the interests with less than 6 months worth of data, which are the top 10 and bottom 10 interests 
which have the largest composition values in any month_year? 
Only use the maximum composition value for each interest but you must keep the corresponding month_year

(Filtrelenmiş veri setimizi kullanarak, 6 aydan daha az veriye sahip ilgi alanlarını çıkararak, herhangi bir ay_yılda en büyük 
 kompozisyon değerlerine sahip ilk 10 ve en alt 10 ilgi alanı hangileridir? 
 Her bir ilgi alanı için yalnızca maksimum bileşim değerini kullanın ancak ilgili ay_yılı saklamanız gerekir)

* Filtrelenmiş yeni tablo ; 
````sql
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
````

* top 10
````sql
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
````
|       | month_year  | interest_id | interest_name                   | max_composition |
|-------|-------------|-------------|---------------------------------|----------------|
| 1     | 2018-12-01  | 21057       | Work Comes First Travelers      | 21.2           |
| 2     | 2018-10-01  | 21057       | Work Comes First Travelers      | 20.28          |
| 3     | 2018-11-01  | 21057       | Work Comes First Travelers      | 19.45          |
| 4     | 2019-01-01  | 21057       | Work Comes First Travelers      | 18.99          |
| 5     | 2018-07-01  | 6284        | Gym Equipment Owners            | 18.82          |
| 6     | 2019-02-01  | 21057       | Work Comes First Travelers      | 18.39          |
| 7     | 2018-09-01  | 21057       | Work Comes First Travelers      | 18.18          |
| 8     | 2018-07-01  | 39          | Furniture Shoppers              | 17.44          |
| 9     | 2018-07-01  | 77          | Luxury Retail Shoppers          | 17.19          |
| 10    | 2018-10-01  | 12133       | Luxury Boutique Hotel Researchers | 15.15        |

* bottom 10
````sql
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
````
|       | month_year  | interest_id | interest_name                | min_composition |
|-------|-------------|-------------|------------------------------|----------------|
| 1     | 2019-05-01  | 45524       | Mowing Equipment Shoppers    | 1.51           |
| 2     | 2019-05-01  | 4918        | Gastrointestinal Researchers | 1.52           |
| 3     | 2019-06-01  | 34083       | New York Giants Fans         | 1.52           |
| 4     | 2019-06-01  | 35742       | Disney Fans                  | 1.52           |
| 5     | 2019-05-01  | 20768       | Beer Aficionados             | 1.52           |
| 6     | 2019-04-01  | 44449       | United Nations Donors        | 1.52           |
| 7     | 2019-05-01  | 39336       | Philadelphia 76ers Fans      | 1.52           |
| 8     | 2019-06-01  | 6314        | Online Directory Searchers   | 1.53           |
| 9     | 2019-05-01  | 36877       | Crochet Enthusiasts          | 1.53           |
| 10    | 2019-05-01  | 6127        | LED Lighting Shoppers        | 1.53           |

* Aynı sorguları tekrar bir tablo olusturmadan yapmak istersek ; 

* top 10
````sql
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
````
|       | month_year  | interest_name                   | max_composition |
|-------|-------------|---------------------------------|----------------|
| 1     | 2018-12-01  | Work Comes First Travelers      | 21.2           |
| 2     | 2018-10-01  | Work Comes First Travelers      | 20.28          |
| 3     | 2018-11-01  | Work Comes First Travelers      | 19.45          |
| 4     | 2019-01-01  | Work Comes First Travelers      | 18.99          |
| 5     | 2018-07-01  | Gym Equipment Owners            | 18.82          |
| 6     | 2019-02-01  | Work Comes First Travelers      | 18.39          |
| 7     | 2018-09-01  | Work Comes First Travelers      | 18.18          |
| 8     | 2018-07-01  | Furniture Shoppers              | 17.44          |
| 9     | 2018-07-01  | Luxury Retail Shoppers          | 17.19          |
| 10    | 2018-10-01  | Luxury Boutique Hotel Researchers | 15.15        |

* bottom 10
````sql
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
````
|       | month_year  | interest_name                | min_composition|
|-------|-------------|------------------------------|----------------|
| 1     | 2019-05-01  | Mowing Equipment Shoppers    | 1.51           |
| 2     | 2019-05-01  | Gastrointestinal Researchers | 1.52           |
| 3     | 2019-06-01  | New York Giants Fans         | 1.52           |
| 4     | 2019-06-01  | Disney Fans                  | 1.52           |
| 5     | 2019-05-01  | Beer Aficionados             | 1.52           |
| 6     | 2019-04-01  | United Nations Donors        | 1.52           |
| 7     | 2019-05-01  | Philadelphia 76ers Fans      | 1.52           |
| 8     | 2019-06-01  | Online Directory Searchers   | 1.53           |
| 9     | 2019-05-01  | Crochet Enthusiasts          | 1.53           |
| 10    | 2019-05-01  | LED Lighting Shoppers        | 1.53           |

2. Which 5 interests had the lowest average ranking value?

(Hangi 5 ilgi alanı en düşük ortalama sıralama değerine sahipti?)
````sql
select 
	interest_name,
	round(avg(ranking),0) as avg_ranking
from filtered_table
group by 1
order by 2 
limit 5
````

* Yeni bir tablo olusturmadan sorgu ;
````sql
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
````

|       | interest_name                 | avg_ranking |
|-------|------------------------------|-------------|
| 1     | Winter Apparel Shoppers       | 1           |
| 2     | Fitness Activity Tracker Users | 4           |
| 3     | Mens Shoe Shoppers            | 6           |
| 4     | Shoe Shoppers                 | 9           |
| 5     | Competitive Tri-Athletes      | 12          |

3. Which 5 interests had the largest standard deviation in their percentile_ranking value?

(Hangi 5 ilgi alanı yüzdelik_sıralama değerlerinde en büyük standart sapmaya sahipti?)

````sql
select 
	interest_name,
	round(stddev(percentile_ranking)::numeric,2) as percentile_std
from filtered_table
group by 1
order by 2 desc
limit 5
````

* Yeni bir tablo olusturmadan sorgu ; 
````sql
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
````
|       | interest_name                          | percentile_std |
|-------|----------------------------------------|----------------|
| 1     | Techies                                | 30.18          |
| 2     | Entertainment Industry Decision Makers | 28.97          |
| 3     | Oregon Trip Planners                   | 28.32          |
| 4     | Personalized Gift Shoppers             | 26.24          |
| 5     | Tampa and St Petersburg Trip Planners  | 25.61          |


4.For the 5 interests found in the previous question - what was minimum and maximum percentile_ranking values for each interest 
and its corresponding year_month value? Can you describe what is happening for these 5 interests?

(Önceki soruda bulunan 5 ilgi alanı için - her bir ilgi alanı ve buna karşılık gelen yıl_ay değeri için minimum ve 
 maksimum yüzdelik_sıralama değerleri neydi? Bu 5 ilgi alanı için neler olduğunu açıklayabilir misiniz?)

````sql
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
````
|       | interest_id | interest_name                           | min_year   | min_percentile | max_year   | max_percentile |
|-------|-------------|----------------------------------------|------------|----------------|------------|----------------|
| 1     | 20764       | Entertainment Industry Decision Makers | 2019-08-01 | 11.23          | 2018-07-01 | 86.15          |
| 2     | 23          | Techies                                | 2019-08-01 | 7.92           | 2018-07-01 | 86.69          |
| 3     | 10839       | Tampa and St Petersburg Trip Planners  | 2019-03-01 | 4.84           | 2018-07-01 | 75.03          |
| 4     | 38992       | Oregon Trip Planners                   | 2019-07-01 | 2.2            | 2018-11-01 | 82.44          |
| 5     | 43546       | Personalized Gift Shoppers             | 2019-06-01 | 5.7            | 2019-03-01 | 73.15          |

5. How would you describe our customers in this segment based off their composition and ranking values? What sort of 
products or services should we show to these customers and what should we avoid?

(Bu segmentteki müşterilerimizi yapılarına ve sıralama değerlerine göre nasıl tanımlarsınız? 
 Bu müşterilere ne tür ürün veya hizmetler sunmalı ve nelerden kaçınmalıyız?)


Bu segmentteki müşterilerimizi yapılarına ve sıralama değerlerine göre şu şekilde tanımlayabiliriz:

* Eğlence Sektörü Karar Vericileri: 
Bu müşteriler, eğlence sektöründe çalışan ve karar verme yetkisine sahip kişilerdir. Genellikle yeni teknolojilere ve trendlere açıktır.

* Teknoloji Meraklıları: 
Bu müşteriler, teknolojiye ilgi duyan ve yeni ürünler ve hizmetleri takip eden kişilerdir. 
Genellikle yüksek gelire sahiptir ve teknolojik ürünlere yatırım yapmaya isteklidir.

* Tampa ve St Petersburg Seyahat Planlayıcıları: 
Bu müşteriler, Tampa ve St Petersburg'a seyahat planlayan kişilerdir. Genellikle kültürel etkinliklere ve doğaya ilgi duyar.

* Oregon Seyahat Planlayıcıları: 
Bu müşteriler, Oregon'a seyahat planlayan kişilerdir. Genellikle açık hava etkinliklerine ve doğaya ilgi duyar.

* Kişiselleştirilmiş Hediye Alıcıları: 
Bu müşteriler, sevdiklerine kişiselleştirilmiş hediyeler almak isteyen kişilerdir. Genellikle yeni fikirlere ve trendlere açıktır.

* Bu müşterilere ne tür ürün veya hizmetler sunmalı ? 
Örneğin, eğlence sektöründe çalışan karar vericilere, yeni teknolojiler ve trendler hakkında bilgi sunan ürünler ve hizmetler sunabiliriz. 
Teknoloji meraklıları için, yeni ürünler ve hizmetleri tanıtan ve deneysel olan ürünler ve hizmetler sunabiliriz. 
Tampa ve St Petersburg'a seyahat planlayanlar için, kültürel etkinlikler ve doğa hakkında bilgi sunan ve konaklama ve ulaşım gibi seyahat 
planlama hizmetlerini sunabiliriz. 
Oregon'a seyahat planlayanlar için, açık hava etkinlikleri ve doğa hakkında bilgi sunan ve konaklama ve ulaşım gibi seyahat planlama hizmetlerini sunabiliriz. 
Kişiselleştirilmiş hediye alıcıları için, sevdiklerine kişiselleştirilmiş hediyeler seçmekte yardımcı olan ürünler ve hizmetler sunabiliriz.

* Müşteri segmentlerinin yapıları ve sıralama değerleri dikkate alınarak sunduğumuz ürünler ve hizmetler, 
müşterilerimizin ihtiyaçlarını ve beklentilerini karşılayacak ve onları memnun edecektir.


## :pushpin: D. Index Analysis

* The index_value is a measure which can be used to reverse calculate the average composition for Fresh Segments’ clients.
Average composition can be calculated by dividing the composition column by the index_value column rounded to 2 decimal places.

(Index_value, Fresh Segments müşterilerinin ortalama kompozisyonunu tersine hesaplamak için kullanılabilecek bir ölçüdür.
Ortalama bileşim, bileşim sütununun 2 ondalık basamağa yuvarlanmış index_value sütununa bölünmesiyle hesaplanabilir.)

1. What is the top 10 interests by the average composition for each month?

(Her ay için ortalama bileşime göre ilk 10 ilgi alanı nedir?)
````sql
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
````
|       | interest_name1                   | month_year | avg_composition | rn  |
|-------|----------------------------------|------------|-----------------|-----|
| 1     | Las Vegas Trip Planners          | 2018-07-01 | 7.36            | 1   |
| 2     | Gym Equipment Owners             | 2018-07-01 | 6.94            | 2   |
| 3     | Cosmetics and Beauty Shoppers    | 2018-07-01 | 6.78            | 3   |
| 4     | Luxury Retail Shoppers           | 2018-07-01 | 6.61            | 4   |
| 5     | Furniture Shoppers               | 2018-07-01 | 6.51            | 5   |
| 6     | Asian Food Enthusiasts           | 2018-07-01 | 6.10            | 6   |
| 7     | Recently Retired Individuals     | 2018-07-01 | 5.72            | 7   |
| 8     | Family Adventures Travelers      | 2018-07-01 | 4.85            | 8   |
* The first 8 out of a total of 143 rows are shown


2. For all of these top 10 interests - which interest appears the most often?

(Tüm bu ilk 10 ilgi alanı için - en sık hangi ilgi alanı ortaya çıkıyor?)
````sql
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
````
|       | interest_name1                                | count_interest |
|-------|-----------------------------------------------|----------------|
| 1     | Solar Energy Researchers                      | 10             |
| 2     | Luxury Bedding Shoppers                       | 10             |
| 3     | Alabama Trip Planners                         | 10             |
| 4     | Nursing and Physicians Assistant Journal Researchers | 9              |
| 5     | New Years Eve Party Ticket Purchasers         | 9              |
| 6     | Readers of Honduran Content                   | 9              |
| 7     | Teen Girl Clothing Shoppers                   | 8              |
| 8     | Work Comes First Travelers                    | 8              |
| 9     | Christmas Celebration Researchers             | 7              |
| 10    | Asian Food Enthusiasts                        | 5              |
| 11    | Furniture Shoppers                            | 5              |
| 12    | Recently Retired Individuals                  | 5              |
| 13    | Gym Equipment Owners                         | 5              |
| 14    | Cosmetics and Beauty Shoppers                 | 5              |
| 15    | Las Vegas Trip Planners                      | 5              |
| 16    | Luxury Retail Shoppers                        | 5              |
| 17    | Readers of Catholic News                     | 4              |
| 18    | Restaurant Supply Shoppers                   | 4              |
| 19    | PlayStation Enthusiasts                      | 4              |
| 20    | Medicare Researchers                         | 3              |
| 21    | Medicare Provider Researchers                | 2              |
| 22    | Chelsea Fans                                 | 2              |
| 23    | Readers of El Salvadoran Content             | 1              |
| 24    | Cruise Travel Intenders                      | 1              |
| 25    | Luxury Boutique Hotel Researchers            | 1              |
| 26    | Video Gamers                                 | 1              |
| 27    | Gamers                                       | 1              |
| 28    | HDTV Researchers                             | 1              |
| 29    | Family Adventures Travelers                  | 1              |
| 30    | Medicare Price Shoppers                      | 1              |
| 31    | Marijuana Legalization Advocates             | 1              |



3. What is the average of the average composition for the top 10 interests for each month?

(Her ay için ilk 10 ilgi alanı için ortalama bileşimin ortalaması nedir?)
````sql
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
````
|       | month_year  | avg_monthly_composition |
|-------|-------------|------------------------|
| 1     | 2018-07-01  | 6.04                   |
| 2     | 2018-08-01  | 5.95                   |
| 3     | 2018-09-01  | 6.90                   |
| 4     | 2018-10-01  | 7.07                   |
| 5     | 2018-11-01  | 6.62                   |
| 6     | 2018-12-01  | 6.65                   |
| 7     | 2019-01-01  | 6.32                   |
| 8     | 2019-02-01  | 6.58                   |
| 9     | 2019-03-01  | 6.12                   |
| 10    | 2019-04-01  | 5.75                   |
| 11    | 2019-05-01  | 3.54                   |
| 12    | 2019-06-01  | 2.43                   |
| 13    | 2019-07-01  | 2.77                   |
| 14    | 2019-08-01  | 2.63                   |

4. What is the 3 month rolling average of the max average composition value from September 2018 to August 2019 and include 
the previous top ranking interests in the same output shown below.

(Eylül 2018'den Ağustos 2019'a kadar maksimum ortalama kompozisyon değerinin 3 aylık yuvarlanan ortalaması nedir ve 
 aşağıda gösterilen aynı çıktıya önceki en üst sıradaki ilgi alanlarını dahil edin.)
````sql
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
````
|       | month_year  | interest_id | interest_name                | max_index_composition | 3_month_moving_avg | 1_month_ago                      | 2_month_ago                      |
|-------|-------------|-------------|-----------------------------|-----------------------|--------------------|---------------------------------|---------------------------------|
| 1     | 2018-09-01  | 21057       | Work Comes First Travelers   | 8.26                  | 7.61               | Las Vegas Trip Planners : 7.21   | Las Vegas Trip Planners : 7.36   |
| 2     | 2018-10-01  | 21057       | Work Comes First Travelers   | 9.14                  | 7.99               | Work Comes First Travelers : 8.26 | Las Vegas Trip Planners : 7.21   |
| 3     | 2018-11-01  | 21057       | Work Comes First Travelers   | 8.28                  | 8.05               | Work Comes First Travelers : 9.14 | Work Comes First Travelers : 8.26 |
| 4     | 2018-12-01  | 21057       | Work Comes First Travelers   | 8.31                  | 8.09               | Work Comes First Travelers : 8.28 | Work Comes First Travelers : 9.14 |
| 5     | 2019-01-01  | 21057       | Work Comes First Travelers   | 7.66                  | 8.03               | Work Comes First Travelers : 8.31 | Work Comes First Travelers : 8.28 |
| 6     | 2019-02-01  | 21057       | Work Comes First Travelers   | 7.66                  | 7.99               | Work Comes First Travelers : 7.66 | Work Comes First Travelers : 8.31 |
| 7     | 2019-03-01  | 7541        | Alabama Trip Planners       | 6.54                  | 7.82               | Work Comes First Travelers : 7.66 | Work Comes First Travelers : 7.66 |
| 8     | 2019-04-01  | 6065        | Solar Energy Researchers    | 6.28                  | 7.67               | Alabama Trip Planners : 6.54     | Work Comes First Travelers : 7.66 |
| 9     | 2019-05-01  | 21245       | Readers of Honduran Content | 4.41                  | 7.37               | Solar Energy Researchers : 6.28  | Alabama Trip Planners : 6.54     |
| 10    | 2019-06-01  | 6324        | Las Vegas Trip Planners     | 2.77                  | 6.99               | Readers of Honduran Content : 4.41 | Solar Energy Researchers : 6.28  |
| 11    | 2019-07-01  | 6324        | Las Vegas Trip Planners     | 2.82                  | 6.67               | Las Vegas Trip Planners : 2.77  | Readers of Honduran Content : 4.41 |
| 12    | 2019-08-01  | 4898        | Cosmetics and Beauty Shoppers | 2.73                | 6.39               | Las Vegas Trip Planners : 2.82  | Las Vegas Trip Planners : 2.77  |

5. Provide a possible reason why the max average composition might change from month to month? Could it signal something 
is not quite right with the overall business model for Fresh Segments?

(Maksimum ortalama bileşimin aydan aya değişmesinin olası bir nedenini açıklayabilir misiniz? 
 Bu, Fresh Segments için genel iş modelinde bir şeylerin doğru gitmediğine işaret ediyor olabilir mi?)
 
* Tablodaki maksimum ortalama bileşimdeki aylık değişimlerin temel nedenleri çeşitli faktörlere dayanabilir. 
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





