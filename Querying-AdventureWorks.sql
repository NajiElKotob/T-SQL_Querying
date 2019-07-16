/*
______          ______               _        
|  _  \         | ___ \             | |       
| | | |_____   _| |_/ /___  __ _  __| |_   _  
| | | / _ \ \ / /    // _ \/ _` |/ _` | | | | 
| |/ /  __/\ V /| |\ \  __/ (_| | (_| | |_| | 
|___/ \___| \_/ \_| \_\___|\__,_|\__,_|\__, | 
                                        __/ | 
                                       |___/  
*/

-- T-SQL Querying (AdventureWorks)


-- ========================
-- sp_*
-- ========================

-- Reports information about a specified database or all databases.
-- https://docs.microsoft.com/en-us/sql/relational-databases/system-stored-procedures/sp-helpdb-transact-sql
sp_helpdb 

-- Using sp_datatype_info to get the data type of a variable
-- https://docs.microsoft.com/en-us/sql/relational-databases/system-stored-procedures/sp-datatype-info-transact-sql
sp_datatype_info

-- sp_who: Provides information about current users, sessions, and processes in an instance of the Microsoft SQL Server Database Engine. 
-- https://docs.microsoft.com/en-us/sql/relational-databases/system-stored-procedures/sp-who-transact-sql
EXEC sp_who
EXEC sp_who 'active'
EXEC sp_who2

-- ========================
-- DBCC
-- ========================
-- Provides transaction log space usage statistics for all databases.
-- https://docs.microsoft.com/en-us/sql/t-sql/database-console-commands/dbcc-sqlperf-transact-sql
DBCC SQLPERF (LOGSPACE)

-- |||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||


-- ========================
-- System Catalog Views 
-- ========================

-- https://docs.microsoft.com/en-us/sql/relational-databases/system-catalog-views/catalog-views-transact-sql
/*
Catalog views return information that is used BY the SQL Server Database Engine. 
We recommend that you use catalog views because they are the most general interface 
to the catalog metadata and provide the most efficient way to obtain, transform, 
and present customized forms of this information. All user-available catalog 
metadata is exposed through catalog views.
*/
SELECT name, user_access_desc, is_read_only, state_desc, recovery_model_desc  
FROM sys.databases;  


-- ========================
-- SELECT
-- ========================

USE AdventureWorks
GO

SELECT * From Sales.vSalesPerson

SELECT FirstName + ' ' + LastName As FullName, SalesLastYear
FROM Sales.vSalesPerson
WHERE SalesLastYear > 1900000


SELECT * FROM Production.Product WHERE Name LIKE '%cran%'
SELECT * FROM Production.Product WHERE Color IN ('Black','Red')


--SELECT * FROM Sales.SalesOrderHeader
--SELECT Distinct SalesPersonID From Sales.SalesOrderHeader

SELECT SalesPersonID,  AVG(TotalDue) AS Average, SUM(TotalDue) AS Total, COUNT(*) AS NumberOfOrders ,
CASE
	WHEN COUNT(*) >= 400 THEN 'High'
	WHEN COUNT(*) >= 300 THEN 'Medium'
	ELSE 'Low'
END AS Level
FROM Sales.SalesOrderHeader
WHERE SalesPersonID IS NOT NULL  
GROUP BY SalesPersonID
-- HAVING COUNT(*) > 400
ORDER BY Total DESC


SELECT SubTotal + TaxAmt + Freight AS TotalDue, TotalDue FROM Sales.SalesOrderHeader


SELECT  COUNT(*) AS COUNT, Count(SalesPersonID)
FROM Sales.SalesOrderHeader


SELECT SalesPersonID, OrderDate AS OrderYear, COUNT(*) AS COUNT, Count(SalesPersonID) AS CountPerSalesPersonID
FROM Sales.SalesOrderHeader
--WHERE SalesPersonID IS NOT NULL
GROUP BY SalesPersonID, OrderDate
HAVING COUNT(*) > 20
ORDER BY SalesPersonID, OrderYear


-- Set Operators
-- https://docs.microsoft.com/en-us/sql/t-sql/language-elements/set-operators-except-and-intersect-transact-sql?view=sql-server-2017



