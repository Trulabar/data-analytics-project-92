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