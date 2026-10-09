-- DATA 201 group project: Instacart Market Basket database
-- Member 1: when do people shop? (orders table only)
-- Author: Rohit Tanga
--
-- 2 basic + 2 advanced queries. All four ran in MySQL Workbench on the
-- instacart database, and the output is pasted under each query.
-- Note: order_dow 0 = Sunday is our assumption (the data never says so).
-- It only changes the day names, the counts stay the same.

USE instacart;


-- Q1 (basic): how many orders on each day of the week?
SELECT order_dow,
       CASE order_dow
           WHEN 0 THEN 'Sunday'
           WHEN 1 THEN 'Monday'
           WHEN 2 THEN 'Tuesday'
           WHEN 3 THEN 'Wednesday'
           WHEN 4 THEN 'Thursday'
           WHEN 5 THEN 'Friday'
           WHEN 6 THEN 'Saturday'
       END AS day_name,
       COUNT(*) AS total_orders
FROM orders
GROUP BY order_dow
ORDER BY total_orders DESC;

-- result:
-- order_dow  day_name   total_orders
-- 0          Sunday     600905
-- 1          Monday     587478
-- 2          Tuesday    467260
-- 5          Friday     453368
-- 6          Saturday   448761
-- 3          Wednesday  436972
-- 4          Thursday   426339
-- Sunday and Monday are busiest, Thursday is the quietest.


-- Q2 (basic): the 5 busiest hours of the day
SELECT order_hour_of_day, COUNT(*) AS total_orders
FROM orders
GROUP BY order_hour_of_day
ORDER BY total_orders DESC
LIMIT 5;

-- result:
-- order_hour_of_day  total_orders
-- 10                 288418
-- 11                 284728
-- 15                 283639
-- 14                 283042
-- 13                 277999
-- 10 a.m. is the busiest hour, and all five are between 10 and 3.


-- Q3 (advanced): peak hour for each day of the week, and how big a share
-- of that day's orders it is. CTE + RANK() + SUM() OVER.
WITH hourly AS (
    SELECT order_dow, order_hour_of_day, COUNT(*) AS orders_in_hour
    FROM orders
    GROUP BY order_dow, order_hour_of_day
),
ranked AS (
    SELECT h.*,
           RANK() OVER (PARTITION BY order_dow ORDER BY orders_in_hour DESC) AS hour_rank,
           SUM(orders_in_hour) OVER (PARTITION BY order_dow) AS orders_in_day
    FROM hourly h
)
SELECT order_dow,
       order_hour_of_day AS peak_hour,
       orders_in_hour,
       ROUND(100.0 * orders_in_hour / orders_in_day, 2) AS pct_of_day_orders
FROM ranked
WHERE hour_rank = 1
ORDER BY order_dow;

-- result:
-- order_dow  peak_hour  orders_in_hour  pct_of_day_orders
-- 0          14         54552           9.08
-- 1          10         55671           9.48
-- 2          10         39230           8.40
-- 3          10         36040           8.25
-- 4          10         35034           8.22
-- 5          10         38313           8.45
-- 6          14         38748           8.63
-- Mon-Fri peak at 10 a.m., Sat and Sun at 2 p.m. Even the best hour is
-- only about 8-9% of the day, so shopping is spread out.


-- Q4 (advanced): day-parts, split into weekend vs weekday orders.
-- CASE to make the day-parts, SUM(CASE ...) to pivot weekend/weekday.
SELECT CASE
           WHEN order_hour_of_day BETWEEN 5 AND 11 THEN '1. Morning (5-11)'
           WHEN order_hour_of_day BETWEEN 12 AND 16 THEN '2. Afternoon (12-16)'
           WHEN order_hour_of_day BETWEEN 17 AND 21 THEN '3. Evening (17-21)'
           ELSE '4. Night (22-4)'
       END AS day_part,
       SUM(CASE WHEN order_dow IN (0, 6) THEN 1 ELSE 0 END) AS weekend_orders,
       SUM(CASE WHEN order_dow BETWEEN 1 AND 5 THEN 1 ELSE 0 END) AS weekday_orders,
       COUNT(*) AS total_orders,
       ROUND(100.0 * COUNT(*) / (SELECT COUNT(*) FROM orders), 2) AS pct_of_all_orders
FROM orders
GROUP BY day_part
ORDER BY day_part;

-- result:
-- day_part              weekend_orders  weekday_orders  total_orders  pct_of_all_orders
-- 1. Morning (5-11)     327469          813656          1141125       33.36
-- 2. Afternoon (12-16)  450349          939725          1390074       40.63
-- 3. Evening (17-21)    221473          513204          734677        21.47
-- 4. Night (22-4)       50375           104832          155207        4.54
-- Afternoon is the biggest block (40.6%), only 4.5% of orders happen at night.
