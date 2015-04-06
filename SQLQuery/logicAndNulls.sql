-- Demo: Logical Functions

USE AdventureWorks2012;

-- CHOOSE ( index, val_1, val_2 [, val_n ] )
SELECT CHOOSE (2, 'Route 1', 'Route 2', 'Route 3') 
   AS RouteChoice;

SELECT CHOOSE (3, 'Route 1', 'Route 2', 'Route 3') 
   AS RouteChoice;

-- IIF ( boolean_expression, true_value, false_value )
SELECT pch.ProductID,
       pch.StartDate,
	   IIF ( pch.StartDate BETWEEN '12/31/2004' AND '1/1/2006',
			 'K-Tech Ownership', 'Unknown Ownership') AS OwnerStatus,
	   pch.StandardCost
FROM [Production].[ProductCostHistory] AS pch;

-- Simple CASE
SELECT pch.ProductID,
       pch.StartDate,
	   pch.StandardCost,
	   CASE pch.ProductID
	     WHEN 707 THEN 'Platinum Collection'
		 WHEN 711 THEN 'Silver Collection'
		 WHEN 713 THEN 'Gold Collection'
		 ELSE 'Standard Product'
	   END AS 'Product Status'
FROM [Production].[ProductCostHistory] AS pch;

-- Searched CASE
SELECT pch.ProductID,
       pch.StartDate,
	   CASE 
	      WHEN pch.StartDate BETWEEN '12/31/2004' AND '1/1/2006'
		     THEN 'Owned by K-Tech'
		  WHEN pch.StartDate BETWEEN '12/31/2006' AND '1/1/2008'
		     THEN 'Owned by Z-Tech'
		  ELSE 'Unknown Ownership'
	   END AS 'OwnerStatus',
	   pch.StandardCost
FROM [Production].[ProductCostHistory] AS pch;

-- COALESCE ( expression [ ,...n ] ) 
--returns the forst non null value
DECLARE @val1 int = NULL;
DECLARE @val2 int = NULL;
DECLARE @val3 int = 2;
DECLARE @val4 int = 5;

SELECT COALESCE(@val1, @val2, @val3, @val4) 
   AS FirstNonNull;

-- ISNULL- replaces null vlaues with a sunstistute.
SELECT p.Name,
       ISNULL(p.Color, 'Unknown') AS Color
FROM [Production].[Product] AS p
ORDER BY p.Name;

-- CONCAT_NULL_YIELDS_NULL behavior

SET CONCAT_NULL_YIELDS_NULL ON;
GO

DECLARE @ReportName varchar(20) = NULL;
SELECT 'Report Date:' + @ReportName
   AS ReportHeader;
GO


SET CONCAT_NULL_YIELDS_NULL OFF;
GO

DECLARE @ReportName varchar(20) = NULL;
SELECT 'Report Date:' + @ReportName
   AS ReportHeader;
GO

-- In a future version of SQL Server CONCAT_NULL_YIELDS_NULL will always be ON 
