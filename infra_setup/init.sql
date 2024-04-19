
-- Create schema
CREATE SCHEMA IF NOT EXISTS ALT_SCHOOL;


-- create and populate tables
create table if not exists ALT_SCHOOL.PRODUCTS
(
    id  serial primary key,
    name varchar not null,
    price numeric(10, 2) not null
);


COPY ALT_SCHOOL.PRODUCTS (id, name, price)
FROM '/data/products.csv' DELIMITER ',' CSV HEADER;

-- setup customers table following the example above

-- TODO: Provide the DDL statment to create this table ALT_SCHOOL.CUSTOMERS

-- TODO: provide the command to copy the customers data in the /data folder into ALT_SCHOOL.CUSTOMERS



-- TODO: complete the table DDL statement
create table if not exists ALT_SCHOOL.ORDERS
(
    order_id uuid not null primary key,
    -- provide the other fields
);


-- provide the command to copy orders data into POSTGRES


create table if not exists ALT_SCHOOL.LINE_ITEMS
(
    line_item_id serial primary key,
    -- provide the remaining fields
);


-- provide the command to copy ALT_SCHOOL.LINE_ITEMS data into POSTGRES


-- setup the events table following the examle provided
create table if not exists ALT_SCHOOL.EVENTS
(
    -- TODO: PROVIDE THE FIELDS
);

-- TODO: provide the command to copy ALT_SCHOOL.EVENTS data into POSTGRES







