-- =====================================================================
-- DATA 201 - Group Project - Instacart Market Basket Database
-- Geethaamruth praneeth_tirumalasetty - Aisle analysis: which aisles lead?
-- Author   : Rohit Tanga
-- Tables   : products, aisles, departments
-- Queries  : 4 (2 basic + 2 advanced): M4-B1, M4-B2, M4-A1, M4-A2
-- Database : instacart (MySQL 9.7.2). All four queries ran without errors.
-- Note: the "missing" aisle (1,258 products) is a real supplied label; B1 leaves it out of the top 10 on purpose.
-- =====================================================================

USE instacart;

-- ---------------------------------------------------------------------
-- Query 1 of 4  (project query #13)
-- ---------------------------------------------------------------------
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

-- Result when run on the instacart database:
-- +----------+----------------------+---------------+
-- | aisle_id | aisle                | product_count |
-- +----------+----------------------+---------------+
-- |       45 | candy chocolate      |          1246 |
-- |       37 | ice cream ice        |          1091 |
-- |       47 | vitamins supplements |          1038 |
-- |      120 | yogurt               |          1026 |
-- |      107 | chips pretzels       |           989 |
-- |       94 | tea                  |           894 |
-- |       21 | packaged cheese      |           891 |
-- |       38 | frozen meals         |           880 |
-- |       61 | cookies cakes        |           874 |
-- |        3 | energy granola bars  |           832 |
-- +----------+----------------------+---------------+

-- ---------------------------------------------------------------------
-- Query 2 of 4  (project query #14)
-- ---------------------------------------------------------------------
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

-- Result when run on the instacart database:
-- +------------+-------------------------------------------------------+-----------------+------------+
-- | product_id | product_name                                          | aisle           | department |
-- +------------+-------------------------------------------------------+-----------------+------------+
-- |      45316 | \"Mokaccino\"" Milk + Blue Bottle Coffee Chocolate"   | candy chocolate | snacks     |
-- |      16764 | 100 Count Assorted Minitures Bag                      | candy chocolate | snacks     |
-- |      27457 | 100 Grand Fun Size Bars                               | candy chocolate | snacks     |
-- |      15548 | 3 Musketeers                                          | candy chocolate | snacks     |
-- |      23222 | 31% Cacao Salted Caramel Milk Chocolate               | candy chocolate | snacks     |
-- |       8381 | 34% Cacao Milk Chocolate Bar                          | candy chocolate | snacks     |
-- |      17587 | 38% Milk Banana Pecan Caramel Bar                     | candy chocolate | snacks     |
-- |      46717 | 40 Flavors Jelly Beans                                | candy chocolate | snacks     |
-- |       8133 | 41% Cacao Caramel With Sea Salt Milk Chocolate        | candy chocolate | snacks     |
-- |      27613 | 45% Cacao Barcelona Bar                               | candy chocolate | snacks     |
-- |      27839 | 49 Flavors Jelly Belly Jelly Beans                    | candy chocolate | snacks     |
-- |      22050 | 5 Flavors Sugar Free Hard Candy Variety Pack          | candy chocolate | snacks     |
-- |      26114 | 55% Cocoa Dark Chocolate                              | candy chocolate | snacks     |
-- |      43767 | 57% Organic Dark Chocolate With Sea Salt              | candy chocolate | snacks     |
-- |      45701 | 60% Dark Chocolate Drenched Bing Cherries             | candy chocolate | snacks     |
-- |       1526 | 60% Dark Stone Ground Chocolate                       | candy chocolate | snacks     |
-- |      14195 | 63% Dark Chocolate Sea Salt & Nibs Bar                | candy chocolate | snacks     |
-- |      37470 | 65% Dark Chocolate Vanilla Nib Bar                    | candy chocolate | snacks     |
-- |      21989 | 70% Cacao Bittersweet Chocolate                       | candy chocolate | snacks     |
-- |       3834 | 70% Cocoa Chocolate Bar                               | candy chocolate | snacks     |
-- |       1131 | 70% Dark Chocolate                                    | candy chocolate | snacks     |
-- ... (5 more result lines not shown here)

-- ---------------------------------------------------------------------
-- Query 3 of 4  (project query #15)
-- ---------------------------------------------------------------------
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

-- Result when run on the instacart database:
-- +-----------------+------------+------------------------------+---------------+-------------------+
-- | department      | aisle_rank | aisle                        | product_count | pct_of_department |
-- +-----------------+------------+------------------------------+---------------+-------------------+
-- | alcohol         |          1 | beers coolers                |           385 |              36.5 |
-- | alcohol         |          2 | red wines                    |           232 |              22.0 |
-- | alcohol         |          3 | spirits                      |           195 |              18.5 |
-- | babies          |          1 | baby food formula            |           718 |              66.4 |
-- | babies          |          2 | diapers wipes                |           187 |              17.3 |
-- | babies          |          3 | baby bath body care          |           132 |              12.2 |
-- | bakery          |          1 | bread                        |           557 |              36.7 |
-- | bakery          |          2 | bakery desserts              |           297 |              19.6 |
-- | bakery          |          3 | tortillas flat bread         |           241 |              15.9 |
-- | beverages       |          1 | tea                          |           894 |              20.5 |
-- | beverages       |          2 | juice nectars                |           792 |              18.1 |
-- | beverages       |          3 | coffee                       |           680 |              15.6 |
-- | breakfast       |          1 | cereal                       |           454 |              40.7 |
-- | breakfast       |          2 | hot cereal pancake mixes     |           303 |              27.2 |
-- | breakfast       |          3 | granola                      |           185 |              16.6 |
-- | bulk            |          1 | bulk grains rice dried goods |            26 |              68.4 |
-- | bulk            |          2 | bulk dried fruits vegetables |            12 |              31.6 |
-- | canned goods    |          1 | soup broth bouillon          |           737 |              35.2 |
-- | canned goods    |          2 | canned jarred vegetables     |           487 |              23.3 |
-- | canned goods    |          3 | canned meals beans           |           342 |              16.3 |
-- | dairy eggs      |          1 | yogurt                       |          1026 |              29.7 |
-- ... (37 more result lines not shown here)

-- ---------------------------------------------------------------------
-- Query 4 of 4  (project query #16)
-- ---------------------------------------------------------------------
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

-- Result when run on the instacart database:
-- +--------------------------------------+-------------------+---------------+
-- | issue                                | name              | product_count |
-- +--------------------------------------+-------------------+---------------+
-- | Products in missing aisle/department | missing / missing |          1258 |
-- +--------------------------------------+-------------------+---------------+
