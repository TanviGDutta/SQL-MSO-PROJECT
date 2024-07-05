SELECT TOP 1 * FROM CUSTOMER
SELECT TOP 1 * FROM ORDERSNEW
SELECT TOP 1 * FROM PRODUCT
SELECT TOP 1 * FROM ORDERITEM
SELECT TOP 1 * FROM SUPPLIER

--List all Customers
Select * from Customer

--2. List the first name, last name, and city of all customers
select FirstName,LastName,City from Customer

--3. List the customers in Sweden. Remember it is "Sweden" and NOT "sweden" because filtering
--value is case sensitive in Redshift.
select * from Customer
where Country='Sweden'

--4. Create a copy of Supplier table. Update the city to Sydney for supplier starting with letter P.
SELECT * INTO SUPPLIER_COPY2 FROM Supplier
UPDATE SUPPLIER_COPY2
 Set  City='Sydney' where ContactName like 'P%'

 
 --5.Create a copy of Products table and Delete all products with unit price higher than $50
 select * into product_copy_1 from Product
 delete from product_copy_1 where cast (UnitPrice as float)>50
 
 
 --6.List the number of customers in each country
 select count(id) as CUST_CNT,Country from CUSTOMER
 group by Country

 --7.List the number of customers in each country sorted high to low
 SELECT COUNT(ID) AS CUST_CNT,Country FROM CUSTOMER
 GROUP BY Country
 ORDER BY COUNT(ID) DESC
 
 --8.List the total amount for items ordered by each customer
 select a.id,sum(cast(b.TotalAmount as float)) as total_amt from CUSTOMER as a
 left join orders as b
 on a.id=b.Id
 group by a.Id

 --9. List the number of customers in each country. Only include countries with more than 10
 --customers.
 select count(id) as cnt_,Country from CUSTOMER
 group by Country
 having count(id)>10

 --10. List the number of customers in each country, except the USA, sorted high to low. Only
