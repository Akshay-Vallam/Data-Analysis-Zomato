-- Zomato Data Analysis Project - 20 Advaned Business Problems

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
		
-- Handling Null values (Alternatively)

	UPDATE orders
	SET total_amount = COALESCE(total_amount, 0);