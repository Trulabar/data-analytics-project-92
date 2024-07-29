--average over all sellers
with avg_all as(
select ceil(AVG(p.price*s.quantity)) as average_overall
from sales s
join
	products p
on s.product_id = p.product_id
),
--average over every seller
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
