--using this with TransActions file.
--dirty read example
SELECT LastName
FROM Person.Person
Where BusinessEntityID = 1;

--prevents lost updates only. tho will change after
--the other transaction has completed.
BEGIN TRANSACTION;
Set TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
UPDATE Person.Person
SET LastName = 'Clark'
WHERE BusinessEntityID = 1;

commit transaction;

--the default.
--prevents dirty and lost update.
--locks modified data, but only locks
--select data for the duration of the SELECT
--does not prevent non repatable reads
BEGIN TRANSACTION;
Set TRANSACTION ISOLATION LEVEL READ COMMITTED;
UPDATE Person.Person
SET LastName = 'Clark'
WHERE BusinessEntityID = 1;

Select LastName
FROM Person.Person
WHERE BusinessEntityID = 1;

commit transaction;

--preventing non repeatable reads.
BEGIN TRANSACTION;
Set TRANSACTION ISOLATION LEVEL repeatable READ;
Select LastName
FROM Person.Person
WHERE BusinessEntityID = 1;

Select LastName
FROM Person.Person
WHERE BusinessEntityID = 1;

rollback;

--preventing phantom rows.
--prevent changes or adding clarkes
--can add others depending on index structure.
BEGIN TRANSACTION;
Set TRANSACTION ISOLATION LEVEL SERIALIZABLE;
Select LastName
FROM Person.Person
WHERE LastName = 'Clark';

Select LastName
FROM Person.Person
WHERE LastName = 'Clark';
rollback;

