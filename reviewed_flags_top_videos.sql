-- For the video (or videos) that received the most user flags, how many of these flags were reviewed by YouTube? Output the video ID and the corresponding number of reviewed flags.  Ignore flags that do not have a corresponding flag_id.

-- TABLE DESCRIPTION

-- user_flags
-- flag_id: text
-- user_firstname: text
-- user_lastname: text
-- video_id: text

-- flag_review
-- flag_id: text
-- reviewed_by_yt: boolean
-- reviewed_date: date
-- reviewed_outcome: text

with flag_rank as (
    SELECT
        video_id,
        RANK() OVER(order by count(u.flag_id) DESC) as rnk,
        SUM(reviewed_by_yt::int) as flag_count
    FROM user_flags u
    JOIN flag_review r
        ON u.flag_id = r.flag_id
    GROUP by video_id
    ORDER BY rnk
    )

SELECT 
    video_id,
    flag_count
FROM flag_rank
WHERE rnk = 1