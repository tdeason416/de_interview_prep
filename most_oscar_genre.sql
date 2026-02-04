Find the genre of the person with the most number of oscar winnings.
-- If there are more than one person with the same number of oscar wins, return the first one in alphabetic order based on their name. Use the names as keys when joining the tables.
-- Table DESCRIPTION
-- oscar_nominees
-- category: text
-- id: bigint
-- movie: text
-- nominee: text
-- winner: boolean
-- year: bigint

-- nominee_information 
-- amg_person_id: character varying
-- birthday:date
-- id: bigint
-- name: character varying
-- top_genre: character varying

SELECT
    i.top_genre
FROM oscar_nominees o
JOIN nominee_information i
    ON o.nominee = i.name
GROUP BY
    o.nominee,
    i.top_genre
ORDER BY COUNT(movie) DESC, nominee LIMIT 1