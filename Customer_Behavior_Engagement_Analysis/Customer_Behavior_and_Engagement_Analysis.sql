USE mavenmovies;
SHOW TABLES;


# Objective 1 : Customer Behaviour  and Engagement Analysis



## 1. Customers with the Highest Total Rental Frequency

SELECT c.customer_id, c.first_name, c.last_name, COUNT(r.rental_id) AS total_rentals
FROM customer c
JOIN rental r ON c.customer_id = r.customer_id
GROUP BY c.customer_id, c.first_name, c.last_name
ORDER BY total_rentals DESC LIMIT 10;


## 2. Average Rental Amount and Frequency per Customer in Each City

SELECT a.city_id, c.customer_id, c.first_name, c.last_name,
COUNT(r.rental_id) AS rental_count,
AVG(p.amount) AS avg_payment
FROM customer c
JOIN address a ON c.address_id = a.address_id
LEFT JOIN rental r ON c.customer_id = r.customer_id
LEFT JOIN payment p ON r.rental_id = p.rental_id
GROUP BY a.city_id, c.customer_id, c.first_name, c.last_name
ORDER BY rental_count DESC LIMIT 10;


## 3. Which customers have the highest total payment amounts across all their rentals?

SELECT c.customer_id, c.first_name, c.last_name, SUM(p.amount) AS total_payment
FROM customer c
JOIN payment p ON c.customer_id = p.customer_id
GROUP BY c.customer_id, c.first_name, c.last_name
ORDER BY total_payment DESC LIMIT 10;


## 4. Customers with No Rentals in Last 3 Months

SELECT c.customer_id, c.first_name, c.last_name
FROM customer c
LEFT JOIN rental r 
ON c.customer_id = r.customer_id AND r.rental_date >= DATE_SUB(CURDATE(), INTERVAL 3 MONTH)
WHERE r.rental_id IS NULL;


## 5. Which customers have rented the most distinct film titles?

SELECT c.customer_id,c.first_name,c.last_name,COUNT(DISTINCT f.film_id) AS distinct_films_rented
FROM customer c
JOIN rental r ON c.customer_id = r.customer_id
JOIN inventory i ON r.inventory_id = i.inventory_id
JOIN film f ON i.film_id = f.film_id
GROUP BY c.customer_id, c.first_name, c.last_name
ORDER BY distinct_films_rented DESC
LIMIT 10;


## 6. Customer Segments Renting Most During Weekends

SELECT c.customer_id, c.first_name, c.last_name, COUNT(r.rental_id) AS weekend_rentals
FROM customer c
JOIN rental r ON c.customer_id = r.customer_id
WHERE DAYOFWEEK(r.rental_date) IN (1,7)    -- 1=Sunday, 7=Saturday in MySQL
GROUP BY c.customer_id, c.first_name, c.last_name
ORDER BY weekend_rentals DESC;


## 7. Which customers have the shortest average turnaround time between renting and returning movies?

SELECT c.customer_id,c.first_name,c.last_name,
ROUND(AVG(DATEDIFF(r.return_date, r.rental_date)), 2) AS avg_turnaround_days
FROM customer c
JOIN rental r ON c.customer_id = r.customer_id
WHERE r.return_date IS NOT NULL
GROUP BY c.customer_id, c.first_name, c.last_name
ORDER BY avg_turnaround_days ASC
LIMIT 10;
## 8. Percentage of Customers Who Are Repeat Renters

SELECT ROUND(100.0 * SUM(is_repeat)/COUNT(*), 2) AS repeat_pct
FROM (
    SELECT c.customer_id, CASE WHEN COUNT(r.rental_id) > 1 THEN 1 ELSE 0 END AS is_repeat
    FROM customer c
    LEFT JOIN rental r ON c.customer_id = r.customer_id
    GROUP BY c.customer_id
) AS sub;

## 9. Distribution of Active vs. Inactive Customers by City and Store
SELECT s.store_id, a.city_id, c.active, COUNT(*) AS num_customers
FROM customer c
JOIN address a ON c.address_id = a.address_id
JOIN store s ON c.store_id = s.store_id
GROUP BY s.store_id, a.city_id, c.active;

## 10. Average Customer Lifetime Value

SELECT AVG(lifetime_value) AS avg_clv
FROM (
    SELECT c.customer_id, SUM(p.amount) AS lifetime_value
    FROM customer c
    JOIN payment p ON c.customer_id = p.customer_id
    GROUP BY c.customer_id
) AS sub;

