/*querie counts all customers from table 'customers'*/
select COUNT(customer_id) as customers_count
from customers;

--script-top10-sellers
select
    (e.first_name || ' ' || e.last_name) as seller,
    COUNT(s.sales_person_id) as operations,
    FLOOR(SUM(p.price * s.quantity)) as income
from
    employees as e
inner join
    sales as s
    on
        e.employee_id = s.sales_person_id
inner join
    products as p
    on s.product_id = p.product_id
group by seller
order by income desc
limit 10;

--script-below-average-income
--average over all sellers
with avg_all as (
    select FLOOR(AVG(p.price * s.quantity)) as average_overall
    from sales as s
    inner join
        products as p
        on s.product_id = p.product_id
),

--average seller income
avg_seller as (
    select
        (e.first_name || ' ' || e.last_name) as seller,
        FLOOR(AVG(p.price * s.quantity)) as seller_average_income
    from
        employees as e
    inner join
        sales as s
        on
            e.employee_id = s.sales_person_id
    inner join
        products as p
        on s.product_id = p.product_id
    group by seller
)

select
    avg_seller.seller,
    avg_seller.seller_average_income as average_income
from avg_seller
where avg_seller.seller_average_income < (select average_overall from avg_all)
order by avg_seller.seller_average_income;

--script-day-of-week-income
with tab as (
    select
        (e.first_name || ' ' || e.last_name) as seller,
        FLOOR(SUM(p.price * s.quantity)) as income,
        TO_CHAR(s.sale_date, 'day') as day_of_week,
        EXTRACT(isodow from s.sale_date) as day_number
    from
        employees as e
    inner join
        sales as s
        on
            e.employee_id = s.sales_person_id
    inner join
        products as p
        on
            s.product_id = p.product_id
    group by
        day_number, seller, day_of_week
    order by day_number, seller
)

select
    seller,
    day_of_week,
    income
from tab;

--#6--
--age-groups
select
    case
        when age between 16 and 25 then '16-25'
        when age between 26 and 40 then '26-40'
        when age > 40 then '40+'
    end as age_category,
    COUNT(*) as age_count
from
    customers
group by age_category
order by age_category asc;

--customers-by-month
select
    TO_CHAR(s.sale_date, 'YYYY-MM') as selling_month,
    COUNT(distinct s.customer_id) as total_customers,
    FLOOR(SUM(s.quantity * p.price)) as income
from sales as s
inner join products as p
    on s.product_id = p.product_id
group by selling_month
order by selling_month asc;

--special-offer
with tab as (
    select
        s.customer_id,
        s.sale_date,
        (c.first_name || ' ' || c.last_name) as customer,
        (e.first_name || ' ' || e.last_name) as seller,
        ROW_NUMBER()
            over (partition by s.customer_id order by s.sale_date)
        as sale_number
    from sales as s
    inner join customers as c
        on s.customer_id = c.customer_id
    inner join employees as e
        on s.sales_person_id = e.employee_id
    inner join products as p
        on s.product_id = p.product_id
    where p.price = 0
    order by s.customer_id, s.sale_date
)

select
    customer,
    sale_date,
    seller
from tab
where sale_number = 1;
