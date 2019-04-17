-- use the saklia database
USE sakila;

-- 1a
SELECT first_name, last_name FROM actor;

-- 1b
SELECT concat(first_name, "  ",  last_name) AS "Actor Name"
FROM actor;


-- 2a
SELECT actor_id, first_name, last_name
FROM actor
WHERE first_name ="Joe"

-- 2b
SELECT  last_name, first_name
FROM actor
WHERE last_name LIKE "%gen%";

-- 2c
SELECT  last_name, first_name
FROM actor
WHERE last_name LIKE "%LI%";

-- 2d. Using IN, display the country_id and country columns of the following countries: Afghanistan, Bangladesh, and China

SELECT country_id, country
FROM country 
WHERE country IN ("Afghanistan" , "Bangladesh", "China");

-- 3a. You want to keep a description of each actor. You don't think you will be performing queries on a description, 
-- so create a column in the table actor named description and use the data type BLOB 

AlTER TABLE actor
ADD COlUMN description
BLOB NOT NULL;

-- 3b. Very quickly you realize that entering descriptions for each actor is too much effort. Delete the description column.

ALTER TABLE actor DROP description;

-- 4a. List the last names of actors, as well as how many actors have that last name.
 SELECT  last_name, COUNT(last_name) AS Counter
 FROM actor
 GROUP BY last_name;
 
 
 
 -- 4b. List last names of actors and the number of actors who have that last name, but only for names that are shared by at least two actors

 SELECT  last_name, COUNT(last_name) AS Counter
 FROM actor
 GROUP BY last_name
 HAVING Count(last_name) >= 2;
 
 -- 4c. The actor HARPO WILLIAMS was accidentally entered in the actor table as GROUCHO WILLIAMS. Write a query to fix the record.
SELECT first_name, actor_id, last_name
FROM actor
WHERE first_name = "Groucho" AND last_name ="Williams";



UPDATE actor
SET first_name = "Harpo"
WHERE first_name = "Groucho" AND last_name ="Williams";

-- 4d. Perhaps we were too hasty in changing GROUCHO to HARPO. It turns out that GROUCHO was the correct name after all! In a single query, if the first name of the actor is currently HARPO, change it to GROUCHO.

UPDATE actor
SET first_name = "Groucho"
WHERE first_name = "Harpo" AND last_name = "Williams";

-- 5a. You cannot locate the schema of the address table. Which query would you use to re-create it?
DESCRIBE sakila.address

SHOW CREATE TABLE address;


-- 6a. Use JOIN to display the first and last names, as well as the address, of each staff member. Use the tables staff and address:

SELECT staff.first_name, staff.last_name, address.address
FROM staff
JOIN address ON 
staff.address_id = address.address_id;

-- 6b. Use JOIN to display the total amount rung up by each staff member in August of 2005. Use tables staff and payment.

SELECT staff.first_name, staff.last_name, payment_date, SUM(payment.amount)
FROM staff
JOIN payment ON 
staff.staff_id = payment.staff_id;

-- 6c. List each film and the number of actors who are listed for that film. Use tables film_actor and film. Use inner join.

SELECT film.title, COUNT(film_actor.actor_id)
FROM film
INNER JOIN film_actor ON 
film.film_id = film_actor.film_id
GROUP BY film.title;

-- 6d. How many copies of the film Hunchback Impossible exist in the inventory system?

SELECT film.title, COUNT(inventory.inventory_id) AS "IN stock"
FROM inventory
JOIN film
ON film.film_id = inventory.film_id
WHERE title = "Hunchback Impossible";

-- 6e. Using the tables payment and customer and the JOIN command, list the total paid by each customer. List the customers alphabetically by last name:

SELECT customer.last_name, customer.first_name, SUM(payment.amount) AS "Total"
FROM customer 
LEFT JOIN payment ON 
customer.customer_id = payment.customer_id
GROUP BY customer.last_name, customer.first_name
ORDER BY customer.last_name ASC;

-- 7a. The music of Queen and Kris Kristofferson have seen an unlikely resurgence. As an unintended consequence, films starting with the letters K and Q have also soared in popularity.
-- Use subqueries to display the titles of movies starting with the letters K and Q whose language is English.

SELECT title
FROM film
WHERE (title LIKE 'K%' OR title LIKE 'Q%') 
AND language_id=
	(SELECT language_id 
    FROM 
    language 
    WHERE name='English');
    
-- 7b. Use subqueries to display all actors who appear in the film Alone Trip.

SELECT first_name, last_name
FROM actor
WHERE actor_id IN 
(SELECT actor_id 
FROM film_actor 
WHERE film_id
IN (SELECT film_id 
FROM film
WHERE title = "Alone Trip"));

-- 7c. You want to run an email marketing campaign in Canada, for which you will need the names and email addresses of all Canadian customers. Use joins to retrieve this information.
SELECT first_name, last_name, email 
FROM customer c
JOIN address a ON (c.address_id = a.address_id)
JOIN city cit ON (a.city_id=cit.city_id)
JOIN country cntry ON (cit.country_id=cntry.country_id)
WHERE country = "Canada";

-- 7d. Sales have been lagging among young families, and you wish to target all family movies for a promotion. Identify all movies categorized as family films.

SELECT title, name , rating
FROM film f
JOIN film_category c 
ON f.film_id = c.film_id
JOIN category cd
ON c.category_id = cd.category_id
WHERE name = "Family";


-- 7e. Display the most frequently rented movies in descending order.
SELECT inventory.film_id, film_text.title, COUNT(rental.inventory_id) FROM inventory
JOIN rental ON inventory.inventory_id = rental.inventory_id
JOIN film_text ON inventory.film_id = film_text.film_id
GROUP BY rental.inventory_id ORDER BY COUNT(rental.inventory_id) DESC;






-- 7f. Write a query to display how much business, in dollars, each store brought in.

SELECT SUM(amount), store.store_id
FROM payment p
JOIN staff s
ON s.staff_id = p.staff_id
JOIN store 
ON store.store_id = s.store_id
GROUP BY store.address_id;

-- 7g. Write a query to display for each store its store ID, city, and country.
SELECT store_id, city, country
FROM city
JOIN country c
ON c.country_id = city.country_id
JOIN address a
ON a.city_id = city.city_id
JOIN store s
ON s.address_id = a.address_id;


-- 7h. List the top five genres in gross revenue in descending order. (Hint: you may need to use the following tables: category, film_category, inventory, payment, and rental.)
SELECT name, SUM(p.amount)
FROM category c
JOIN film_category fc
ON c.category_id = fc.category_id
JOIN inventory i
JOIN rental r
ON r.inventory_id = i.inventory_id
JOIN payment p
ON p.rental_id = r.rental_id
GROUP BY name ORDER BY SUM(p.amount) DESC
LIMIT 5;

-- 8a. In your new role as an executive, you would like to have an easy way of viewing the Top five genres by gross revenue. Use the solution from the problem above to create a view. If you haven't solved 7h, you can substitute another query to create a view.

CREATE VIEW top_five AS
SELECT name, SUM(p.amount)
FROM category c
JOIN film_category fc
ON c.category_id = fc.category_id
JOIN inventory i
JOIN rental r
ON r.inventory_id = i.inventory_id
JOIN payment p
ON p.rental_id = r.rental_id
GROUP BY name ORDER BY SUM(p.amount) DESC
LIMIT 5;

-- 8b How would you display the view that you created in 8a
SELECT * FROM top_five;

-- 8c You find that you no longer need the view top_five_genres. Write a query to delete it.
DROP VIEW top_five;