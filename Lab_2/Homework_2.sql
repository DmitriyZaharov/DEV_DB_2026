--Задание. Использование подзапросов
--
--    1. Выведите информацию о заказах клиента, который был зарегистрирован в БД последним.
SELECT 
    orderid, 
    custid, 
    empid, 
    orderdate, 
    requireddate, 
    shippeddate
FROM "Sales"."Orders"
-- Сначала выполняется часть в скобках SELECT MAX(custid) 
-- FROM Sales.Customers. Она находит самый большой идентификатор 
-- клиента в таблице заказчиков.
WHERE custid = (
    SELECT MAX(custid) 
    FROM "Sales"."Customers"
);

--    2. Выведите следующие данные по клиентам, которые сделали заказ в самую последнюю дату
--
SELECT DISTINCT
    c.customer_id,
    c.company_name,
    c.contact_name,
    c.contact_title,
    c.country,
    c.city,
    c.phone,
    o.order_date
FROM
    "Sales"."Customers" c
    INNER JOIN orders o ON c.customer_id = o.customer_id
WHERE
    o.order_date = (
        SELECT MAX(order_date)
        FROM orders
    )
ORDER BY
    c.customer_id;
--    3. Выведите список клиентов, которые не делали заказов
--
--    4. Выведите список заказов тех клиентов, которые проживают в Mexico
--
--    5. Выведите самые дорогие продукты в каждой категории. Детали должны присутствовать!

