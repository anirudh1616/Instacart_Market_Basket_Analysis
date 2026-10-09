
-- =====================================================================
-- MEMBER 2 : CUSTOMER LOYALTY & REPEAT BEHAVIOUR  (orders)
-- Anirudh Nadella
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
--   Comparing each customer's first 5 orders with their latest 5 orders
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
