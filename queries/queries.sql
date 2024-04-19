/* 
This query aims to find the most ordered product and it achieves this by
identifying items that were added to the cart and checks if they were later removed,
focusing on successful checkouts. 
It then counts the number of times each product appears in a successful
checkout.
*/

with cart_events as (
    -- Select events related to adding items to the cart, excluding visits and checkouts
    select *
    from ecomm.events e 
    where 
        e.customer_id in (
            select e.customer_id 
            from ecomm.events e
            where e.event_data @> '{"status": "success"}'
        ) 
        and not e.event_data @> '{"event_type":"visit"}'
        and not e.event_data @> '{"event_type":"checkout"}'
),
find_removed_items as (
    -- Find items added to the cart and removed later
    select *,
           row_number() over 
           (partition by customer_id, (event_data ->> 'item_id')::int order by event_timestamp) as row_num
    from cart_events
),
removed_items as (
    -- Identify removed items
    select distinct
           customer_id,
           (event_data ->> 'item_id')::int as item_id
    from find_removed_items
    where row_num = 2 -- Row number indicates duplicate (row number = 2)
),
checked_out_cart as (
    -- Exclude removed items from the cart
    select ce.*
    from cart_events ce
    left join removed_items ri 
    on ce.customer_id = ri.customer_id and (ce.event_data ->> 'item_id')::int = ri.item_id
    where ri.customer_id is null -- Exclude rows that are duplicates
)
-- Count the number of successful orders for each product
select
    p.id as product_id, 
    p.name as product_name,
    count(*) as num_times_in_successful_orders
from 
    checked_out_cart cc
join 
    ecomm.products p on p.id = (cc.event_data ->> 'item_id')::int
group by 1,2
order by 3 desc
limit 1;



/*
This query aims to find the top 5 biggest spenders on the e commerce platform 
by identifying items that were added to the cart and checks if they were later removed, 
focusing on successful checkouts. 
It then calculates the total spend for each customer, considering only customers 
who completed a checkout.
*/

with cart_events as (
    -- Select events related to adding items to the cart, excluding visits and checkouts
    select *
    from ecomm.events e 
    where 
        e.customer_id in (
            select e.customer_id 
            from ecomm.events e
            where e.event_data @> '{"status": "success"}'
        ) 
        and not e.event_data @> '{"event_type":"visit"}'
        and not e.event_data @> '{"event_type":"checkout"}'
),
find_removed_items as (
    -- Find items added to the cart and removed later
    select *,
           row_number() 
           over (partition by customer_id, (event_data ->> 'item_id')::int order by event_timestamp) as row_num
    from cart_events
),
removed_items as (
    -- Identify removed items
    select distinct
           customer_id,
           (event_data ->> 'item_id')::int as item_id
    from find_removed_items
    where row_num = 2 -- Row number indicates duplicate (row number = 2)
),
checked_out_cart as (
    -- Exclude removed items from the cart
    select ce.*
    from cart_events ce
    left join removed_items ri 
    on ce.customer_id = ri.customer_id and (ce.event_data ->> 'item_id')::int = ri.item_id
    where ri.customer_id is null -- Exclude rows that are duplicates
),
customer_spend as (
    -- Calculate spend per product for each customer
    select
        c.customer_id, 
        c.location, 
        (cc.event_data ->> 'quantity')::int * p.price as spend_per_product
    from ecomm.customers c 
    join checked_out_cart cc 
    on c.customer_id = cc.customer_id
    join ecomm.products p 
    on p.id = (cc.event_data ->> 'item_id')::int
)
-- Calculate total spend for each customer
select 
    customer_id, 
    location, 
    sum(spend_per_product) as total_spend
from customer_spend
group by 1, 2
order by 3 desc
limit 5;



/*
   This query determines the most common location (country) where successful 
   checkouts occurred.
   It returns the location and the number of checkouts that occurred 
   in that location.
*/
select c.location, count(*) as checkout_count
from ecomm.events e
join ecomm.customers c
on c.customer_id = e.customer_id
where e.event_data @> '{"status": "success"}'
group by 1
order by 2 desc
limit 1;



/*
   This query identifies customers who abandoned their carts and counts the number
   of events (excluding visits and the checkout event itself i.e failed or cancelled) 
   that occurred before the abandonment. 
   It returns the customer_id and the number of events.
*/
select customer_id, count(*) as num_events
from ecomm.events 
-- Filter for only customers who abandoned their carts
where customer_id not in (select customer_id
                       from ecomm.events 
                        where event_data ->> 'status' = 'success')
                        and event_data ->> 'event_type' != 'visit'
                        and event_data ->> 'event_type' != 'checkout'
group by 1
order by 2 desc



/*
   This query calculates the average number of visits per customer, considering only 
   customers who completed a checkout. It returns the average_visits metric rounded to 
   2 decimal places.
*/
with visits_per_customer as (
    select customer_id, count(*) as num_visits
    from ecomm.events
    where 
        event_data ->> 'event_type' = 'visit'
        -- To filter for customers who completed a checkout
        and customer_id in (
            select customer_id
            from ecomm.events
            where 
                event_data ->> 'status' = 'success'
        )
    group by 
        customer_id
)
select round(avg(num_visits)::numeric, 2) as average_visits
from visits_per_customer;
