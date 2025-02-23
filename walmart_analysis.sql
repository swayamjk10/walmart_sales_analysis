-- Walmart Project Queries

SELECT * 
FROM `utility-axis-344306.walmart_analysis.invoices` 
LIMIT 5;


-- Total no of transactions
SELECT COUNT(*) AS Total_no_of_records
FROM `utility-axis-344306.walmart_analysis.invoices`;

-- distribution of product categories
SELECT COUNT(DISTINCT(category)) AS Category
FROM `utility-axis-344306.walmart_analysis.invoices`;

SELECT DISTINCT(category) AS Category
FROM `utility-axis-344306.walmart_analysis.invoices`;

-- top 5 most frequently purchased categories
SELECT category, COUNT(*) AS purchase_count
FROM `utility-axis-344306.walmart_analysis.invoices`
GROUP BY category
ORDER BY purchase_count DESC
LIMIT 5;

-- no of unique branches
SELECT DISTINCT(branch) as Branch_names
FROM `utility-axis-344306.walmart_analysis.invoices`;

-- revenue and profit by branches
SELECT branch, ROUND(SUM(unit_price * quantity),1) as revenue, ROUND(SUM(profit_margin),1) as profit
FROM `utility-axis-344306.walmart_analysis.invoices`
GROUP BY branch
ORDER BY revenue DESC
LIMIT 10;


-- Business Problems
--Q.1 Find different payment method and number of transactions, number of qty sold
SELECT payment_method,COUNT(*) as no_payments,SUM(quantity) as no_qty_sold
FROM `utility-axis-344306.walmart_analysis.invoices`
GROUP BY payment_method;

-- Q.2 Identify the highest-rated category in each branch, displaying the branch, category
-- AVG RATING
SELECT * 
FROM
(	SELECT 
		branch,
		category,
		AVG(rating) as avg_rating,
		RANK() OVER(PARTITION BY branch ORDER BY AVG(rating) DESC) as rank
	FROM `utility-axis-344306.walmart_analysis.invoices`
	GROUP BY 1, 2
)
WHERE rank = 1;

-- Q.3 Which branch has the highest number of transactions?
SELECT branch,COUNT(*) AS No_of_transactions
FROM `utility-axis-344306.walmart_analysis.invoices`
GROUP BY branch
ORDER BY No_of_transactions DESC
LIMIT 5;

-- Q. 4 Calculate the total quantity of items sold per payment method. List payment_method and total_quantity.
SELECT 
	 payment_method,
	 -- COUNT(*) as no_payments,
	 SUM(quantity) as no_qty_sold
FROM `utility-axis-344306.walmart_analysis.invoices`
GROUP BY payment_method;

-- Q.5
-- Determine the average, minimum, and maximum rating of category for each city. 
-- List the city, average_rating, min_rating, and max_rating.

SELECT 
	city,
	category,
	MIN(rating) as min_rating,
	MAX(rating) as max_rating,
	ROUND(AVG(rating),1) as avg_rating
FROM `utility-axis-344306.walmart_analysis.invoices`
GROUP BY 1, 2
ORDER BY avg_rating DESC;

-- Q.6
-- Calculate the total profit for each category by considering total_profit as
-- (unit_price * quantity * profit_margin). 
-- List category and total_profit, ordered from highest to lowest profit.
SELECT 
	category,
	ROUND(SUM(unit_price * quantity * profit_margin),1) as total_profit
FROM `utility-axis-344306.walmart_analysis.invoices`
GROUP BY 1
ORDER BY total_profit DESC;

-- Q.7
-- Determine the most common payment method for each Branch. 
-- Display Branch and the preferred_payment_method.

WITH cte 
AS
(SELECT 
	branch,
	payment_method,
	COUNT(*) as total_trans,
	RANK() OVER(PARTITION BY branch ORDER BY COUNT(*) DESC) as rank
FROM `utility-axis-344306.walmart_analysis.invoices`
GROUP BY 1, 2
)
SELECT *
FROM cte
WHERE rank = 1;

-- Q.8
-- Categorize sales into 3 group MORNING, AFTERNOON, EVENING 
-- Find out each of the shift and number of invoices

SELECT
    branch,
    CASE 
        WHEN EXTRACT(HOUR FROM CAST(time AS TIME)) < 12 THEN 'Morning'
        WHEN EXTRACT(HOUR FROM CAST(time AS TIME)) BETWEEN 12 AND 17 THEN 'Afternoon'
        ELSE 'Evening'
    END AS day_time,
    COUNT(*) AS transaction_count
FROM `utility-axis-344306.walmart_analysis.invoices`
GROUP BY branch, day_time
ORDER BY branch, transaction_count DESC;

-- Most Transactions by Daytime per Branch
WITH Transactions_Per_Daytime AS (
    SELECT
        branch,
        CASE 
            WHEN EXTRACT(HOUR FROM CAST(time AS TIME)) < 12 THEN 'Morning'
            WHEN EXTRACT(HOUR FROM CAST(time AS TIME)) BETWEEN 12 AND 17 THEN 'Afternoon'
            ELSE 'Evening'
        END AS day_time,
        COUNT(*) AS transaction_count
    FROM `utility-axis-344306.walmart_analysis.invoices`
    GROUP BY branch, day_time
)

SELECT *
FROM (
    SELECT *,
           RANK() OVER (PARTITION BY day_time ORDER BY transaction_count DESC) AS rank
    FROM Transactions_Per_Daytime
) 
WHERE rank = 1;

-- Product Category with the Highest Profit Margin
SELECT 
    category, 
    ROUND(AVG(profit_margin * 100),2) AS avg_profit_margin
FROM `utility-axis-344306.walmart_analysis.invoices`
GROUP BY category
ORDER BY avg_profit_margin DESC;









