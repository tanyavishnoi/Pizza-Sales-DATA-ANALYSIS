CREATE DATABASE Pizzahut;
CREATE TABLE Orders (
Order_id INT NOT NULL,
Order_date DATE NOT NULL,
Order_time TIME NOT NULL
);
ALTER TABLE Orders
ADD PRIMARY KEY(Order_id);

CREATE TABLE Order_details (
Order_details_id INT NOT NULL,
Order_id INT NOT NULL,
Pizza_id TEXT NOT NULL,
Quantity INT NOT NULL,
PRIMARY KEY(Order_details_id)
);

-- 1. Retrieve the total number of orders placed.
SELECT 
    COUNT(Order_id) AS Total_orders
FROM
    orders;

-- 2. Calculate the total revenue generated from pizza sales.
SELECT 
    ROUND(SUM((Order_details.Quantity * Pizzas.Price)),
            2) Total_Sales
FROM
    order_details
        JOIN
    pizzas ON Pizzas.Pizza_id = Order_details.Pizza_id;
  
-- 3. Identify the highest-priced pizza.
SELECT 
    pizza_types.name, Pizzas.Price
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
ORDER BY pizzas.price DESC
LIMIT 1;


-- 4. Identify the most common pizza size ordered.
SELECT 
    pizzas.size,
    COUNT(order_details.Order_details_id) AS Order_count
FROM
    pizzas
        JOIN
    order_details ON order_details.Pizza_id = pizzas.pizza_id
GROUP BY pizzas.size
ORDER BY Order_count DESC;

-- 5. List the top 5 most ordered pizza types along with their quantities.
SELECT 
    pizza_types.name, SUM(order_details.quantity) AS Total_order
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
        JOIN
    order_details ON order_details.Pizza_id = pizzas.pizza_id
GROUP BY pizza_types.name
ORDER BY Total_order DESC
LIMIT 5;


-- 6. Join the necessary tables to find the total quantity of each pizza category ordered.
SELECT 
    pizza_types.category,
    SUM(order_details.Quantity) AS Quantity
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
        JOIN
    order_details ON Order_details.pizza_id = pizzas.pizza_id
GROUP BY pizza_types.category
ORDER BY Quantity DESC;

-- 7. Determine the distribution of orders by hour of the day.
SELECT 
    HOUR(Order_time) AS Hour, COUNT(Order_id) AS Order_Count
FROM
    orders
GROUP BY Hour;

-- 8. Join relevant tables to find the category-wise distribution of pizzas.
SELECT Category, COUNT(Name) FROM pizza_types
GROUP BY category;

-- 9. Group the orders by date and calculate the average number of pizzas ordered per day.
SELECT 
    ROUND(AVG(Quantity), 0) AS Avg_order_per_day
FROM
    (SELECT 
        orders.Order_date, SUM(order_details.Quantity) AS Quantity
    FROM
        orders
    JOIN order_details ON orders.Order_id = order_details.Order_id
    GROUP BY orders.Order_date
    ORDER BY Quantity) AS Order_quantity;
    
-- 10. Determine the top 3 most ordered pizza types based on revenue.
SELECT 
    pizza_types.name,
    SUM(order_details.Quantity * pizzas.price) AS Total
FROM
    pizza_types
        JOIN
    pizzas ON pizzas.pizza_type_id = pizza_types.pizza_type_id
        JOIN
    order_details ON Order_details.Pizza_id = pizzas.Pizza_id
GROUP BY pizza_types.name
ORDER BY Total DESC
LIMIT 3;

-- 11. Calculate the percentage contribution of each pizza type to total revenue.
SELECT 
    pizza_types.category,
    ROUND((SUM(order_details.Quantity * pizzas.price) / (SELECT 
                    ROUND(SUM((Order_details.Quantity * Pizzas.Price)),
                                2) Total_Sales
                FROM
                    order_details
                        JOIN
                    pizzas ON Pizzas.Pizza_id = Order_details.Pizza_id)) * 100,
            2) AS Revenue
FROM
    pizza_types
        JOIN
    pizzas ON pizzas.pizza_type_id = pizza_types.pizza_type_id
        JOIN
    order_details ON Order_details.Pizza_id = pizzas.Pizza_id
GROUP BY pizza_types.category
ORDER BY Revenue DESC;

-- 12. Analyze the cumulative revenue generated over time.
SELECT order_date, ROUND(SUM(Revenue) OVER(order by order_date),2) AS Cum_revenue FROM
(SELECT orders.Order_date, SUM(order_details.Quantity * pizzas.price) AS Revenue
FROM Order_details 
JOIN pizzas ON order_details.Pizza_id = pizzas.pizza_id
JOIN orders ON Orders.order_id = order_details.Order_id
GROUP BY orders.Order_date) AS Sales;


-- 13. Determine the top 3 most ordered pizza types based on revenue for each pizza category.
SELECT Name, Revenue FROM
(SELECT Category, Name, Revenue, RANK() OVER(partition by category ORDER BY Revenue DESC) AS rn FROM
(SELECT pizza_types.category, pizza_types.name, SUM(order_details.Quantity * pizzas.price) AS Revenue 
FROM pizza_types
JOIN pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
JOIN order_details ON Order_details.Pizza_id = pizzas.Pizza_id
GROUP BY pizza_types.category, pizza_types.name) AS A) AS B
WHERE RN <=3;