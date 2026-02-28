--		Задание. Использование подзапросов
--
--    1. Выведите информацию о заказах клиента, который был зарегистрирован в БД последним.
--	Внешний запрос выбирает все столбцы из таблицы заказов только для этого конкретного custid
SELECT 
    custid, 
    orderid, 
    orderdate
FROM "Sales"."Orders"
-- Сначала выполняется часть в скобках SELECT MAX(custid) 
-- она находит самый большой идентификатор клиента в таблице заказчиков:
WHERE custid = (
    SELECT MAX(custid)
    FROM "Sales"."Customers"
);

--    2. Выведите следующие данные по клиентам, которые сделали заказ в самую последнюю дату
--
select
	companyname,
	contactname,
	contacttitle, 
	address,
	city,
	region,
	postalcode 
FROM "Sales"."Customers"
WHERE orderdate = (
    SELECT MAX(orderdate)-1
    FROM "Sales"."Customers"
);

--    3. Выведите список клиентов, которые не делали заказов
SELECT 
	custid, 
	companyname, 
	contactname
FROM "Sales"."Customers"
WHERE custid NOT IN (
    SELECT DISTINCT custid 
    FROM "Sales"."Orders"
    WHERE custid IS NOT NULL
);

--    4. Выведите список заказов тех клиентов, которые проживают в Mexico
SELECT 
	custid, 
	orderid, 
	orderdate, 
	shipcountry 
FROM "Sales"."Orders"
WHERE custid IN (
    SELECT custid
    FROM "Sales"."Customers"
    WHERE country = 'Mexico'
);

--    5. Выведите самые дорогие продукты в каждой категории. Детали должны присутствовать!
SELECT 
	P1.productid , 
	P1.productname ,
	P1.supplierid , 
	P1.categoryid , 
	P1.unitprice ,
	P1.discontinued 
FROM "Production"."Products" AS P1
WHERE unitprice = (
    SELECT MAX(unitprice)
    FROM "Production"."Products" AS P2
    WHERE P2.categoryid = P1.categoryid
);









