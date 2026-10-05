# Instacart Market Basket Analysis

Project Topic

Analysis of Grocery Shopping Patterns and Product Reordering Behavior

Project Overview

This project analyzes the Instacart Market Basket Analysis dataset obtained from Kaggle. The dataset contains information about grocery orders, products, aisles, departments, and customer reordering behavior.

The purpose of this project is to identify common grocery shopping patterns and understand which products customers are most likely to purchase again. The data will be organized into a relational database and analyzed using SQL queries.

Dataset Source

Kaggle: [Instacart Market Basket Analysis](https://www.kaggle.com/datasets/psparks/instacart-market-basket-analysis/data)


The dataset contains more than three million grocery orders from over 200,000 users. It includes order timing, product information, product categories, and reorder indicators.

Main Tables

orders —Contains customer order information, including order sequence, day of the week, hour of the day, and time since the previous order.

products —Contains product names and their associated aisle and department IDs.

aisles—Contains aisle names.

departments—Contains department names.

order_products_prior — Contains products purchased in customers’ previous orders.

order_products_train — Contains products purchased in the training orders and whether each product was reordered.

