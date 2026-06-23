--Adcanced Analytics
--Change Over Time
--Analyse sales performance over time
select Orderyear as order_year,
sum(sales) total_sales,
count(customerID) total_customers
from sales.orders_combined
where OrderYear IS NOT NULL
group by OrderYear
order by order_Year

--cummulative analysys
--Calculate the total sales per month and the running total of sales over time
SELECT *,
SUM(total_sales)OVER(partition by Year(order_date) order by order_date) as running_total 
FROM
( 
SELECT DATETRUNC(MONTH,orderdate) ORDER_DATE,
SUM(sales) total_sales
FROM sales.orders_combined
where ORDERDATE IS NOT NULL
GROUP BY DATETRUNC(MONTH,orderdate)
) t
--performance Analysys
/* Analyse the yearly performance of products by comparing their sales
to both the average sales performance of the product and the previos years sales*/
WITH yearly_sales_product AS(
select OrderYear ,product,sum(sales)as current_sales from sales.orders_combined o 
left join sales.Products p
on o.productID=p.productID
where OrderYear is not null
group by OrderYear,product
)
select *,avg(current_sales)over(partition by product)as average,
current_sales-avg(current_sales)over(partition by product) as diff_avg,
case when current_sales-avg(current_sales)over(partition by product)>0 then 'above average'
     when current_sales-avg(current_sales)over(partition by product)<0 then 'below average'
     else 'average'
     end avg_change,
     ---YOY ANALYSIS
LAG(current_sales)over(partition by product order by orderyear) py_sales,
current_sales-LAG(current_sales)over(partition by product order by orderyear)  as diff_py,
case when current_sales-LAG(current_sales)over(partition by product order by orderyear) >0 then 'Increase'
     when current_sales-LAG(current_sales)over(partition by product order by orderyear) <0 then 'Decrease'
     Else 'No change'
 END  py_change
from yearly_sales_product
order by product,orderyear

--Data Segmentation
--Segment product into each ranges and count how many products fall into each segment
with product_segment as(
select 
productID,
product,
price,
case when price<10 then 'Below 10'
     when price between 10 and 15 then '10-15'
     when price between 15 and 25 then '15-25'
     else 'above 25'
     end as cost_range
from sales.Products
)
select cost_range,count(productID) as total_products from product_segment
group by cost_range
order by total_products desc

