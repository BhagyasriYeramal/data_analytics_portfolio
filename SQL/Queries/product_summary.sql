/*
=========================================================================================================================
PRODUCT REPORT
=========================================================================================================================
Purpose:
     - This report Summaries important Product information in one place.
Highlights:
     1.Get basic Product details like name and age.
     2.Groups products as High,Mid or Low performance based on revenue.
     3.Calculates totals for each product:
         -number of orders
         -total sales
         -total quantity sold
         -number of customers(Unique)
         -active selling period (in months)
    4.Calculates valuable KPI's:
          -recency (months since last order)
          -average order revenue(AOR)
          -average monthly revenue
============================================================================================================================
*/
CREATE VIEW sales.product_summary AS
WITH base_query AS(
/*
--------------------------------------------------
1. Base Query: Retrieves core columns from tables.
--------------------------------------------------
*/
SELECT 
o.orderID,
o.customerID,
o.orderdate,
o.sales,
o.quantity,
p.productID,
p.product,
p.category,
p.price
FROM sales.orders_combined o
LEFT JOIN sales.Products p
ON o.productID=p.productID
WHERE o.orderdate IS NOT NULL
)
,product_aggregation AS(
/*
----------------------------------------------------------------------
2.Product level metrics
-----------------------------------------------------------------------
*/
select 
productID,
product,
category,
Price,
DATEDIFF(MONTH,MIN(orderdate),MAX(orderdate)) AS life_span,
MAX(orderdate) AS last_sale_date,
COUNT( orderID) AS total_orders,
COUNT(DISTINCT customerID) AS total_customers,
SUM(sales) AS total_sales,
SUM(quantity) AS total_quantity,
ROUND(AVG(CAST(sales AS FLOAT)/NULLIF(quantity,0)),1) AS avg_selling_price
from base_query
GROUP BY productID,
         product,
         category,
         price
         )
SELECT 
         ProductID,
         product,
         category,
         price,
         last_sale_date,
         DATEDIFF(MONTH,last_sale_date,GETDATE()) AS recency,
CASE WHEN total_sales>200 THEN 'High-Performer'
     WHEN total_sales>150 THEN 'MID-Range'
ELSE 'Low-Performer'
END as product_segment,
life_span,
total_orders,
total_sales,
total_quantity,
total_customers,
avg_selling_price,

--  average order revenue(AOR)
CASE WHEN total_orders=0 THEN 0
ELSE total_sales/total_orders 
END AS avg_order_revenue,
--average monthly revenue
CASE WHEN life_span=0 THEN 0
ELSE total_sales/life_span 
END AS avg_monthly_revenue
FROM product_aggregation