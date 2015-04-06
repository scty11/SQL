-- Demo: String Functions

USE AdventureWorks2012;

-- ASCII code value of the leftmost character 
SELECT ASCII('T') AS ASCII_T_int;
SELECT ASCII('t') AS ASCII_t_int;

-- int ASCII code to a character
SELECT CHAR(84) AS ASCII_T_char;
SELECT CHAR(116) AS ASCII_t_char;

-- integer value given Unicode character
SELECT UNICODE(N'Њ') AS Unicode_Cyrillic_int;

-- Output nchar given integer for Unicode character
SELECT NCHAR(1034) AS Unicode_Cyrillic_nchar;


-- LEFT ( character_expression , integer_expression )
-- RIGHT ( character_expression , integer_expression )
--number os characters to ne returned from the specified direction.
SELECT LEFT(p.LastName, 1) +
       '####' +
	   RIGHT(p.LastName, 2) AS Mask
FROM [Person].[Person] AS p;

-- FORMAT ( value, format [, culture ] )
-- See http://bit.ly/MEAOeM for type formats to choose from
SELECT pch.ProductID,
       pch.StartDate,
	   FORMAT(pch.StartDate, 'MMMM dd, yyyy') AS StartDateFmt
FROM [Production].[ProductCostHistory] AS pch
WHERE pch.EndDate IS NOT NULL;

-- LEN vs. DATALENGTH
-- Name column is nvarchar(50) data type
SELECT p.Name,
       LEN(p.Name) AS Name_LEN,
	   DATALENGTH(p.Name) AS Name_DATALENGT--byte storage.
FROM [Production].[Product] AS p
ORDER BY p.Name;

SELECT p.Name,
       LOWER(p.Name) AS LOWER_Name,
	   UPPER(p.Name) AS UPPER_Name
FROM [Production].[Product] AS p
ORDER BY p.Name;

-- LTRIM / RTRIM
DECLARE @ExampleText nvarchar(100) = 
   '  I have leading and trailing spaces   ';

SELECT RTRIM(LTRIM(@ExampleText)) AS ExampleText;

-- CHARINDEX ( expression1, expression2 [ , start_location ] ) 
SELECT pd.ProductDescriptionID, 
	   CHARINDEX('alloy', pd.[Description]) 
	      AS StartLocation,
       pd.[Description]
FROM [Production].[ProductDescription] AS pd
WHERE CHARINDEX('alloy', pd.[Description]) > 0;--0 value means we have no match.


SELECT pd.ProductDescriptionID, 
	   CHARINDEX('%alloy%', pd.[Description]) 
	      AS StartLocation,
       pd.[Description]
FROM [Production].[ProductDescription] AS pd
WHERE CHARINDEX('%alloy%', pd.[Description]) > 0;

-- PATINDEX, works with wild cards
SELECT pd.ProductDescriptionID, 
	   PATINDEX('%all%', pd.[Description]) 
	      AS StartLocation,
       pd.[Description]
FROM [Production].[ProductDescription] AS pd
WHERE PATINDEX('%all%', pd.[Description]) > 0 AND
     CHARINDEX('alloy', pd.[Description]) = 0;

-- REPLACE ( string_expression , string_pattern , string_replacement )
SELECT pd.ProductDescriptionID, 
       REPLACE(pd.[Description], 'alloy', 'mixture') ModifiedDescription
FROM [Production].[ProductDescription] AS pd
WHERE PATINDEX('%alloy%', pd.[Description]) > 0;

-- STUFF (character_expression, start , length,character_expression)
DECLARE @PhoneCallNotes nvarchar(max) =
  'The AdventureWorks client had an issue with the recent shipment.';

DECLARE @StartLocation int = 
   PATINDEX('%AdventureWorks%', @PhoneCallNotes);

SELECT STUFF(@PhoneCallNotes, @StartLocation, 14, '"Anonymous"');

-- SUBSTRING(character_expression, position, length)
SELECT p.Name,
       p.ProductNumber,
	   SUBSTRING(p.ProductNumber, 4, 21) AS EndCode
FROM [Production].[Product] AS p;
