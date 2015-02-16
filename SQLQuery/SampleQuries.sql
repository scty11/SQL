
USE AdventureWorks2012;

--SELECT columns
--FROM tables
--WHERE conditions 
--GROUP BY columns
--HAVING conditions
--ORDER BY columns

SELECT FirstName
	+ ' ' +  LastName AS [FullName] --combining the name into  single column
	                                -- where we have to use an alias.
	, PersonType
FROM Person.Person;


SELECT ProductID  
	,  Name
	, ListPrice
FROM Production.Product
WHERE ListPrice  NOT Between 100 AND 200;


SELECT FirstName
	 , LastName                   
FROM Person.Person
WHERE LastName = 'Smith';

SELECT ProductID  
	,  Name
	, ListPrice
FROM Production.Product
WHERE Name LIKE '/[ws/]' ESCAPE '/'; --can use our own escape character to allow the use of special characters
									--Like in c# strings.
                --'Mou%'; --finds mou then any other characters. so starts with Mou.
                --'Mou_'; --finds four letter word beginning with Mou and ending in character.
				--'Mou[^a]%' --Begins with MOU then not a letter a followed by any characters.
				--'Mou[a-h][b]%'--Begins with MOU then a to h then b then any letter.

SELECT FirstName
	 , p.LastName                   
FROM Person.Person as p
WHERE MiddleName IS NOT NULL;  

SELECT pc.Name AS CatName
	   , ps.Name AS SubName
	   , p.Name
	   , pr.Comments
FROM Production.ProductCategory AS pc
	 INNER JOIN Production.ProductSubcategory AS ps ON pc.ProductCategoryID = ps.ProductCategoryID
	 INNER JOIN Production.Product AS p ON ps.ProductSubcategoryID = p.ProductSubcategoryID
	 INNER JOIN Production.ProductReview AS pr ON p.ProductID = pr.ProductID;

--Will also include the orders which have no work orders with those columns
--being null.
SELECT p.Name
	 , wo.DueDate
FROM Production.Product AS p
	 LEFT OUTER JOIN Production.WorkOrder AS wo ON p.ProductID = wo.ProductID;

--a self join. finding those who were hired on the same date
-- making sure not to match the same rows with each other.
SELECT lhs.BusinessEntityID
	 , lhs.HireDate
	 , rhs.BusinessEntityID
FROM HumanResources.Employee AS lhs
	 INNER JOIN HumanResources.Employee AS rhs ON lhs.HireDate = rhs.HireDate
											AND lhs.BusinessEntityID < rhs.BusinessEntityID;


--here we only get the how many matches not the actual 
SELECT COUNT(BusinessEntityID) as mathes
	 , HireDate	 
FROM HumanResources.Employee AS lhs
GROUP BY HireDate;


SELECT Name
	 , ListPrice - ( SELECT AVG(ListPrice) FROM Production.Product) AS DiffFromAvg
FROM Production.Product;


--gets the average of all the products in a subcatergory and then
--gets the difference for each product with its subcatorgery average.
SELECT Name
	 , ListPrice - ap.AverageListPrice AS DiffFromSubCategory
FROM Production.Product p 
	 INNER JOIN (SELECT ProductSubcategoryID
					  , AVG(ListPrice) AS 'AverageListPrice'
				 FROM Production.Product
				 GROUP BY ProductSubcategoryID) AS ap 
	     ON p.ProductSubcategoryID = ap.ProductSubcategoryID;

--those customers who have made an order.
SELECT p.FirstName
	 , p.LastName
	 , ea.EmailAddress
FROM Person.Person p
	INNER JOIN Person.EmailAddress ea ON p.BusinessEntityID = ea.BusinessEntityID
WHERE p.BusinessEntityID IN (SELECT CustomerID
							FROM Sales.SalesOrderHeader);

	
SELECT  p.FirstName
	 , p.LastName
	 , ea.EmailAddress
FROM Person.Person p
	INNER JOIN Person.EmailAddress ea ON p.BusinessEntityID = ea.BusinessEntityID 
WHERE EXISTS  (SELECT soh.CustomerID
							FROM Sales.SalesOrderHeader soh
							WHERE p.BusinessEntityID = soh.CustomerID );

