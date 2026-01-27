-- You are given a table of tennis players and their matches that they could either win (W) or lose (L). Find the longest streak of wins. A streak is a set of consecutive won matches of one player. The streak ends once a player loses their next match.
-- For this question, disregard edge cases such as: players who never lose, streaks that start before the first loss, and streaks that continue after the final match.
-- TABLE DESCRIPTION
-- players_results
-- match_date: date
-- match_result: text
-- player_id: bigint


WITH ordered_matches AS (
    SELECT 
        player_id,
        match_date,
        match_result,
        ROW_NUMBER() OVER (PARTITION BY player_id ORDER BY match_date DESC) AS rn
    FROM players_results
),

loss_cumulative AS (
    SELECT 
        player_id,
        match_date,
        match_result,
        SUM(CASE WHEN match_result = 'L' THEN 1 ELSE 0 END) 
            OVER (PARTITION BY player_id ORDER BY match_date ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS group_id
    FROM ordered_matches
    -- ORDER BY player_id, match_date DESC
    ORDER BY player_id, group_id DESC, match_date DESC
),

w_streaks AS (
    SELECT 
        player_id,
        group_id,
        COUNT(*) AS w_count
    FROM loss_cumulative
    WHERE match_result = 'W'
    GROUP BY player_id, group_id
),

streak_with_rank AS (
    SELECT 
        player_id,
        w_count,
        RANK() OVER (ORDER BY w_count DESC) as win_rank
    FROM w_streaks
    )
    
SELECT
    player_id,
    w_count AS longest_win_streak
FROM
    streak_with_rank
WHERE
    win_rank = 1
    