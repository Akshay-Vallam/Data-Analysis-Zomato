# Comprehensive Data Analysis using SQL
# Amazon - A multinational technology company engaged in e-commerce, cloud computing, digital streaming etc.

![AMAZON](https://github.com/Akshay-Vallam/Data-Analysis_Amazon/blob/main/amazon_image.jpg)

## Overview

This project demonstrates my problem-solving skills through the analysis of 9 comprehensive datasets having more than 21,000 records for the company Amazon. This project involves usage of PostgreSQL. It helped me to understand the following business insights:

 - Customer Behaviour, Segmentation and Insights
 - Sales Trends and Revenue Analysis
 - Inventory Management
 - Payment and shipping Analysis
 - Forecasting and Product Performance

Also the key business problems identified from this project are:

 - Low product availability due to inconsistent restocking.
 - High return rates for specific product categories.
 - Significant delays in shipments and inconsistencies in delivery times.
 - High customer acquisition costs with a low customer retention rate.

This project has helped me develop the following skills:

 - Design and implement a normalized database schema.
 - Clean and preprocess real-world datasets for analysis.
 - Utilize advanced SQL techniques like window functions, subqueries, joins etc.
 - Conduct in-depth business analysis using SQL.
 - Optimize query performance and handle large datasets efficiently.

## Project Structure

- **Database Setup:** Creation of the `amazon_db` database and the required tables.
- **Data Import:** Inserting sample data into the tables.
- **Data Cleaning:** Handling null values and ensuring data integrity.
- **Business Problems:** Solving 20 specific business problems using SQL queries.

![ERD](https://github.com/Akshay-Vallam/Data-Analysis_Amazon/blob/main/amazon_schemas_erd.png)

## Database Setup
```sql
CREATE DATABASE amazon_db;
```
### 1. Dropping Existing Tables
```sql
DROP TABLE IF EXISTS category;
DROP TABLE IF EXISTS customers;
DROP TABLE IF EXISTS sellers;
DROP TABLE IF EXISTS products;
DROP TABLE IF EXISTS orders;
DROP TABLE IF EXISTS order_items;
DROP TABLE IF EXISTS payments;
DROP TABLE IF EXISTS shipping;
DROP TABLE IF EXISTS inventory;
```
### 2. Creating Tables
```sql
-- Create category table
DROP TABLE IF EXISTS category;
CREATE TABLE category
(
category_id	INT PRIMARY KEY,
category_name VARCHAR(20)
);

-- Create customers table
DROP TABLE IF EXISTS customers;
CREATE TABLE customers
(
customer_id INT PRIMARY KEY,	
first_name	VARCHAR(20),
last_name	VARCHAR(20),
state VARCHAR(20)
);

-- Create sellers table
DROP TABLE IF EXISTS sellers;
CREATE TABLE sellers
(
seller_id INT PRIMARY KEY,
seller_name	VARCHAR(25),
origin VARCHAR(15)
);

-- Create products table
DROP TABLE IF EXISTS products;
CREATE TABLE products
(
product_id INT PRIMARY KEY,	
product_name VARCHAR(50),	
price	FLOAT,
cogs	FLOAT,
category_id INT, -- FK 
CONSTRAINT product_fk_category FOREIGN KEY(category_id) REFERENCES category(category_id)
);
	
-- Create orders table
DROP TABLE IF EXISTS orders;
CREATE TABLE orders
(
order_id INT PRIMARY KEY, 	
order_date	DATE,
customer_id	INT, -- FK
seller_id INT, -- FK 
order_status VARCHAR(15),
CONSTRAINT orders_fk_customers FOREIGN KEY (customer_id) REFERENCES customers(customer_id),
CONSTRAINT orders_fk_sellers FOREIGN KEY (seller_id) REFERENCES sellers(seller_id)
);

-- Create order_items table
DROP TABLE IF EXISTS order_items;
CREATE TABLE order_items
(
order_item_id INT PRIMARY KEY,
order_id INT,	-- FK 
product_id INT, -- FK
quantity INT,	
price_per_unit FLOAT,
CONSTRAINT order_items_fk_orders FOREIGN KEY (order_id) REFERENCES orders(order_id),
CONSTRAINT order_items_fk_products FOREIGN KEY (product_id) REFERENCES products(product_id)
);
	
-- Create payments table
DROP TABLE IF EXISTS payments;
CREATE TABLE payments
(
payment_id	
INT PRIMARY KEY,
order_id INT, -- FK 	
payment_date DATE,
payment_status VARCHAR(20),
CONSTRAINT payments_fk_orders FOREIGN KEY (order_id) REFERENCES orders(order_id)
);

-- Create shipping table
DROP TABLE IF EXISTS shipping;
CREATE TABLE shipping
(
shipping_id	INT PRIMARY KEY,
order_id	INT, -- FK
shipping_date DATE,	
return_date	 DATE,
shipping_providers	VARCHAR(15),
delivery_status VARCHAR(15),
CONSTRAINT shipping_fk_orders FOREIGN KEY (order_id) REFERENCES orders(order_id)
);

-- Create inventory table
DROP TABLE IF EXISTS inventory;
CREATE TABLE inventory
(
inventory_id INT PRIMARY KEY,
product_id INT, -- FK
stock INT,
warehouse_id INT,
last_stock_date DATE,
CONSTRAINT inventory_fk_products FOREIGN KEY (product_id) REFERENCES products(product_id)
);
```
## Data Import

Import data into tables in the below order
- category
- customers
- sellers
- products
- orders
- order_items
- payments
- shipping
- inventory

## Data Cleaning

Prior to analysis, I've ensured that the data was clean and free from null values where necessary.

```sql
SELECT * FROM category;
SELECT * FROM customers;
SELECT * FROM sellers;
SELECT * FROM products;
SELECT * FROM orders;
SELECT * FROM order_items;
SELECT * FROM payments;
SELECT * FROM shipping;
SELECT * FROM inventory;

-- Handling Null Values

SELECT COUNT(*) FROM category
    WHERE
    category_name IS NULL;

SELECT COUNT(*) FROM customers
    WHERE
    first_name IS NULL
    OR
    last_name IS NULL
    OR
    state IS NULL;

SELECT COUNT(*) FROM sellers
    WHERE
    seller_name IS NULL
    OR
    origin IS NULL;

SELECT COUNT(*) FROM products
    WHERE
    product_name IS NULL
    OR
    price IS NULL
    OR
    cogs IS NULL
    OR
    category_id IS NULL;

SELECT COUNT(*) FROM orders
    WHERE
    order_date IS NULL
    OR
    customer_id IS NULL
    OR
    seller_id IS NULL
    OR
    order_status IS NULL;

SELECT COUNT(*) FROM order_items
    WHERE
    order_id IS NULL
    OR
    product_id IS NULL
    OR
    quantity IS NULL
    OR
    price_per_unit IS NULL;

SELECT COUNT(*) FROM payments
    WHERE
    order_id IS NULL
    OR
    payment_date IS NULL
    OR
    payment_status IS NULL;

--return_date null values in shipping table are left as is, as not all shipments are returned

SELECT COUNT(*) FROM shipping
    WHERE
    order_id IS NULL
    OR
    shipping_date IS NULL
    OR
    return_date IS NULL
    OR
    shipping_providers IS NULL
    OR
    delivery_status IS NULL;

SELECT COUNT(*) FROM inventory
    WHERE
    product_id IS NULL
    OR
    stock IS NULL
    OR
    warehouse_id IS NULL
    OR
    last_stock_date IS NULL;
```
## Business Problems

### Tables overview
```sql
SELECT * FROM category;
SELECT * FROM customers;
SELECT * FROM sellers;
SELECT * FROM products;
SELECT * FROM orders;
SELECT * FROM order_items;
SELECT * FROM payments;
SELECT * FROM shipping;
SELECT * FROM inventory;
```

### 1. Top Selling Products

#### Question: 
#### Query the top 10 products by total sales value.
#### Challenge: 
#### Include product name, total quantity sold, and total sales value..
	
#### Solution:
```sql
/* Join - Order_items, orders, product tables
Calculate - quantity * price_per_unit
Group - product_id, product_name
Limit - 10 */	

-- Approach 1 - Without adding new column

SELECT 
    oi.product_id,
    p.product_name,
    COUNT(o.order_id) as total_orders,
    ROUND(SUM(oi.quantity * oi.price_per_unit)::numeric, 2) as total_sale_amount
FROM orders as o
JOIN order_items as oi
ON o.order_id = oi.order_id
JOIN products as p
ON p.product_id = oi.product_id
GROUP BY 1, 2
ORDER BY 4 DESC
LIMIT 10;
	
-- Approach 2 - By adding new column

ALTER TABLE order_items
ADD COLUMN total_sale FLOAT;

SELECT * FROM order_items;

UPDATE order_items
SET total_sale = quantity * price_per_unit;

SELECT * FROM order_items
ORDER BY quantity DESC;

SELECT 
    oi.product_id,
    p.product_name,
    COUNT(o.order_id) as total_orders,
    ROUND(SUM(oi.total_sale)::numeric, 2) as total_sale
FROM orders as o
JOIN order_items as oi
ON o.order_id = oi.order_id
JOIN products as p
ON p.product_id = oi.product_id
GROUP BY 1, 2
ORDER BY 4 DESC
LIMIT 10;
```

### 2. Revenue by Category
#### Question: 
#### Calculate total revenue generated by each product category
#### Challenge: 
#### Include the percentage contribution of each category to total revenue.
	
#### Solution:
```sql
/* Join - Order_items, orders, product tables
Calculate - total sale of product_id * total sale amount * 100
Group - product_id, category_name */	
		
SELECT 
    p.product_id,
    c.category_name,
    ROUND(SUM(oi.total_sale)::numeric) as total_sale,
    ROUND(SUM(oi.total_sale)::numeric/(SELECT SUM(total_sale)::numeric FROM order_items),2) * 100 as contribution
FROM order_items as oi
JOIN products as p
ON oi.product_id = p.product_id
LEFT JOIN category as c
ON c.category_id = p.category_id
GROUP BY 1, 2
ORDER BY 3 DESC;
```

### 3. Average Order Value (AOV)
#### Question: 
#### Compute the average order value for each customer.
#### Challenge: 
#### Include only customers with more than 5 orders.

#### Solution:
```sql
/* Join - Order_items, orders, customers tables
Calculate - Sum of total sale / total orders */	
	
SELECT 
    c.customer_id,
    CONCAT(c.first_name, ' ', c.last_name) as full_name,
    ROUND(SUM(oi.total_sale)::numeric/COUNT(o.order_id)::numeric, 2) as AOV,
    COUNT(o.order_id) as total_orders
FROM orders as o
JOIN order_items as oi
ON o.order_id = oi.order_id
JOIN customers as c
ON c.customer_id = o.customer_id
GROUP BY 1, 2
HAVING COUNT(o.order_id) > 5
ORDER BY 3;
```

### 4. Monthly Sales Trend
#### Question: 
#### Query monthly total sales over the past year.
#### Challenge: 
#### Display the sales trend, grouping by month, return current_month sale, last month sale! 
	
#### Solution:
```sql
/* CTE - to extract month, year, total sale for 2024
LAG - to lag total_sale by 1 month	*/	

WITH cy AS
    (SELECT 
        EXTRACT(MONTH FROM order_date) as month,
        EXTRACT(YEAR FROM order_date) as year,
        ROUND(SUM(oi.total_sale::numeric), 2) as total_sale
    FROM orders as o
    JOIN order_items as oi
    ON oi.order_id = o.order_id
    WHERE o.order_date >= CURRENT_DATE - INTERVAL '1 Year 2 month'
    GROUP BY 1, 2
    ORDER BY 1, 2)

SELECT 
    year,
    month,
    total_sale as current_mont_sale,
    LAG(total_sale, 1) OVER(ORDER BY year, month) as last_month_sale
FROM cy;
```

### 5. Customers with No Purchases
#### Question: 
#### Find customers who have registered but never placed an order.
#### Challenge: 
#### List customer details and the time since their registration.
	
#### Solution:
```sql
/* Left Join - customers to orders table
Filter - where order_id is null */	

SELECT * 
FROM customers as c
LEFT JOIN orders as o
ON o.customer_id = c.customer_id
WHERE o.customer_id IS NULL;
```

### 6. Least-Selling Categories by State
#### Question: 
#### Identify the least-selling product category for each state.
#### Challenge: 
#### Include the total sales for that category within each state.
	
#### Solution:
```sql
/* Join - orders, customers, order_items, products tables
Calculate - Sum of order items
Group - state and category
Rank - least as 1 and display least */	

WITH rt AS 
    (
    SELECT 
        c.state,
        cat.category_name,
        ROUND(SUM(oi.total_sale)::numeric,2) as total_sale,
        RANK() OVER (PARTITION BY c.state ORDER BY SUM(oi.total_sale) ASC) as rank
    FROM orders as o
    JOIN customers as c
    ON c.customer_id = o.customer_id
    JOIN order_items as oi
    ON oi.order_id = o.order_id
    JOIN products as p
    ON p.product_id = oi.product_id
    JOIN category as cat
    ON cat.category_id = p.category_id
    GROUP BY 1, 2
    )

SELECT * FROM rt
WHERE rank = 1;
```
	
### 7. Customer Lifetime Value (CLTV)
#### Question: 
#### Calculate the total value of orders placed by each customer over their lifetime.
#### Challenge: 
#### Rank customers based on their CLTV.
	
#### Solution:
```sql
/* Join - orders, order_items, customers tables
Calculate - Sum of total_sale
Rank - Highest as 1 */	

SELECT 
    c.customer_id,
    CONCAT(c.first_name, ' ', c.last_name) as full_name,
    ROUND(SUM(oi.total_sale)::numeric, 2) as CLTV,
    DENSE_RANK() OVER (ORDER BY SUM(oi.total_sale) DESC) as cx_ranking
FROM orders as o
JOIN order_items as oi
ON o.order_id = oi.order_id
JOIN customers as c
ON c.customer_id = o.customer_id
GROUP BY 1, 2;
```

### 8. Inventory Stock Alerts
#### Question: 
#### Query products with stock levels below a certain threshold (e.g., less than 10 units).
#### Challenge: 
#### Include last restock date and warehouse information.
	
#### Solution:
```sql
/* Join - inventory, products table
where - stock<10 */	
	
SELECT
    i.inventory_id,
    p.product_name,
    i.stock as current_remaining_stock,
    i.last_stock_date,
    i.warehouse_id
FROM inventory as i
JOIN products as p
ON p.product_id = i.product_id
WHERE i.stock<10;
```

### 9. Shipping Delays
#### Question: 
#### Identify orders where the shipping date is later than 3 days after the order date.
#### Challenge: 
#### Include customer, order details, and delivery provider.
	
#### Solution:
```sql
/* Join - prders, customers, shipping tables
where - shipping_date - order_date > 3 */	

SELECT 
    c.*,
    o.*,
    s.shipping_providers,
    s.shipping_date - o.order_date as days_to_ship
FROM orders as o
JOIN customers as c
ON o.customer_id = c.customer_id
JOIN shipping as s
ON o.order_id = s.order_id
WHERE s.shipping_date - o.order_date > 3;
```

### 10. Payment Success Rate
#### Question: 
#### Calculate the percentage of successful payments across all orders.
#### Challenge: 
#### Include breakdowns by payment status (e.g., failed, pending).
	
#### Solution:
```sql
/* Join - orders, payments tables
Group by - payment status
Calculate - Total and percentage by payment status category */	
	
SELECT
    p.payment_status,
    COUNT(*) as total_count,
    ROUND(COUNT(*)::numeric/(SELECT COUNT(*) FROM payments)::numeric * 100, 2) as contribution
FROM orders as o
JOIN payments as p
ON o.order_id = p.order_id
GROUP BY 1;
```
	
### 11. Top Performing Sellers
#### Question: 
#### Find the top 5 sellers based on total sales value.
#### Challenge: 
#### Include both successful and failed orders, and display their percentage of successful orders.
	
#### Solution:
```sql
/* Join -sellers, orders, order_items tables 
CTE - for total sales, order_status not in 'inprogress', 'returned'
Calculate - completed, cancelled orders count, percentage */	

WITH top_sellers AS
    (
    SELECT 
        s.seller_id,
        s.seller_name,
        ROUND(SUM(oi.total_sale)::numeric, 2) as total_sale
    FROM orders as o
    JOIN sellers as s
    ON o.seller_id = s.seller_id
    JOIN order_items as oi
    ON oi.order_id = o.order_id
    GROUP BY 1,2
    ORDER BY 3 DESC
    LIMIT 5
    ),
    
seller_report AS
(
SELECT
    o.seller_id,
    ts.seller_name,
    o.order_status,
    COUNT(*) as total_orders
FROM orders as o
JOIN top_sellers as ts
ON ts.seller_id = o.seller_id
WHERE o.order_status NOT IN ('Inprogress', 'Returned')
GROUP BY 1, 2, 3
)

SELECT 
    sr.seller_id,
    sr.seller_name,
    SUM(CASE WHEN sr.order_status = 'Completed' THEN sr.total_orders ELSE 0 END) as completed_orders,
    SUM(CASE WHEN sr.order_status = 'Cancelled' THEN sr.total_orders ELSE 0 END) as cancelled_orders,
    SUM(sr.total_orders) as total_orders,
    ROUND(SUM(CASE WHEN sr.order_status = 'Completed' THEN sr.total_orders ELSE 0 END)::numeric
        /SUM(total_orders)::numeric * 100, 2) as sucessful_orders_percentage,
    ROUND(SUM(CASE WHEN sr.order_status = 'Cancelled' THEN sr.total_orders ELSE 0 END)::numeric
        /SUM(total_orders)::numeric * 100, 2) as unsucessful_orders_percentage		
FROM seller_report as sr
GROUP BY 1, 2;
```

### 12. Product Profit Margin
#### Question: 
#### Calculate the profit margin for each product (difference between price and cost of goods sold).
#### Challenge: 
#### Rank products by their profit margin, showing highest to lowest. 
	
#### Solution:
```sql
/* Join - products, order_items tables
Calculate - sum of total sale/(cogs*quantity) and its percentage
Rank - Higest margin as 1 with the help of CTE */	

WITH pm AS
(
SELECT 
    p.product_id,
    p.product_name,
    ROUND(SUM(total_sale::numeric - (p.cogs * oi.quantity)::numeric), 2) as profit,
    ROUND(SUM(total_sale::numeric - (p.cogs * oi.quantity)::numeric)/SUM(total_sale)::numeric, 2) * 100 as profit_margin
FROM order_items as oi
JOIN products as p
ON oi.product_id = p.product_id
GROUP BY 1, 2
)

SELECT 
    product_id,
    product_name,
    profit_margin,
    DENSE_RANK() OVER (ORDER BY profit_margin DESC) as product_ranking
FROM pm;
```

### 13. Most Returned Products
#### Question: 
#### Query the top 10 products by the number of returns.
#### Challenge: 
#### Display the return rate as a percentage of total units sold for each product. 
	
#### Solution:
```sql
/* Join - order_items, products, orders tables
Calculate - Count of total orders, Sum of number of returned orders and its percentage */	

SELECT
    p.product_id,
    p.product_name,
    COUNT(*) as total_units_sold,
    SUM(CASE WHEN o.order_status = 'Returned' THEN 1 ELSE 0 END) as total_returned,
    ROUND(SUM(CASE WHEN o.order_status = 'Returned' THEN 1 ELSE 0 END)::numeric
        /COUNT(*)::numeric * 100, 2) as return_percentage
FROM order_items as oi
JOIN products as p
ON oi.product_id = p.product_id
JOIN orders as o
ON o.order_id = oi.order_id
GROUP BY 1, 2
ORDER BY 5 DESC;
```	
	
### 14. Orders Pending Shipment
#### Question: 
#### Find orders that have been paid but are still pending shipment.
#### Challenge: 
#### Include order details, payment date, and customer information.
	
#### Solution:
```sql
/* Join - shippings, payments, orders tables
Where - payment succeded & order shipped */	
    
SELECT
    o.customer_id,
    s.order_id,
    pt.payment_status,
    pt.payment_date,
    s.delivery_status
FROM shipping as s
JOIN payments as pt
ON s.order_id = pt.order_id
JOIN orders as o
ON s.order_id = o.order_id
WHERE 
    pt.payment_status = 'Payment Successed'
    AND
    s.delivery_status = 'Shipped';
```

### 15. Inactive Sellers
#### Question: 
#### Identify sellers who haven’t made any sales in the last 8 months.
#### Challenge: 
#### Show the last sale date and total sales from those sellers.
	
#### Solution:
```sql
/* CTE - sellers not in current date - 8 months
Show - last sale date, last sale amount, seller id*/	

WITH st as
(
SELECT  * FROM sellers
WHERE seller_id NOT IN (SELECT seller_id FROM orders where order_date >= CURRENT_DATE - interval '8 month')
)

SELECT
    o.seller_id,
    MAX(o.order_date) as last_sale_date,
    ROUND(MAX(oi.total_sale)::numeric,2) as last_sale_amount
FROM orders as o
JOIN st as st
ON st.seller_id = o.seller_id
JOIN order_items as oi
ON o.order_id = oi.order_id
GROUP BY 1;
```
	
### 16. Categorize customers into returning or new
#### Question: 
#### if the customer has done more than 5 return categorize them as returning otherwise new
#### Challenge: 
#### List customers id, name, total orders, total returns.
	
#### Solution:
```sql
/* Join - orders, customers, order_items tables
CTE - to calculate count of total orders when order_status is returned
Case - when returned > 5 categorize as returning else new */	

WITH tr AS
    (
    SELECT
        CONCAT (c.first_name, ' ', c.last_name) as full_name,
        COUNT(o.order_id) as total_orders,
        SUM(CASE WHEN o.order_status = 'Returned' THEN 1 ELSE 0 END) as total_returns
    FROM orders as o
    JOIN customers as c
    ON c.customer_id = o.customer_id
    JOIN order_items as oi
    ON oi.order_id = o.order_id
    GROUP BY 1
    )

SELECT 
    tr.full_name,
    tr.total_orders,
    tr.total_returns,
    CASE WHEN tr.total_returns > 5 THEN 'Returning_customers' ELSE 'New' END as cx_category
FROM tr;
```

### 17. Top 5 Customers by Orders in Each State
#### Question: 
#### Identify sales trends by comparing each month's total sales to the previous month.
	
#### Solution:
```sql
/* Calculate - total orders
Rank - top 5 customers with total_sale
CTE - to calculate rank <=5 */	

    WITH rank AS
    (
    SELECT
        c.state,
        CONCAT(c.first_name, ' ', c.last_name) as full_name,
        COUNT(o.order_id) as total_orders,
        ROUND(SUM(total_sale)::numeric, 2) as total_sales,
        DENSE_RANK() OVER (PARTITION BY c.state ORDER BY COUNT(o.order_id) DESC) as rank 
    FROM orders as o
    JOIN order_items as oi
    ON oi.order_id = o.order_id
    JOIN customers as c
    ON c.customer_id = o.customer_id
    GROUP BY 1, 2
    )
    
SELECT * FROM rank
WHERE rank <= 5;
```

### 18. Revenue by Shipping Provider
#### Question: 
#### Calculate the total revenue handled by each shipping provider.
#### Challenge: 
#### Include the total number of orders handled and the average delivery time for each provider.

#### Solution:
```sql
SELECT
    s.shipping_providers,
    COUNT(o.order_id) as order_handled,
    ROUND(SUM(oi.total_sale)::numeric, 2) as total_sale,
    ROUND(COALESCE(AVG(s.return_date - s.shipping_date), 0)::numeric, 2) as average_days
FROM orders as o
JOIN
order_items as oi
ON oi.order_id = o.order_id
JOIN
shipping as s
ON s.order_id = o.order_id
GROUP BY 1;
```

### 19. Decreasing Revenue Ratio
#### Question: 
#### Top 10 product with highest decreasing revenue ratio compare to last year(2022) and current_year(2023)
#### Challenge: 
#### Return product_id, product_name, category_name, 2022 revenue and 2023 revenue decrease ratio at end Round the result Note: Decrease ratio = cr-ls/ls* 100 (cs = current_year ls=last_year).
	
#### Solution:
```sql
/* CTE - to calculate revenue of 2022, 2023 seperately
Join - 2022, 2023 ctes
calculate - revenue of 2022 - revenue pf 2023 and its percentage decrease
Limit to top 10	*/	

WITH year2022 AS
(
    SELECT 
        p.product_id,
        p.product_name,
        ROUND(SUM(oi.total_sale)::numeric, 2) as revenue
    FROM orders as o
    JOIN order_items as oi
    ON oi.order_id = o.order_id
    JOIN products as p
    ON p.product_id = oi.product_id
    WHERE EXTRACT(YEAR FROM o.order_date) = 2022
    GROUP BY 1,2
),
year2023 AS
(
    SELECT 
        p.product_id,
        p.product_name,
        ROUND(SUM(oi.total_sale)::numeric, 2) as revenue
    FROM orders as o
    JOIN order_items as oi
    ON oi.order_id = o.order_id
    JOIN products as p
    ON p.product_id = oi.product_id
    WHERE EXTRACT(YEAR FROM o.order_date) = 2023
    GROUP BY 1,2
)

SELECT 
    y23.product_id,
    y22.revenue as revenue_2022,
    y23.revenue as revenue_2023,
    y22.revenue - y23.revenue as revenue_diff,
    ROUND((y22.revenue - y23.revenue)::numeric/(y22.revenue)::numeric * 100, 2) as dec_revenue_ratio
FROM year2022 as y22
JOIN year2023 as y23
ON y22.product_id = y23.product_id
WHERE
    y22.revenue > y23.revenue
ORDER BY 5 DESC
LIMIT 10;
```

### 20. Stored Procedure
#### Question: 
#### Create a function as soon as the product is sold the the same quantity should reduced from inventory table after adding any sales records it should update the stock in the inventory table based on the product and quantity purchased.
	
#### Solution:
```sql
/* Create - stored procedure
Verify - stock
Use - stored procedure */	
CREATE OR REPLACE PROCEDURE add_sales
(
p_order_id INT,
p_customer_id INT,
p_seller_id INT,
p_order_item_id INT,
p_product_id INT,
p_quantity INT
)
LANGUAGE plpgsql
AS $$

DECLARE 
-- all variable
v_count INT;
v_price FLOAT;
v_product VARCHAR(50);

BEGIN
-- Fetching product name and price based p id entered
    SELECT 
        price, product_name
        INTO
        v_price, v_product
    FROM products
    WHERE product_id = p_product_id;
    
-- checking stock and product availability in inventory	
    SELECT 
        COUNT(*) 
        INTO
        v_count
    FROM inventory
    WHERE 
        product_id = p_product_id
        AND 
        stock >= p_quantity;
    
IF v_count > 0 THEN
    -- add into orders and order_items table
    -- update inventory
    INSERT INTO orders(order_id, order_date, customer_id, seller_id)
    VALUES
    (p_order_id, CURRENT_DATE, p_customer_id, p_seller_id);
    
    -- adding into order list
    INSERT INTO order_items(order_item_id, order_id, product_id, quantity, price_per_unit, total_sale)
    VALUES
    (p_order_item_id, p_order_id, p_product_id, p_quantity, v_price, v_price*p_quantity);
    
    --updating inventory
    UPDATE inventory
    SET stock = stock - p_quantity
    WHERE product_id = p_product_id;
        
    RAISE NOTICE 'Thank you product: % sale has been added also inventory stock updates',v_product; 
    
    ELSE
    RAISE NOTICE 'Thank you for for your info the product: % is not available', v_product;
    
    END IF;
    
END;
$$

--	Verifying table for existinjg stock
SELECT COUNT(*) 
FROM inventory
WHERE 
    product_id = 1
    AND 
    stock >= 56


--	Testing Store Procedure
call add_sales
(
25005, 2, 5, 25004, 1, 14
);
```

## Conclusion

This project showcases my proficiency in managing complex SQL queries and offering solutions to practical business challenge to real-world business problems in the context of a ecommerce service like Amazon. The approach here reflects a structured problem-solving methodology, data manipulation skills, and the ability to derive actionable insights from data. From improving customer retention to optimizing inventory and logistics, the project provides valuable insights into operational challenges and solutions.

## Notice 

All customer names and data used in this project are computer-generated using AI and random functions. They do not represent real data associated with Amazon or any other entity. This project is solely for learning and educational purposes, and any resemblance to actual persons, businesses, or events is purely coincidental. 

The datasets (CSV files) have not been uploaded to the GitHub repository.

## Source of Inspiration

This project draws ideas, datasets or code structures from the project featured on Youtube channel - Zero Analyst.
