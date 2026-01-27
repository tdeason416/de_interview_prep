-- Find all the users who were active for 3 consecutive days or more.

-- TABLE DESCRIPTION
-- account_id: character varying
-- record_date: date
-- user_id: character varying


WITH pivoted AS (
    SELECT
        record_date,
        user_id,
        record_date - LAG(record_date) OVER (
            PARTITION BY user_id 
            ORDER BY record_date
            ) one_login_back,
        record_date - LAG(record_date, 2) OVER (
            PARTITION BY user_id 
            ORDER BY record_date
            ) two_logins_back
    FROM sf_events
    ORDER BY record_date DESC
    )
    
SELECT
    user_id
FROM
    pivoted
WHERE
    one_login_back = 1
    AND two_logins_back = 2