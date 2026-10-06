-- Check for duplicates and how many duplicates are there in the table
SELECT transactionid, COUNT(*) 
FROM sales_transaction 
GROUP BY transactionid  
HAVING COUNT(*) > 1;

-- Removing duplicates by creating a new table with unique values
CREATE TABLE sales_unique AS (SELECT DISTINCT * FROM sales_transaction);

DROP TABLE sales_transaction;

RENAME TABLE sales_unique TO sales_transaction;

SELECT * FROM sales_transaction;

--Alternative way
--Creating a unique surrogate key
ALTER TABLE sales_transaction ADD COLUMN temp_id INT AUTO_INCREMENT UNIQUE FIRST;

--Delete duplicate columns
DELETE FROM sales_transaction
WHERE temp_id IN (
    SELECT temp_id FROM (
        SELECT temp_id,
               ROW_NUMBER() OVER (PARTITION BY transactionid ORDER BY temp_id) AS rn
        FROM sales_transaction
    ) t
    WHERE rn > 1
);
--Remove the column
ALTER TABLE sales_transaction DROP COLUMN temp_id;

---------------------------------------------------------------end------------------------------------------------

-- Identified some discrepancies in the price of the same product in "sales_transaction" and "product_inventory" tables
SELECT Transactionid, s.price AS TransactionPrice, p.price AS InventoryPrice 
FROM sales_transaction s 
JOIN product_inventory p ON s.productid = p.productid AND s.price <> p.price;

-- Cleaned the data by setting same price for both tables
UPDATE sales_transaction s  
JOIN product_inventory p ON s.productid = p.productid AND s.price <> p.price
SET s.price = p.price 
WHERE s.productid = p.productid AND s.price <> p.price;

SELECT * FROM sales_transaction;

------------------------------------------------------------end------------------------------------------------

-- Identified null values in customer_profiles table
SELECT COUNT(*) 
FROM customer_profiles
WHERE location IS NULL;

-- Replaced those null values with 'Unknown'
SELECT CustomerID, Age, Gender, IFNULL(location, 'Unknown') AS Location, JoinDate 
FROM customer_profiles;

------------------------------------------------------------end------------------------------------------------

-- Format the date column of sale_transaction table to apply datetime functions on it and analyze more
CREATE TABLE sales_duplicate AS
(SELECT s.*, STR_TO_DATE(s.transactiondate, '%Y-%m-%d') AS TransactionDate_updated 
 FROM sales_transaction s);

DROP TABLE sales_transaction;

RENAME TABLE sales_duplicate TO sales_transaction;

SELECT * FROM sales_transaction;

------------------------------------------------------------end------------------------------------------------

-- Created a summarized table of sales_transactions to calculate total quantity and total price
SELECT ProductID, SUM(quantityPurchased) AS TotalUnitsSold, SUM(quantityPurchased * price) AS TotalSales 
FROM sales_transaction
GROUP BY ProductID
ORDER BY TotalSales DESC;

------------------------------------------------------------end------------------------------------------------

-- Analyze the number of transactions per customer to understand purchase frequency
SELECT CustomerID, COUNT(Transactionid) AS NumberOfTransactions 
FROM sales_transaction
GROUP BY CustomerID 
ORDER BY NumberOfTransactions DESC;

------------------------------------------------------------end------------------------------------------------

-- Identifying the performance of the product categories based on total sales
SELECT Category, SUM(quantitypurchased) AS TotalUnitsSold, SUM(quantitypurchased * s.price) AS TotalSales 
FROM sales_transaction s 
JOIN product_inventory p ON s.productid = p.productid
GROUP BY Category
ORDER BY TotalSales DESC;

------------------------------------------------------------end------------------------------------------------

-- Calculating top 10 products with highest total sales revenue
SELECT ProductID, SUM(quantitypurchased * price) AS TotalRevenue 
FROM sales_transaction
GROUP BY ProductID
ORDER BY TotalRevenue DESC 
LIMIT 10;