--include countries with 9 or more customers
`SELECT COUNT(ID) AS CUST_CNT,Country FROM CUSTOMER
  WHERE Country !='USA'
  GROUP BY COUNTRY
  HAVING COUNT(ID)>=9
  ORDER BY CUST_CNT DESC

--11.List all customers whose first name or last name contains "ill".
SELECT * FROM CUSTOMER
WHERE FirstName like'%ill%' or  LastName like '%ill%'

--12. List all customers whose average of their total order amount is between $1000 and
--$1200.Limit your output to 5 results.

select TOP 5 A.ID,AVG(CAST(B.TotalAmount AS FLOAT)) AS AVG_AMT from CUSTOMER AS A
left join Orders as B
ON A.ID=B.ID
GROUP BY A.ID
HAVING AVG(CAST(B.TotalAmount AS FLOAT)) BETWEEN 1000 AND 1200

--13.List all suppliers in the 'USA', 'Japan', and 'Germany', ordered by country from A-Z, and then
--by company name in reverse order.

SELECT CompanyName,ContactName,Country FROM Supplier 
WHERE Country IN ('USA','Japan','Germany')
order by country asc,CompanyName desc
select * from Orders
--14. Show all orders, sorted by total amount (the largest amount first), within each year.

select * from (
select *,year(OrderDate) as Year_,DENSE_RANK() over (partition by year(OrderDate) order by TotalAmount Desc) as Rank_  from Orders
) as T
order by T.Year_ ASC,T.Rank_


SELECT *,YEAR(OrderDate) as Year_,DENSE_RANK() over(Partition by YEAR(OrderDate) order by TotalAmount desc) as Rank_  FROM Orders

--15. Products with UnitPrice greater than 50 are not selling despite promotions. You are asked to
--discontinue products over $25. Write a query to relfelct this. Do this in the copy of the Product
--table. DO NOT perform the update operation in the Product table.
DELETE FROM  product_copy_1
WHERE CAST(UnitPrice AS FLOAT) >25

SELECT * FROM product_copy_1

--List top 10 most expensive products
SELECT TOP 10 * FROM Product
ORDER BY UnitPrice DESC

--17. Get all but the 10 most expensive products sorted by price
select * from Product

except 

SELECT TOP 10 * FROM Product
ORDER BY UnitPrice DESC 


OR

Select* from Product
order by UnitPrice Desc
Offset 10 rows



SELECT  * FROM
(
SELECT *,RANK() OVER(order by UnitPrice desc) as Rank_ FROM PRODUCT 
) AS T
WHERE Rank_>10

--18.Get the 10th to 15th most expensive products sorted by price
select * from (
      SELECT *, RANK() OVER (ORDER BY UnitPrice Desc) as Rank_ FROM Product
      ) as X
WHERE Rank_ Between 10 AND 15

OR

SELECT * FROM Product
ORDER BY UnitPrice Desc
OFFSET 9 ROWS
FETCH NEXT 6 ROWS ONLY

--19.Write a query to get the number of supplier countries. Do not count duplicate values
SELECT count(DISTINCT(Country)) as No_countries FROM Supplier

--20. Find the total sales cost in each month of the year 2013

select SUM(cast(TotalAmount as float)) as Total_Sales,Month(OrderDate) as Month_ from Orders
where YEAR(OrderDate) = 2013
group by Month(OrderDate)
order by Month(OrderDate) asc

--21. List all products with names that start with 'Ca'.
select * from Product
where ProductName like 'Ca%'

--22.List all products that start with 'Cha' or 'Chan' and have one more character
select * from product 
where ProductName like 'Cha_' or ProductName like 'Chan_'

--23. Your manager notices there are some suppliers without fax numbers. He seeks your help to
--get a list of suppliers with remark as "No fax number" for suppliers who do not have fax
--numbers (fax numbers might be null or blank).Also, Fax number should be displayed for
--customer with fax numbers.

select * from Supplier
update Supplier 
set Fax='No_Fax Number' where Fax='NO FAX NUMBER' or Fax=' '

--OR

SELECT *,
CASE
WHEN Fax='No_Fax Number' or Fax=' '
Then 'NOFAXNUMBER'
ELSE Fax
End as FAX_
from Supplier
 

 
 --24. List all orders, their orderDates with product names, quantities, and prices.
 select A.OrderDate,c.ProductName,b.Quantity,b.UnitPrice  from Orders as A
 INNER join OrderItem as B
 on a.Id=b.Id
 INNER JOIN Product as C
 ON A.Id=C.Id


 --25.List all customers who have not placed any Orders.
 SELECT * FROM CUSTOMER AS A
 WHERE A.Id NOT IN (SELECT CustomerId FROM Orders)

 --OR

 SELECT A.Id FROM CUSTOMER AS A
 EXCEPT
 SELECT B.CustomerId FROM Orders AS B

--26. List suppliers that have no customers in their country, and customers that have no suppliers
--in their country, and customers and suppliers that are from the same country.



 SELECT * FROM CUSTOMER AS A
 RIGHT JOIN Supplier AS B
 ON A.Country=B.Country  AND A.City=B.City
 WHERE A.Id IS Null
 union all
 SELECT * FROM CUSTOMER AS A
 left JOIN Supplier AS B
 ON A.Country=B.Country  AND A.City=B.City
 WHERE b.Id IS Null
 union all
 SELECT * FROM CUSTOMER AS A
 Inner JOIN Supplier AS B
 ON A.Country=B.Country  AND A.City=B.City

 --27. Match customers that are from the same city and country. That is you are asked to give a list
--of customers that are from same country and city. Display firstname, lastname, city and
--coutntry of such customers.
  select A.FirstName,A.LastName,B.FirstName,B.LastName,A.Country,A.City from Customer as A
  INNER JOIN CUSTOMER AS B
  ON A.Country=B.Country AND A.City=B.City
  WHERE A.Id !=B.Id

--28. List all Suppliers and Customers. Give a Label in a separate column as 'Suppliers' if he is a
--supplier and 'Customer' if he is a customer accordingly. Also, do not display firstname and
--lastname as twoi fields; Display Full name of customer or supplier.

 SELECT *,
 CASE WHEN T.Concat_Name IN (select Concat(FirstName,' ',LastName) from CUSTOMER)
 then 'Customer'
 else 'Suppliers'
 end as Type_
 from
 (SELECT  CONCAT(A.FirstName,' ',A.LastName) as Concat_Name,A.City,A.Country,A.Phone from  CUSTOMER AS A
 UNION 
 SELECT B.ContactName,B.City,B.Country,B.Phone FROM Supplier as B) as T
 


--29. Create a copy of orders table. In this copy table, now add a column city of type varchar (40).
--Update this city column using the city info in customers table.
SELECT * INTO ORDERS_COPY12 FROM ORDERS
SELECT * FROM  ORDERS_COPY12
alter table orders_copy12 
add city varchar(40)


select * into order_copy11 
   from
   (select a.id,a.orderdate,a.ordernumber,a.customerid,a.totalAmount,b.city from orders_copy12 as a
    left join customer as b
    on a.id=b.id
	) as T



--30. Suppose you would like to see the last OrderID and the OrderDate for this last order that
--was shipped to 'Paris'. Along with that information, say you would also like to see the
--OrderDate for the last order shipped regardless of the Shipping City. In addition to this, you
--would also like to calculate the difference in days between these two OrderDates that you get.
--Write a single query which performs this.
--(Hint: make use of max (columnname) function to get the last order date and the output is a
--single row output.)
SELECT T.MAX_ID,MAX_Paris_date,max_date,datediff(day,t.max_paris_date,t.max_date) as day_diff FROM 

(
select MAX(a.id) AS MAX_ID,max(a.orderdate) as max_Paris_date,(select max(orderdate) from ordersnew) as max_date from orders as a
left join customer as b
on a.customerid=b.id
where b.city='paris'
)  as T

--31. Find those customer countries who do not have suppliers. This might help you provide
--better delivery time to customers by adding suppliers to these countires. Use SubQueries.


select * from customer AS A
left join supplier as B
ON A.CITY=B.CITY AND A.COUNTRY=B.COUNTRY
WHERE B.ID IS NULL

OR

SELECT * FROM CUSTOMER AS A
WHERE CONCAT(A.COUNTRY,A.CITY)  NOT IN (SELECT CONCAT(B.COUNTRY,B.CITY) FROM SUPPLIER AS B)




















 


 








































 SELECT TOP 1 * FROM Supplier











