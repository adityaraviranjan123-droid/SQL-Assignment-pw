-- Maven Movies SQL Assignment
-- Topics: Subqueries, Window Functions, CTEs, Views and Stored Procedures
-- Database: Maven Movies Data
-- MySQL 8+

USE mavenmovies;

-- ------------------------------------------------------------
-- QUESTION 1
-- Customers who have rented more movies than the average
-- number of rentals made by all customers.
-- ------------------------------------------------------------

 CREATE VIEW customer_rentals AS
    SELECT
        customer_id,
        COUNT(*) AS rental_count FROM rental
    GROUP BY customer_id;

SELECT
    c.customer_id,
    c.first_name,
    c.last_name,
    cr.rental_count
FROM customer c
JOIN customer_rentals cr
    ON c.customer_id = cr.customer_id
WHERE cr.rental_count > (
    SELECT AVG(rental_count)
    FROM customer_rentals
)
ORDER BY cr.rental_count DESC;

-- -------------------------------------------------------------
-- QUESTION 2
-- Display each film with rental rate and rank from highest
-- to lowest rental rate.
-- -------------------------------------------------------------

SELECT
    film_id,
    title,
    rental_rate,
    
    (SELECT COUNT(*) +1 
    FROM film f2
    WHERE f2.rental_rate > f1.rental_rate)
    AS rate_rank
FROM film f1
ORDER BY rental_rate DESC, title;


-- -----------------------------------------------------------------
-- QUESTION 3
-- Create a view showing customer name, email and active status.
-- -----------------------------------------------------------------

DROP VIEW IF EXISTS customer_active_view;

CREATE VIEW customer_active_view AS
SELECT
    customer_id,
    first_name,
    last_name,
    email,
    active
FROM customer;

-- Test the view
SELECT *
FROM customer_active_view;


---------------------------------------------------------------
-- QUESTION 4
-- Top 10 customers who generated the highest payment amount.
---------------------------------------------------------------

SELECT
    c.customer_id,
    c.first_name,
    c.last_name,
    SUM(p.amount) AS total_payment
FROM customer c
JOIN payment p
    ON c.customer_id = p.customer_id
GROUP BY
    c.customer_id,
    c.first_name,
    c.last_name
ORDER BY total_payment DESC
LIMIT 10;


-------------------------------------------------------------
-- QUESTION 5
-- Customers whose total rental spending falls within the
-- top 20% of all customers.
-------------------------------------------------------------


CREATE VIEW customer_spending AS 
    SELECT
        c.customer_id,
        c.first_name,
        c.last_name,
        SUM(p.amount) AS total_spending,
        CASE
        WHEN SUM(p.amount) >= 150 THEN 1
        WHEN SUM(p.amount) >= 120 THEN 2
        WHEN SUM(p.amount) >= 90 THEN 3
        WHEN SUM(p.amount) >= 60 THEN 4
        ELSE 5
        
        END AS spending_group
    FROM customer c
    JOIN payment p
        ON c.customer_id = p.customer_id
    GROUP BY
        c.customer_id,
        c.first_name,
        c.last_name;

SELECT
    customer_id,
    first_name,
    last_name,
    total_spending
FROM customer_spending
WHERE spending_group = 1
ORDER BY total_spending DESC;


-- -------------------------------------------------------------
-- QUESTION 6
-- Every actor with number of movies acted in and dense rank
-- based on movie count.
-- -------------------------------------------------------------

SELECT
    a.actor_id,
    a.first_name,
    a.last_name,
    COUNT(fa.film_id) AS movie_count,
    (
         SELECT COUNT(DISTINCT movie_count_sub) +1
     
       FROM (
	SELECT COUNT(film_id) AS movie_count_sub
    FROM film_actor
    GROUP BY actor_id
    ) AS t
    WHERE t.movie_count_sub > COUNT(fa.film_id)
        
   )  AS movie_count_rank
FROM actor a
LEFT JOIN film_actor fa
    ON a.actor_id = fa.actor_id
GROUP BY
    a.actor_id,
    a.first_name,
    a.last_name
ORDER BY movie_count DESC, a.last_name, a.first_name;


-- -----------------------------------------------------------
-- QUESTION 7
-- Create a view showing movie title, category, rental rate
-- and replacement cost.
-- ------------------------------------------------------------

DROP VIEW IF EXISTS movie_details_view;

CREATE VIEW movie_details_view AS
SELECT
    f.film_id,
    f.title,
    c.name AS category,
    f.rental_rate,
    f.replacement_cost
FROM film f
JOIN film_category fc
    ON f.film_id = fc.film_id
JOIN category c
    ON fc.category_id = c.category_id;

-- Test the view
SELECT *
FROM movie_details_view;


