-- Data Analysis Project
-- ZOMATO - An Indian food delivery company and multinational restaurant aggregator

	CREATE DATABASE zomato_db;

-- Drop existing tables, if available
	DROP TABLE IF EXISTS restaurants;
	DROP TABLE IF EXISTS customers;
	DROP TABLE IF EXISTS riders;
	DROP TABLE IF EXISTS orders;
	DROP TABLE IF EXISTS deliveries;

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

-- END of Schemas

	SELECT * FROM restaurants;
	SELECT * FROM customers;
	SELECT * FROM riders;
	SELECT * FROM orders;
	SELECT * FROM deliveries;

-- Import data into tables in the below order
-- 1. restaurants
-- 2. customers
-- 3. riders
-- 4. orders
-- 5. deliveries