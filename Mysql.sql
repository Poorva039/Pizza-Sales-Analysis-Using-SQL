CREATE DATABASE pizzahut;

USE pizzahut;

CREATE TABLE orders (
    order_id INT NOT NULL,
    order_date DATE NOT NULL,
    order_time TIME NOT NULL,
    PRIMARY KEY (order_id)
);

CREATE TABLE order_details (
    order_details_id INT NOT NULL,
    order_id INT NOT NULL,
    pizza_id TEXT NOT NULL,
    quantity INT NOT NULL,
    PRIMARY KEY (order_details_id)
);

SELECT * FROM pizzas;
SELECT * FROM pizza_types;
SELECT * FROM orders;
SELECT * FROM order_details;

-- Retrieve the total number of orders placed.
SELECT 
    COUNT(order_id) AS Total_order
FROM
    orders;

-- Calculate the total revenue generated from pizza sales.
SELECT 
    ROUND(SUM(od.quantity * p.price), 2) 'Total Sales'
FROM
    order_details od
        JOIN
    pizzas p ON od.pizza_id = p.pizza_id;

-- Identify the highest-priced pizza.
SELECT 
    pt.name, p.price
FROM
    pizza_types pt
        JOIN
    pizzas p USING (pizza_type_id)
WHERE
    p.price = (SELECT 
            MAX(price)
        FROM
            pizzas);

-- Identify the most common pizza size ordered.
SELECT 
    p.size, COUNT(od.order_details_id) AS order_count
FROM
    pizzas p
JOIN
    order_details od ON p.pizza_id = od.pizza_id
GROUP BY p.size
ORDER BY order_count DESC;

-- List the top 5 most ordered pizza types along with their quantities.
SELECT 
    pt.name, SUM(od.quantity) AS Quantity
FROM pizza_types pt 
JOIN
    pizzas p ON pt.pizza_type_id=p.pizza_type_id
JOIN
    order_details od ON p.pizza_id = od.pizza_id
GROUP BY pt.name
ORDER BY SUM(od.quantity) DESC
LIMIT 5;

-- Join the necessary tables to find the total quantity of each pizza category ordered.
SELECT 
    pt.category, SUM(od.quantity) AS Quantity
FROM
    pizza_types pt
        JOIN
    pizzas p ON pt.pizza_type_id = p.pizza_type_id
        JOIN
    order_details od ON od.pizza_id = p.pizza_id
GROUP BY pt.category
ORDER BY quantity DESC;

-- Determine the distribution of orders by hour of the day
SELECT 
    HOUR(order_time) as Hour_base_orders, COUNT(order_id) as count_order
FROM
    orders
GROUP BY HOUR(order_time);

-- Join relevant tables to find the category-wise distribution of pizzas.
select category, count(name)
from pizza_types
group by category;


-- Group the orders by date and calculate the average number of pizzas ordered per day.
SELECT ROUND(AVG(quantity), 0)
FROM
    (SELECT 
        o.order_date, SUM(od.quantity) AS quantity
    FROM
        orders o
    JOIN order_details od ON o.order_id = od.order_id
    GROUP BY o.order_date) AS order_quantity;

-- Determine the top 3 most ordered pizza types based on revenue.
SELECT pt.name, SUM(od.quantity * p.price) AS Revenue
FROM
    pizza_types pt
        JOIN
    pizzas p ON pt.pizza_type_id = p.pizza_type_id
        JOIN
    order_details od ON od.pizza_id = p.pizza_id
GROUP BY pt.name
ORDER BY Revenue DESC
LIMIT 3;

-- Calculate the percentage contribution of each pizza type to total revenue.
SELECT pt.category,
    ROUND((SUM(od.quantity * p.price) / (SELECT 
                    ROUND(SUM(od.quantity * p.price), 2) AS total_sales
                FROM
                    order_details od
                        JOIN
                    pizzas p ON od.pizza_id = p.pizza_id)) * 100,2) AS Revenue
FROM pizza_types pt
        JOIN
    pizzas p ON pt.pizza_type_id = p.pizza_type_id
        JOIN
    order_details od ON od.pizza_id = p.pizza_id
GROUP BY pt.category
ORDER BY Revenue DESC;

-- Analyze the cumulative revenue generated over time.
SELECT order_date, SUM(revenue) OVER (ORDER BY order_date) AS cum_revenue
FROM (SELECT o.order_date, SUM(od.quantity * p.price) AS Revenue
		FROM order_details od
				JOIN
			pizzas p ON od.pizza_id = p.pizza_id
				JOIN
			orders o ON o.order_id = od.order_id
		GROUP BY o.order_date) as sales;

-- Determine the top 3 most ordered pizza types based on revenue for each pizza category.
SELECT name, revenue 
FROM (SELECT category, name, revenue,
RANK() OVER(PARTITION BY category ORDER BY revenue DESC) AS rn
FROM(SELECT pt.category, pt.name,
		SUM((od.quantity) * p.price) AS Revenue
	FROM pizza_types pt
			JOIN
		pizzas p ON pt.pizza_type_id = p.pizza_type_id
			JOIN
		order_details od ON od.pizza_id = p.pizza_id
	GROUP BY pt.category, pt.name) as a) as b
WHERE rn<=3;




