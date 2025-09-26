--BEGINNER

--1.List the top 10 orders with the highest sales from the EachOrderBreakdown table.
select * from eachorderbreakdown
order by sales desc
limit 10

--2.Show the number of orders for each product category in the EachOrderBreakdown table.

select category, count(*) as num_orders
from eachorderbreakdown
group by category


--3.Find the total profit for each sub-category in the EachOrderBreakdown table.

select SubCategory, sum(Profit) as total_profit
from eachorderbreakdown
group by SubCategory



--Intermediate


--1.Identify the customer with the highest total sales across all orders.
select *from orderlist;
select *from eachorderbreakdown;
select CustomerName,sum(Sales) as total_sales
from orderlist ol
join eachorderbreakdown ob
on ol.OrderID=ob.orderid
group by CustomerName
order by total_sales desc;


--2.Find the month with the highest average sales in the OrdersList table.

SELECT Top 1 Month(OrderDate) As month, AVG(Sales) as AverageSales 
FROM OrdersList ol
JOIN eachorderbreakdown ob
ON ol.OrderID = ob.orderid
GROUP BY Month(OrderDate)
Order By AverageSales DESC

--3.Find out the average quantity ordered by customers whose first name starts with an alphabet 's'?
SELECT AVG(Quantity) as AverageQuantity 
FROM OrdersList ol
JOIN EachOrderBreakdown ob
ON ol.OrderID = ob.OrderID
Where LEFT(CustomerName,1) = 'S'


--Advanced

--1.Find out how many new customers were acquired in the year 2014?
SELECT COUNT(*) As NumberOfNewCustomers FROM (
SELECT CustomerName, MIN(OrderDate) AS FirstOrderDate
from orderlist
GROUP BY CustomerName
Having YEAR(MIN(OrderDate)) = '2014') AS CustWithFirstOrder2014


--2.Calculate the percentage of total profit contributed by each sub-category to the overall profit.


Select SubCategory, SUM(Profit) As SubCategoryProfit,
SUM(Profit)/(Select SUM(Profit) FROM eachorderbreakdown) * 100 AS PercentageOfTotalContribution
FROM eachorderbreakdown
Group By SubCategory


--3.Find the average sales per customer, considering only customers who have made more than one order.

WITH CustomerAvgSales AS(
SELECT CustomerName, COUNT(DISTINCT ol.OrderID) As NumberOfOrders, AVG(Sales) AS AvgSales
FROM OrdersList ol
JOIN EachOrderBreakdown ob
ON ol.OrderID = ob.OrderID 
GROUP BY CustomerName
)
SELECT CustomerName, AvgSales
FROM CustomerAvgSales
WHERE NumberOfOrders > 12



--4.Identify the top-performing subcategory in each category based on total sales. Include the sub-category name, total sales, and a ranking of sub-category within each category.
WITH topsubcategory AS(
SELECT Category, SubCategory, SUM(sales) as TotalSales,
RANK() OVER(PARTITION BY Category ORDER BY SUM(sales) DESC) AS SubcategoryRank
FROM EachOrderBreakdown
Group By Category, SubCategory
)
SELECT *
FROM topsubcategory
WHERE SubcategoryRank = 1
