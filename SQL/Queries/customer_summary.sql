/*
=========================================================================================================================
CUSTOMER REPORT
=========================================================================================================================
Purpose:
     - This report Summaries important customer information in one place.
Highlights:
     1.Get basic customer details like name and age.
     2.Groups customers as VIP,Regular,New based on their purchases. 
     3.Aggregate customer-level metrics:
         -number of orders
         -total sales
         -total quantity bought
         -number of products purchased
         -how long they have been a customer (in months)
    4.Calculates valuable KPI's:
          -recency (months since last order)
          -average order value
          -average monthly spend
============================================================================================================================
*/
CREATE VIEW Sales.Customer_summary AS
WITH base_query AS(
/*
--------------------------------------------------
1. Base Query: Retrieves core columns from tables.
--------------------------------------------------
*/
SELECT 
o.orderID,
o.productID,
o.orderdate,
o.sales,
o.quantity,
o.customerID,
CONCAT(c.firstname,' ',c.lastname) AS customer_name
FROM sales.orders_combined o 
LEFT JOIN sales.customers c 
ON c.customerID=o.customerID
WHERE o.orderdate IS NOT NULL
)
,customer_aggregation AS(
/*
----------------------------------------------------------------------
2.Customer level metrics
-----------------------------------------------------------------------
*/
select 
customerID,
customer_name,
COUNT(orderID) AS total_orders,
SUM(sales) AS total_sales,
SUM(quantity) AS total_quantity,
COUNT(DISTINCT productID) AS total_products,
MAX(orderdate) AS last_order_date,
DATEDIFF(MONTH,MIN(orderdate),MAX(orderdate)) AS life_span
from base_query
GROUP BY customerID,
         customer_name
         )
SELECT 
CustomerID,
customer_name,
case when total_sales>100 and life_span>=5 then 'VIP'
     when total_sales<100 and life_span>=5 then 'Regular'
     else 'new'
     end as groups,
last_order_date,
DATEDIFF(MONTH,last_order_date,GETDATE()) AS recency,
total_orders,
total_sales,
total_quantity,
total_products,
life_span,
-- compute average order value(AVO)
CASE WHEN total_orders=0 THEN 0
ELSE total_sales/total_orders 
END AS avg_order_value,
--Compute average monthly spend
CASE WHEN life_span=0 THEN 0
ELSE total_sales/life_span 
END AS avg_monthly_spend
FROM customer_aggregation

