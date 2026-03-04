-- Identify all products that experienced a turnaround in user engagement: at least 3 consecutive months of declining monthly active users followed by at least 3 consecutive months of growth.
-- For each product that matches this pattern, return the product name, the month when the decline started, the month when growth resumed, and the growth ratio from the lowest point to the most recent peak, calculated as: (peak_users - lowest_users) / lowest_users.

-- TABLE DESCRIPTION
-- product_engagement
-- month_start: date
-- monthly_active_users: bigint
-- product_id: bigint
-- product_name: text

with deltas as (
    SELECT
        product_name,
        product_id,
        month_start,
        monthly_active_users,
        CASE WHEN 
            monthly_active_users - LAG(monthly_active_users) OVER(partition by product_id order by month_start) > 0 then 1
            WHEN LAG(monthly_active_users) OVER(partition by product_id order by month_start) IS NULL THEN 0
            ELSE -1 END as monthly_change,
        CASE WHEN 
            LAG(monthly_active_users) OVER(partition by product_id order by month_start) - 
                LAG(monthly_active_users, 2) OVER(partition by product_id order by month_start) > 0 then 1
            WHEN LAG(monthly_active_users, 2) OVER(partition by product_id order by month_start) IS NULL THEN 0
            ELSE -1 END as two_months,
        CASE WHEN month_start - LAG(month_start) OVER(PARTITION BY product_id ORDER BY month_start) > 32
            OR LEAD(month_start) OVER(PARTITION BY product_id ORDER BY month_start) - month_start > 32 THEN 0
            ELSE 1 END as seq_months,
        month_start - LAG(month_start) OVER(PARTITION BY product_id ORDER BY month_start) as days_to_next_obs
    FROM product_engagement
    ORDER BY
        product_id, month_start DESC
        ),
        
streak_groups as (  
    SELECT
        product_name,
        product_id,
        month_start,
        monthly_active_users,
        monthly_change,
        two_months,
        SUM(CASE WHEN monthly_change != two_months OR seq_months != 1 THEN 1 ELSE 0 END) 
            OVER(PARTITION BY product_id ORDER BY month_start ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) as streak_group
    FROM
        deltas
    ORDER BY
        product_id,
        month_start DESC
    ),

long_streaks as (
    SELECT
        product_name,
        product_id,
        MAX(monthly_active_users) as peak_users,
        MIN(monthly_active_users) as min_users,
        min(month_start) as streak_start,
        max(monthly_change) as direction,
        COUNT(monthly_change) as streak_length
    FROM
        streak_groups
    GROUP BY
        product_name,
        product_id,
        streak_group
    -- ORDER BY
    --     product_id,
    --     streak_start DESC
    HAVING COUNT(monthly_change) >= 3
),

grouped_streaks as (
    SELECT
        product_name,
        product_id,
        streak_start current_streak_start,
        lag(streak_start) OVER(PARTITION BY product_id ORDER BY streak_start) prev_streak_start,
        direction current_streak_direction,
        LAG(direction) OVER(PARTITION BY product_id ORDER BY streak_start) prev_streak_direction,
        peak_users,
        lag(min_users) OVER(PARTITION BY product_id ORDER BY streak_start) min_users
    FROM
        long_streaks
    ORDER BY
        product_id,
        current_streak_start
        )
        

SELECT
    product_name,
    prev_streak_start decline_started,
    current_streak_start growth_resumed,
    (CAST(peak_users AS FLOAT) - min_users) / min_users as growth_ratio
FROM
    grouped_streaks
WHERE
    current_streak_direction = 1
    AND prev_streak_direction  = -1