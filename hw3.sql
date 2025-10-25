USE AdventureWorks2019
GO 

-- 1) How many products can you find in the Production.Product table?
SELECT COUNT(*) AS ProductCount
FROM Production.Product

-- 2) Write a query that retrieves the number of products in the Production.Product table that are included in a subcategory. The rows that have NULL in column ProductSubcategoryID are considered to not be a part of any subcategory.
SELECT COUNT(*) AS ProductsWithSubcategory
FROM Production.Product
WHERE ProductSubcategoryID IS NOT NULL

-- 3) How many Products reside in each SubCategory? Write a query to display the results with the following titles: ProductSubcategoryID CountedProducts
SELECT ProductSubcategoryID, COUNT(*) AS CountedProducts
FROM Production.Product
WHERE ProductSubcategoryID IS NOT NULL
GROUP BY ProductSubcategoryID

-- 4) How many products that do not have a product subcategory.
SELECT COUNT(*)
FROM Production.Product
WHERE ProductSubcategoryID IS NULL

-- 5) Write a query to list the sum of products quantity in the Production.ProductInventory table.
SELECT SUM(Quantity)
FROM Production.ProductInventory

-- 6) Write a query to list the sum of products in the Production.ProductInventory table and LocationID set to 40 and limit the result to include just summarized quantities less than 100. 
-- ProductID TheSum
SELECT ProductID, SUM(Quantity) AS TheSum
FROM Production.ProductInventory
WHERE LocationID = 40
GROUP BY ProductID
HAVING SUM(Quantity) < 100

-- 7) Write a query to list the sum of products with the shelf information in the Production.ProductInventory table and LocationID set to 40 and limit the result to include just summarized quantities less than 100. 
-- Shelf ProductID TheSum
SELECT Shelf, ProductID, SUM(Quantity) AS TheSum
FROM Production.ProductInventory
WHERE LocationID = 40
GROUP BY Shelf, ProductID
HAVING SUM(Quantity) < 100

-- 8) Write the query to list the average quantity for products where column LocationID has the value of 10 from the table Production.ProductInventory table.
SELECT AVG(Quantity)
FROM Production.ProductInventory
WHERE LocationID = 10

-- 9) Write query to see the average quantity of products by shelf from the table Production.ProductInventory. 
-- ProductID Shelf TheAvg
SELECT ProductID, Shelf, AVG(Quantity) AS TheAvg
FROM Production.ProductInventory
GROUP BY ProductID, Shelf

-- 10) Write query to see the average quantity of products by shelf excluding rows that has the value of N/A in the column Shelf from the table Production.ProductInventory. 
-- ProductID Shelf TheAvg
SELECT ProductID, Shelf, AVG(Quantity) AS TheAvg
FROM Production.ProductInventory
WHERE Shelf <> 'N/A'
GROUP BY ProductID, Shelf

-- 11) List the members (rows) and average list price in the Production.Product table. This should be grouped independently over the Color and the Class column. Exclude the rows where Color or Class are null. 
-- Color Class TheCount AvgPrice
SELECT Color, Class, COUNT(*) AS TheCount, AVG(ListPrice) AS AvgPrice
FROM Production.Product
WHERE Color IS NOT NULL AND Class IS NOT NULL
GROUP BY Color, Class

-- 12) Write a query that lists the country and province names from person.CountryRegion and person.StateProvince tables. Join them and produce a result set similar to the following: 
-- Country Province
SELECT c.Name AS Country, s.Name AS Province
FROM person.CountryRegion c
JOIN person.StateProvince s ON c.CountryRegionCode = s.CountryRegionCode

-- 13) Write a query that lists the country and province names from person.CountryRegion and person.StateProvince tables and list the countries filter them by Germany and Canada. Join them and produce a result set similar to the following: 
-- Country Province
SELECT c.Name AS Country, s.Name AS Province
FROM person.CountryRegion c
JOIN person.StateProvince s ON c.CountryRegionCode = s.CountryRegionCode
WHERE c.Name IN ('Canada', 'Germany')

--  Using Northwnd Database: (Use aliases for all the Joins)

USE Northwind
GO

-- 14) List all Products that has been sold at least once in last 27 years.
SELECT DISTINCT p.ProductName
FROM Products p
JOIN [Order Details] od ON p.ProductID = od.ProductID
JOIN [Orders] o ON od.OrderID = o.OrderID
WHERE o.OrderDate >= DATEADD(year, -27, GETDATE()) -- I had to look this syntax up