-- ------------------------------------------------------------
-- QUESTION 8
-- Stored procedure returning the top 20 most rented movies.
-- ------------------------------------------------------------

DROP PROCEDURE IF EXISTS sp_top_20_rented_movies;

DELIMITER $$

CREATE PROCEDURE sp_top_20_rented_movies()
BEGIN
    SELECT
        f.film_id,
        f.title,
        COUNT(r.rental_id) AS rental_count
    FROM film f
    JOIN inventory i
        ON f.film_id = i.film_id
    JOIN rental r
        ON i.inventory_id = r.inventory_id
    GROUP BY
        f.film_id,
        f.title
    ORDER BY rental_count DESC
    LIMIT 20;
END $$

DELIMITER ;

-- Execute procedure
CALL sp_top_20_rented_movies();


-- ---------------------------------------------------------------
-- QUESTION 9
-- Procedure accepting a movie rating and returning all movies
-- with that rating.
-- ---------------------------------------------------------------


SELECT 
    film_id,
    title,
    category_id,
    category,
    rental_count,
    category_rank
FROM (
    SELECT 
        film_id,
        title,
        category_id,
        category,
        rental_count,
        @rank := IF(@current_cat = category_id, @rank + 1, 1) AS category_rank,
        @current_cat := category_id
    FROM film_rentals, (SELECT @rank := 0, @current_cat := NULL) r
    ORDER BY category_id, rental_count DESC, film_id
) AS ranked_films
WHERE category_rank <= 3
ORDER BY category, category_rank;
-- ---------------------------------------------------------------
-- QUESTION 11
-- Running total of rentals per category, ordered by rental count.
-- ---------------------------------------------------------------

 CREATE VIEW category_rentals AS (
    SELECT
        c.category_id,
        c.name AS category,
        f.film_id,
        f.title,
        COUNT(r.rental_id) AS rental_count
    FROM category c
    JOIN film_category fc
        ON c.category_id = fc.category_id
    JOIN film f
        ON fc.film_id = f.film_id
    JOIN inventory i
        ON f.film_id = i.film_id
    JOIN rental r
        ON i.inventory_id = r.inventory_id
    GROUP BY
        c.category_id,
        c.name,
        f.film_id,
        f.title
);
SELECT
    cr1.category,
    cr1.title,
    cr1.rental_count,
    (
        SELECT SUM(cr2.rental_count)
        FROM category_rentals cr2
        WHERE cr2.category_id = cr1.category_id
          AND (
              cr2.rental_count > cr1.rental_count 
              OR (cr2.rental_count = cr1.rental_count AND cr2.film_id <= cr1.film_id)
          )
    ) AS running_total
FROM category_rentals cr1
ORDER BY cr1.category, cr1.rental_count DESC, cr1.film_id;


-- ---------------------------------------------------------------
-- QUESTION 12
-- CTE showing pairs of actors who appeared in the same film.
-- Uses film_actor table.
-- ---------------------------------------------------------------


CREATE VIEW actor_pairs AS
SELECT 
        fa1.film_id,
        fa1.actor_id AS actor1_id,
        fa2.actor_id AS actor2_id
    FROM film_actor fa1
    JOIN film_actor fa2
        ON fa1.film_id = fa2.film_id
       AND fa1.actor_id < fa2.actor_id;

SELECT
    CONCAT(a1.first_name, ' ', a1.last_name) AS actor1,
    CONCAT(a2.first_name, ' ', a2.last_name) AS actor2,
    COUNT(DISTINCT ap.film_id) AS common_films
FROM actor_pairs ap
JOIN actor a1
    ON ap.actor1_id = a1.actor_id
JOIN actor a2
    ON ap.actor2_id = a2.actor_id
GROUP BY
    ap.actor1_id,
    ap.actor2_id,
    a1.first_name,
    a1.last_name,
    a2.first_name,
    a2.last_name
ORDER BY common_films DESC, actor1, actor2;


-- --------------------------------------------------------------
-- QUESTION 13
-- Procedure accepting customer ID and returning total payment
-- through an OUT parameter.
-- --------------------------------------------------------------

DROP PROCEDURE IF EXISTS sp_customer_total_payment;

DELIMITER $$

CREATE PROCEDURE sp_customer_total_payment(
    IN p_customer_id INT,
    OUT p_total_amount DECIMAL(10,2)
)
BEGIN
    SELECT
        COALESCE(SUM(amount), 0.00)
    INTO p_total_amount
    FROM payment
    WHERE customer_id = p_customer_id;
END $$

DELIMITER ;

-- Example:
-- SET @total_payment = 0;
-- CALL sp_customer_total_payment(1, @total_payment);
-- SELECT @total_payment AS total_payment;


-- -----------------------------------------------------------
-- END OF ASSIGNMENT
-- -----------------------------------------------------------
