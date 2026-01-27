-- Given the users' sessions logs on a particular day, calculate how many hours each user was active that day.

-- Note: The session starts when state=1 and ends when state=0.

-- TABLE DESCRIPTION
-- cust_tracking
-- cust_id: text
-- state: bigint
-- timestamp: timestamp without time zone


WITH sessions as (
    SELECT
        cust_id,
        state,
        timestamp logoff,
        LAG(timestamp) OVER(PARTITION BY cust_id ORDER BY timestamp ASC) as logon
    FROM cust_tracking
    ORDER BY cust_id, logoff DESC
    ),

epoch_logged AS (
    SELECT
        cust_id,
        date(logoff) as event_day,
        EXTRACT('EPOCH' FROM logoff) - EXTRACT('EPOCH' FROM logon) as online_time
    FROM
        sessions
    WHERE state = 0
    )

    
SELECT
    cust_id,
    sum(online_time) / 3600 as hour_logged
FROM
    epoch_logged
GROUP BY
    cust_id