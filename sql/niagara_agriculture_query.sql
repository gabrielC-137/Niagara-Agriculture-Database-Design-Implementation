USE niagara_agriculture;

-- Query 1: Employee turnover 
WITH EmployeeTenure AS (
    SELECT 
        employee_id, 
        DATEDIFF(CURDATE(), hire_date) AS Days_Employed
    FROM niagara_agriculture.Employee
)
SELECT 
    e.employee_id,
    e.first_name,
    e.last_name,
    e.position,
    e.hourly_salary,
    s.store_name AS Store_Location,
    COUNT(o.order_id) AS Total_Sales_Associated,
    AVG(o.total_amount) AS Avg_Sales_Per_Order,
    et.Days_Employed,
    CASE 
        WHEN e.hourly_salary < 18 AND et.Days_Employed < 180 THEN 'High Risk'  -- Poco tiempo en la empresa + bajo salario
        WHEN e.hourly_salary BETWEEN 18 AND 22 AND et.Days_Employed < 365 THEN 'Medium Risk'  -- Menos de un año + salario medio
        ELSE 'Low Risk'
    END AS Turnover_Risk
FROM niagara_agriculture.Employee e
JOIN niagara_agriculture.store s ON e.store_id = s.store_id
LEFT JOIN niagara_agriculture.orders o ON s.store_id = o.store_id
LEFT JOIN EmployeeTenure et ON e.employee_id = et.employee_id
GROUP BY e.employee_id, et.Days_Employed
ORDER BY e.employee_id;

-- Query 2: Store performance for machine learning models 
WITH SalesData AS (
    SELECT 
        s.store_id,
        s.store_name AS Store_Location,
        COUNT(o.order_id) AS Total_Orders,
        SUM(o.total_amount) AS Total_Sales,
        ROUND(AVG(o.total_amount), 2) AS Avg_Sale_Value,
        ROUND(STDDEV(o.total_amount), 2) AS Sales_Std_Dev,
        MIN(o.total_amount) AS Min_Sale,
        MAX(o.total_amount) AS Max_Sale,
        COUNT(DISTINCT o.customer_id) AS Unique_Customers
    FROM niagara_agriculture.Store s
    LEFT JOIN niagara_agriculture.orders o ON s.store_id = o.store_id
    GROUP BY s.store_id
)

SELECT 
    SalesData.*,
    RANK() OVER (ORDER BY SalesData.Total_Sales DESC) AS Revenue_Rank,
    NTILE(4) OVER (ORDER BY SalesData.Total_Sales DESC) AS Quartile_Performance
FROM SalesData
ORDER BY SalesData.Total_Sales DESC;

-- Query 3: ROLLUP function 
SELECT 
    COALESCE(CONCAT(c.first_name, ' ', c.last_name), 'GRAND TOTAL') AS customer_name,
    COALESCE(p.product_name, 'CUSTOMER TOTAL') AS product_name,
    SUM(od.quantity * od.unit_price) AS total_sales
FROM niagara_agriculture.orders o
JOIN niagara_agriculture.customer c ON o.customer_id = c.customer_id
JOIN niagara_agriculture.orderdetails od ON o.order_id = od.order_id
JOIN niagara_agriculture.product p ON od.product_id = p.product_id
GROUP BY c.first_name, c.last_name, p.product_name WITH ROLLUP;

-- Query 4: Customer order value quartiles by destination country
SELECT
    subquery.total_value,
    subquery.country_name AS destination_country,
    NTILE(4) OVER(ORDER BY subquery.total_value DESC) AS quartile
FROM (
    SELECT
        c.country_name,
        SUM(od.quantity * od.unit_price) AS total_value
    FROM niagara_agriculture.orders AS o
    JOIN niagara_agriculture.stock AS st ON st.store_id = o.store_id
    JOIN niagara_agriculture.customer AS cu ON cu.customer_id = o.customer_id
    JOIN niagara_agriculture.address AS a ON a.address_id = cu.address_id
    JOIN niagara_agriculture.city AS ci ON ci.city_id = a.city_id
    JOIN niagara_agriculture.state AS s ON s.state_id = ci.state_id
    JOIN niagara_agriculture.country AS c ON c.country_id = s.country_id
    JOIN niagara_agriculture.orderdetails AS od ON od.order_id = o.order_id
    GROUP BY c.country_name
) AS subquery
ORDER BY subquery.total_value DESC;

-- Query 5: Ranking payment methods by total and international transactions
SELECT 
    payment_method,
    total_payments,
    total_amount_sold,
    international_payments,
    international_amount_sold,
    ROUND((international_payments * 100.0 / total_payments), 2) AS international_payment_percentage,
    ROUND((international_amount_sold * 100.0 / total_amount_sold), 2) AS international_amount_percentage,
    RANK() OVER (ORDER BY total_payments DESC) AS method_rank