--gets all the names and email address of person and product review.
SELECT  p.FirstName + ' ' + p.LastName AS 'Fullname'
	 , ea.EmailAddress
FROM Person.Person p
	INNER JOIN Person.EmailAddress ea ON p.BusinessEntityID = ea.BusinessEntityID 
UNION ALL --includes duplicated rows
SELECT pr.ReviewerName
	 , pr.EmailAddress 
FROM Production.ProductReview pr;

--* counts all rows, the column name ignors null values.
SELECT COUNT(*) AS 'TotalPeople'
	 , COUNT(MiddleName) AS 'PeopleWithMiddleName'
FROM Person.Person;

--gets the total sales of each territory. by grouping the territories 
--and suming the total.
SELECT SUM(soh.TotalDue) AS 'SaleAmount'
	 , st.Name AS 'SaleTerritory'
FROM Sales.SalesOrderHeader soh
	 INNER JOIN Sales.SalesTerritory st ON soh.TerritoryID = st.TerritoryID
WHERE st.Name LIKE 'South%'
GROUP BY st.Name, st.[Group]
HAVING SUM(soh.TotalDue) < 40000000;

--CREATE VIEW Sales.vSalesByCategory
--AS
--Select soh.TotalDue
--	 , pc.Name AS 'Category'
--	 , ps.Name AS 'Subcategory'
--	 , p.Name AS 'Product'
--FROM Sales.SalesOrderHeader soh
--	INNER JOIN Sales.SalesOrderDetail sod ON soh.SalesOrderID = sod.SalesOrderDetailID
--	INNER JOIN Production.Product p ON sod.ProductID = p.ProductID
--	INNER JOIN Production.ProductSubcategory ps ON p.ProductSubcategoryID = ps.ProductSubcategoryID
--	INNER JOIN Production.ProductCategory pc ON ps.ProductCategoryID = pc.ProductCategoryID;

--ROLL UP allows us to break up the totals for each of the columns in the 
--group by
SELECT Category
	 , Subcategory
	 , Product
	 , SUM(TotalDue) AS 'TotalDue'
FROM Sales.vSalesByCategory
--WHERE Category = 'Clothing'
GROUP BY Category
	 , Subcategory
	 , Product
WITH ROLLUP --CUBE gets all combinations
Order BY Category
	 , Subcategory
	 , Product;

SELECT Category
	 , Subcategory
	 , Product
	 , SUM(TotalDue) AS 'TotalDue'
FROM Sales.vSalesByCategory
GROUP BY GROUPING SETS ((Category, Subcategory) --acts like roll up but allows us to set the catergory.
	 , (Subcategory)
	 , (Product))
Order BY Category
	 , Subcategory
	 , Product;

--give a number to indicate which columns were used.
--cat = 1
--subCat = 2
--cat, subCate = 3
-- pro = 4
--cat, Pro = 4
SELECT GROUPING_ID(Category, Subcategory, product) AS 'TotalBitmap'
	 , Category
	 , Subcategory
	 , Product
	 , SUM(TotalDue) AS 'TotalDue'
FROM Sales.vSalesByCategory
GROUP BY Category --acts like roll up but allows us to set the catergory.
	 , Subcategory
	 , Product
WITH ROLLUP
Order BY Category
	 , Subcategory
	 , Product;



--CTE (common table expression) allows us to break dow a complex query by creating 
--these to be used like tables.
WITH SalesData
AS
(SELECT SUM(soh.TotalDue) AS 'TotalSold'
	 , YEAR(soh.OrderDate) 'OrderYear'
	 , st.Name
FROM Sales.SalesOrderHeader soh
	 INNER JOIN Sales.SalesTerritory st ON soh.TerritoryID = st.TerritoryID
GROUP BY YEAR(soh.OrderDate)
	 , st.Name)
--using a pivot to use column values as column names
--here we sum the total sold for the given year which 
--will be now the column name.
SELECT *
FROM SalesData
	PIVOT (SUM(TotalSold)
			FOR OrderYear IN ([2006],[2007],[2008]) )AS pvt;


