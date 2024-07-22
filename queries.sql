/*querie counts all customers from table 'customers'*/
select
	COUNT(customer_id) as customers_count
from customers;

--script-top10-sellers
select
	(first_name || ' ' || last_name) as seller,
	COUNT(sales_person_id) as operations,
	ceil(SUM(p.price*s.quantity)) as income
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
select ceil(AVG(p.price*s.quantity)) as average_overall
from sales s
join
	products p
on s.product_id = p.product_id
),
--average seller income
 avg_seller AS(
select
	(first_name || ' ' || last_name) as seller,
	ceil(AVG(p.price*s.quantity)) as seller_average_income
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
	ceil(sum(p.price*s.quantity)) as income,
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

