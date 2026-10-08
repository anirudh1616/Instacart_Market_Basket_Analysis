-- =====================================================================
-- Instacart Database - Team SQL Queries (MySQL 8+)
-- Database: instacart
-- Tables: orders, products, aisles, departments
-- 4 members x (2 basic + 2 advanced) = 16 queries
-- =====================================================================
USE instacart;

-- Day-of-week codes in the Instacart dataset: 0 = Sunday ... 6 = Saturday


-- =====================================================================
-- MEMBER 1 : WHEN DO CUSTOMERS SHOP?  (orders)
-- =====================================================================

-- [M1 - Basic 1] Number of orders placed on each day of the week
SELECT
    order_dow,
    CASE order_dow
        WHEN 0 THEN 'Sunday'   WHEN 1 THEN 'Monday'  WHEN 2 THEN 'Tuesday'
        WHEN 3 THEN 'Wednesday' WHEN 4 THEN 'Thursday' WHEN 5 THEN 'Friday'
        WHEN 6 THEN 'Saturday'
    END              AS day_name,
    COUNT(*)         AS total_orders
FROM orders
GROUP BY order_dow
ORDER BY total_orders DESC;

-- [M1 - Basic 2] Top 5 busiest hours of the day
SELECT
    order_hour_of_day,
    COUNT(*) AS total_orders
FROM orders
GROUP BY order_hour_of_day
ORDER BY total_orders DESC
LIMIT 5;

-- [M1 - Advanced 1] Peak shopping hour for each day of the week
--   (CTE + RANK window function) and its share of that day's orders
WITH hourly AS (
    SELECT
        order_dow,
        order_hour_of_day,
        COUNT(*) AS orders_in_hour
    FROM orders
    GROUP BY order_dow, order_hour_of_day
),
ranked AS (
    SELECT
        h.*,
        RANK()           OVER (PARTITION BY order_dow ORDER BY orders_in_hour DESC) AS hour_rank,
        SUM(orders_in_hour) OVER (PARTITION BY order_dow)                         AS orders_in_day
    FROM hourly h
)
SELECT
    order_dow,
    order_hour_of_day                                   AS peak_hour,
    orders_in_hour,
    ROUND(100.0 * orders_in_hour / orders_in_day, 2)    AS pct_of_day_orders
FROM ranked
WHERE hour_rank = 1
ORDER BY order_dow;

-- [M1 - Advanced 2] Day-part vs. weekday/weekend pivot table
--   (conditional aggregation with CASE inside SUM)
SELECT
    CASE
        WHEN order_hour_of_day BETWEEN 5  AND 11 THEN '1. Morning (5-11)'
        WHEN order_hour_of_day BETWEEN 12 AND 16 THEN '2. Afternoon (12-16)'
        WHEN order_hour_of_day BETWEEN 17 AND 21 THEN '3. Evening (17-21)'
        ELSE '4. Night (22-4)'
    END                                                         AS day_part,
    SUM(CASE WHEN order_dow IN (0, 6) THEN 1 ELSE 0 END)        AS weekend_orders,
    SUM(CASE WHEN order_dow BETWEEN 1 AND 5 THEN 1 ELSE 0 END)  AS weekday_orders,
    COUNT(*)                                                    AS total_orders,
    ROUND(100.0 * COUNT(*) / (SELECT COUNT(*) FROM orders), 2)  AS pct_of_all_orders
FROM orders
GROUP BY day_part
ORDER BY day_part;


-- =====================================================================
-- MEMBER 2 : CUSTOMER LOYALTY & REPEAT BEHAVIOUR  (orders)
-- =====================================================================

-- [M2 - Basic 1] Overall customer summary
SELECT
    COUNT(DISTINCT user_id)                 AS total_customers,
    COUNT(*)                                AS total_orders,
    ROUND(COUNT(*) / COUNT(DISTINCT user_id), 2) AS avg_orders_per_customer,
    ROUND(AVG(days_since_prior_order), 2)   AS avg_days_between_orders
