RETAIL ANALYTICS CASE STUDY
PROBLEM STATEMENT
A retail company wants to use data analytics to solve three main problems:
understanding which products sell best or worst, grouping customers for
targeted marketing (customer segmentation), and analyzing customer behavior
to improve loyalty and sales.
They analyze data from three tables: sales transactions, customer profiles, and
product inventory.
KEY CONCEPTS & ANALYTICAL OBJECTIVES
• Product Sales Analysis: Identify top-selling and underperforming products to
guide inventory stock decisions and marketing campaigns.
• Customer Segmentation: Categorize customers into distinct tiers based on
purchase volume and total spend for targeted promotions.
• Customer Loyalty & Behavior: Analyze purchase frequency, repeat orders, and
lifespan (duration between first and last purchase) to build long-term retention
strategies.
TECHNICAL CONCEPTS & SQL SKILLS APPLIED
1.
Data Cleaning & Transformation: • DISTINCT - Eliminating duplicate
records • IFNULL() - Handling missing/null values • UPDATE ... JOIN -
Reconciling price discrepancies across tables • STR_
TO
_DATE() -
Converting text fields into standard date formats
2.
Aggregations & Grouping: • SUM() & COUNT() - Calculating totals,
volumes, and order frequencies • ROUND() - Formatting financial
values and metrics • GROUP BY - Categorizing metrics by product,
customer, or month • HAVING - Filtering aggregated groups (e.g.,
HAVING COUNT(*) > 1) • ORDER BY & LIMIT- Ranking top/bottom
items and retrieving top N results
3.
Advanced SQL & Window Functions: • Common Table Expressions
(CTEs) : WITH cte AS (...) • Window Functions : LAG() OVER(ORDER
BY month) for MoM growth • Conditional Logic : CASE WHEN ...
THEN ... END for segmentation
4.
Relational Operations & Date Analytics: • INNER JOIN - Combining
transaction and inventory data • Date Extraction & Calculations -
MONTH(), DATEDIFF(MAX(date), MIN(date))
