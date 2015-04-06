-- Demo: Conversion Functions

USE AdventureWorks2012;

-- PARSE ( string_value AS data_type [ USING culture ] )
SELECT PARSE('12/31/2012' AS date) AS YearEndDateUS;

-- Error converting string value
SELECT PARSE('31/12/2012' AS date USING 'en-US') AS YearEndDate;

-- This works...
SELECT PARSE('31/12/2012' AS date USING 'en-GB') AS YearEndDateUK;

-- TRY_PARSE ( string_value AS data_type [ USING culture ] )
--     from string to date/time and number types

-- Returns a date
SELECT TRY_PARSE('12/31/2012' AS date) AS YearEndDateUS;

-- Returns NULL
SELECT TRY_PARSE('31/12/2012' AS date USING 'en-US') AS YearEndDate;

-- Returns Date
SELECT TRY_PARSE('31/12/2012' AS date USING 'en-GB') AS YearEndDateUK;

--  CAST ( expression AS data_type [ ( length ) ] )

SELECT CAST ('12/31/2012' AS date) AS YearEndDate;

SELECT CAST (GETDATE() AS time) AS YearEndDate;


-- Error
SELECT CAST ('13/31/2012' AS date) AS YearEndDate;

-- TRY_CAST ( expression AS data_type [ ( length ) ] )
SELECT TRY_CAST ('13/31/2012'AS date) AS YearEndDate;

-- CONVERT ( data_type [ ( length ) ] , expression [ , style ] )
SELECT CONVERT (date, '12/31/2012', 101) AS YearEndDateUS;

SELECT CONVERT (date, '12/5/2012',103) AS UkDates;

-- Fails
SELECT CONVERT (date, '13/31/2012', 101) AS YearEndDateUS;

-- TRY_CONVERT ( data_type [ ( length ) ], expression [, style ] )
SELECT TRY_CONVERT (date, '13/31/2012', 101) AS YearEndDateUS;



-- ISDATE
DECLARE @Name nvarchar(50) = 'XY14822';
DECLARE @DiscontinuedDate datetime = '12/4/2012';

SELECT ISDATE(@Name) AS NameISDATE,
       ISDATE(@DiscontinuedDate) AS DiscontinuedDateISDATE;
GO

-- ISNUMERIC
DECLARE @Name nvarchar(50) = 'XY14822';
DECLARE @DiscontinuedDate datetime = '12/4/2012';
DECLARE @DaysToManufacture int = 100;

SELECT ISNUMERIC(@Name) AS NameISNUMERIC,
       ISNUMERIC(@DiscontinuedDate) AS DiscontinuedDateISNUMERIC,
	   ISNUMERIC(@DaysToManufacture) AS DaysToManufactureISNUMERIC;


SELECT 'SYSDATETIME' AS STFunction, SYSDATETIME();

SELECT 'SYSDATETIMEOFFSET' AS STFunction, SYSDATETIMEOFFSET();

SELECT 'SYSUTCDATETIME' AS STFunction, SYSUTCDATETIME();

SELECT 'CURRENT_TIMESTAMP' AS STFunction, CURRENT_TIMESTAMP;

SELECT 'GETUTCDATE' AS STFunction, GETUTCDATE();

SELECT 'GETDATE' AS STFunction, GETDATE();


SELECT pch.ProductID,
       pch.StartDate,
	   MONTH(pch.StartDate) AS StartMonth,
	   DAY(pch.StartDate) AS StartDay,
	   YEAR(pch.StartDate) AS StartYear
FROM [Production].[ProductCostHistory] AS pch
WHERE pch.EndDate IS NOT NULL;

-- DATEPART ( datepart , date )
SELECT pch.ProductID,
       pch.StartDate,
	   DATEPART(MONTH, pch.StartDate) AS StartMonth,
	   DATEPART(DAY, pch.StartDate) AS StartDay,
	   DATEPART(YEAR, pch.StartDate) AS StartYear
FROM [Production].[ProductCostHistory] AS pch
WHERE pch.EndDate IS NOT NULL;

-- DATENAME ( datepart , date )
SELECT pch.ProductID,
       pch.StartDate,
	   DATENAME(m, pch.StartDate) AS StartMonth,
	   DATENAME(DAY, pch.StartDate) AS StartDay,
	   DATENAME(WEEKDAY, pch.StartDate) AS [WeekDay],
	   DATENAME(yy, pch.StartDate) AS StartYear
FROM [Production].[ProductCostHistory] AS pch
WHERE pch.EndDate IS NOT NULL;

-- DATEFROMPARTS ( year, month, day )
-- DATETIMEFROMPARTS ( year, month, day, hour, minute, seconds, milliseconds )
-- DATETIME2FROMPARTS ( year, month, day, hour, minute, seconds, fractions, precision )

SELECT DATEFROMPARTS (2012, 08, 31) AS 'MyDate';

-- All arguments required!
SELECT DATETIMEFROMPARTS (2012, 08) AS 'MyDate';

-- Null returns null
SELECT DATEFROMPARTS (2012, 08, NULL) AS 'MyDate';

--TIMEFROMPARTS ( hour, minute, seconds, fractions, precision )
SELECT TIMEFROMPARTS(4,12,0,0,0);

-- DATEDIFF ( datepart , startdate , enddate )

-- Years
SELECT DATEDIFF (yy,'1/1/2007', '1/1/2008') AS 'YearDiff';

-- Days
SELECT DATEDIFF (dd,'1/1/2007', '1/1/2008') AS 'DayDiff';

-- Months
SELECT pch.ProductID,
       pch.StartDate,
	   pch.EndDate,
	   DATEDIFF(mm, pch.StartDate, pch.EndDate) AS MonthsStartEnd
FROM [Production].[ProductCostHistory] AS pch
WHERE pch.EndDate IS NOT NULL;


-- DATEADD (datepart , number , date )
SELECT pch.ProductID,
	   pch.StartDate,
	   DATEADD (yy, 1, pch.StartDate) AS PriceEvaluationDate
FROM [Production].[ProductCostHistory] AS pch;

-- EOMONTH ( start_date [, month_to_add ] )
SELECT pch.ProductID,
	   pch.StartDate,
	   EOMONTH (pch.StartDate) AccountingPeriod
FROM [Production].[ProductCostHistory] AS pch;

SELECT pch.ProductID,
	   pch.StartDate,
	   EOMONTH (pch.StartDate, 1) AccountingPeriod
FROM [Production].[ProductCostHistory] AS pch;

-- SWITCHOFFSET ( DATETIMEOFFSET, time_zone ) 
SELECT pch.ProductID,
	   pch.StartDate,
	   CAST(pch.StartDate as datetimeoffset) 
	      AS StartDateUTC,
	   SWITCHOFFSET(CAST(pch.StartDate as datetimeoffset), '-06:00')
	      AS StartDateUTC_CST
FROM [Production].[ProductCostHistory] AS pch;

-- TODATETIMEOFFSET ( expression , time_zone )
SELECT pch.ProductID,
	   pch.StartDate,
	   TODATETIMEOFFSET(pch.StartDate, '-06:00')
	      AS StartDateUTC_CST
FROM [Production].[ProductCostHistory] AS pch;

-- FORMAT ( value, format [, culture ] )
-- See http://bit.ly/MEAOeM for type formats to choose from
SELECT pch.ProductID,
       pch.StartDate,
	   FORMAT(pch.StartDate, 'MMMM dd, yyyy') AS StartDateFmt
FROM [Production].[ProductCostHistory] AS pch
WHERE pch.EndDate IS NOT NULL;