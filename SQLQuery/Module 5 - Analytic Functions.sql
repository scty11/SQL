-- Demo: Analytic Functions

USE AdventureWorks2012;

-- LAG
/* BOL syntax
	LAG (scalar_expression [,offset] [,default])
		OVER ( [ partition_by_clause ] order_by_clause )
*/

SELECT p.Name ProductName,
	   pch.EndDate,
       pch.StandardCost,
	   LAG(pch.StandardCost, 1, 0.00)
	     OVER (PARTITION BY p.ProductID
		       ORDER BY p.Name, pch.EndDate) AS PreviousStandardCost
FROM [Production].[Product] AS p
INNER JOIN [Production].[ProductCostHistory] AS pch 
  ON p.ProductID = pch.ProductID
ORDER BY p.Name, pch.EndDate, pch.StandardCost;

-- LEAD
/* BOL syntax
	LEAD ( scalar_expression [ ,offset ] , [ default ] ) 
      OVER ( [ partition_by_clause ] order_by_clause )
*/

SELECT p.Name ProductName,
	   pch.EndDate,
       pch.StandardCost,
	   LEAD(pch.StandardCost, 1, 0.00)
	     OVER (PARTITION BY p.ProductID
		       ORDER BY p.Name, pch.EndDate) AS NextStandardCost
FROM [Production].[Product] AS p
INNER JOIN [Production].[ProductCostHistory] AS pch 
  ON p.ProductID = pch.ProductID
ORDER BY p.Name, pch.EndDate, pch.StandardCost;

-- FIRST_VALUE

-- LEAD
/* BOL syntax
	FIRST_VALUE ( [scalar_expression ) 
    OVER ( [ partition_by_clause ] order_by_clause [ rows_range_clause ] ) 

*/

SELECT p.Name ProductName,
	   CAST(pch.StartDate as date) AS StartDate,
       pch.StandardCost,
	   FIRST_VALUE(pch.StandardCost)
	     OVER (PARTITION BY p.ProductID
		       ORDER BY p.Name, pch.StartDate) AS InitialStandardCost
FROM [Production].[Product] AS p
INNER JOIN [Production].[ProductCostHistory] AS pch 
  ON p.ProductID = pch.ProductID
WHERE p.Name IN 
	('AWC Logo Cap', 'Long-Sleeve Logo Jersey, L', 'Sport-100 Helmet, Black')
ORDER BY p.Name, pch.StartDate, pch.StandardCost;

-- LAST_VALUE
/*
	LAST_VALUE ( [scalar_expression ) 
		OVER ( [ partition_by_clause ] order_by_clause rows_range_clause ) 

	Window Frames become important here... (Sampling of options below)

	UNBOUNDED PRECEDING (Window begins at first row of partition)
	UNBOUNDED FOLLOWING (Window ends at last row of partition)
*/

SELECT p.Name ProductName,
	   CAST(pch.StartDate as date) AS StartDate,
       pch.StandardCost,
	   LAST_VALUE(pch.StandardCost)
	     OVER (PARTITION BY p.ProductID
		       ORDER BY p.Name, pch.StartDate
			   RANGE BETWEEN UNBOUNDED PRECEDING AND 
			                 UNBOUNDED FOLLOWING) AS LatestStandardCost
FROM [Production].[Product] AS p
INNER JOIN [Production].[ProductCostHistory] AS pch 
  ON p.ProductID = pch.ProductID
WHERE p.Name IN 
	('AWC Logo Cap', 'Long-Sleeve Logo Jersey, L', 'Sport-100 Helmet, Black')
ORDER BY p.Name, pch.StartDate, pch.StandardCost;