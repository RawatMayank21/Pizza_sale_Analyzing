Create database pizza_sales;

use pizza_sales;

create table orders
(order_id int not null,
order_date date not null,
order_time time not null,
primary key (order_id) ) ;

create table order_details (
order_details_id int not null,
order_id int not null,
pizza_id varchar(255) not null,
quantity int not null,
primary key(order_details_id));

-- Retrieve the total number of orders placed.

select count(order_date) as total_order from orders;

-- Calculate the total revenue generated from pizza sales.

SELECT 
    ROUND(SUM(order_details.quantity * pizzas.price),
            2) total_revenue
FROM
    order_details
        JOIN
    pizzas ON order_details.pizza_id = pizzas.pizza_id;
    
-- Identify the highest-priced pizza.

SELECT 
    pizza_types.name, pizzas.price
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
ORDER BY pizzas.price DESC
LIMIT 1;

-- Identify the most common pizza size ordered.

SELECT 
    pizzas.size,
    COUNT(order_details.order_details_id) AS most_ordered_pizza
FROM
    pizzas
        JOIN
    order_details ON pizzas.pizza_id = order_details.pizza_id
GROUP BY pizzas.size
ORDER BY most_ordered_pizza DESC
LIMIT 1;

-- List the top 5 most ordered pizza types along with their quantities.

SELECT 
    pizza_types.name, SUM(order_details.quantity) AS quantity
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
        JOIN
    order_details ON order_details.pizza_id = pizzas.pizza_id
GROUP BY pizza_types.name
ORDER BY quantity DESC
LIMIT 5;

-- Join the necessary tables to find the total quantity of each pizza category ordered.

SELECT 
    pizza_types.category,
    SUM(order_details.quantity) AS quantity
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
        JOIN
    order_details ON order_details.pizza_id = pizzas.pizza_id
GROUP BY pizza_types.category
ORDER BY quantity DESC;

-- Determine the distribution of orders by hour of the day.

SELECT 
    HOUR(order_time) AS Timing, COUNT(order_id) num_of_order
FROM
    orders
GROUP BY Timing;

-- Join relevant tables to find the category-wise distribution of pizzas.

SELECT 
    category, COUNT(name)
FROM
    pizza_types
GROUP BY category;

-- Group the orders by date and calculate the average number of pizzas ordered per day.

SELECT 
    ROUND(AVG(quantity), 0)
FROM
    (SELECT 
        orders.order_date, SUM(order_details.quantity) AS quantity
    FROM
        orders
    JOIN order_details ON orders.order_id = order_details.order_id
    GROUP BY orders.order_date) AS per_day_quantity;
    
-- Determine the top 3 most ordered pizza types based on revenue.

SELECT 
    pizza_types.name,
    SUM(order_details.quantity * pizzas.price) AS revenue
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
        JOIN
    order_details ON order_details.pizza_id = pizzas.pizza_id
GROUP BY pizza_types.name
ORDER BY revenue DESC
LIMIT 3;

-- Calculate the percentage contribution of each pizza type to total revenue.

SELECT 
    pizza_types.category,
    round(SUM(order_details.quantity * pizzas.price) / (SELECT 
    ROUND(SUM(order_details.quantity * pizzas.price),
            2) total_revenue
FROM
    order_details
        JOIN
    pizzas ON order_details.pizza_id = pizzas.pizza_id) * 100,2) as revenue
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
        JOIN
    order_details ON order_details.pizza_id = pizzas.pizza_id
GROUP BY pizza_types.category
ORDER BY revenue DESC;

-- Analyze the cumulative revenue generated over time.

select order_date, sum(revenue) over(order by order_date) as cum_revenue from 
(SELECT 
orders.order_date, sum(order_details.quantity*pizzas.price) as revenue 
from order_details join pizzas on order_details.pizza_id = pizzas.pizza_id join orders on  orders.order_id = order_details.order_id group by orders.order_date) as sale;

-- Determine the top 3 most ordered pizza types based on revenue for each pizza category.
select category, name, revenue, rank() over(partition by category order by revenue desc) as rn from  
(select pizza_types.category, pizza_types.name, sum((order_details.quantity)*pizzas.price) as revenue FROM pizza_types join pizzas on pizza_types.pizza_type_id = pizzas.pizza_type_id
join order_details on order_details.pizza_id = pizzas.pizza_id group by pizza_types.category, pizza_types.name) as category_revenue;
