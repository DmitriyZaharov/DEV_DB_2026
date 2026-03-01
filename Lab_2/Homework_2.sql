--		Задание. Использование подзапросов

--    1. Выведите информацию о заказах клиента, который был зарегистрирован в БД последним.
--	Внешний запрос выбирает все столбцы из таблицы заказов только для этого конкретного custid
SELECT 
    custid, 
    orderid, 
    orderdate
FROM "Sales"."Orders"
WHERE custid = (
    SELECT MAX(custid)
    FROM "Sales"."Customers"
);

SELECT 
    o.custid, 
    o.orderid, 
    o.orderdate
FROM "Sales"."Orders" as o
-- JOIN:соединил таблицы Customers и Orders по общему полю custid
JOIN "Sales"."Customers" AS c ON c.custid = o.custid
WHERE o.custid = (
    SELECT MAX(custid)
    FROM "Sales"."Customers"
);

--    2. Выведите следующие данные по клиентам, которые сделали заказ в самую последнюю дату
SELECT 
    c.companyname,
    c.contactname,
    c.contacttitle, 
    c.address,
    c.city,
    c.region,
    c.postalcode
FROM "Sales"."Customers" AS c
-- JOIN:соединил таблицы Customers и Orders по общему полю custid
JOIN "Sales"."Orders" AS o ON c.custid = o.custid
WHERE o.orderdate = (
    SELECT MAX(orderdate) 
    FROM "Sales"."Orders"
);

--    3. Выведите список клиентов, которые не делали заказов
SELECT 
    c.custid, 
    c.companyname, 
    c.contactname
FROM "Sales"."Customers" AS c
WHERE NOT EXISTS (
    SELECT 1 
    FROM "Sales"."Orders" AS o 
    WHERE o.custid = c.custid
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

SELECT 
    o.custid, 
    o.orderid, 
    o.orderdate, 
    o.shipcountry 
FROM "Sales"."Orders" AS o
JOIN "Sales"."Customers" AS c ON o.custid = c.custid
WHERE c.country = 'Mexico';

--    5. Выведите самые дорогие продукты в каждой категории. Детали должны присутствовать!
SELECT 
	p.productid , 
	p.productname ,
	p.supplierid , 
	p.categoryid , 
	p.unitprice ,
	p.discontinued 
FROM "Production"."Products" AS p
WHERE p.unitprice = (
-- Подзапрос находит макс. цену для категории текущей строки внешнего запроса
    SELECT MAX(p2.unitprice)
    FROM "Production"."Products" AS p2
    WHERE p2.categoryid = p.categoryid
)
ORDER BY p.categoryid;









