
-- Create schema
CREATE SCHEMA IF NOT EXISTS ECOMM;


-- setup the products table
create table if not exists ECOMM.PRODUCTS
(
    id  serial primary key,
    name varchar not null,
    price numeric(10, 2) not null
);

COPY ECOMM.PRODUCTS (id, name, price)
FROM '/data/products.csv' DELIMITER ',' CSV HEADER;


-- setup the customers table 
create table if not exists ECOMM.CUSTOMERS
(
    customer_id uuid not null primary key, 
    device_id uuid not null,
    location varchar not null,
    currency varchar not null
);

COPY ECOMM.CUSTOMERS (customer_id, device_id, location, currency)
FROM '/data/customers.csv' DELIMITER ',' CSV HEADER;


-- setup the orders table 
create table if not exists ECOMM.ORDERS
(
    order_id uuid not null primary key,
    customer_id uuid not null, 
    status varchar not null,
    checked_out_at timestamp not null
);

COPY ECOMM.ORDERS (order_id, customer_id, status, checked_out_at)
FROM '/data/orders.csv' DELIMITER ',' CSV HEADER;


-- setup the line_items table 
create table if not exists ECOMM.LINE_ITEMS
(
    line_item_id serial primary key,
    order_id uuid not null,
    item_id int not null,
    quantity int not null
);

COPY ECOMM.LINE_ITEMS (line_item_id, order_id, item_id, quantity)
FROM '/data/line_items.csv' DELIMITER ',' CSV HEADER;


-- setup the events table 
create table if not exists ECOMM.EVENTS
(
    event_id serial primary key,
    customer_id uuid not null,
    event_data jsonb,
    event_timestamp timestamp
);
 
COPY ECOMM.EVENTS (event_id, customer_id, event_data, event_timestamp)
FROM '/data/events.csv' DELIMITER ',' CSV HEADER;
