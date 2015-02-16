CREATE DATABASE DemoDatabase;
USE DemoDatabase;
GO

CREATE TABLE dbo.Customers
(
	CustomerId int NOT NULL IDENTITY(1,1), --to add to an existing database, need to drop column then readd the column
	Name varchar(100) NOT NULL,
	EmailAddress varchar(100) CONSTRAINT AK_Customers_EmailAddress UNIQUE --ak = alternate key
);

CREATE TABLE Orders
(
	OrderID int NOT NULL IDENTITY(1,1),
	OrderDate date NOT NULL CONSTRAINT DF_0rderDate_CurrentDate DEFAULT GETDATE(),
	ShipDate date NULL,
	CustomerId int NOT NULL,
	 
	CONStraint CK_Orders_ShipDateIsNullOrAfterOrderDate 
		CHECK (ShipDate IS NULL OR ShipDate >= OrderDate),

	CONSTRAINT  PK_Orders_OrderID PRIMARY KEY (OrderID),

	CONSTRAINT FK_Orders_Customers_CustomerID 
		FOREIGN KEY (CustomerID) REFERENCES dbo.Customers (CustomerID)-- ON DELETE/UPDATE {NO ACTION | NULL | DEFAULT | CASCADE}
);

ALTER TABLE Orders
ADD CustomerId int NOT NULL;
ALTER TABLE Orders
DROP COLUMN CustomerId;
ALTER TABLE Orders
ALTER COLUMN OrderDate datetime NOT NULL;

--default constraint
ALTER TABLE dbo.Orders
ADD CONSTRAINT DF_0rderDate_CurrentDate DEFAULT GETDATE() FOR OrderDate;


--check constraint
ALTER TABLE dbo.Orders WITH CHECK
ADD CONSTRAINT CK_Orders_ShipDateIsNullOrAfterOrderDate 
	 CHECK (ShipDate IS NULL OR ShipDate >= OrderDate); 

--unique constraint
ALTER TABLE dbo.Customers 
ADD CONSTRAINT AK_Customers_EmailAddress UNIQUE  (EmailAddress);

--primary key
ALTER TABLE dbo.Customers
ADD CONSTRAINT PK_Customers_CustomerID PRIMARY KEY (CustomerID);

ALTER TABLE dbo.Orders
ADD CONSTRAINT PK_Orders_OrderID PRIMARY KEY (OrderID);

--Foregin key constraint.
ALTER TABLE dbo.Orders
ADD CONSTRAINT FK_Orders_Customers_CustomerID  
	Foreign KEY(CustomerID) REFERENCES dbo.CustomerS (CustomerID);




	CREATE TABLE dbo.TriggerCustomers
(
	CustomerId int NOT NULL IDENTITY(1,1), --to add to an existing database, need to drop column then readd the column
	Name varchar(100) NOT NULL,
	IsActive bit NOT NULL CONSTRAINT DF_TriggerCustomers_IsActive DEFAULT (1), --1 true. 0 false?

	CONSTRAINT  PK_TriggerCustomers_CustomerID PRIMARY KEY (CustomerID)
);

CREATE TABLE dbo.TriggerArchiveCustomers
(
	CustomerId int NOT NULL ,
	OldName varchar(100) NOT NULL,
	NewName varchar(100) NOT NULL,

);

--CREATE TRIGGER I_D_TriggerCustomers_MarkCustomerAsInactive
--ON dbo.TriggerCustomers
--INSTEAD OF DELETE
--AS
--BEGIN 
--	SET NOCOUNT ON;--supress the rows effected, otherwise we will see this twice

--	UPDATE dbo.TriggerCustomers
--	SET IsActive = 0
--	FROM dbo.TriggerCustomers tc 
--		INNER JOIN deleted d ON tc.CustomerId = d.CustomerId;--instead of deleteing the customer we set to inactive.
--END;

INSERT INTO TriggerCustomers(Name)
VALUES ('Scott');

SELECT *
FROM TriggerCustomers;

DELETE FROM TriggerCustomers
WHERE CustomerId = 1;

--CREATE TRIGGER A_U_TriggerCustomers_ArchiveNames
--ON dbo.TriggerCustomers
--AFTER UPDATE 
--AS 
--BEGIN
--	SET NOCOUNT ON;--supress the rows effected, otherwise we will see this twice

--	INSERT dbo.TriggerArchiveCustomers(CustomerId, OldName, NewName)
--	SELECT i.CustomerId,
--		   d.Name, 
--		   i.Name
--	FROM deleted d 
--		INNER JOIN inserted i ON d.CustomerId = i.CustomerId
--								AND d.Name <> i.Name;--ensure name has changed.
--END;

UPDATE dbo.TriggerCustomers
SET Name = 'Lee'
WHERE CustomerId = 1;

SELECT *
FROM TriggerArchiveCustomers;
