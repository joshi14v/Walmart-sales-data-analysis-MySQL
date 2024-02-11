
-- Create table
CREATE TABLE IF NOT EXISTS walmartSales.sales(
	invoice_id VARCHAR(30) NOT NULL PRIMARY KEY,
    branch VARCHAR(5) NOT NULL,
    city VARCHAR(30) NOT NULL,
    customer_type VARCHAR(30) NOT NULL,
    gender VARCHAR(30) NOT NULL,
    product_line VARCHAR(100) NOT NULL,
    unit_price DECIMAL(10,2) NOT NULL,
    quantity INT NOT NULL,
    tax_pct FLOAT(6,4) NOT NULL,
    total DECIMAL(12, 4) NOT NULL,
    date DATETIME NOT NULL,
    time TIME NOT NULL,
    payment VARCHAR(15) NOT NULL,
    cogs DECIMAL(10,2) NOT NULL,
    gross_margin_pct FLOAT(11,9),
    gross_income DECIMAL(12, 4),
    rating FLOAT(2, 1)
);



-- ------------------------------------------Feature engineering--------------------------------------------------------

-- Adding Time of the day - Morning, Afternoon and Evening feature in the dataset 

ALTER TABLE sales ADD COLUMN time_of_date VARCHAR(10);

UPDATE sales 
SET time_of_date = (
CASE
	WHEN time BETWEEN '00:00:00' AND '12:00:00' THEN 'morning'
    WHEN time BETWEEN '12:00:01' AND '16:00:00' THEN 'afternoon'
    ELSE 'evening'
END
);

-- Adding day name 
ALTER TABLE sales ADD COLUMN day_name VARCHAR(15);

UPDATE sales 
SET day_name = DAYNAME(date);

-- Adding Month name
ALTER TABLE sales ADD COLUMN month_name VARCHAR(15);

UPDATE sales 
SET month_name = MONTHNAME(date);

-- --------------------------- Exploratory Data Analysis -----------------------------------
-- Generic Question
-- Q1 How many unique cities does the data have?
SELECT count(DISTINCT city) AS total_city
FROM sales;
-- 3 unique city

-- Q2 In which city is each branch?
SELECT DISTINCT branch, city
FROM sales;

-- Product
-- Q1 How many unique product lines does the data have?
SELECT DISTINCT product_line 
FROM sales;  -- To find the names

SELECT count(DISTINCT product_line) AS total_product_line 
FROM sales; -- To find numbers

-- Q2 What is the most common payment method?
SELECT payment, count(payment)
FROM sales
GROUP BY payment; 

-- Q3 What is the most selling product line?
SELECT product_line, count(product_line) 
FROM sales
GROUP BY product_line
ORDER BY  count(product_line) DESC;

-- Q4 What is the total revenue by month?
SELECT month_name, sum(total)
FROM sales
GROUP BY month_name;

-- Q5 What month had the largest COGS?
SELECT month_name, sum(cogs) AS total_cogs
FROM sales
GROUP BY month_name
ORDER BY total_cogs DESC
LIMIT 1;

-- Q6 What product line had the largest revenue?
SELECT product_line, sum(total) AS revenue
FROM sales
GROUP BY product_line
ORDER BY revenue DESC
LIMIT 1;

-- Q7 What is the city with the largest revenue?
SELECT city, sum(total) AS revenue
FROM sales
GROUP BY city
ORDER BY revenue DESC
LIMIT 1;

-- Q8 What product line had the largest VAT?
-- VAT means amount of tax on purchase
SELECT product_line, sum(tax_pct) AS VAT
FROM sales
GROUP BY product_line
ORDER BY VAT DESC
LIMIT 1;

-- Q9 Fetch each product line and add a column to those product line showing "Good", "Bad". Good if its greater than average sales
WITH ProductSales AS(
    SELECT 
        product_line, 
        COUNT(invoice_id) AS total_sales
    FROM 
        sales
    GROUP BY 
        product_line
), AverageSales AS (
    SELECT 
        AVG(total_sales) AS avg_sales
    FROM 
        ProductSales
)

SELECT 
    ps.product_line, 
    ps.total_sales,
    CASE 
        WHEN ps.total_sales > (SELECT avg_sales FROM AverageSales) THEN 'Good'
        ELSE 'Bad'
    END AS Sale_Status
FROM 
    ProductSales ps;
-- Q10 Which branch sold more products than average product sold?
Select branch, sum(quantity) as qnt
from sales
group by branch
having sum(quantity) > (select avg(quantity) from sales);

-- Q11 What is the most common product line by gender?
Select product_line, gender, sum(quantity) as qnt
from sales
group by product_line, gender
order by qnt desc;

-- Q12 What is the average rating of each product line?
select product_line, avg(rating) as avg_rate
from sales
group by product_line;

-- Sales
-- Q1 Number of sales made in each time of the day per weekday
select day_name, time_of_date, count(*) as total_sale
from sales
group by time_of_date, day_name
order by day_name, time_of_date, total_sale;

-- Q2 Which of the customer types brings the most revenue?
select customer_type, sum(total) as revenue
from sales
group by customer_type
order by revenue desc;

-- Q3 Which city has the largest tax percent/ VAT (Value Added Tax)?
select city, avg(tax_pct) as avg_tax
from sales
group by city
order by avg_tax desc
limit 1;

-- Customer

-- Q5 How many unique customer types does the data have?
Select count(DISTINCT customer_type) as uniq_cus
from sales;

-- Q6 How many unique payment methods does the data have?
select COUNT(DISTINCT payment) as payment_type
from sales;

-- Q7 What is the most common customer type?
select count(*) as count, customer_type
from sales
group by customer_type
order by count desc
limit 1;
-- Q8 Which customer type buys the most?
select sum(quantity) as total_purchase, customer_type
from sales
group by customer_type
order by total_purchase desc
limit 1;
-- Q9 What is the gender of most of the customers?
select count(*), gender
from sales
group by gender;

-- Q10 What is the gender distribution per branch?
SELECT gender, branch, count(*) as count
from sales
group by gender, branch;

-- Q11 Which time of the day do customers give most ratings?
SELECT time_of_date , avg(rating) as avg_rate
FROM sales
GROUP BY time_of_date
order by avg_rate desc;

-- Q12 Which time of the day do customers give most ratings per branch?
SELECT time_of_date, branch, avg(rating) as avg_rate
FROM sales
GROUP BY time_of_date, branch
order by avg_rate desc;

-- Q13 Which day of the week has the best avg ratings?
SELECT day_name, avg(rating) as avg_rate
FROM sales
GROUP BY day_name
order by avg_rate desc;

-- Q14 Which day of the week has the best average ratings per branch?
SELECT day_name, branch, avg(rating) as avg_rate
FROM sales
GROUP BY day_name, branch
order by avg_rate desc;