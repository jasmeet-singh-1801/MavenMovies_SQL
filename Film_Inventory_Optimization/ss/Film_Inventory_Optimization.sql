USE mavenmovies;
SHOW TABLES;
SELECT * FROM inventory;
SELECT * FROM rental;
SELECT * FROM store;
SELECT * FROM film;


-- -- Objective 2: Film Inventory Optimization
-- 1. Which films are understocked at each store compared to demand?

SELECT 
    i.store_id,
    i.film_id,
    COUNT(i.inventory_id) AS stock_count,
    COALESCE(SUM(r.rental_count), 0) AS rental_count
FROM inventory i
LEFT JOIN (
    SELECT 
        inventory_id, 
        COUNT(*) AS rental_count
    FROM rental
    WHERE rental_date > DATE_SUB(
        (SELECT MAX(rental_date) FROM rental), 
        INTERVAL 12 MONTH)
    GROUP BY inventory_id
) r ON i.inventory_id = r.inventory_id
GROUP BY i.store_id, i.film_id
HAVING rental_count > stock_count
ORDER BY rental_count DESC;

-- 2. What is the average rental frequency for each film in the last 12 months?

SELECT 
    f.film_id, 
    f.title,
    COUNT(r.rental_id) / 12 AS avg_monthly_rentals
FROM film f
JOIN inventory i ON f.film_id = i.film_id
JOIN rental r ON i.inventory_id = r.inventory_id
WHERE r.rental_date > DATE_SUB((SELECT MAX(rental_date) FROM rental), INTERVAL 12 MONTH)
GROUP BY f.film_id, f.title;

-- 3. Films not rented in the last 6 months?

SELECT 
    f.film_id,
    f.title
FROM film f
LEFT JOIN inventory i ON f.film_id = i.film_id
LEFT JOIN rental r 
    ON i.inventory_id = r.inventory_id 
    AND r.rental_date > DATE_SUB((SELECT MAX(rental_date) FROM rental), INTERVAL 6 MONTH)
WHERE r.rental_id IS NULL;


-- 4. Top 10 most frequently rented films by store and month

SELECT 
    s.store_id,
    DATE_FORMAT(r.rental_date, '%Y-%m') AS rental_month,
    f.film_id, 
    f.title,
    COUNT(r.rental_id) AS rentals
FROM rental r
JOIN inventory i ON r.inventory_id = i.inventory_id
JOIN film f ON i.film_id = f.film_id
JOIN store s ON i.store_id = s.store_id
GROUP BY s.store_id, rental_month, f.film_id, f.title
ORDER BY s.store_id, rental_month, rentals DESC
LIMIT 10;

-- 5. Which genres/categories have the highest turnover rates?

SELECT 
    fc.category_id, 
    COUNT(r.rental_id) AS rentals
FROM film_category fc
JOIN inventory i ON fc.film_id = i.film_id
JOIN rental r ON i.inventory_id = r.inventory_id
GROUP BY fc.category_id
ORDER BY rentals DESC;

-- 6. Films with the longest average rental durations
SELECT
    f.film_id,
    f.title,
    ROUND(AVG(TIMESTAMPDIFF(HOUR, r.rental_date, r.return_date)) / 24, 2) AS avg_days_out
FROM film f
JOIN inventory i ON f.film_id = i.film_id
JOIN rental r ON i.inventory_id = r.inventory_id
WHERE r.return_date IS NOT NULL
GROUP BY f.film_id, f.title
ORDER BY avg_days_out DESC
LIMIT 10;

-- 7. Which films are most frequently rented per copy

SELECT 
    f.film_id,
    f.title,
    COUNT(r.rental_id) / COUNT(i.inventory_id) AS rentals_per_copy
FROM film f
JOIN inventory i ON f.film_id = i.film_id
LEFT JOIN rental r ON i.inventory_id = r.inventory_id
    AND r.rental_date > DATE_SUB((SELECT MAX(rental_date) FROM rental), INTERVAL 12 MONTH)
GROUP BY f.film_id, f.title
HAVING COUNT(i.inventory_id) > 0
ORDER BY rentals_per_copy DESC
LIMIT 10;


-- 8. Average days films spend in inventory before rental

SELECT
    f.film_id,
    f.title,
    ROUND(AVG(TIMESTAMPDIFF(DAY, r.rental_date, i.last_update)), 2) AS avg_days_in_inventory
FROM film f
JOIN inventory i ON f.film_id = i.film_id
JOIN rental r ON i.inventory_id = r.inventory_id
GROUP BY f.film_id, f.title
ORDER BY avg_days_in_inventory ASC;

-- 9. Which stores have the widest selection of unique film titles?

SELECT
    s.store_id,
    s.manager_staff_id,
    COUNT(DISTINCT i.film_id) AS unique_films
FROM store s
JOIN inventory i ON s.store_id = i.store_id
GROUP BY s.store_id, s.manager_staff_id
ORDER BY unique_films DESC;


-- 10. What are the least rented films

SELECT
    f.film_id,
    f.title,
    COUNT(r.rental_id) AS total_rentals
FROM film f
JOIN inventory i ON f.film_id = i.film_id
LEFT JOIN rental r ON i.inventory_id = r.inventory_id
    AND r.rental_date > DATE_SUB((SELECT MAX(r.rental_date) FROM rental), INTERVAL 12 MONTH)
GROUP BY f.film_id, f.title
ORDER BY total_rentals ASC
LIMIT 10;