--The ids of who has made an order
SELECT p.BusinessEntityID
FROM Person.Person p
	INNER JOIN Person.EmailAddress ea ON p.BusinessEntityID = ea.BusinessEntityID 
INTERSECT  
SELECT soh.CustomerID
FROM Sales.SalesOrderHeader soh;

--here we are using a cte to gain the name and contact
--of those people who have made an order.
WITH ContactsWithOrders
AS(
SELECT p.BusinessEntityID
FROM Person.Person p
	INNER JOIN Person.EmailAddress ea ON p.BusinessEntityID = ea.BusinessEntityID 
INTERSECT  
SELECT soh.CustomerID
FROM Sales.SalesOrderHeader soh
)
SELECT  p.FirstName
	 , p.LastName
	 , ea.EmailAddress
FROM Person.Person p
	INNER JOIN Person.EmailAddress ea ON p.BusinessEntityID = ea.BusinessEntityID 
	INNER JOIN ContactsWithOrders cwo ON cwo.BusinessEntityID = p.BusinessEntityID;

--the ids of the people who have not made an order.
SELECT TOP 10 p.BusinessEntityID
FROM Person.Person p
	INNER JOIN Person.EmailAddress ea ON p.BusinessEntityID = ea.BusinessEntityID 
EXCEPT
SELECT soh.CustomerID
FROM Sales.SalesOrderHeader soh


SELECT Name
	 , ListPrice
	 , ROW_NUMBER() OVER (ORDER BY ListPrice DESC) AS 'Row_Number'
	 , RANK() OVER (ORDER BY ListPrice DESC) AS 'Rank'--normal ranking like in golf, if two are first then the next is third
	 , DENSE_RANK() OVER (ORDER BY ListPrice) AS 'Dense_Rank'--like the olypics can have two golds and the next is silver.
	 , NTILE(4) OVER (ORDER BY ListPrice) AS 'NTile' -- breaks up into 4 groups
FROM Production.Product p
WHERE ProductSubcategoryID = 1
ORDER BY ListPrice DESC


--paging by 10, grabbing page 3
--21-30
SELECT Name
	 , ListPrice
	 , ROW_NUMBER() OVER (ORDER BY Name) AS 'RowNumber'
FROM Production.Product p
ORDER BY Name
	OFFSET 20 ROWS
	FETCH NEXT 10 ROWS ONLY


SELECT DISTINCT p.FirstName
	 , p.LastName
	 , ea.EmailAddress
FROM Person.Person p
	INNER JOIN Person.EmailAddress ea ON p.BusinessEntityID = ea.BusinessEntityID
	INNER JOIN Sales.SalesOrderHeader soh ON p.BusinessEntityID = soh.CustomerID
ORDER BY p.FirstName
	 , p.LastName
	 , ea.EmailAddress;

--can replace  null values 
SELECT p.FirstName
	 , p.LastName
	 , p.Title
	 , ISNULL(P.MiddleName, 'Not Given') AS 'IsNull' -- here we only have 1 input and a placement.
	 ,COALESCE(p.MiddleName, p.Title, 'Not Given') AS 'CoalesceNull'--here we can have multiple values, here if the first is null the second will be used, if both are null then the third is used.
FROM Person.Person p
	INNER JOIN Person.EmailAddress ea ON p.BusinessEntityID = ea.BusinessEntityID
ORDER BY p.Title DESC;


SELECT MAX(soh.OrderDate) AS 'MostRecentOrderDate'
	 , YEAR(MAX(soh.OrderDate)) AS 'MostRecentOrderYearYearFunction'
	 , DATEPART(year, MAX(soh.OrderDate)) AS 'DatePartFunction'--the big differene here is that we can pass in the part we want, say day, year, month.
	 , p.LastName	
FROM Person.Person p
	INNER JOIN Person.EmailAddress ea ON p.BusinessEntityID = ea.BusinessEntityID
    INNER JOIN Sales.SalesOrderHeader soh ON p.BusinessEntityID = soh.CustomerID
GROUP BY P.LastName; 


