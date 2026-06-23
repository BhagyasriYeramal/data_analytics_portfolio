DROP TABLE IF EXISTS sales.orders_combined
SELECT *,'2025' AS OrderYear INTO Sales.orders_combined FROM Sales.Orders
UNION ALL
Select *,'2024'As OrderYear FROM Sales.OrdersArchive

--Make both columns not null
ALTER TABLE sales.orders_combined
ALTER COLUMN OrderID INT NOT NULL
ALTER TABLE sales.orders_combined
ALTER COLUMN OrderYear VARCHAR(10) NOT NULL
--Remove duplicates keeping one row
WITH CTE_Duplicates AS(
SELECT *,
ROW_NUMBER()OVER(PARTITION BY OrderID,OrderYear ORDER BY OrderID) AS RowNum
FROM sales.orders_Combined
)
DELETE FROM CTE_Duplicates WHERE RowNum>1
--Add composite primary key
ALTER TABLE sales.orders_combined
ADD CONSTRAINT pk_Orders_Combined
PRIMARY KEY (OrderID,OrderYear)

select * from sales.orders_combined
