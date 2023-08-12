# :heavy_check_mark: Case Study #6 - Clique Bait
![Case Study 2 Image](https://8weeksqlchallenge.com/images/case-study-designs/6.png)

# Case Study Questions

## :pushpin: A. Digital Analysis

1. How many users are there?
(Kaç kullanıcı var?)
````sql
select 
      count(distinct user_id) as user_count 
from users
````
