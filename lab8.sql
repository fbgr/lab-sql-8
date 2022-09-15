USE sakila;

-- 1. Write a query to display for each store its store ID, city, and country.
SELECT s.store_id, c.city, co.country
FROM sakila.store s INNER JOIN sakila.address a USING(address_id)
INNER JOIN sakila.city c USING(city_id)
INNER JOIN sakila.country co using (country_id);

-- 2. Write a query to display how much business, in dollars, each store brought in.
SELECT s.store_id, SUM(p.amount) as business
FROM sakila.payment p INNER JOIN sakila.staff s USING(staff_id)
GROUP BY s.store_id;

-- 3. Which film categories are longest? -> Sports
SELECT cat.name,avg(length) as avg_length
FROM sakila.film f INNER JOIN sakila.film_category fc USING(film_id)
INNER JOIN category cat USING(category_id)
GROUP BY cat.name
ORDER BY avg_length DESC;

-- 4. Display the most frequently rented movies in descending order.
SELECT f.title,COUNT(rental_id) as times_rented
FROM sakila.rental r INNER JOIN sakila.inventory i USING(inventory_id)
INNER JOIN sakila.film f USING(film_id)
GROUP BY f.title
ORDER BY times_rented DESC;

-- 5. List the top five genres in gross revenue in descending order.
SELECT cat.name, SUM(p.amount) as total_revenue
FROM sakila.payment p INNER JOIN sakila.rental r USING(rental_id)
INNER JOIN sakila.inventory i USING(inventory_id)
INNER JOIN sakila.film f USING(film_id)
INNER JOIN sakila.film_category fc using(film_id)
INNER JOIN sakila.category cat using(category_id)
GROUP BY cat.name
ORDER BY total_revenue DESC
LIMIT 5;

-- 6. Is "Academy Dinosaur" available for rent from Store 1? -> Yes, they have 4 copies in Store 1
SELECT *
FROM sakila.film f INNER JOIN sakila.inventory i USING (film_id)
WHERE f.title = 'Academy Dinosaur' AND store_id = 1;

-- 7. Get all pairs of actors that worked together.
SELECT *
FROM (SELECT CONCAT(a.first_name,' ',a.last_name) AS actor,fa.film_id
FROM sakila.film_actor fa INNER JOIN sakila.actor a using (actor_id)) ACT1 
INNER JOIN
(SELECT CONCAT(a.first_name,' ',a.last_name) AS actor,fa.film_id
FROM sakila.film_actor fa INNER JOIN sakila.actor a using (actor_id)) ACT2 
ON (ACT1.film_id = ACT2.film_id) AND (ACT1.actor <> ACT2.actor);

-- 8. Get all pairs of customers that have rented the same film more than 3 times.
SELECT *, CUST1.times_rented+CUST2.times_rented AS sum_times_rented
FROM (SELECT i.film_id as film, r.customer_id as customer, COUNT(film_id) as times_rented
FROM sakila.rental r INNER JOIN sakila.inventory i USING(inventory_id)
GROUP BY i.film_id, r.customer_id) CUST1 INNER JOIN
(SELECT i.film_id as film, r.customer_id as customer, COUNT(film_id) as times_rented
FROM sakila.rental r INNER JOIN sakila.inventory i USING(inventory_id)
GROUP BY i.film_id, r.customer_id) CUST2 
ON CUST1.film = CUST2.film AND CUST1.customer <> CUST2.customer
HAVING sum_times_rented > 3;

-- 9. For each film, list actor that has acted in more films.
-- (I know we were supposed to do it with nested queries but I think this way works too:
-- I do an self inner join ON actor=actor but film_id <> film_id, so I lose the actors that do not
-- appear on at least 2 films. Then I just group by actor and film to avoid repitions).
SELECT ACT1.film_id AS film_id, ACT1.actor_id as actor_id
FROM film_actor ACT1 INNER JOIN film_actor ACT2
ON ACT1.actor_id = ACT2.actor_id AND ACT1.film_id <> ACT2.film_id
GROUP BY ACT1.actor_id,ACT1.film_id
ORDER BY film_id;
