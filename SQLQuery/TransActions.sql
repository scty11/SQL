--Transaction ACID property
--Atomic- everything succeeds of all fails
--Consistent - when complete everythinh must be in a safe state
--Isolated - no opertaion can impact the operation.
--Durable- when complete, changes are perment.

--Lost Updates- i change data, and sum1 else has changed it when i go to read it back.
--Dirty Read- I access data while sum1 else is in the process of changing it, so i get data that may not yet be committed.
--Non repeatable reads-- where a same query returns different data.
--Phantom read- i use a select and get 5 rows, i do it again and now there is 6 rows.


--using this with TransActionExamples.
BEGIN TRANSACTION; 
UPDATE Person.Person
SET LastName = 'Clark'
WHERE BusinessEntityID = 1;

commit transaction;
rollback;