FROM (
    SELECT
        p.payment_method,
        COUNT(p.payment_id) AS total_payments,
        SUM(p.amount) AS total_amount_sold,
        SUM(CASE WHEN o.order_type = 'International' THEN 1 ELSE 0 END) AS international_payments,
        SUM(CASE WHEN o.order_type = 'International' THEN p.amount ELSE 0 END) AS international_amount_sold
    FROM niagara_agriculture.payment AS p
    JOIN niagara_agriculture.orders AS o ON o.order_id = p.order_id
    GROUP BY p.payment_method
) AS payment_details
ORDER BY total_payments DESC;

-- Query 6: Ranking payment methods by incomplete transactions 
SELECT
    p.payment_method,
    COUNT(p.payment_id) AS total_incomplete_payments,
    SUM(p.amount) AS total_incomplete_value,
    (COUNT(p.payment_id) * 100.0 / total.total_payments) AS percentage_incomplete_payments,
    RANK() OVER (ORDER BY COUNT(p.payment_id) DESC) AS method_rank
FROM niagara_agriculture.payment AS p
JOIN niagara_agriculture.orders AS o ON o.order_id = p.order_id
JOIN niagara_agriculture.customer AS cu ON cu.customer_id = o.customer_id
JOIN niagara_agriculture.address AS a ON a.address_id = cu.address_id
JOIN niagara_agriculture.city AS ci ON ci.city_id = a.city_id
JOIN niagara_agriculture.state AS s ON s.state_id = ci.state_id
JOIN niagara_agriculture.country AS c ON c.country_id = s.country_id
JOIN (
    SELECT
        COUNT(payment_id) AS total_payments
    FROM niagara_agriculture.payment
    WHERE payment_status = 'Completed' OR payment_status != 'Completed'
) AS total
WHERE p.payment_status != 'Completed'
GROUP BY p.payment_method, total.total_payments
ORDER BY total_incomplete_payments DESC;

-- Query 7: Top 2 companies generating the highest revenue across all their stores
SELECT
	c.name AS company_name, 
	SUM(o.total_amount) AS total_revenue
FROM Orders o
JOIN Store s ON o.store_id = s.store_id
JOIN Company c ON s.company_id = c.company_id
GROUP BY c.company_id
ORDER BY total_revenue DESC
LIMIT 2;

-- Query 8: Recognizes top-performing employees based on the revenue they handle 
SELECT
    e.employee_id,
    e.first_name,
    e.last_name,
    e.hourly_salary,
    CASE
        WHEN e.hourly_salary > avg_salary.avg_hourly_salary THEN 'Yes'
        ELSE 'No'
    END AS salary_above_average,
    s.store_id,
    COUNT(o.order_id) AS orders_processed,
    SUM(o.total_amount) AS total_revenue_generated,
    DENSE_RANK() OVER (
        ORDER BY SUM(o.total_amount) DESC
    ) AS employee_rank
FROM Employee AS e
JOIN Store AS s ON e.store_id = s.store_id
JOIN Orders AS o ON s.store_id = o.store_id
CROSS JOIN (SELECT AVG(hourly_salary) AS avg_hourly_salary FROM Employee) AS avg_salary
GROUP BY e.employee_id, e.first_name, e.last_name, s.store_id, avg_salary.avg_hourly_salary
ORDER BY total_revenue_generated DESC;

-- Query 9: Understanding customer retention by checking first and last purchase dates 
SELECT
	c.customer_id,
	CONCAT(c.first_name, ' ', c.last_name) AS customer_full_name,
    MIN(o.order_date) AS first_order,
    MAX(o.order_date) AS last_order,
    COUNT(o.order_id) AS total_orders
FROM Orders AS o
JOIN Customer AS c ON o.customer_id=c.customer_id
GROUP BY customer_id
HAVING total_orders > 1
ORDer BY total_orders DESC;

-- Query 10: Segments customers into quartiles based on their spending, useful for targeted marketing strategies 
SELECT
	c.customer_id,
    c.first_name, 
    c.last_name, 
	SUM(o.total_amount) AS total_spent,
	NTILE(4) OVER (
		ORDER BY SUM(o.total_amount) DESC
        ) AS spending_quartile
FROM Customer c
JOIN Orders o ON c.customer_id = o.customer_id
GROUP BY c.customer_id
ORDER BY total_spent DESC;

-- Query 11: identify customers for re-engagement campaigns who haven’t ordered in the last 6 months 
SELECT
	c.customer_id,
    c.first_name,
    c.last_name,
    MAX(o.order_date) AS last_order_date
FROM Customer c
LEFT JOIN Orders o ON c.customer_id = o.customer_id
GROUP BY c.customer_id
HAVING last_order_date < DATE_SUB(CURDATE(), INTERVAL 6 MONTH) 
	   OR last_order_date IS NULL;

-- Query 12: Identifies the top 20% products that generate 80% of revenue, following the Pareto principle. 
CREATE VIEW TopRevenueProducts AS
    SELECT
        p.product_id,
        p.product_name, 
        SUM(oi.quantity * oi.unit_price) AS total_revenue,
        SUM(SUM(oi.quantity * oi.unit_price)) OVER () AS total_market_revenue,
        SUM(SUM(oi.quantity * oi.unit_price)) OVER (
            ORDER BY SUM(oi.quantity * oi.unit_price) DESC
        ) AS cumulative_revenue
    FROM OrderDetails AS oi
    JOIN Product AS p ON oi.product_id = p.product_id
    GROUP BY p.product_id;
    
