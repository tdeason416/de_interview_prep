-- Amazon tracks orders through multiple stages from placement to delivery. Each order has three key dates: when it was ordered, when it was shipped, and when it was received by the customer.
-- Create a weekly report showing the count of orders in each status, with weeks starting on Monday. An order's status is determined by its most recent state change: if an order was placed in week 1 and shipped in week 2, it counts as pending in week 1 and shipped in week 2. Orders that have been received should be counted as delivered.
-- Output the week start date, count of pending orders, count of shipped orders, and count of delivered orders.

-- TABLE DESCRIPTION
-- shipment_tracking
-- delivered_date: date
-- order_amount: double precision
-- order_id: bigint
-- ordered_date: date
-- shipped_date: date
-- user_id: bigint

with pendings as (
    SELECT
        order_id,
        DATE_TRUNC('week', ordered_date) week_start,
        ordered_date
    FROM
        shipment_tracking
),

shipped as (
    SELECT
        order_id,
        shipped_date,
        DATE_TRUNC('week', shipped_date) week_start
    FROM
        shipment_tracking
    WHERE shipped_date IS NOT NULL
),

delivd as (
    SELECT
        order_id,
        delivered_date,
        DATE_TRUNC('week', delivered_date) week_start
    FROM
        shipment_tracking
    WHERE delivered_date IS NOT NULL
),

all_weeks as (
    SELECT order_id, week_start
    FROM pendings
    UNION ALL
    SELECT order_id, week_start
    FROM shipped
    UNION ALL
    SELECT order_id, week_start
    FROM delivd
),

weeklys as (
    SELECT
        a.week_start,
        a.order_id,
        CASE WHEN shipped_date IS NULL AND ordered_date IS NOT NULL THEN 1 ELSE 0 END as ordered,
        -- CASE WHEN ordered_date IS NOT NULL THEN 1 ELSE 0 END as ordered,
        CASE WHEN delivered_date IS NULL and shipped_date IS NOT NULL THEN 1 ELSE 0 END as shipped,
        -- CASE WHEN shipped_date IS NOT NULL THEN 1 ELSE 0 END as shipped,
        CASE WHEN delivered_date IS NOT NULL THEN 1 ELSE 0 END as delivered 
    FROM all_weeks a
    LEFT JOIN pendings p ON a.week_start = p.week_start AND a.order_id = p.order_id
    LEFT JOIN shipped s ON a.week_start = s.week_start AND a.order_id = s.order_id
    LEFT JOIN delivd d ON a.week_start = d.week_start AND a.order_id = d.order_id
    )
    
SELECT
    week_start,
    SUM(ordered) as pending,
    SUM(shipped) as shipped,
    SUM(delivered) as delivered
FROM weeklys
GROUP BY week_start
ORDER BY week_start DESC