FROM orders;

-- [M2 - Basic 2] Top 10 most loyal customers (most orders placed)
SELECT
    user_id,
    MAX(order_number)                       AS total_orders,
    ROUND(AVG(days_since_prior_order), 1)   AS avg_days_between_orders
FROM orders
GROUP BY user_id
ORDER BY total_orders DESC, avg_days_between_orders ASC
LIMIT 10;

-- [M2 - Advanced 1] Segment customers by how often they reorder
--   (CTE + CASE bucketing + percentage of total with a window function)
WITH customer_stats AS (
    SELECT
        user_id,
        COUNT(*)                     AS total_orders,
        AVG(days_since_prior_order)  AS avg_gap_days
    FROM orders
    GROUP BY user_id
)
SELECT
    CASE
        WHEN avg_gap_days <= 7  THEN '1. Weekly shopper (<=7 days)'
        WHEN avg_gap_days <= 14 THEN '2. Bi-weekly shopper (8-14 days)'
        WHEN avg_gap_days <= 21 THEN '3. Occasional (15-21 days)'
        ELSE '4. Rare (>21 days)'
    END                                                     AS customer_segment,
    COUNT(*)                                                AS customers,
    ROUND(AVG(total_orders), 1)                             AS avg_orders,
    ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (), 2)      AS pct_of_customers
FROM customer_stats
GROUP BY customer_segment
ORDER BY customer_segment;

-- [M2 - Advanced 2] Are customers ordering faster or slower over time?
--   Compare each customer's first 5 orders with their latest 5 orders
--   (ROW_NUMBER window function + HAVING + correlated buckets)
WITH numbered AS (
    SELECT
        user_id,
        order_number,
        days_since_prior_order,
        ROW_NUMBER() OVER (PARTITION BY user_id ORDER BY order_number DESC) AS rev_order_no
    FROM orders
),
per_user AS (
    SELECT
        user_id,
        AVG(CASE WHEN order_number BETWEEN 2 AND 6 THEN days_since_prior_order END) AS early_gap,
        AVG(CASE WHEN rev_order_no <= 5          THEN days_since_prior_order END) AS recent_gap
    FROM numbered
    GROUP BY user_id
    HAVING COUNT(*) >= 15          -- only customers with enough history
)
SELECT
    CASE
        WHEN recent_gap < early_gap - 2 THEN 'Ordering MORE often'
        WHEN recent_gap > early_gap + 2 THEN 'Ordering LESS often'
        ELSE 'About the same'
    END                                   AS trend,
    COUNT(*)                              AS customers,
    ROUND(AVG(early_gap), 1)              AS avg_early_gap_days,
    ROUND(AVG(recent_gap), 1)             AS avg_recent_gap_days
FROM per_user
GROUP BY trend
ORDER BY customers DESC;


-- =====================================================================
-- MEMBER 3 : PRODUCT CATALOG BY DEPARTMENT  (products + departments)
-- =====================================================================

-- [M3 - Basic 1] Number of products in each department
SELECT
    d.department_id,
    d.department,
    COUNT(p.product_id) AS product_count
FROM departments d
LEFT JOIN products p ON p.department_id = d.department_id
GROUP BY d.department_id, d.department
ORDER BY product_count DESC;

-- [M3 - Basic 2] Find all organic products in the 'produce' department
SELECT
    p.product_id,
    p.product_name
FROM products p
JOIN departments d ON d.department_id = p.department_id
WHERE d.department = 'produce'
  AND p.product_name LIKE '%Organic%'
ORDER BY p.product_name
LIMIT 25;

-- [M3 - Advanced 1] Organic share of each department's catalog,
--   ranked with DENSE_RANK
WITH dept_mix AS (
    SELECT
        d.department,
        COUNT(*)                                                       AS total_products,
        SUM(CASE WHEN p.product_name LIKE '%Organic%' THEN 1 ELSE 0 END) AS organic_products
    FROM products p
    JOIN departments d ON d.department_id = p.department_id
    GROUP BY d.department
)
SELECT
    department,
    total_products,
    organic_products,
    ROUND(100.0 * organic_products / total_products, 2)                      AS organic_pct,
    DENSE_RANK() OVER (ORDER BY organic_products / total_products DESC)      AS organic_rank
