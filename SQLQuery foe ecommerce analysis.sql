-- ======================================
-- E-commerce Sales Analysis Database
-- ======================================

-- Drop tables if they exist (for reruns)
DROP TABLE IF EXISTS Payments;
DROP TABLE IF EXISTS Order_Details;
DROP TABLE IF EXISTS Orders;
DROP TABLE IF EXISTS Products;
DROP TABLE IF EXISTS Customers;

-- ======================================
-- 1. Customers Table
-- ======================================
CREATE TABLE Customers (
    customer_id INT PRIMARY KEY,
    name VARCHAR(100),
    email VARCHAR(100) UNIQUE,
    country VARCHAR(50),
    signup_date DATE
);

-- ======================================
-- 2. Products Table
-- ======================================
CREATE TABLE Products (
    product_id INT PRIMARY KEY,
    name VARCHAR(100),
    category VARCHAR(50),
    price DECIMAL(10,2)
);

-- ======================================
-- 3. Orders Table
-- ======================================
CREATE TABLE Orders (
    order_id INT PRIMARY KEY,
    customer_id INT,
    order_date DATE,
    total_amount DECIMAL(10,2),
    FOREIGN KEY (customer_id) REFERENCES Customers(customer_id)
);

-- ======================================
-- 4. Order_Details Table
-- ======================================
CREATE TABLE Order_Details (
    order_detail_id INT PRIMARY KEY,
    order_id INT,
    product_id INT,
    quantity INT,
    FOREIGN KEY (order_id) REFERENCES Orders(order_id),
    FOREIGN KEY (product_id) REFERENCES Products(product_id)
);

-- ======================================
-- 5. Payments Table
-- ======================================
CREATE TABLE Payments (
    payment_id INT PRIMARY KEY,
    order_id INT,
    payment_method VARCHAR(50),
    payment_date DATE,
    amount DECIMAL(10,2),
    FOREIGN KEY (order_id) REFERENCES Orders(order_id)
);
-- ======================================
-- Insert Sample Data
-- ======================================

-- Customers
INSERT INTO Customers VALUES
(1, 'Alice Johnson', 'alice@example.com', 'USA', '2023-01-15'),
(2, 'Bob Smith', 'bob@example.com', 'India', '2023-02-10'),
(3, 'Charlie Lee', 'charlie@example.com', 'UK', '2023-03-05'),
(4, 'Diana Prince', 'diana@example.com', 'Canada', '2023-04-20'),
(5, 'Ethan Brown', 'ethan@example.com', 'Australia', '2023-05-12');

-- Products
INSERT INTO Products VALUES
(101, 'Laptop', 'Electronics', 1200.00),
(102, 'Smartphone', 'Electronics', 800.00),
(103, 'Headphones', 'Electronics', 150.00),
(104, 'Shoes', 'Fashion', 90.00),
(105, 'T-Shirt', 'Fashion', 25.00);

-- Orders
INSERT INTO Orders VALUES
(1001, 1, '2023-06-01', 2000.00),
(1002, 2, '2023-06-05', 800.00),
(1003, 3, '2023-06-10', 240.00),
(1004, 1, '2023-07-01', 1300.00),
(1005, 4, '2023-07-15', 115.00);

-- Order Details
INSERT INTO Order_Details VALUES
(1, 1001, 101, 1),
(2, 1001, 102, 1),
(3, 1002, 102, 1),
(4, 1003, 103, 2),
(5, 1003, 105, 4),
(6, 1004, 101, 1),
(7, 1004, 103, 2),
(8, 1005, 104, 1),
(9, 1005, 105, 1);

-- Payments
INSERT INTO Payments VALUES
(5001, 1001, 'Credit Card', '2023-06-01', 2000.00),
(5002, 1002, 'PayPal', '2023-06-05', 800.00),
(5003, 1003, 'Credit Card', '2023-06-10', 240.00),
(5004, 1004, 'Debit Card', '2023-07-01', 1300.00),
(5005, 1005, 'Cash', '2023-07-15', 115.00);

-- ======================================
-- E-commerce Analysis Queries
-- ======================================

-- 1. Total number of customers
SELECT COUNT(*) AS total_customers FROM Customers;

-- 2. Total number of products
SELECT COUNT(*) AS total_products FROM Products;

-- 3. Total number of orders
SELECT COUNT(*) AS total_orders FROM Orders;

-- 4. List customers who signed up in the last 60 days
SELECT * 
FROM Customers
WHERE signup_date >= DATEADD(DAY, -60, GETDATE());

-- 5. Top 5 most expensive products
SELECT TOP 5 name, price
FROM Products
ORDER BY price DESC;

-- 6. Total sales revenue
SELECT SUM(total_amount) AS total_revenue FROM Orders;

