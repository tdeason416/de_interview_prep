-- Find the popularity percentage for each user on Meta/Facebook. The dataset contains two columns, user1 and user2, which represent pairs of friends. Each row indicates a mutual friendship between user1 and user2, meaning both users are friends with each other. A user's popularity percentage is calculated as the total number of friends they have (counting connections from both user1 and user2 columns) divided by the total number of unique users on the platform. Multiply this value by 100 to express it as a percentage.


-- Output each user along with their calculated popularity percentage. The results should be ordered by user ID in ascending order.

--TABLE DESCRIPTION

-- facebook_friends
-- user1:bigint
-- user2:bigint

with relationships as (
    SELECT user1, user2
    FROM facebook_friends
    UNION
    SELECT user2 as user1, user1 as user2
    FROM facebook_friends
)

SELECT
    user1,
    COUNT(DISTINCT user2)::double precision / (SELECT COUNT(DISTINCT user1) FROM relationships) * 100 as pop_percent
FROM
    relationships
GROUP BY user1
ORDER BY pop_percent DESC