-- AND, OR, NOT
/*
https://docs.microsoft.com/en-us/sql/t-sql/language-elements/operator-precedence-transact-sql
https://www.w3schools.com/sql/sql_and_or.asp
https://www.techonthenet.com/sql/not.php
*/
DECLARE @val1 int = 1, @val2 int = 2, @val3 int = 3;
SELECT @val1, @val2, @val3 
WHERE
@val1 = 1 AND @val2 = 0 OR NOT @val3 = 2


--	=============
--	EXISTS
--	=============
-- https://docs.microsoft.com/en-us/sql/t-sql/language-elements/exists-transact-sql
-- http://searchsqlserver.techtarget.com/answer/Delete-FROM-table-A-if-matching-row-exists-in-B

CREATE TABLE #tmpTableA 
(Id int Identity NOT NULL,
Name varchar(10) NOT NULL)

CREATE TABLE #tmpTableB
(Id int Identity NOT NULL,
Name varchar(10) NOT NULL)


TRUNCATE TABLE #tmpTableA
TRUNCATE TABLE #tmpTableB

DECLARE @count int = 0

WHILE @count < 10
BEGIN
INSERT INTO #tmpTableA (Name) VALUES ('A' + CAST(@count AS varchar(10)));
SET @count += 1;
IF @count > 3 CONTINUE
INSERT INTO #tmpTableB (Name) VALUES ('B' + CAST(@count AS varchar(10)));
END;


SELECT * FROM #tmpTableA;
SELECT * FROM #tmpTableB;

