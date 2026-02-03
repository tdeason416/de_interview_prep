-- You work as a data analyst for an e-commerce platform. The sales team needs to understand the net revenue performance of Product ID 'PROD-2891' in the US market for purchases made during a recent two-week period. The dataset contains purchases and refunds. Refunds link to their original purchase via the original_transaction_id field.
-- Calculate daily net revenue for April 15-28, 2025. For each purchase date, sum all purchases from that day plus all refunds linked to those purchases (regardless of when the refund occurred). Include only completed transactions. Show zero for days with no activity. Return the transaction date and the calculated daily net revenue.

-- Table DESCRIPTION
-- product_sales
-- amount: double precision
-- country: text
-- original_transaction_id: text
-- product_id: text
-- status: text
-- transaction_date: date
-- transaction_id: text
-- type: text

--  April 15-28, 2025

with purchases as (
    SELECT
        product_id,
        transaction_date,
        transaction_id,
        amount
    FROM
        product_sales
    WHERE
        status = 'completed'
        AND type = 'purchase'
        AND product_id = 'PROD-2891'
        AND country = 'US'
        AND transaction_date BETWEEN '2025-04-15' AND '2025-04-28'
),

returns as (
    SELECT
        p.transaction_date,
        p.transaction_id,
        s.amount
    FROM product_sales s
    JOIN purchases p
        ON p.transaction_id = s.original_transaction_id
        AND s.type = 'refund'
        AND s.status = 'completed'
    ORDER by p.transaction_date
    ),
    
all_dates AS (
    SELECT date::DATE transaction_date, 0 amount
    FROM GENERATE_SERIES(
        DATE '2025-04-15',
        DATE '2025-04-28',
        INTERVAL '1 day'
    ) AS date
)

SELECT
    a.transaction_date,
    SUM(a.amount) + COALESCE(SUM(p.amount), 0) + COALESCE(SUM(r.amount), 0) as total
FROM all_dates a
LEFT JOIN purchases p
    ON a.transaction_date = p.transaction_date
LEFT JOIN returns r
    ON p.transaction_id = r.transaction_id
    AND a.transaction_date = r.transaction_date
GROUP BY
    a.transaction_date
order by a.transaction_date