SELECT p.LastName	
	 , DATEDIFF(day, MAX(soh.OrderDate), GETDATE()) AS 'DaysSinceLastOrder'
	 , DATEADD(day,10,GETDATE()) AS 'AddingTenDays' 
	 , ISDATE(p.EmailPromotion) AS 'IsDateOrNot'--0 for false, 1 for true?
FROM Person.Person p
	INNER JOIN Person.EmailAddress ea ON p.BusinessEntityID = ea.BusinessEntityID
    INNER JOIN Sales.SalesOrderHeader soh ON p.BusinessEntityID = soh.CustomerID
GROUP BY P.LastName
	 , p.EmailPromotion; 


SELECT p.ModifiedDate
	 , DATEFROMPARTS(YEAR(p.ModifiedDate), MONTH(p.ModifiedDate), (DAY(p.ModifiedDate)))
					AS 'BuildingDateFunction'
	 --, TIMEFROMPARTS(hour, minute, second)
	 , EOMONTH(p.ModifiedDate) AS 'LastDayOfCurrentMonth'--gets the last day of the month
FROM Person.Person p
WHERE P.ModifiedDate IS NOT NULL;

SELECT CHARINDEX('speaker', 'loudspeaker');--searches for the string
SELECT PATINDEX('%speake_%', 'loudspeaker');--searches for the pattern.
SELECT LEN('scott');
--SELECT LTRIM('loud speaker');--RTRIM both remove white space. at both ends.

--selects the left most characters from the string.
SELECT LEFT (Name, 2)
FROM Production.Product
WHERE ListPrice > 0;

--selects the right most characters from the string.
SELECT RIGHT (Name, 2)
FROM Production.Product
WHERE ListPrice > 0;

--list price is money so will try to convert others to money.
--SELECT Name + ' costs ' + ListPrice AS Display 
--Need to concat
SELECT CONCAT( Name, ' costs ', ListPrice) AS Display
FROM Production.Product
WHERE ListPrice > 0;

--this time converts to a string
SELECT Name + ' costs ' + CAST(ListPrice AS nvarchar) AS Display
FROM Production.Product
WHERE ListPrice > 0;

--SELECT TRY_CONVERT() returns null if conversion fails
--SELECT TRY_PARSE() more for strings into data types, returns null if fails.

--can control which data is in Name.
SELECT CHOOSE (1, FirstName, LastName, FirstName + ' ' + LastName) AS 'Name'
FROM Person.Person;

--like using the ? operator in c#.
SELECT IIF(ListPrice > 0, 'NormalProduct', 'InternalProduct') AS 'ProductInfo'
FROM Production.Product;

--using the query plan to show non clusted seek.
SELECT  p.FirstName
	 , p.LastName
	 , p.BusinessEntityID
	 , p.PersonType
FROM Person.Person p
WHERE LastName = 'Wright';

--Here we are creating dynamic SQL, which can be useful where we dont know 
--balues until runtime.
DECLARE @sql nvarchar(500) = 'SELECT  p.FirstName
	 , p.LastName
FROM Person.Person p
WHERE LastName = @LastName';
DECLARE @paramDefinitions nvarchar(500) = '@LastName nvarchar(50)';
EXECUTE sp_executesql @sql, @paramDefinitions, @LastName = 'Wright';



--insert, update and delete examples.
INSERT INTO Sales.Currency(CurrencyCode, Name)
VALUES('MUM', 'made up money'), 
	  ('SMM', 'Some More made up money');

UPDATE Sales.Currency
SET Name = 'made up money copy'
WHERE CurrencyCode = 'MUM'

SELECT TOP 1000 [CurrencyCode]
      ,[Name]
      ,[ModifiedDate]
  FROM [AdventureWorks2012].[Sales].[Currency]

DELETE FROM Sales.Currency
WHERE CurrencyCode = 'MUM' OR CurrencyCode = 'SMM';


UPDATE Production.Product
SET ListPrice = ListPrice *1.1
    , ModifiedDate = GETDATE()
OUTPUT inserted.Name
	 , deleted.ListPrice AS 'OldListPrice'
	 , inserted.ListPrice AS 'NewListPrice'
	 --can put these into another table.