SELECT
	product_id,
    product_name,
    total_revenue,
	ROUND((cumulative_revenue / total_market_revenue) * 100, 2) AS cumulative_percentage
FROM TopRevenueProducts
WHERE (cumulative_revenue / total_market_revenue) <= 0.8;

-- Query 13: Identifies the top 3 best-selling products in each store 
SELECT
	store_id,
    store_name,
    product_id,
    product_name,
    total_sales_quantity,
    product_rank_by_quantity
FROM (
    SELECT
		s.store_id,
        s.store_name,
        p.product_id,
        p.product_name, 
		SUM(oi.quantity) AS total_sales_quantity,
		RANK() OVER (
			PARTITION BY s.store_id
            ORDER BY SUM(oi.quantity) DESC
            ) AS product_rank_by_quantity
    FROM OrderDetails AS oi
    JOIN Product AS p ON oi.product_id = p.product_id
    JOIN Orders AS o ON oi.order_id = o.order_id
    JOIN Store AS s ON o.store_id = s.store_id
    GROUP BY s.store_id, p.product_id
) AS ranked_products
WHERE product_rank_by_quantity <= 3;

-- Query 14: Tracks revenue trends by store and calculates the growth percentage month over month 
SELECT
	s.store_id,
	s.store_name,
	DATE_FORMAT(o.order_date, '%Y-%m') AS order_month, 
	SUM(o.total_amount) AS monthly_revenue,
	LAG(SUM(o.total_amount)) OVER (
		PARTITION BY s.store_id
        ORDER BY DATE_FORMAT(order_date, '%Y-%m')
        ) AS prev_month_revenue,
	(SUM(o.total_amount) - 
    LAG(SUM(o.total_amount)) OVER (
		PARTITION BY s.store_id
        ORDER BY DATE_FORMAT(order_date, '%Y-%m')
        )) /
	NULLIF(LAG(SUM(o.total_amount)) OVER (
		PARTITION BY s.store_id
        ORDER BY DATE_FORMAT(o.order_date, '%Y-%m')
        ), 1) * 100 AS revenue_growth
FROM Orders AS o
JOIN Store AS s ON s.store_id=o.store_id
GROUP BY store_id, order_month
ORDER BY store_id, order_month;

-- Query 15: Provides a rolling average of sales over 3 months for trend analysis 
SELECT
	store_id, 
	DATE_FORMAT(order_date, '%Y') AS order_year,
	DATE_FORMAT(order_date, '%m') AS order_month,
	SUM(total_amount) AS monthly_revenue,
	AVG(SUM(total_amount)) OVER (
		PARTITION BY store_id
        ORDER BY DATE_FORMAT(order_date, '%Y'), DATE_FORMAT(order_date, '%m')
        ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
        ) AS rolling_avg_revenue
FROM Orders
GROUP BY store_id, order_year, order_month
ORDER BY store_id, order_year, order_month;

-- Query 16: Flags products that need urgent restocking based on demand and stock levels 
WITH RecentSales AS (
    SELECT
		oi.product_id, 
		SUM(oi.quantity) / 30 AS avg_daily_sales
    FROM OrderDetails AS oi
    JOIN Orders AS o
    WHERE o.order_date >= DATE_SUB(CURDATE(), INTERVAL 30 DAY)
    GROUP BY oi.product_id
)
SELECT
	p.product_id,
    p.product_name,
    st.remaining_stock, 
	COALESCE(rs.avg_daily_sales, 0) AS avg_daily_sales,
	CASE 
		WHEN COALESCE(rs.avg_daily_sales, 0) * 7 > st.remaining_stock
			THEN 'Urgent Replenishment'
		WHEN COALESCE(rs.avg_daily_sales, 0) * 14 > st.remaining_stock
			THEN 'Low Stock'
		ELSE 'Sufficient Stock'
	END AS stock_status
FROM Product AS p
LEFT JOIN Stock AS st ON p.product_id = st.product_id
LEFT JOIN RecentSales AS rs ON p.product_id = rs.product_id;

-- Query 17: Recursive Query to Retrieve Products in a Category Hierarchy 
WITH RECURSIVE CategoryHierarchy AS (
    SELECT category_id, name, parent_category_id
    FROM ProductCategory
    WHERE category_id=2
    
    UNION ALL
    
    SELECT pc.category_id, pc.name, pc.parent_category_id
    FROM ProductCategory pc
    INNER JOIN CategoryHierarchy ch
    ON pc.parent_category_id = ch.category_id
)
SELECT p.product_id, p.product_name, p.price, p.sku, p.status, p.created_at,
       c.name AS category_name
FROM Product p
INNER JOIN CategoryHierarchy ch ON p.category_id = ch.category_id
INNER JOIN ProductCategory c ON p.category_id = c.category_id
ORDER BY c.name, p.product_name;