FROM dept_mix
ORDER BY organic_rank;

-- [M3 - Advanced 2] Departments whose catalog is bigger than the average
--   department (derived-table subquery joined back + HAVING)
SELECT
    d.department,
    COUNT(*)                          AS product_count,
    ROUND(avg_t.avg_cnt, 0)           AS avg_dept_size,
    ROUND(COUNT(*) - avg_t.avg_cnt, 0) AS above_avg_by
FROM products p
JOIN departments d ON d.department_id = p.department_id
CROSS JOIN (
    SELECT AVG(cnt) AS avg_cnt
    FROM (SELECT COUNT(*) AS cnt FROM products GROUP BY department_id) t
) avg_t
GROUP BY d.department, avg_t.avg_cnt
HAVING COUNT(*) > avg_t.avg_cnt
ORDER BY product_count DESC;


-- =====================================================================
-- MEMBER 4 : AISLE ANALYSIS  (products + aisles + departments)
-- =====================================================================

-- [M4 - Basic 1] Top 10 aisles with the most products
SELECT
    a.aisle_id,
    a.aisle,
    COUNT(p.product_id) AS product_count
FROM aisles a
JOIN products p ON p.aisle_id = a.aisle_id
WHERE a.aisle <> 'missing'
GROUP BY a.aisle_id, a.aisle
ORDER BY product_count DESC
LIMIT 10;

-- [M4 - Basic 2] Full product listing with aisle and department names
--   (3-table join) - e.g. everything in the 'snacks' department
SELECT
    p.product_id,
    p.product_name,
    a.aisle,
    d.department
FROM products p
JOIN aisles a      ON a.aisle_id      = p.aisle_id
JOIN departments d ON d.department_id = p.department_id
WHERE d.department = 'snacks'
ORDER BY a.aisle, p.product_name
LIMIT 25;

-- [M4 - Advanced 1] Top 3 aisles inside every department
--   (3-table join + ROW_NUMBER per department + % of department)
WITH aisle_counts AS (
    SELECT
        d.department,
        a.aisle,
        COUNT(*) AS product_count
    FROM products p
    JOIN aisles a      ON a.aisle_id      = p.aisle_id
    JOIN departments d ON d.department_id = p.department_id
    GROUP BY d.department, a.aisle
),
ranked AS (
    SELECT
        ac.*,
        ROW_NUMBER() OVER (PARTITION BY department ORDER BY product_count DESC) AS rn,
        SUM(product_count) OVER (PARTITION BY department)                       AS dept_total
    FROM aisle_counts ac
)
SELECT
    department,
    rn                                                  AS aisle_rank,
    aisle,
    product_count,
    ROUND(100.0 * product_count / dept_total, 1)        AS pct_of_department
FROM ranked
WHERE rn <= 3
ORDER BY department, aisle_rank;

-- [M4 - Advanced 2] Data-quality check: aisles with no products, and
--   products whose aisle/department is 'missing'  (LEFT JOIN + UNION ALL)
SELECT 'Aisle with no products' AS issue,
       a.aisle                  AS name,
       0                        AS product_count
FROM aisles a
LEFT JOIN products p ON p.aisle_id = a.aisle_id
WHERE p.product_id IS NULL

UNION ALL

SELECT 'Products in missing aisle/department',
       CONCAT(a.aisle, ' / ', d.department),
       COUNT(*)
FROM products p
JOIN aisles a      ON a.aisle_id      = p.aisle_id
JOIN departments d ON d.department_id = p.department_id
WHERE a.aisle = 'missing' OR d.department = 'missing'
GROUP BY a.aisle, d.department;
