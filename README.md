# Comprehensive Data Analysis using SQL
# ZOMATO - An Indian food delivery company and multinational restaurant aggregator

![ZOMATO](https://github.com/Akshay-Vallam/Data-Analysis_Zomato/blob/main/zomato_image.jpg)

## Overview

This project demonstrates my problem-solving skills through the analysis of data for the company Zomato. It helped me to understand the following business insights:

 - Customer Behaviour and Insights
 - Order and Sales Analysis
 - Restaurant Performance
 - Rider Efficiency and Performance
 - Operational Effectiveness

This project has helped me develop the following skills and understanding in SQL:

 - Database Creation and Table Design (Database concepts, constraints)
 - Data Retrieval and Filtering (Basics SQL)
 - Aggregations and Grouping 
 - Joining Tables (Left Join, Inner Join)
 - Window Functions (Row Number, Rank, Dense Rank, Lead, Lag)
 - Date and Time Functions
 - Conditional Logic 
 - Subqueries
 - Ranking and Ordering
 - Data Segmentation (CASE STATEMENT)

## Project Structure

- **Database Setup:** Creation of the `zomato_db` database and the required tables.
- **Data Import:** Inserting sample data into the tables.
- **Data Cleaning:** Handling null values and ensuring data integrity.
- **Business Problems:** Solving 20 specific business problems using SQL queries.

![ERD](https://github.com/Akshay-Vallam/Data-Analysis_Zomato/blob/main/zomato_schemas_erd.png)

## Database Setup
```sql
CREATE DATABASE zomato_db;
```
### 1. Dropping Existing Tables
```sql
DROP TABLE IF EXISTS restaurants;
DROP TABLE IF EXISTS customers;
DROP TABLE IF EXISTS riders;
DROP TABLE IF EXISTS orders;
DROP TABLE IF EXISTS deliveries;
```
### 2. Creating Tables
```sql
-- Create restaurants table
DROP TABLE IF EXISTS restaurants;
CREATE TABLE restaurants (
    restaurant_id SERIAL PRIMARY KEY,
    restaurant_name VARCHAR(100) NOT NULL,
    city VARCHAR(50),
    opening_hours VARCHAR(50)
);

-- Create customers table
DROP TABLE IF EXISTS customers;
CREATE TABLE customers (
    customer_id SERIAL PRIMARY KEY,
    customer_name VARCHAR(100) NOT NULL,
    reg_date DATE
);

-- Create riders table
DROP TABLE IF EXISTS riders;
CREATE TABLE riders (
    rider_id SERIAL PRIMARY KEY,
    rider_name VARCHAR(100) NOT NULL,
    sign_up DATE
);

-- Create orders table
DROP TABLE IF EXISTS orders;
CREATE TABLE orders (
    order_id SERIAL PRIMARY KEY,
    customer_id INT,
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id),
    restaurant_id INT,
    FOREIGN KEY (restaurant_id) REFERENCES restaurants(restaurant_id),
    order_item VARCHAR(255),
    order_date DATE NOT NULL,
    order_time TIME NOT NULL,
    order_status VARCHAR(20) DEFAULT 'Pending',
    total_amount DECIMAL(10,2) NOT NULL
);

-- Create deliveries table
DROP TABLE IF EXISTS deliveries;
CREATE TABLE deliveries(
    delivery_id SERIAL PRIMARY KEY,
    order_id INT,
    FOREIGN KEY (order_id) REFERENCES Orders(order_id),
    delivery_status VARCHAR(20) DEFAULT 'Pending',
    delivery_time TIME,
    rider_id INT,
    FOREIGN KEY (rider_id) REFERENCES riders(rider_id)
);
```
## Data Import

Import data into tables in the below order:
 - restaurants
 - customers
 - riders
 - orders
 - deliveries

## Data Cleaning

Prior to analysis, I've ensured that the data was clean and free from null values where necessary.

```sql
SELECT * FROM restaurants;
SELECT * FROM customers;
SELECT * FROM riders;
SELECT * FROM orders;
SELECT * FROM deliveries;

-- Handling Null Values

SELECT COUNT(*) FROM restaurants
    WHERE
    restaurant_name IS NULL
    OR
    city IS NULL
    OR
    opening_hours IS NULL;

SELECT COUNT(*) FROM customers
    WHERE
    customer_name IS NULL
    OR
    reg_date IS NULL;

SELECT COUNT(*) FROM riders
    WHERE
    rider_name IS NULL
    OR
    sign_up IS NULL;

SELECT COUNT(*) FROM orders
    WHERE
    order_item IS NULL
    OR
    order_date IS NULL
    OR
    order_time IS NULL
    OR
    order_status IS NULL
    OR 
    total_amount IS NULL;

SELECT COUNT(*) FROM deliveries
    WHERE
    delivery_status IS NULL
    OR
    delivery_time IS NULL;

-- Sample - Insert & Delete Null Values

-- Insert Null Values
INSERT INTO orders(order_id, customer_id, restaurant_id)
VALUES
(10002, 9, 54),
(10003, 10, 51),
(10005, 10, 50)
;

-- Delete Null Values
DELETE FROM orders
WHERE 
    order_item IS NULL
    OR
    order_date IS NULL
    OR
    order_time IS NULL
    OR
    order_status IS NULL
    OR 
    total_amount IS NULL;
```

For instance, the null values can also be handled as below:

```sql
UPDATE orders
SET total_amount = COALESCE(total_amount, 0);
```
## Business Problems

### Tables overview
```sql
SELECT * FROM restaurants;
SELECT * FROM customers;
SELECT * FROM riders;
SELECT * FROM orders;
SELECT * FROM deliveries;
```

### 1. Frequently ordered dishes

#### Question: 
#### Write a query to find the top 5 most frequently ordered dishes by customer called "Arjun Mehta" in the last 2 years.
	
#### Solution:
```sql
/* Join - customers & orders table 
Filter - last 2 years
Filter - last 'Arjun Mehta'
Rank - top 5 items
Group - customer_id, customer_name, order_item, count of order_item. 
CTE or Subquery - to view top 5 ranks*/	
	
WITH t1 as (
    SELECT
        c.customer_id,
        c.customer_name,
        o.order_item,
        COUNT(*) as total_orders,
        DENSE_RANK() OVER (ORDER BY COUNT(*) DESC) as ranking
    FROM orders as o
    JOIN
    customers as c
    ON c.customer_id = o.customer_id
    WHERE
        c.customer_name = 'Arjun Mehta'
        AND
        o.order_date >= CURRENT_DATE - INTERVAL '2 Year'
    GROUP BY 1, 2, 3
    ORDER BY 1, 4 DESC
    )
SELECT
    customer_name,
    order_item,
    total_orders,
    ranking
FROM t1
WHERE
    ranking <= 5;
```

### 2. Popular Time Slots
#### Question: 
#### Identify the time slots during which the most orders are placed. based on 2-hour intervals.
	
#### Solution:
```sql
/* Extract hours from order_time for 2 hour interval time slots
Assign values to those timeslots
Count orders for those time slots*/

SELECT
    CASE
        WHEN EXTRACT(HOUR FROM order_time) BETWEEN 0 AND 1 THEN '00:00 - 02:00'
        WHEN EXTRACT(HOUR FROM order_time) BETWEEN 2 AND 3 THEN '02:00 - 04:00'
        WHEN EXTRACT(HOUR FROM order_time) BETWEEN 4 AND 5 THEN '04:00 - 06:00'
        WHEN EXTRACT(HOUR FROM order_time) BETWEEN 6 AND 7 THEN '06:00 - 08:00'
        WHEN EXTRACT(HOUR FROM order_time) BETWEEN 8 AND 9 THEN '08:00 - 10:00'
        WHEN EXTRACT(HOUR FROM order_time) BETWEEN 10 AND 11 THEN '10:00 - 12:00'
        WHEN EXTRACT(HOUR FROM order_time) BETWEEN 12 AND 13 THEN '12:00 - 14:00'
        WHEN EXTRACT(HOUR FROM order_time) BETWEEN 14 AND 15 THEN '14:00 - 16:00'
        WHEN EXTRACT(HOUR FROM order_time) BETWEEN 16 AND 17 THEN '16:00 - 18:00'
        WHEN EXTRACT(HOUR FROM order_time) BETWEEN 18 AND 19 THEN '18:00 - 20:00'
        WHEN EXTRACT(HOUR FROM order_time) BETWEEN 20 AND 21 THEN '20:00 - 22:00'
        WHEN EXTRACT(HOUR FROM order_time) BETWEEN 22 AND 23 THEN '22:00 - 00:00'
    END as time_slot,
    COUNT(order_id) as order_count
FROM orders
GROUP BY time_slot
ORDER BY order_count DESC;
```

### 3. Order Value Analysis
#### Question: 
#### Find the average order value per customer who has placed more than 750 orders.	Return customer_name, and AOV(average order value).
	
#### Solution:
```sql
/* Join - customers & orders tables
Count - order_id
AVG - total_amount
Having - count > 750 */

-- Approach 1 - With 'HAVING'
SELECT
    c.customer_name,
    COUNT(o.order_id) as total_orders,
    ROUND(AVG(o.total_amount),2) as AOV
FROM orders as o
JOIN customers as c
on c.customer_id = o.customer_id
GROUP BY 1
HAVING COUNT(o.order_id) > 750;

-- Approach 2 - With 'WHERE' using CTE
WITH t1 as (
SELECT
    c.customer_name,
    COUNT(o.order_id) as total_orders,
    ROUND(AVG(o.total_amount),2) as AOV
FROM orders as o
JOIN customers as c
on o.customer_id = c.customer_id
GROUP BY customer_name
)
SELECT 
    customer_name,
    total_orders,
    AOV
FROM t1
WHERE total_orders > 750
ORDER BY total_orders;
```

### 4. High-Value Customers
#### Question: 
#### List the customers who have spent more than 100K in total on food orders. Return customer_name, and customer_id. 
	
#### Solution:
```sql
/* Join - customers & orders tables
SUM - total_amount
Having - SUM > 100000 */

SELECT
    c.customer_name,
    SUM(o.total_amount) as total_spent
FROM orders as o
JOIN customers as c
on c.customer_id = o.customer_id
GROUP BY 1
HAVING SUM(o.total_amount) > 100000
ORDER BY SUM(o.total_amount) DESC;
```

### 5. Orders Without Delivery
#### Question: 
#### Write a query to find orders that were placed but not delivered. Return each restuarant name,	city and number of not delivered orders.
	
#### Solution:
```sql
/* Left Join - restaurants, orders & deliveries tables
Where - delivery_id is null */

SELECT
    r.restaurant_name,
    COUNT(o.order_id) as undelivered_orders
FROM orders as o
LEFT JOIN restaurants as r
on r.restaurant_id = o.restaurant_id
LEFT JOIN deliveries as d
on d.order_id = o.order_id
WHERE d.delivery_id IS NULL
GROUP BY 1
ORDER BY 2 DESC;
```

### 6. Restaurant Revenue Ranking
#### Question: 
#### Rank restaurants by their total revenue from the last 2 years, including their name, total revenue, and rank within their city.
	
#### Solution:
```sql
/* Join - restaurants & orders tables
Rank - based on total revenue
Where - order_date < 2 years 
Where - rank = 1 */

WITH rt as (
SELECT
    r.city,
    r.restaurant_name,
    SUM(o.total_amount) as total_revenue,
    RANK () OVER (PARTITION BY r.city ORDER BY SUM(o.total_amount) DESC)
FROM orders as o
JOIN restaurants as r
on r.restaurant_id = o.restaurant_id
WHERE o.order_date >= CURRENT_DATE - INTERVAL '2 year'
GROUP BY 1,2
)
SELECT * FROM rt
WHERE rank = 1;
```
	
### 7. Most Popular Dish by City
#### Question: 
#### Identify the most popular dish in each city based on the number of orders.
	
#### Solution:
```sql
/* Join - restaurants & orders tables
Group - order_items
Rank - based on total orders
Where - rank = 1 */

WITH rt as (	
SELECT
    r.city,
    o.order_item,
    COUNT(o.order_item) as total_orders,
    RANK () OVER (PARTITION BY r.city ORDER BY COUNT(o.order_item) DESC)
FROM orders as o
JOIN restaurants as r
on r.restaurant_id = o.restaurant_id
GROUP BY 1,2
)
SELECT * FROM rt
WHERE rank = 1;
```

### 8. Customer Churn
#### Question: 
#### Find customers who haven’t placed an order in 2024 but did in 2023.
	
#### Solution:
```sql
/* Extract year - from order_date
Where - year = 2023
Where - year <> 2024 */

SELECT DISTINCT customer_id
FROM orders
WHERE
    EXTRACT (YEAR FROM order_date) = 2023
    AND
    customer_id NOT IN (
    SELECT DISTINCT customer_id
    FROM orders
    WHERE
        EXTRACT (YEAR FROM order_date) = 2024
    );
```

### 9. Cancellation Rate Comparison
#### Question: 
#### Calculate and compare the order cancellation rate for each restaurant between the year 2023 and the year 2024.
	
#### Solution:
```sql
/* Join - orders, deliveries tables
Count - total orders when delivery_id is null
Where - year 2023 & 2024
Calulate - not delivered % for 2023 & 2024 
Compare - not delivered % for 2023 & 2024 */

WITH cancel_ratio_23 as (
SELECT 
    o.restaurant_id,
    COUNT(o.order_id) as total_orders,
    COUNT(CASE WHEN d.delivery_id IS NULL THEN 1 END) as not_delivered
FROM orders as o
LEFT JOIN deliveries as d
ON o.order_id = d.order_id
WHERE EXTRACT(YEAR FROM order_date) = 2023
GROUP BY 1
),
cancel_ratio_24 as (
SELECT 
    o.restaurant_id,
    COUNT(o.order_id) as total_orders,
    COUNT(CASE WHEN d.delivery_id IS NULL THEN 1 END) as not_delivered
FROM orders as o
LEFT JOIN deliveries as d
ON o.order_id = d.order_id
WHERE EXTRACT(YEAR FROM order_date) = 2024
GROUP BY 1
    ),
year_23_data as (
SELECT 
    restaurant_id,
    total_orders,
    not_delivered,
    ROUND((not_delivered::numeric/total_orders::numeric)*100,2) as cancel_ratio
FROM cancel_ratio_23		
),
year_24_data as (
SELECT 
    restaurant_id,
    total_orders,
    not_delivered,
    ROUND((not_delivered::numeric/total_orders::numeric)*100,2) as cancel_ratio
FROM cancel_ratio_24		
)	

SELECT
    r24.restaurant_id,
    r24.cancel_ratio as cancel_ratio_24,
    r23.cancel_ratio as cancel_ratio_23
FROM year_24_data as r24
JOIN year_23_data as r23
ON r24.restaurant_id = r23.restaurant_id;
```

### 10. Rider Average Delivery Time
#### Question: 
#### Determine each rider's average delivery time.
	
#### Solution:
```sql
/* Join - orders, deliveries tables
Subtract - delivery_time & order_time
Subtract - delivery_time & order_time for midnight deliveries
Where - delivery status is delivered */

SELECT
    o.order_id,
    o.order_time,
    d.delivery_time,
    d.rider_id,
    d.delivery_time - o.order_time as time_difference,
    ROUND(EXTRACT(EPOCH FROM (d.delivery_time - o.order_time 
    + CASE WHEN d.delivery_time < o.order_time THEN INTERVAL '1 day'
    ELSE INTERVAL '0 day'
    END))/60,2) as time_difference_in_min
FROM orders AS o
JOIN deliveries AS d
ON o.order_id = d.order_id
WHERE d.delivery_status = 'Delivered';
```
	
### 11. Monthly Restaurant Growth Ratio
#### Question: 
#### Calculate each restaurant's growth ratio based on the total number of delivered orders since its joining.
	
#### Solution:
```sql
/* Join - orders, deliveries tables
Extract - year, month from order_date
Lag - year, month from order_date
Count - order_date
Where - delivery status is delivered 
Calulate - ratio between current and previous month orders */

WITH growth_ratio AS (
SELECT
    o.restaurant_id,
    EXTRACT(YEAR FROM o.order_date) as year,
    EXTRACT(MONTH FROM o.order_date) as month,
    COUNT(o.order_date) as cr_month_orders,
    LAG(COUNT(o.order_date), 1) OVER(PARTITION BY o.restaurant_id ORDER BY EXTRACT(YEAR FROM o.order_date),
        EXTRACT(MONTH FROM o.order_date)) as prev_month_orders
FROM orders as o
JOIN deliveries as d
ON o.order_id = d.order_id
WHERE d.delivery_status ILIKE 'Delivered'
GROUP BY 1, 2, 3
ORDER BY 1, 2
)

SELECT
    restaurant_id,
    year,
    month,
    cr_month_orders,
    prev_month_orders,
    ROUND(((cr_month_orders::numeric-prev_month_orders::numeric)/prev_month_orders::numeric)*100,2) as growth_ratio
    FROM growth_ratio;
```

### 12. Customer Segmentation
#### Question: 
#### Customer Segmentation: Segment customers into 'Gold' or 'Silver' groups based on their total spending compared to the average order value (AOV). If a customer's total spending	exceeds the AOV, label them as 'Gold'; otherwise, label them as 'Silver'. Write an SQL query to determine each segment's total number of orders and total revenue.
	
#### Solution:
```sql
/* Calculate - sum of total amount, count of total order, avg of total amount
Case - Category gold for total amount > aov, silver for total amount < aov
Subquery - for total revenue based on category */

SELECT 
    cx_category,
    SUM(total_orders) as total_orders,
    SUM(total_spent) as total_revenue
FROM
    (SELECT
        customer_id,
        SUM(total_amount) as total_spent,
        count(order_id) as total_orders,
        CASE 
            WHEN SUM(total_amount) > (SELECT AVG(total_amount) FROM ORDERS) THEN 'Gold'
            ELSE 'Silver'
        END as cx_category
    FROM orders
    GROUP BY 1) as cat
GROUP BY 1;
```

### 13. Rider Monthly Earnings
#### Question: 
#### Calculate each rider's total monthly earnings, assuming they earn 8% of the order amount.
	
#### Solution:
```sql
/* Join - order, deliveries table
Calculate - sum of total amount, 8% of sum of total amount
Convert - order-date to mm-yy
Group - rider_id */

SELECT
    d.rider_id,
    TO_CHAR(o.order_date, 'mm-yy') as month,
    SUM(total_amount) as revenue,
    ROUND(SUM(total_amount)*0.08,2) as rider_earnings
FROM orders as o
JOIN deliveries as d
ON o.order_id = d.order_id
GROUP BY 1,2
ORDER BY 1,2;
```	
	
### 14. Rider Ratings Analysis
#### Question: 
#### Find the number of 5-star, 4-star, and 3-star ratings each rider has. Riders receive this rating based on delivery time. If orders are delivered less than 15 minutes of order received time the rider get 5 star rating, 	if they deliver 15 and 20 minute they get 4 star rating  if they deliver after 20 minute they get 3 star rating.
	
#### Solution:
```sql
/* Join - order, deliveries table
Calculate & CTE - time to deliver and categorize with stars
Count - total stars */

    WITH dt as (
        SELECT
            o.order_id,
            o.order_time,
            d.delivery_time,
            ROUND(EXTRACT(EPOCH FROM (d.delivery_time - o.order_time 
            + CASE WHEN d.delivery_time < o.order_time THEN INTERVAL '1 day'
            ELSE INTERVAL '0 day'
            END))/60,2) as time_to_deliver,
            d.rider_id
        FROM orders as o
        JOIN deliveries as d
        ON o.order_id = d.order_id
        WHERE delivery_status ILIKE 'Delivered'
    ),
    ct as (
        SELECT
            rider_id,
            time_to_deliver,
            CASE 
                WHEN time_to_deliver < 15 THEN '5 stars'
                WHEN time_to_deliver BETWEEN 15 AND 20 THEN '4 stars'
                ELSE '3 stars'
                END as stars
        FROM dt
    )
    SELECT 
        rider_id,
        stars,
        COUNT(*) as total_stars
    FROM ct
    GROUP BY 1, 2
    ORDER BY 1, 3 DESC;
```

### 15. Order Frequency by Day
#### Question: 
#### Analyze order frequency per day of the week and identify the peak day for each restaurant.
	
#### Solution:
```sql
/* Join - restaurants, orders table
Calculate - order day based on order date, count of orders
Rank - based on total orders of the day
Where - rank = 1 */

SELECT * 
FROM
    (SELECT
        r.restaurant_name,
        TO_CHAR(o.order_date, 'Day') as day,
        COUNT(o.order_id) as total_orders,
        RANK () OVER(PARTITION BY r.restaurant_name ORDER BY COUNT(o.order_id) DESC) as rank
    FROM orders as o
    JOIN restaurants as r
    ON o.restaurant_id = r.restaurant_id
    GROUP BY 1, 2
    ORDER BY 1, 3 DESC) as t1
WHERE rank = 1;
```
	
### 16. Customer Lifetime Value (CLV)
#### Question: 
#### Calculate the total revenue generated by each customer over all their orders.
	
#### Solution:
```sql
/* Join - customers, orders table
Calculate - sum of total amount */

SELECT 
    c.customer_id,
    c.customer_name,
    SUM(o.total_amount) as CLV
FROM orders as o
JOIN customers as c
ON o.customer_id = c.customer_id
GROUP BY 1, 2
```

### 17. Monthly Sales Trends
#### Question: 
#### Identify sales trends by comparing each month's total sales to the previous month.
	
#### Solution:
```sql
/* Extract - year, month from order date
Sum - total amount
Lag - total amount with 1 month */

SELECT
EXTRACT(YEAR FROM order_date) as year,
EXTRACT(MONTH FROM order_date) as month,
SUM(total_amount) as total_sales,
LAG(SUM(total_amount), 1) OVER (ORDER BY EXTRACT(YEAR FROM order_date), 
    EXTRACT(MONTH FROM order_date)) as previous_total_sales
FROM orders
GROUP BY 1, 2;
```

### 18. Rider Efficiency
#### Question: 
#### Evaluate rider efficiency by determining average delivery times and identifying those with the lowest and highest averages.

#### Solution:
```sql
/* CTE - extract time to deliver
Join - orders, deliveries tables
CTE - avg of time to deliver grouped on rider
Calculate - max and min of all the averages */

WITH riders_time as (
    SELECT
        *,
        o.order_id,
        d.rider_id as riders_id,
        o.order_time,
        d.delivery_time,
        ROUND(EXTRACT(EPOCH FROM (d.delivery_time - o.order_time + 
        CASE WHEN d.delivery_time < o.order_time THEN INTERVAL '1 day' 
        ELSE INTERVAL '0 day' 
        END))/60, 2) as time_to_deliver
    FROM orders as o
    JOIN deliveries as d
    ON o.order_id = d.order_id
    WHERE d.delivery_status = 'Delivered'
),

avg_riders_time as (
SELECT 
    riders_id,
    AVG(time_to_deliver) as avg_time
    FROM riders_time
    GROUP BY 1
)

SELECT 
    ROUND(max(avg_time),2) as max_time,
    ROUND(min(avg_time),2) as min_time
FROM avg_riders_time;
```

### 19. Order Item Popularity
#### Question: 
#### Track the popularity of specific order items over time and identify seasonal demand spikes.
	
#### Solution:
```sql
/* CTE - to extract month and categorize season
Count - Orders
Group by - orders, item */

WITH t1 as (
    SELECT
        *,
        EXTRACT (MONTH FROM order_date) as month,
        CASE
            WHEN EXTRACT (MONTH FROM order_date) BETWEEN 3 AND 5 THEN 'Summer'
            WHEN EXTRACT (MONTH FROM order_date) BETWEEN 6 AND 8 THEN 'Monsoon'
            WHEN EXTRACT (MONTH FROM order_date) BETWEEN 9 AND 11 THEN 'Autumn'
            ELSE 'Winter'
            END as seasons
    FROM orders
    )
SELECT
    order_item,
    seasons,
    count(order_id) as total_orders
FROM t1
GROUP BY 1, 2
ORDER BY 1, 3 DESC;
```

### 20. City Ranking
#### Question: 
#### Rank each city based on the total revenue for last year 2023. 
	
#### Solution:
```sql
/* Join - restaurants, orders tables
Sum - total amount
Rank - based on sum of total_amount
Group by - city */

SELECT
    r.city,
    SUM(o.total_amount) as revenue,
    RANK() OVER (ORDER BY SUM(o.total_amount) DESC) as city_rank
FROM orders as o
JOIN restaurants as r
ON o.restaurant_id = r.restaurant_id
GROUP BY 1;

SELECT
    o.order_id,
    o.order_time,
    d.delivery_time
FROM orders as o
JOIN deliveries as d
ON o.order_id = d.order_id
WHERE d.delivery_status = 'Delivered'

select delivery_time from deliveries
WHERE delivery_status = 'Delivered'
```

## Conclusion

This project showcases my proficiency in managing complex SQL queries and offering solutions to practical business challenge to real-world business problems in the context of a food delivery service like Zomato. The approach here reflexts a structured problem-solving methodology, data manipulation skills, and the ability to derive actionable insights from data.

## Notice 

All customer names and data used in this project are computer-generated using AI and random functions. They do not represent real data associated with Zomato or any other entity. This project is solely for learning and educational purposes, and any resemblance to actual persons, businesses, or events is purely coincidental.

## Source of Inspiration

This project draws ideas, datasets or code structures from the project featured on Youtube channel - Zero Analyst.
