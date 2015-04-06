-- Demo: Analytic Functions (2)

USE AdventureWorks2012;

-- CUME_DIST - computes the relative position of a specified value in a group of values
SELECT ps.Name SubCategoryName,
	   p.Name ProductName,
       pch.StandardCost,
	   CUME_DIST () OVER (PARTITION BY ps.ProductSubcategoryID
	                      ORDER BY pch.StandardCost) AS CumeDist
FROM [Production].[Product] AS p
INNER JOIN [Production].[ProductSubcategory] AS ps 
  ON p.ProductSubcategoryID = ps.ProductSubcategoryID
INNER JOIN [Production].[ProductCostHistory] AS pch 
  ON p.ProductID = pch.ProductID
ORDER BY ps.Name, pch.StandardCost;

-- PERCENT_RANK - derived by RANK 
--		(RANK - 1)/(Row Count - 1)
SELECT ps.Name SubCategoryName,
	   p.Name ProductName,
       pch.StandardCost,
	   RANK() OVER (PARTITION BY ps.ProductSubcategoryID
	                      ORDER BY pch.StandardCost) RowRank,
	   PERCENT_RANK () OVER (PARTITION BY ps.ProductSubcategoryID
	                      ORDER BY pch.StandardCost) AS PercentRank
FROM [Production].[Product] AS p
INNER JOIN [Production].[ProductSubcategory] AS ps 
  ON p.ProductSubcategoryID = ps.ProductSubcategoryID
INNER JOIN [Production].[ProductCostHistory] AS pch 
  ON p.ProductID = pch.ProductID
ORDER BY ps.Name, pch.StandardCost;

-- PERCENTILE_CONT (interpolated) - percentile based on a continuous distribution
SELECT ps.Name SubCategoryName,
	   p.Name ProductName,
       pch.StandardCost,
	   PERCENTILE_CONT (0.3) 
	     WITHIN GROUP (ORDER BY pch.StandardCost)
		 OVER (PARTITION BY ps.ProductSubcategoryID) 
		  AS Percentile
FROM [Production].[Product] AS p
INNER JOIN [Production].[ProductSubcategory] AS ps 
  ON p.ProductSubcategoryID = ps.ProductSubcategoryID
INNER JOIN [Production].[ProductCostHistory] AS pch 
  ON p.ProductID = pch.ProductID
ORDER BY ps.Name, pch.StandardCost;

-- PERCENTILE_DISC - percentile based on smallest CUME_DIST value >= percentile
SELECT ps.Name SubCategoryName,
	   p.Name ProductName,
       pch.StandardCost,
	   PERCENTILE_DISC (0.3) 
	     WITHIN GROUP (ORDER BY pch.StandardCost)
		 OVER (PARTITION BY ps.ProductSubcategoryID) 
		  AS Percentile
FROM [Production].[Product] AS p
INNER JOIN [Production].[ProductSubcategory] AS ps 
  ON p.ProductSubcategoryID = ps.ProductSubcategoryID
INNER JOIN [Production].[ProductCostHistory] AS pch 
  ON p.ProductID = pch.ProductID
ORDER BY ps.Name, pch.StandardCost;