-- 7. Sales revenue by country
SELECT c.country, SUM(o.total_amount) AS revenue
FROM Orders o
JOIN Customers c ON o.customer_id = c.customer_id
GROUP BY c.country
ORDER BY revenue DESC;

-- 8. Average order value
SELECT AVG(total_amount) AS avg_order_value FROM Orders;

-- 9. Monthly sales trend
SELECT FORMAT(order_date, 'yyyy-MM') AS month, 
       SUM(total_amount) AS monthly_revenue
FROM Orders
GROUP BY FORMAT(order_date, 'yyyy-MM')
ORDER BY month;

-- 10. Most sold product (by quantity)
SELECT p.name, SUM(od.quantity) AS total_sold
FROM Order_Details od
JOIN Products p ON od.product_id = p.product_id
GROUP BY p.name
ORDER BY total_sold DESC;

-- 11. Revenue contribution % by product
SELECT p.name,
       SUM(od.quantity * p.price) AS product_revenue,
       (SUM(od.quantity * p.price) * 100.0) / (SELECT SUM(total_amount) FROM Orders) AS revenue_percentage
FROM Order_Details od
JOIN Products p ON od.product_id = p.product_id
GROUP BY p.name
ORDER BY product_revenue DESC;

-- 12. Top 3 customers by spend
SELECT TOP 3 c.name, SUM(o.total_amount) AS total_spent
FROM Orders o
JOIN Customers c ON o.customer_id = c.customer_id
GROUP BY c.name
ORDER BY total_spent DESC;

-- 13. Total revenue by payment method
SELECT payment_method, SUM(amount) AS total_revenue
FROM Payments
GROUP BY payment_method
ORDER BY total_revenue DESC;

-- 14. Customers with no orders
SELECT c.name, c.email
FROM Customers c
LEFT JOIN Orders o ON c.customer_id = o.customer_id
WHERE o.order_id IS NULL;

-- 15. Customers inactive in last 6 months
SELECT c.name, c.email
FROM Customers c
LEFT JOIN Orders o ON c.customer_id = o.customer_id
WHERE o.order_date < DATEADD(MONTH, -6, GETDATE()) OR o.order_date IS NULL;

-- 16. Best selling category
SELECT p.category, SUM(od.quantity) AS total_items_sold
FROM Products p
JOIN Order_Details od ON p.product_id = od.product_id
GROUP BY p.category
ORDER BY total_items_sold DESC;

-- 17. Revenue by category
SELECT p.category, SUM(od.quantity * p.price) AS total_revenue
FROM Products p
JOIN Order_Details od ON p.product_id = od.product_id
GROUP BY p.category
ORDER BY total_revenue DESC;

-- 18. Orders and revenue per customer
SELECT c.name, COUNT(o.order_id) AS total_orders, SUM(o.total_amount) AS total_spent
FROM Customers c
LEFT JOIN Orders o ON c.customer_id = o.customer_id
GROUP BY c.name
ORDER BY total_spent DESC;

-- 19. Repeat customers (customers with more than 1 order)
SELECT c.name, COUNT(o.order_id) AS order_count
FROM Customers c
JOIN Orders o ON c.customer_id = o.customer_id
GROUP BY c.name
HAVING COUNT(o.order_id) > 1;

-- 20. Daily sales trend
SELECT order_date, SUM(total_amount) AS daily_sales
FROM Orders
GROUP BY order_date
ORDER BY order_date;
-- ======================================
-- Advanced SQL Features
-- ======================================

-- 1. Ranking customers by total spend (Window Function)
SELECT c.name, 
       SUM(o.total_amount) AS total_spent,
       RANK() OVER (ORDER BY SUM(o.total_amount) DESC) AS spend_rank
FROM Orders o
JOIN Customers c ON o.customer_id = c.customer_id
GROUP BY c.name;

-- 2. Running total of revenue by order date (Window Function)
SELECT order_date,
       SUM(total_amount) OVER (ORDER BY order_date ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS running_total
FROM Orders;

-- 3. Monthly moving average of sales (Window Function)
SELECT FORMAT(order_date, 'yyyy-MM') AS month,
       AVG(SUM(total_amount)) OVER (ORDER BY FORMAT(order_date, 'yyyy-MM') ROWS 2 PRECEDING) AS moving_avg
FROM Orders
GROUP BY FORMAT(order_date, 'yyyy-MM');

-- 4. CTE for Average Spend Per Customer
WITH avg_spend AS (
    SELECT customer_id, AVG(total_amount) AS avg_order_value
    FROM Orders
    GROUP BY customer_id
)
SELECT c.name, avg_order_value
FROM avg_spend a
JOIN Customers c ON a.customer_id = c.customer_id;
