-- =====================================================================
-- DATA 201 - Group Project - Instacart Market Basket Database
-- MEMBER 3 - Product catalog by department: what does the catalog look like?
-- Author   : [Member 3 full name]
-- Tables   : products, departments
-- Queries  : 4 (2 basic + 2 advanced): M3-B1, M3-B2, M3-A1, M3-A2
-- Database : instacart (MySQL 9.7.2). All four queries ran without errors.
-- Note: "organic" means the product name contains the word Organic, so it is an approximation.
-- =====================================================================

USE instacart;

-- ---------------------------------------------------------------------
-- Query 1 of 4  (project query #9)
-- ---------------------------------------------------------------------
-- [M3 - Basic 1] Number of products in each department
SELECT
    d.department_id,
    d.department,
    COUNT(p.product_id) AS product_count
FROM departments d
LEFT JOIN products p ON p.department_id = d.department_id
GROUP BY d.department_id, d.department
ORDER BY product_count DESC;

-- Result when run on the instacart database:
-- +---------------+-----------------+---------------+
-- | department_id | department      | product_count |
-- +---------------+-----------------+---------------+
-- |            11 | personal care   |          6563 |
-- |            19 | snacks          |          6264 |
-- |            13 | pantry          |          5371 |
-- |             7 | beverages       |          4365 |
-- |             1 | frozen          |          4007 |
-- |            16 | dairy eggs      |          3449 |
-- |            17 | household       |          3084 |
-- |            15 | canned goods    |          2092 |
-- |             9 | dry goods pasta |          1858 |
-- |             4 | produce         |          1684 |
-- |             3 | bakery          |          1516 |
-- |            20 | deli            |          1322 |
-- |            21 | missing         |          1258 |
-- |             6 | international   |          1139 |
-- |            14 | breakfast       |          1115 |
-- |            18 | babies          |          1081 |
-- |             5 | alcohol         |          1054 |
-- |             8 | pets            |           972 |
-- |            12 | meat seafood    |           907 |
-- |             2 | other           |           548 |
-- |            10 | bulk            |            38 |
-- ... (1 more result lines not shown here)

-- ---------------------------------------------------------------------
-- Query 2 of 4  (project query #10)
-- ---------------------------------------------------------------------
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

-- Result when run on the instacart database:
-- +------------+----------------------------------------------------------+
-- | product_id | product_name                                             |
-- +------------+----------------------------------------------------------+
-- |       8277 | Apple Honeycrisp Organic                                 |
-- |      13176 | Bag of Organic Bananas                                   |
-- |      47229 | Bag of Organic Fuji Apples                               |
-- |      48825 | Bag of Organic Lemons                                    |
-- |      34450 | Bag Of Organic Lemons                                    |
-- |      22849 | Bunny-Luv Fresh Organic Carrots                          |
-- |      28413 | Bunny-Luv Organic Carrots                                |
-- |       6598 | Butternut Spirals Organic                                |
-- |      12616 | Certified Organic Oranges                                |
-- |      10367 | Cherries Rainer Organic                                  |
-- |      32548 | Citrus Lemons Organic 2 Lb Bag                           |
-- |      38557 | Citrus Mandarins Organic                                 |
-- |      34882 | Fresh Organic Blueberries                                |
-- |      21701 | Fresh Wrap Organic Cucumber                              |
-- |       4149 | Frozen Organic Blueberries                               |
-- |      49478 | Frozen Organic Strawberries                              |
-- |       2062 | Good Life Organic Cherry Tomatoes                        |
-- |      20870 | Gourmet Mixed Organic Fingerlings Potatoes               |
-- |      41162 | Grapes, Certified Organic, California, Black Seedless    |
-- |      44419 | Handy Candy Organic Grape Tomatoes                       |
-- |      48253 | Happy Squeeze Organic Twist Apple Mango & Kale Squeezers |
-- ... (5 more result lines not shown here)

-- ---------------------------------------------------------------------
-- Query 3 of 4  (project query #11)
-- ---------------------------------------------------------------------
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

-- Result when run on the instacart database:
-- +-----------------+----------------+------------------+-------------+--------------+
-- | department      | total_products | organic_products | organic_pct | organic_rank |
-- +-----------------+----------------+------------------+-------------+--------------+
-- | bulk            |             38 |               22 |       57.89 |            1 |
-- | produce         |           1684 |              473 |       28.09 |            2 |
-- | babies          |           1081 |              260 |       24.05 |            3 |
-- | dry goods pasta |           1858 |              300 |       16.15 |            4 |
-- | canned goods    |           2092 |              320 |       15.30 |            5 |
-- | beverages       |           4365 |              624 |       14.30 |            6 |
-- | missing         |           1258 |              175 |       13.91 |            7 |
-- | breakfast       |           1115 |              155 |       13.90 |            8 |
-- | pantry          |           5371 |              746 |       13.89 |            9 |
-- | dairy eggs      |           3449 |              435 |       12.61 |           10 |
-- | snacks          |           6264 |              656 |       10.47 |           11 |
-- | bakery          |           1516 |              116 |        7.65 |           12 |
-- | deli            |           1322 |              100 |        7.56 |           13 |
-- | international   |           1139 |               84 |        7.37 |           14 |
-- | other           |            548 |               37 |        6.75 |           15 |
-- | frozen          |           4007 |              252 |        6.29 |           16 |
-- | meat seafood    |            907 |               47 |        5.18 |           17 |
-- | personal care   |           6563 |              187 |        2.85 |           18 |
-- | pets            |            972 |               23 |        2.37 |           19 |
-- | alcohol         |           1054 |               15 |        1.42 |           20 |
-- | household       |           3084 |                9 |        0.29 |           21 |
-- ... (1 more result lines not shown here)

-- ---------------------------------------------------------------------
-- Query 4 of 4  (project query #12)
-- ---------------------------------------------------------------------
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

-- Result when run on the instacart database:
-- +---------------+---------------+---------------+--------------+
-- | department    | product_count | avg_dept_size | above_avg_by |
-- +---------------+---------------+---------------+--------------+
-- | personal care |          6563 |          2366 |         4197 |
-- | snacks        |          6264 |          2366 |         3898 |
-- | pantry        |          5371 |          2366 |         3005 |
-- | beverages     |          4365 |          2366 |         1999 |
-- | frozen        |          4007 |          2366 |         1641 |
-- | dairy eggs    |          3449 |          2366 |         1083 |
-- | household     |          3084 |          2366 |          718 |
-- +---------------+---------------+---------------+--------------+
