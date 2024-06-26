{{
  config(
    materialized='table'
  )
}}
/* I'm leaving text instead of casting to character varying */
WITH orders AS (
    SELECT
        NULLIF(order_id, '')::smallint AS order_id,
        customer_id,
        NULLIF(employee_id, '')::smallint AS employee_id,
        NULLIF(order_date, '')::date AS order_date,
        NULLIF(required_date, '')::date AS required_date,
        NULLIF(shipped_date, '')::date AS shipped_date,
        NULLIF(ship_via, '')::smallint AS ship_via,
        NULLIF(freight, '')::real AS freight,
        ship_name,
        ship_address,
        ship_city,
        ship_region,
        ship_postal_code,
        ship_country
    FROM {{ source('orders_and_details', 'orders') }}
),
order_details AS (
    SELECT
        NULLIF(order_id, '')::smallint AS order_details_order_id,
        NULLIF(product_id, '')::smallint AS product_id,
        NULLIF(unit_price, '')::real AS unit_price,
        NULLIF(quantity, '')::smallint AS quantity,
        NULLIF(discount, '')::real AS discount
    FROM {{ source('orders_and_details', 'order_details') }}
)
SELECT *
FROM orders
    INNER JOIN order_details
    ON orders.order_id = order_details.order_details_order_id