FROM Production.Product p
	INNER JOIN Production.ProductSubcategory ps ON p.ProductSubcategoryID = ps.ProductSubcategoryID
--this gets the bikes.
WHERE ps.ProductCategoryID = 1; 

SELECT *
FROM Production.Product
ORDER BY ModifiedDate DESC;


BEGIN TRY
	BEGIN TRANSACTION;
	UPDATE Production.ProductCategory
	SET Name = 'Widgets'
	WHERE ProductCategoryID = 1;

	DELETE FROM Production.ProductSubcategory
	WHERE ProductSubcategoryID = 1;
	COMMIT TRANSACTION;
END TRY
BEGIN CATCH
	--somthong gone wrong
	ROLLBACK TRANSACTION;

	PRINT 'An errir ocurred';
	PRINT ERROR_NUMBER();
	PRINT ERROR_LINE();
	PRINT ERROR_MESSAGE();
	--can re through the error so whoever called
	--can see the error.
	THROW;
END CATCH

RAISERROR('Demo message', 16, 1);

--50000, must this or hogher for custom ones.
--allows us to re through an exception like used above
--unlike raise-error.
THROW 50000, 'This is a demo', 1;

SELECT pc.Name AS 'ProductCatName'
	 , ps.Name AS 'ProductSubName'
FROM Production.ProductSubcategory ps
	INNER JOIN Production.ProductCategory pc ON PS.ProductCategoryID = PC.ProductCategoryID
	
FOR XML RAW('ProductCategory'), ROOT('ProductCategories'), ELEMENTS;


SELECT ProductCat.Name AS 'ProductCatName'
	 , SubCategory.Name AS 'ProductSubName'
FROM Production.ProductCategory ProductCat
	INNER JOIN  Production.ProductSubcategory SubCategory ON SubCategory.ProductCategoryID = ProductCat.ProductCategoryID	
FOR XML AUTO, ROOT('Categories');--, ELEMENTS;

SELECT ProductCat.ProductCategoryID AS '@ID'
	 , ProductCat.Name AS '@ProductCatName'
	 , SubCategory.Name AS 'Category/ProductSubName'
FROM Production.ProductCategory ProductCat
	INNER JOIN  Production.ProductSubcategory SubCategory ON SubCategory.ProductCategoryID = ProductCat.ProductCategoryID	
FOR XML Path('Category'), ROOT('Categories'), ELEMENTS;




CREATE VIEW HumanResources.vEmployeeList
AS
SELECT p.FirstName
	 , p.LastName
	 , ea.EmailAddress
	 , e.HireDate
FROM Person.Person p 
	INNER JOIN Person.EmailAddress ea ON p.BusinessEntityID = ea.BusinessEntityID
	INNER JOIN HumanResources.Employee e ON p.BusinessEntityID = e.BusinessEntityID;
	

SELECT *
FROM HumanResources.vEmployeeList;

CREATE PROCEDURE Sales.up_Currency_Insert
	@Code nchar(3), @Name nvarchar(50)
AS
BEGIN
INSERT INTO Sales.Currency
VALUES(@Code, @Name, GETDATE());

SELECT *
FROM Sales.Currency
WHERE Name = @Name;
END

DECLARE @lCode nchar(3) = 'smc';
DECLARE @lName nvarchar(50) = 'Some More Money';

EXEC Sales.up_Currency_Insert @lCode, @lName;

CREATE FUNCTION Sales.uf_MostRecentCustomerOrderDate(@CustID int)
RETURNS datetime
AS
BEGIN;
	DECLARE @MostRecentOrderDate datetime;
	SELECT @MostRecentOrderDate=  MAX(OrderDate)
	FROM Sales.SalesOrderHeader
	WHERE CustomerID = @CustID;
	RETURN @MostRecentOrderDate;
END;

SELECT Sales.uf_MostRecentCustomerOrderDate(29825);

CREATE FUNCTION Sales.uf_CustomerOrderDates(@CustID int)
RETURNS TABLE
AS
RETURN 
		SELECT OrderDate
		FROM Sales.SalesOrderHeader
		WHERE CustomerID = @CustID;

SELECT OrderDate
FROM Sales.uf_CustomerOrderDates(29815);

