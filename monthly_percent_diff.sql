-- Given a table of purchases by date, calculate the month-over-month percentage change in revenue. The output should include the year-month date (YYYY-MM) and percentage change, rounded to the 2nd decimal point, and sorted from the beginning of the year to the end of the year.
-- The percentage change column will be populated from the 2nd month forward and can be calculated as ((this month's revenue - last month's revenue) / last month's revenue)*100.

-- TABLE DESCRIPTION
-- sf_transactions
-- created_at: date
-- id: bigint
-- purchase_id: bigint
-- value: bigint

with bymonth as (
SELECT
    DATE_TRUNC('month', created_at) as purmonth,
    SUM(value) as revenue
FROM sf_transactions
GROUP BY DATE_TRUNC('month', created_at)
),

withlags as (
    SELECT
        purmonth,
        revenue,
        LAG(revenue) OVER(ORDER BY purmonth) lastmonth
    FROM
        bymonth
)

SELECT
    purmonth,
    revenue,
    revenue - lastmonth as revenue_change,
    ((revenue - lastmonth) / lastmonth) * 100 as percent_change
FROM
    withlags
WHERE
    revenue - lastmonth IS NOT NULL 