-- Figuring out the least sold products to help company in decision making
SELECT ProductID, SUM(quantitypurchased) AS TotalUnitsSold 
FROM sales_transaction 
GROUP BY ProductID
HAVING SUM(quantitypurchased) > 0
ORDER BY TotalUnitsSold 
LIMIT 10;

------------------------------------------------------------end------------------------------------------------

-- Identifying the sales trend to understand the revenue pattern of the company
SELECT TransactionDate_updated AS DATETRANS, COUNT(transactionid) AS Transaction_count,
       SUM(quantitypurchased) AS TotalUnitsSold, ROUND(SUM(quantitypurchased * price), 2) AS TotalSales 
FROM sales_transaction
GROUP BY DATETRANS
ORDER BY DATETRANS DESC;

------------------------------------------------------------end------------------------------------------------

-- Identifying the month-on-month growth rate of sales
WITH cte AS (
    SELECT MONTH(TransactionDate_updated) AS month, 
           ROUND(SUM(quantitypurchased * price), 2) AS total_sales 
    FROM sales_transaction
    GROUP BY MONTH(TransactionDate_updated)
)
SELECT month, total_sales, 
       LAG(total_sales) OVER(ORDER BY month) AS previous_month_sales,
       ROUND(((total_sales - LAG(total_sales) OVER(ORDER BY month)) / LAG(total_sales) OVER(ORDER BY month)) * 100, 2) AS mom_growth_percentage
FROM cte
ORDER BY month;

------------------------------------------------------------end------------------------------------------------

-- Calculating high frequency purchase customers
SELECT CustomerID, COUNT(transactionid) AS NumberOfTransactions, SUM(quantitypurchased * price) AS TotalSpent 
FROM sales_transaction
GROUP BY CustomerID
HAVING NumberOfTransactions > 10 AND TotalSpent > 1000
ORDER BY TotalSpent DESC;

------------------------------------------------------------end------------------------------------------------

-- Calculating occasional/low purchase frequency customers
SELECT CustomerID, COUNT(transactionid) AS NumberOfTransactions, SUM(quantitypurchased * price) AS TotalSpent 
FROM sales_transaction
GROUP BY CustomerID
HAVING NumberOfTransactions <= 2
ORDER BY NumberOfTransactions, TotalSpent DESC;

------------------------------------------------------------end------------------------------------------------

-- Total number of purchases made by each customer against each productID (repeat customers)
SELECT CustomerID, ProductID, COUNT(*) AS TimesPurchased 
FROM sales_transaction
GROUP BY CustomerID, ProductID
HAVING COUNT(*) > 1
ORDER BY TimesPurchased DESC;

------------------------------------------------------------end------------------------------------------------

-- Duration between the first and last purchase of each customer
SELECT CustomerID, MIN(TransactionDate_updated) AS FirstPurchase, MAX(TransactionDate_updated) AS LastPurchase,
       DATEDIFF(MAX(TransactionDate_updated), MIN(TransactionDate_updated)) AS DaysBetweenPurchases 
FROM sales_transaction
GROUP BY CustomerID
HAVING DaysBetweenPurchases > 0
ORDER BY DaysBetweenPurchases DESC;

------------------------------------------------------------end------------------------------------------------

-- Customer segmentation based on total quantity purchased
WITH cte AS (
    SELECT CustomerID,
           CASE 
               WHEN SUM(quantityPurchased) > 30 THEN 'High'
               WHEN SUM(quantityPurchased) BETWEEN 11 AND 30 THEN 'Med'
               WHEN SUM(quantityPurchased) BETWEEN 1 AND 10 THEN 'Low' 
           END AS category
    FROM sales_transaction
    GROUP BY CustomerID
)
SELECT category AS CustomerSegment, COUNT(*) AS CustomerCount 
FROM cte 
GROUP BY category;