-- 15) List top 5 locations (Zip Code) where the products sold most.
SELECT TOP 5 c.PostalCode, SUM(od.Quantity) AS TotalQty
FROM Customers AS c
JOIN Orders AS o ON o.CustomerID = c.CustomerID
JOIN [Order Details] AS od ON od.OrderID = o.OrderID
WHERE c.PostalCode IS NOT NULL
GROUP BY c.PostalCode
ORDER BY TotalQty DESC, c.PostalCode

-- 16) List top 5 locations (Zip Code) where the products sold most in last 27 years.
SELECT TOP 5 c.PostalCode, SUM(od.Quantity) AS TotalQty
FROM Customers AS c
JOIN Orders AS o ON o.CustomerID = c.CustomerID
JOIN [Order Details] AS od ON od.OrderID = o.OrderID
WHERE c.PostalCode IS NOT NULL AND o.OrderDate >= DATEADD(year, -27, GETDATE())
GROUP BY c.PostalCode
ORDER BY TotalQty DESC, c.PostalCode

-- 17) List all city names and number of customers in that city.
SELECT c.City, COUNT(*) AS NumCustomers
FROM Customers AS c
GROUP BY c.City

-- 18) List city names which have more than 2 customers, and number of customers in that city.
SELECT c.City, COUNT(*) AS NumCustomers
FROM Customers AS c
GROUP BY c.City
HAVING COUNT(*) >= 2

-- 19) List the names of customers who placed orders after 1/1/98 with order date.
SELECT DISTINCT c.ContactName AS CustomerName, o.OrderDate
FROM Customers AS c
JOIN Orders AS o ON o.CustomerID = c.CustomerID
WHERE o.OrderDate > '1998-01-01'

-- 20) List the names of all customers with most recent order dates.
SELECT c.ContactName, MAX(o.OrderDate) AS MostRecentOrderDate
FROM Customers AS c
LEFT JOIN Orders AS o ON o.CustomerID = c.CustomerID
GROUP BY c.ContactName
ORDER BY MostRecentOrderDate DESC

-- 21) Display the names of all customers along with the count of products they bought.
SELECT c.ContactName AS CustomerName, SUM(od.Quantity) AS TotalProductsBought
FROM Customers AS c
LEFT JOIN Orders AS o ON o.CustomerID = c.CustomerID
LEFT JOIN [Order Details] od ON od.OrderID = o.OrderID
GROUP BY c.ContactName

-- 22) Display the customer ids who bought more than 100 Products with count of products.
SELECT c.ContactName AS CustomerName, SUM(od.Quantity) AS TotalProductsBought
FROM Customers AS c
LEFT JOIN Orders AS o ON o.CustomerID = c.CustomerID
LEFT JOIN [Order Details] od ON od.OrderID = o.OrderID
GROUP BY c.ContactName
HAVING SUM(od.Quantity) > 100

-- 23) List all of the possible ways that suppliers can ship their products. Display the results as below: 
-- Supplier Company Name Shipping Company Name
SELECT DISTINCT s.CompanyName  AS [Supplier Company Name], sh.CompanyName AS [Shipping Company Name]
FROM Suppliers AS s
JOIN Products AS p  ON p.SupplierID = s.SupplierID
JOIN [Order Details] AS od ON od.ProductID = p.ProductID
JOIN Orders AS o ON o.OrderID = od.OrderID
JOIN Shippers AS sh  ON sh.ShipperID = o.ShipVia

-- 24) Display the products order each day. Show Order date and Product Name.
SELECT o.OrderDate, p.ProductName
FROM Orders AS o
JOIN [Order Details] AS od ON od.OrderID = o.OrderID
JOIN Products AS p ON p.ProductID = od.ProductID
GROUP BY o.OrderDate, p.ProductName

-- 25) Displays pairs of employees who have the same job title.
SELECT e1.EmployeeID, e1.FirstName + ' ' + e1.LastName, e2.EmployeeID, e2.FirstName + ' ' + e2.LastName, e1.Title
FROM Employees AS e1
JOIN Employees AS e2 ON e1.Title = e2.Title AND e1.EmployeeID <> e2.EmployeeID

-- 26) Display all the Managers who have more than 2 employees reporting to them.
SELECT m.FirstName + ' ' + m.LastName AS Manager
FROM Employees m
JOIN Employees e ON e.ReportsTo = m.EmployeeID
GROUP BY m.FirstName, m.LastName
HAVING COUNT(e.EmployeeID) > 2

-- 27) Display the customers and suppliers by city. The results should have the following columns: 
-- City Name Contact Name Type (Customer or Supplier)
SELECT c.City AS [City Name], c.ContactName AS [Contact Name], 'Customer' AS Type
FROM Customers c

UNION ALL

SELECT s.City AS [City Name], s.ContactName AS [Contact Name], 'Supplier' AS Type
FROM Suppliers s