-- Calculate the search success rate for new users versus existing users. A successful search is one where the first click event occurs within 30 seconds of the search event.

-- Group all users into two segments:
-- •  new (registered within the last 30 days covered by the dataset — that is, on or after 30 days before the most recent date in the dataset)
-- •  existing (registered earlier).

-- Return one row per user segment with total searches, successful searches, and success rate.

-- TABLE DESCRIPTION(S)
-- search_events
-- event_id:bigint
-- event_timestamp: timestamp without time zone
-- event_type: text
-- query: text
-- session_id: text
-- user_id: bigint

-- accounts
-- country: text
-- registration_date: date
-- user_id: bigint

with search as (
    SELECT
        user_id,
        session_id,
        query,
        event_timestamp
    FROM
        search_events
    WHERE
        event_type = 'search'
),

click as (
    SELECT
        user_id,
        session_id,
        query,
        min(event_timestamp) event_timestamp
    FROM
        search_events
    WHERE
        event_type = 'click'
    GROUP BY 1,2,3
),

success as (
    SELECT
        s.user_id,
        s.session_id,
        c.event_timestamp as clicktime,
        CASE WHEN EXTRACT(EPOCH FROM c.event_timestamp) - EXTRACT(EPOCH FROM s.event_timestamp) <= 30 THEN 1.0 ELSE 0.0 END as success,
        'a' as dummy
    FROM search s
    LEFT JOIN click c
        ON s.session_id = c.session_id
        AND s.user_id = c.user_id
        AND s.query = c.query
),

maxtime as (
    SELECT
        CAST(MAX(event_timestamp) AS DATE) as maxtime,
        'a' as dummy
    FROM search_events
),

new_users as (
    SELECT
    user_id,
    CASE WHEN m.maxtime - a.registration_date <= 30 THEN 'new' ELSE 'existing' END as new_user
    FROM
        (SELECT *, 'a' as dummy FROM accounts) a
    JOIN
        maxtime m
        ON a.dummy = m.dummy
)

SELECT
    n.new_user,
    COUNT(session_id) as searches,
    SUM(success) as successful_searches,
    SUM(success) / COUNT(session_id) as ratio_success
FROM success s
JOIN new_users n
    ON s.user_id = n.user_id
GROUP BY
    n.new_user