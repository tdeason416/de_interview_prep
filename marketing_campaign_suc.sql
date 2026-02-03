-- Marketing Campaign Success
-- You have the marketing_campaign table, which records in-app purchases by users. Users making their first in-app purchase enter a marketing campaign, where they see call-to-actions for more purchases. Find how many users made additional purchases due to the campaign's success.
-- The campaign starts one day after the first purchase. Users with only one or multiple purchases on the first day do not count, nor do users who later buy only the same products from their first day.

-- TABLE DESCRIPTION
-- marketing_campaign
-- created_at:date
-- price: bigint
-- product_id: bigint
-- quantity: bigint
-- user_id: bigint

with first_day as (
    SELECT
        user_id,
        min(created_at) first_day
    FROM
        marketing_campaign
    GROUP BY
        user_id
),

first_product as (
    SELECT
        m.user_id,
        m.product_id first_product
    FROM
        marketing_campaign m
    JOIN
        first_day f
        ON f.user_id = m.user_id
        AND f.first_day = m.created_at
),

counted_products as (
    SELECT
        m.user_id,
        m.product_id,
        m.price,
        sum(m.quantity) as num_items
    FROM
        marketing_campaign m
    JOIN
        first_day f
        ON m.user_id = f.user_id
        AND m.created_at != f.first_day
    GROUP BY
        m.user_id,
        m.product_id,
        m.price
    ORDER BY
        user_id,
        product_id
    ),
        
by_product as (
    SELECT
        user_id,
        product_id,
        price * num_items total_value
    FROM
        counted_products
        ),

later_purchases as (    
    SELECT
        p.user_id,
        p.product_id,
        p.total_value
    FROM
        by_product p
    LEFT JOIN
        first_product f
        ON f.user_id = p.user_id
        AND p.product_id = f.first_product
    WHERE
        f.first_product IS NULL
    ),

user_ids as (
    SELECT
        user_id,
        sum(total_value) total_value
    FROM
        later_purchases
    GROUP BY
        user_id
    ORDER BY 
        total_value DESC
    )

SELECT COUNT(user_id) as user_count FROM user_ids