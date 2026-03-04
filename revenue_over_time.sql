-- Find the 3-month rolling average of total revenue from purchases given a table with users, their purchase amount, and date purchased. Do not include returns which are represented by negative purchase values. Output the year-month (YYYY-MM) and 3-month rolling average of revenue, sorted from earliest month to latest month.


-- A 3-month rolling average is defined by calculating the average total revenue from all user purchases for the current month and previous two months. The first two months will not be a true 3-month rolling average since we are not given data from last year. Assume each month has at least one purchase.

-- Table Description
-- amazon_purchases
-- created_at: date
-- purchase_amt: bigint
-- user_id: bigint


-- with grouped_purchases as (
--     SELECT
--     DATE_TRUNC('month', created_at) transmonth,
--     SUM(purchase_amt) as mthtotal
--     FROM amazon_purchases
--     WHERE purchase_amt >= 0
--     GROUP BY DATE_TRUNC('month', created_at)
--     ),

-- withlags as (
--     SELECT
--         transmonth,
--         mthtotal,
--         LAG(mthtotal, 1) OVER(ORDER by transmonth DESC) as onemonth,
--         LAG(mthtotal, 2) OVER(ORDER by transmonth DESC) as twomonths
--     FROM
--         grouped_purchases
-- )

-- SELECT
--     transmonth,
--     -- Replace null values with current value
--     (mthtotal + COALESCE(onemonth, mthtotal) + COALESCE(twomonths, COALESCE(onemonth, mthtotal))) / 3 as avg_3month
-- FROM withlags
-- ORDER BY transmonth
    