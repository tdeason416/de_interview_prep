-- Compare the total number of comments made by users in each country during December 2019 and January 2020.
-- For each month, rank countries by their total number of comments in descending order. Countries with the same total should share the same rank, and the next rank should increase by one (without skipping numbers).
-- Return the names of the countries whose rank improved from December to January (that is, their rank number became smaller).

-- TABLES DESCRIPTION

-- fb_comments_count
-- created_at:date
-- number_of_comments: bigint 
-- user_id:bigint

-- fb_active_users
-- country:text
-- name: text
-- status: text
-- user_id: bigint


-- Comments per user ID


with extract_month as (
    SELECT
        user_id,
        EXTRACT('year' FROM Created_at) as year_of_comment,
        EXTRACT('month' FROM created_at) as month_of_comment,
        number_of_comments
    FROM
        fb_comments_count
        ),

jan20 as (
    SELECT
        country,
        year_of_comment,
        month_of_comment,
        sum(number_of_comments) as count20
    FROM extract_month e
    JOIN 
        fb_active_users u
        ON e.user_id = u.user_id
        AND year_of_comment = 2020 
        AND month_of_comment = 1
    GROUP BY
        country,
        year_of_comment,
        month_of_comment
    ORDER BY
        country,
        year_of_comment,
        month_of_comment
        ),
        
dec19 as (
    SELECT
        country,
        year_of_comment,
        month_of_comment,
        sum(number_of_comments) as count19
    FROM extract_month e
    JOIN 
        fb_active_users u
        ON e.user_id = u.user_id
        AND year_of_comment = 2019 
        AND month_of_comment = 12
    GROUP BY
        country,
        year_of_comment,
        month_of_comment
    ORDER BY
        country,
        year_of_comment,
        month_of_comment
        ),
 
rank20 as (   
    SELECT
        country,
        count20,
        DENSE_RANK() OVER (ORDER BY count20 DESC) rank20
    FROM jan20
    ORDER BY rank20 DESC
    ),
    
rank19 as (
    SELECT
        country,
        count19,
        DENSE_RANK() OVER (ORDER BY count19 DESC) rank19
    FROM dec19
    ORDER BY rank19 DESC
    )
    
SELECT
    rank20.country
    -- rank19,
    -- rank20,
    -- rank19.rank19 - rank20.rank20 AS rank_change
FROM rank20
JOIN rank19
    ON rank20.country = rank19.country
WHERE
    rank19.rank19 - rank20.rank20 > 0
    
    