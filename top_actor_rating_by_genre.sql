-- Find the top actors based on their average movie rating within the genre they appear in most frequently.
-- •  For each actor, determine their most frequent genre (i.e., the one they’ve appeared in the most).
-- •   If there is a tie in genre count, select the genre where the actor has the highest average rating.
-- •   If there is still a tie in both count and rating, include all tied genres for that actor.


-- Rank all resulting actor + genre pairs in descending order by their average movie rating.
-- •  Return all pairs that fall within the top 3 ranks (not simply the top 3 rows), including ties.
-- •  Do not skip rank numbers — for example, if two actors are tied at rank 1, the next rank is 2 (not 3).

-- TABLE DESCRIPTION
-- top_actors_rating
-- actor_name: text
-- genre: ext
-- movie_rating: double precision
-- movie_title: text
-- production_company: text
-- release_date: date


with avgrate as (
    SELECT
        actor_name,
        genre,
        COUNT(movie_title) nummovies,
        AVG(movie_rating) avgrate
    FROM
        top_actors_rating

    GROUP BY
        actor_name,
        genre
        ),
        
topranks as (
    SELECT
        actor_name,
        genre,
        avgrate,
        nummovies,
        DENSE_RANK() OVER(PARTITION BY actor_name ORDER BY nummovies DESC, avgrate DESC) as topgenre
    FROM avgrate
    ),

allranks as (
    SELECT
        actor_name,
        genre,
        avgrate,
        DENSE_RANK() OVER(ORDER BY avgrate DESC) actor_rank
    FROM topranks
    WHERE topgenre = 1
    )
    
SELECT
    actor_name,
    genre,
    avgrate,
    actor_rank
FROM allranks
WHERE actor_rank <= 3
ORDER BY actor_rank