-- Provided a table with user id and the dates they visited the platform, find the top 5 users with the longest continuous streak of visiting the platform as of August 10, 2022. Output the user ID and the length of the streak.
-- In case of a tie, display all users with the top three longest streaks.

-- TABLE DESCRIPTION
-- date_visited: date
-- user_id: text

with last_login as (
    SELECT
        user_id,
        date_visited,
        -- LEAD(date_visited, 1) OVER(partition by user_id ORDER BY date_visited DESC) as last_date,
        date_visited - LEAD(date_visited, 1) OVER(partition by user_id ORDER BY date_visited DESC) as num_days
    FROM user_streaks
    WHERE date_visited <= '2022-08-10'
    GROUP By user_id, date_visited
    ),

streak_group as ( 
    SELECT
        user_id,
        date_visited,
        num_days,
        SUM(CASE WHEN num_days != 1 THEN 1 ELSE 0 END) 
                OVER (PARTITION BY user_id ORDER BY date_visited ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS streak_id
    FROM
        last_login
    ),
    
streak_length as (
    SELECT
        user_id,
        streak_id,
        SUM(num_days) + 1 streak_length
    FROM
        streak_group
    WHERE
        num_days = 1
    GROUP BY
        user_id,
        streak_id
    ORDER BY
        streak_length DESC
    )

SELECT user_id, max(streak_length) max_streak
FROM streak_length
GROUP BY user_id
ORDER BY max_streak DESC
LIMIT 5;