CREATE TABLE dbo.[Target]
(
	EmployeeID int,
	EmployeeName varchar(20),
	CONSTRAINT Target_PK PRIMARY KEY (EmployeeID)
);

CREATE TABLE dbo.[Source]
(
	EmployeeID int,
	EmployeeName varchar(20),
	CONSTRAINT Source_PK PRIMARY KEY (EmployeeID)
);

INSERT INTO dbo.[Target]
VALUES (100, 'Karin')
	  ,(101, 'Donna')
	  ,(102, 'Christopher');

INSERT INTO dbo.[Source]
VALUES (102, 'Source Change')
	  ,(103, 'Scott')
	  ,(104, 'Lee');


MERGE dbo.[Target] AS T --target table. Where the merge data will be
USING dbo.Source AS S
	ON T.EmployeeID = S.EmployeeID --The rows that will match.
WHEN MATCHED THEN --row exists in target.
	UPDATE SET T.EmployeeName = S.EmployeeName
WHEN NOT MATCHED THEN --row does not exist.
	INSERT VALUES (S.EmployeeID, S.EmployeeName)
OUTPUT $action AS 'action'
	   , INSERTED.EmployeeID AS 'NewEmployeeID'
	   , INSERTED.EmployeeName AS 'NewEmployeeName'
	   , DELETED.EmployeeId AS 'OldID'
	   , DELETED.EmployeeName AS 'OldName';
