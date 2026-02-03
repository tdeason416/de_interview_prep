-- Find the best-selling item for each month (no need to separate months by year). The best-selling item is determined by the highest total sales amount, calculated as: total_paid = unitprice * quantity. A negative quantity indicates a return or cancellation (the invoice number begins with 'C'. To calculate sales, ignore returns and cancellations. Output the month, description of the item, and the total amount paid.

-- TABLE DESCRIPTION
-- online_retail
-- country: text
-- customerid: double precision
-- description: text
-- invoicedate: date
-- invoiceno: text
-- quantity: bigint  
-- stockcode: text
-- unitprice: double precision

with truncd as (
    SELECT
        description,
        CAST(quantity as double precision) * unitprice AS transval,
        -- DATE_TRUNC('month', invoicedate) as invoice_month
        EXTRACT("month" FROM invoicedate) as invoice_month
    FROM online_retail
    WHERE quantity > 0
    ),

monthvals as (
    SELECT
        description,
        invoice_month,
        SUM(transval) total_value
    FROM truncd
    GROUP BY description, invoice_month
    ),

valranks as (
    SELECT
        description,
        invoice_month,
        total_value,
        RANK() OVER(PARTITION BY invoice_month ORDER BY total_value DESC) as valrank
    FROM monthvals
    ORDER BY invoice_month, valrank
    )
    
SELECT
    description,
    invoice_month,
    total_value
FROM valranks
WHERE valrank = 1