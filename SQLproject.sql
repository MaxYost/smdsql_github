/*Project: Investigate a Relational Database*/

/*Question Set #1 Problem 1:
We want to understand more about the movies that families are watching. The following
categories are considered family movies: Animation, Children, Classics, Comedy, Family
and Music. Create a query that lists each movie, the film category it is classified in,
and the number of times it has been rented out.*/

/*Query #1*/
SELECT title,
       genre,
       COUNT(rental_count)
FROM
  (SELECT f.title title,
        c.name genre,
        r.rental_id rental_count
  FROM category c
     JOIN film_category fc
     ON c.category_id = fc.category_id

     JOIN film f
     ON fc.film_id = f.film_id

     JOIN inventory i
     ON f.film_id = i.film_id

     JOIN rental r
     ON i.inventory_id = r.inventory_id

     AND c.name IN ('Animation', 'Children', 'Classics', 'Comedy', 'Family', 'Music')) t1

GROUP BY 1,2
ORDER BY 2;


*/Question Set #1 Problem 2:
Now we need to know how the length of rental duration of these family-friendly movies
compares to the duration that all movies are rented for. Can you provide a table with
the movie titles and divide them into 4 levels (first_quarter, second_quarter, third_quarter,
and final_quarter) based on the quartiles (25%, 50%, 75%) of the average rental duration
(in the number of days) for movies across all categories? Make sure to also indicate the
category that these family-friendly movies fall into.*/

/*Query #2*/
SELECT f.title title,
       c.name genre,
       f.rental_duration rental_duration,
       NTILE(4) OVER (PARTITION BY f.rental_duration) AS standard_quartile
FROM category c
     JOIN film_category fc
     ON c.category_id = fc.category_id

     JOIN film f
     ON fc.film_id = f.film_id

     AND c.name IN ('Animation', 'Children', 'Classics', 'Comedy', 'Family', 'Music')

ORDER BY 3,4;

/*Query #3 - query used for table*/

SELECT genre,
       standard_quartile,
       COUNT(*)
FROM
    (SELECT c.name genre, f.rental_duration,
            NTILE(4) OVER (PARTITION BY f.rental_duration) AS standard_quartile
     FROM category c
          JOIN film_category fc
          ON c.category_id = fc.category_id

          JOIN film f
          ON fc.film_id = f.film_id

     WHERE c.name IN ('Animation', 'Children', 'Classics', 'Comedy', 'Family', 'Music')) t1
GROUP BY 1,2
ORDER BY 1,2;


*/Question Set #2 Problem 1:
We want to find out how the two stores compare in their count of rental orders during
every month for all the years we have data for. Write a query that returns the store ID
for the store, the year and month and the number of rental orders each store has fulfilled
for that month. Your table should include a column for each of the following: year, month,
store ID and count of rental orders fulfilled during that month.*/

/*Query #4*/
SELECT DATE_PART('month', r.rental_date) AS rental_month,
       DATE_PART('year', r.rental_date) AS rental_year,
       s.store_id store_id,
       COUNT(r.rental_id)
FROM store s
JOIN staff stf
ON s.store_id = stf.store_id

JOIN rental r
ON r.staff_id = stf.staff_id

GROUP BY 1,2,3
ORDER BY 2,1,4 DESC;


*/Question Set #2 Problem 2:
We would like to know who were our top 10 paying customers, how many payments they made
on a monthly basis during 2007, and what was the amount of the monthly payments. Can you
write a query to capture the customer name, month and year of payment, and total payment
amount for each month by these top 10 paying customers?*/

/*Query #5*/
SELECT DATE_TRUNC('month', p.payment_date) pay_month,
       CONCAT(c.first_name, ' ', c.last_name) AS full_name,
       COUNT(p.payment_id) AS pay_countpermon,
       SUM(p.amount) AS pay_amount
FROM payment p
JOIN
(SELECT customer_id, SUM(amount) AS pay_amount
      FROM payment
      WHERE (payment_date BETWEEN '2007-01-01' AND '2008-01-01')
      GROUP BY 1
      ORDER BY 2 DESC
      LIMIT 10) t1
ON p.customer_id = t1.customer_id
JOIN customer c
ON p.customer_id = c.customer_id
GROUP BY 1,2
ORDER BY 2;
