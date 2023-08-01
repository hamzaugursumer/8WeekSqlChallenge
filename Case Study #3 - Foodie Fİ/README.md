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