DELETE FROM #tmpTableA WHERE EXISTS
       (SELECT * FROM #tmpTableB B WHERE B.Id = #tmpTableA.Id); 


-- Uses AdventureWorks  
-- The following example shows queries to find employees of departments that start with P.
SELECT p.FirstName, p.LastName, e.JobTitle  
FROM Person.Person AS p   
JOIN HumanResources.Employee AS e  
   ON e.BusinessEntityID = p.BusinessEntityID   
WHERE EXISTS  
(SELECT *  
    FROM HumanResources.Department AS d  
    JOIN HumanResources.EmployeeDepartmentHistory AS edh  
       ON d.DepartmentID = edh.DepartmentID  
    WHERE e.BusinessEntityID = edh.BusinessEntityID  
    AND d.Name LIKE 'P%');  
GO 

/*
Each AdventureWorks customer is a retail company with a named contact. 
Create queries that return the total revenue for each customer, 
including the company and customer contact names.
*/
SELECT CompanyContact, SUM(SalesAmount) AS Revenue
FROM
	(SELECT CONCAT (C.CompanyName, CONCAT (' (' + c.FirstName + ' ', c.LastName + ')')) AS CompanyContact, SOH.TotalDue
	 FROM Sales.SalesOrderHeader AS SOH
	 JOIN Sales.Customer AS C
	 ON SOH.CustomerID = C.CustomerID) AS CustomerSales(CompanyContact, SalesAmount)
GROUP BY CompanyContact
ORDER BY CompanyContact;


.


/*
The total of the first 3 rows = the total of the last 3 rows = the Null/Null row
SalesPersonID	CustomerID	TotalAmount
NULL	30116	211671.2674
NULL	30117	919801.8188
NULL	30118	313671.5352
NULL	NULL	1445144.6214
275		NULL	755382.7754
276		NULL	211671.2674
277		NULL	478090.5786
*/


SELECT TOP(10) PERCENT * FROM Sales.SalesOrderDetail
ORDER BY LineTotal DESC

--OFFSET and FETCH
--OFFSET <EXPR1> ROWS, which you use to specify the line number FROM which to start retrieving results
--FETCH NEXT <EXPR2> ROWS ONLY, which you use to specify how many lines to
SELECT  ROW_NUMBER() OVER(ORDER BY P.ProductID) AS RowNumber, *
FROM Production.Product AS P
ORDER BY RowNumber
OFFSET 10 ROWS
FETCH NEXT 20 ROWS ONLY


-- Ranking Functions
-- https://docs.microsoft.com/en-us/sql/t-sql/functions/ranking-functions-transact-sql
SELECT p.FirstName, p.LastName  
    ,ROW_NUMBER() OVER (ORDER BY a.PostalCode) AS "Row Number"  
    ,RANK() OVER (ORDER BY a.PostalCode) AS Rank  
    ,DENSE_RANK() OVER (ORDER BY a.PostalCode) AS "Dense Rank"  
    ,NTILE(4) OVER (ORDER BY a.PostalCode) AS Quartile  
    ,s.SalesYTD
    ,a.PostalCode  
FROM Sales.SalesPerson AS s   
    INNER JOIN Person.Person AS p   
        ON s.BusinessEntityID = p.BusinessEntityID  
    INNER JOIN Person.Address AS a   
        ON a.AddressID = p.BusinessEntityID  
WHERE TerritoryID IS NOT NULL AND SalesYTD <> 0;  


SELECT p.FirstName, p.LastName  
    ,ROW_NUMBER() OVER (ORDER BY (ROUND(s.SalesYTD, -6)/1000000) DESC) AS "Row Number"  
    ,RANK() OVER (ORDER BY (ROUND(s.SalesYTD, -6)/1000000) DESC) AS Rank  
    ,DENSE_RANK() OVER (ORDER BY (ROUND(s.SalesYTD, -6)/1000000) DESC) AS "Dense Rank"  
    ,NTILE(4) OVER (ORDER BY (ROUND(s.SalesYTD, -6)/1000000) DESC) AS Quartile  
    ,s.SalesYTD, (ROUND(s.SalesYTD, -6)/1000000) SalesYTDMillion 
FROM Sales.SalesPerson AS s   
    INNER JOIN Person.Person AS p   
        ON s.BusinessEntityID = p.BusinessEntityID  
    INNER JOIN Person.Address AS a   
        ON a.AddressID = p.BusinessEntityID  
WHERE TerritoryID IS NOT NULL AND SalesYTD <> 0; 



WITH OrderedOrders AS  
(  
    SELECT SalesOrderID, OrderDate,  
    ROW_NUMBER() OVER (ORDER BY OrderDate) AS RowNumber  
    FROM Sales.SalesOrderHeader   
)   
SELECT SalesOrderID, OrderDate, RowNumber    
FROM OrderedOrders   
WHERE RowNumber BETWEEN 50 AND 60


-- FUNCTIONS ================
-- ==========================

-- Date and Time functions

SELECT GETDATE(), GETUTCDATE();

SELECT DATENAME(year, GETDATE()) as Year,
       DATENAME(week, GETDATE()) as Week,
       DATENAME(dayofyear, GETDATE()) as DayOfYear,
       DATENAME(month, GETDATE()) as Month,
       DATENAME(day, GETDATE()) as Day,
       DATENAME(weekday, GETDATE()) as Weekday


SELECT   NationalIDNumber,
         HireDate,
         DATEDIFF(year, HireDate, GETDATE()) YearsOfService
FROM     HumanResources.Employee
WHERE    DATEDIFF(year, HireDate, GETDATE()) >= 5
ORDER BY YearsOfService DESC


-- Tables ===================
-- ==========================

-- Table Variable
DECLARE @Colors AS TABLE (Color nvarchar(15));

INSERT INTO @Colors
SELECT DISTINCT Color FROM SalesLT.Product;

SELECT ProductID, Name, Color
FROM SalesLT.Product
WHERE Color IN (SELECT Color FROM @Colors);

-- Union
-- https://technet.microsoft.com/en-us/library/ms187731(v=sql.110).aspx
USE AdventureWorks2014;
GO
IF OBJECT_ID ('dbo.EmployeeOne', 'U') IS NOT NULL
DROP TABLE dbo.EmployeeOne;
GO
IF OBJECT_ID ('dbo.EmployeeTwo', 'U') IS NOT NULL
DROP TABLE dbo.EmployeeTwo;
GO
IF OBJECT_ID ('dbo.EmployeeThree', 'U') IS NOT NULL
DROP TABLE dbo.EmployeeThree;
GO

SELECT pp.LastName, pp.FirstName, e.JobTitle 
INTO dbo.EmployeeOne
FROM Person.Person AS pp JOIN HumanResources.Employee AS e
ON e.BusinessEntityID = pp.BusinessEntityID
WHERE LastName = 'Johnson';
GO
SELECT pp.LastName, pp.FirstName, e.JobTitle 
INTO dbo.EmployeeTwo
FROM Person.Person AS pp JOIN HumanResources.Employee AS e
ON e.BusinessEntityID = pp.BusinessEntityID
WHERE LastName = 'Johnson';
GO
SELECT pp.LastName, pp.FirstName, e.JobTitle 
INTO dbo.EmployeeThree
FROM Person.Person AS pp JOIN HumanResources.Employee AS e
ON e.BusinessEntityID = pp.BusinessEntityID
WHERE LastName = 'Johnson';
GO

-- Union ALL
SELECT LastName, FirstName, JobTitle
FROM dbo.EmployeeOne
UNION ALL
SELECT LastName, FirstName ,JobTitle
FROM dbo.EmployeeTwo
UNION ALL
SELECT LastName, FirstName,JobTitle 
FROM dbo.EmployeeThree;
GO

SELECT LastName, FirstName,JobTitle
FROM dbo.EmployeeOne
UNION 
SELECT LastName, FirstName, JobTitle 
FROM dbo.EmployeeTwo
UNION 
SELECT LastName, FirstName, JobTitle 
FROM dbo.EmployeeThree;
GO

SELECT LastName, FirstName,JobTitle 
FROM dbo.EmployeeOne
UNION ALL
(
SELECT LastName, FirstName, JobTitle 
FROM dbo.EmployeeTwo
UNION
SELECT LastName, FirstName, JobTitle 
FROM dbo.EmployeeThree
);
GO







-- APPLY
-- https://www.simple-talk.com/sql/t-sql-programming/sql-server-apply-basics/
USE AdventureWorks
GO
IF OBJECT_ID (N'fn_sales', N'IF') IS NOT NULL
  DROP FUNCTION dbo.fn_sales
GO
CREATE FUNCTION fn_sales (@SalesPersonID int)
RETURNS TABLE
AS
RETURN
(
  SELECT TOP 3 
    SalesPersonID, 
    ROUND(TotalDue, 2) AS SalesAmount
  FROM 
    Sales.SalesOrderHeader
  WHERE 
    SalesPersonID = @SalesPersonID
  ORDER BY 
    TotalDue DESC
)
GO

SELECT SalesAmount FROM fn_sales(285)
SELECT sp.FirstName + ' ' + sp.LastName AS FullName FROM Sales.vSalesPerson AS sp
SELECT SalesPersonID, TotalDue FROM  Sales.SalesOrderHeader


SELECT 
  sp.FirstName + ' ' + sp.LastName AS FullName,
  fn.SalesAmount
FROM
  Sales.vSalesPerson AS sp
CROSS APPLY -- Similar to Inner Join 
  fn_sales(sp.BusinessEntityID) AS fn
ORDER BY
  sp.LastName, fn.SalesAmount DESC



-- CTE - Common Table Expressions
-- https://technet.microsoft.com/en-us/library/ms190766(v=sql.105).aspx
USE AdventureWorks;
GO
-- Define the CTE expression name and column list.
WITH Sales_CTE (SalesPersonID, SalesOrderID, SalesYear)
AS
-- Define the CTE query.
(
    SELECT SalesPersonID, SalesOrderID, YEAR(OrderDate) AS SalesYear
    FROM Sales.SalesOrderHeader
    WHERE SalesPersonID IS NOT NULL
)
-- Define the outer query referencing the CTE name.
SELECT SalesPersonID, COUNT(SalesOrderID) AS TotalSales, SalesYear
FROM Sales_CTE
GROUP BY SalesYear, SalesPersonID
ORDER BY SalesPersonID, SalesYear;
GO



-- https://sqlwithmanoj.com/tag/option-maxrecursion/
-- https://www.simple-talk.com/sql/t-sql-programming/sql-server-cte-basics/

DECLARE
    @startDate DATETIME,
    @endDate DATETIME
 
SET @startDate = '11/10/2011'
SET @endDate = '03/25/2012'
 
; WITH CTE AS (
    SELECT
        YEAR(@startDate) AS 'yr',
        MONTH(@startDate) AS 'mm',
        DATENAME(mm, @startDate) AS 'mon',
        DATEPART(d,@startDate) AS 'dd',
        @startDate 'new_date'
    UNION ALL
    SELECT
        YEAR(new_date) AS 'yr',
        MONTH(new_date) AS 'mm',
        DATENAME(mm, new_date) AS 'mon',
        DATEPART(d,@startDate) AS 'dd',
        DATEADD(d,1,new_date) 'new_date'
    FROM CTE
    WHERE new_date < @endDate
    )
SELECT yr AS 'Year', mon AS 'Month', count(dd) AS 'Days'
FROM CTE
GROUP BY mon, yr, mm
ORDER BY yr, mm
OPTION (MAXRECURSION 1000)
