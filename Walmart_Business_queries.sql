USE walmart_db;
SELECT COUNT(*) FROM walmart; 
SELECT 
	DISTINCT payment_method,
    COUNT(*)
FROM walmart 
GROUP BY payment_method
ORDER BY 2 DESC;

ALTER TABLE walmart RENAME COLUMN Branch TO branch;
ALTER TABLE walmart RENAME COLUMN City TO city;

SELECT 
	COUNT(distinct branch) 
FROM walmart; 

SELECT MIN(quantity) from walmart;

-- Buisness Problems
-- Find different payment method and number of transactions, number of qty sold.
SELECT 
	DISTINCT(payment_method),
    count(*),
    SUM(quantity)
from walmart
GROUP BY 1
;    

-- Identify the highest rated category in each branch, displaying the branch ,category & avg rating.alter
SELECT * FROM
(SELECT 
	branch,
    category,
    AVG(rating) as avg_rating,
    RANK() OVER(PARTITION BY branch ORDER BY AVG(rating) desc) as ranking
FROM walmart
group by 1,2)
AS ranked_data
WHERE ranking =1;

-- Identify the busiest day for each branch based on the number of transactions.
SELECT * from (
SELECT 
	branch,
    DATE_FORMAT(STR_TO_DATE(date, '%d/%m/%Y'), '%W') AS formatted_date,
    COUNT(*) as no_of_transaction,
    RANK() OVER (PARTITION BY branch ORDER BY COUNT(*) DESC ) as ranked
FROM walmart
GROUP BY 1,2)
AS T1
WHERE ranked = 1;

-- Calculate the total quantity of item sold per payment method. List the payment_method and total quantity.alter

SELECT 
	DISTINCT(payment_method),
    SUM(quantity)
from walmart
GROUP BY 1
;   

-- Determine the avgerage , min , max rating of category of each city 
-- list the city, average_rating , min rating and max rating.

SELECT
	city,
	category,
	avg(rating),
	min(rating),
    max(rating)
FROM walmart    
GROUP BY 1,2;

-- Calculate the total profit for each category by considering total_profit as (unit price*quantity*profit margin)
-- LIst category and total_profit , ordered from highest to lowest profits
SELECT 
	category,
	ROUND(SUM(total*profit_margin),2)
FROM walmart
GROUP BY 1
ORDER BY 2 DESC;

-- Determine the most common payment method of each branch.
-- Display Branch and the preferred_payment_method
WITH CTE 
AS(
SELECT 
	branch,
    COUNT(*) AS total_trans,
    payment_method,
    RANK()over(partition by branch order by COUNT(*) DESC) as ranking
FROM
walmart
GROUP BY 1,3)
SELECT * FROM cte
where ranking = 1;

-- Categorize sales into 3 groups MORNING, AFTERNOON, EVENING
-- find out each of the shift and number of invoices
SELECT 
	CASE
		WHEN time BETWEEN '06:00:00' AND '11:59:59' THEN 'MORNING'
        WHEN time BETWEEN '12:00:00' AND '17:59:59' THEN 'AFTERNOON'
        ELSE 'EVENING'
    END AS shift,
    COUNT(invoice_id) AS total_invoices
FROM walmart
GROUP BY shift
ORDER BY total_invoices DESC;

-- Identify 5 branch with highest decrease ratio in revenue compare to last year (current year 2023 and last year 2022)
 SELECT *,
	    DATE_FORMAT(STR_TO_DATE(date, '%d/%m/%Y'), '%Y') AS formatted_date
FROM walmart;

-- 2022 Sales
WITH revenue_2022
AS(
 SELECT 
	branch,
    SUM(total) as revenue
FROM walmart
WHERE DATE_FORMAT(STR_TO_DATE(date, '%d/%m/%Y'), '%Y') =2022
GROUP BY 1),

revenue_2023
AS(
 SELECT 
	branch,
    SUM(total) as revenue
FROM walmart
WHERE DATE_FORMAT(STR_TO_DATE(date, '%d/%m/%Y'), '%Y') =2023
GROUP BY 1)

SELECT 
	REV22.branch,
	REV22.revenue as last_year_revenue,
    REV23.revenue as current_year_revenue,
    ROUND(REV22.revenue-REV23.revenue/REV22.revenue * 100,2) as revenue ratio
FROM revenue_2022 as REV22
join
revenue_2023 as REV23
ON REV22.branch = REV23.branch
WHERE REV22.revenue > REV23.revenue
ORDER BY 4 desc
limit 5;


