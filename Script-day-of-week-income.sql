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