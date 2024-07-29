/*querie counts all customers from table 'customers'*/
select
	COUNT(customer_id) as customers_count
from customers;

--script-top10-sellers
select
	(first_name || ' ' || last_name) as seller,
	COUNT(sales_person_id) as operations,
	floor(SUM(p.price*s.quantity)) as income
from
	employees e 
inner join 
	sales s
on 
	e.employee_id = s.sales_person_id
inner join
	products p
on s.product_id = p.product_id
group by seller
order by income desc
limit 10;

--script-below-average-income
--average over all sellers
with avg_all as(
select floor(AVG(p.price*s.quantity)) as average_overall
from sales s
join
	products p
on s.product_id = p.product_id
),
--average seller income
 avg_seller AS(
select
	(first_name || ' ' || last_name) as seller,
	floor(AVG(p.price*s.quantity)) as seller_average_income
from
	employees e 
join 
	sales s
on 
	e.employee_id = s.sales_person_id
join
	products p
on s.product_id = p.product_id
group by seller
)
select
	seller,
	seller_average_income as average_income
from avg_seller
where avg_seller.seller_average_income < (select average_overall from avg_all)
order by seller_average_income;

--script-day-of-week-income
with tab as(
	select
	(e.first_name || ' ' || e.last_name) as seller,
	floor(sum(p.price*s.quantity)) as income,
	to_char(sale_date, 'day') AS day_of_week,
	extract(ISODOW from s.sale_date) as day_number
from
	employees e 
inner join 
	sales s
on 
	e.employee_id = s.sales_person_id
inner join
	products p
on 
	s.product_id = p.product_id
group by
	day_number,seller,day_of_week
order by day_number,seller
)
select seller, day_of_week, income from tab;

--#6--
--age-groups
select
	case
		when age between 16 and 25 then '16-25'
		when age between 26 and 40 then '26-40'
		when age >40 then '40+'
	end	as age_category,
	count(*) as age_count
from 
	customers c
group by age_category
order by age_category asc;

--customers-by-month
select
	to_char(s.sale_date,'YYYY-MM') as selling_month,
	count(s.customer_id) as total_customers,
	floor(sum(s.quantity*p.price)) as income
from sales s 
inner join products p 
on s.product_id = p.product_id
group by selling_month
order by selling_month asc;

--special-offer
with tab as(
select 
	(c.first_name || ' ' || c.last_name) as customer,
	s.customer_id,
	s.sale_date,
	(e.first_name || ' ' || e.last_name) as seller,
	row_number() over (partition by s.customer_id order by sale_date) as sale_number
from sales s
inner join customers c 
on s.customer_id = c.customer_id
inner join employees e 
on s.sales_person_id = e.employee_id
join products p
on s.product_id = p.product_id
where p.price= 0
order by customer_id,sale_date
)
select
	customer,
	sale_date,
	seller
from tab
where sale_number =1;