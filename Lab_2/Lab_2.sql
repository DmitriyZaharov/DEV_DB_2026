--Лабораторная работа 2
--
--Задание 1. Написание запросов с фильтрацией
--    1. Выведите заказчиков с кодом (id) 30
SELECT *
FROM "Sales"."Customers"
WHERE custid = 30;

--    2. Выведите все заказы, сделанные (оформленные) после 10 апреля 2008 года
SELECT *
FROM "Sales"."Orders"
WHERE orderdate > '2008-04-10'
ORDER BY orderdate DESC;

--    3. Выведите название и стоимость продуктов, при условии, что стоимость 
--	  находится в диапазоне от 100 до 250.
SELECT productname, unitprice
FROM "Production"."Products"
WHERE unitprice >= 100::money AND unitprice <= 250::money
--WHERE unitprice BETWEEN 100::money AND 250::money
ORDER BY unitprice;

--    4. Выведите всех заказчиков, проживающих в Париже, Берлине или Мадриде.
SELECT *
FROM "Sales"."Customers"
WHERE city IN ('Paris', 'Berlin', 'Madrid')
ORDER BY city DESC;

--    5. Выведите всех сотрудников, для которых не определен регион проживания
SELECT *
FROM "HR"."Employees"
WHERE region IS NULL OR region = '';

--    6. Выведите заказчиков с именами кроме “Linda”, “Robert”, “Ann”
SELECT *
FROM "Sales"."Customers"
-- WHERE contactname NOT IN ('Linda', 'Robert', 'Ann');
WHERE contactname NOT LIKE '%, Ann' -- исключит любого Анн
  AND contactname NOT LIKE '%, Linda'    -- исключит любую Линду
  AND contactname NOT LIKE '%, Robert';  -- исключит любого Роберта
  
--		7. Выведите заказчиков, чья фамилия начинается либо на букву “B” либо “R” либо “N”. 
--	Фильтрация должна производится на исходных данных столбца (не на вычисляемом выражении)
SELECT *
FROM "Sales"."Customers"
WHERE contactname LIKE 'B%' 
   OR contactname LIKE 'R%' 
   OR contactname LIKE 'N%'
ORDER BY contactname ASC;
  
--		8. Выведите информацию о заказчиках, сформировав два вычисляемых столбца: 
--  Фамилия заказчика и Имя заказчика.
--  В результирующую выборку должны попасть только те заказчики, чье имя начинается либо 
--  на букву "P" либо на букву "M", а фамилия при этом начинается либо на  “S”  либо на  “K”.
--	Фильтрация должна производится на исходных данных столбца (не на вычисляемом выражении)
SELECT 
    contactname,
    split_part(contactname, ', ', 1) AS last_name,
    split_part(contactname, ', ', 2) AS first_name
FROM "Sales"."Customers"
WHERE (contactname LIKE 'S%' OR contactname LIKE 'K%')
  AND (contactname LIKE '%, P%' OR contactname LIKE '%, M%');

--		Задание 2. Написание запросов к нескольким таблицам
--  1. Сформируйте выборку следующего вида: ФИО сотрудника, Номер Заказа, Дата Заказа.
--	Отсортируйте выборку по дате (от самых ранних к самым поздним заказам)
SELECT 
    e.firstname || ' ' || e.lastname AS "ФИО сотрудника", 
    o.orderid AS "Номер Заказа", 
    o.orderdate AS "Дата Заказа"
FROM "HR"."Employees" AS e
JOIN "Sales"."Orders" AS o ON e.empid = o.empid
ORDER BY o.orderdate ASC;

--    2. Напишите запрос, который выбирает информацию о заказах и их деталях:[orderid], 
--	[custid],[empid],[orderdate] ,[productid],[unitprice],[qty],[discount].
--	Сформируйте в этом запросе вычисляемый столбец (LineTotal), который рассчитывает 
--	стоимость каждой позиции в заказе с учетом скидки
SELECT 
    o.orderid, 
    o.custid, 
    o.empid, 
    o.orderdate, 
    od.productid, 
    od.unitprice, 
    od.qty, 
    od.discount,
    -- Вычисляемый столбец с учетом скидки
    (od.unitprice * od.qty * (1 - od.discount)) AS "LineTotal"
FROM "Sales"."Orders" AS o
JOIN "Sales"."OrderDetails" AS od ON o.orderid = od.orderid
--ORDER BY o.orderid;
ORDER BY "LineTotal" DESC; -- Сортировка от больших сумм к меньшим

--    3. Напишите запрос, возвращающий выборку следующего вида:   Номер заказа, 
--   Название заказчика, Фамилия сотрудника (компании заказчика), Дата заказа, 
--	 Название транспортной компании. В запрос должны войти только те записи, 
--   которые соответствуют условию:  
--   Заказчики и Сотрудники (Emploees) проживают в одном городе
SELECT 
    o.orderid AS "Номер заказа", 
    c.companyname AS "Название заказчика", 
    c.contactname AS "Фамилия сотрудника", 
    o.orderdate AS "Дата заказа", 
    sh.companyname AS "Название транспортной компании"
FROM "Sales"."Orders" AS o
JOIN "Sales"."Customers" AS c ON o.custid = c.custid -- название компании перев.
JOIN "HR"."Employees" AS e ON o.empid = e.empid -- ФИО сотрудников
JOIN "Sales"."Shippers" AS sh ON o.shipperid = sh.shipperid --имя перевозчика
WHERE c.city = e.city-- Условие: проживание в одном городе
ORDER BY o.orderid;

--	Задание 3. Использование операторов наборов записей (UNION, EXCEPT, INTERSECT)
-- 	1. Напишите запрос, возвращающий набор уникальных записей из 
-- 	таблиц Employees и Customers. Результирующая таблица должна содержать 3 
-- 	столбца: country, region, city. 
SELECT country, region, city
FROM "HR"."Employees"

UNION

SELECT country, region, city
FROM "Sales"."Customers";

--    2. Напишите запрос, возвращающий набор уникальных записей из таблиц 
--	Employees (адреса сотрудников - country, region, city), исключив из этого 
--	списка записи из таблицы Customers (адреса Клиентов - country, region, city). 
--	Результирующая таблица должна содержать 3 столбца: country, region, city. 
SELECT country, region, city
FROM "HR"."Employees"

EXCEPT

SELECT country, region, city
FROM "Sales"."Customers";

--	Задание 4. Запросы с группировкой
--  1. Выведите таблицу из трех столбцов: максимальная, минимальная 
--	и средняя стоимость продуктов.
SELECT 
    MAX(unitprice) AS "Максимальная стоимость",
    MIN(unitprice) AS "Минимальная стоимость",
    -- Приводим к numeric для вычисления среднего и округляем
    ROUND(AVG(unitprice::numeric), 2) AS "Средняя стоимость"
FROM "Production"."Products";
 
--  2. Выведите таблицу из 2-х столбцов: номер категории и 
--	количество продуктов в каждой категории.
SELECT 
    categoryid AS "Номер категории", 
    -- COUNT(*): подсчитывает количество строк (продуктов) в каждой группе.
    COUNT(*) AS "Количество продуктов"
FROM "Production"."Products"
GROUP BY categoryid
ORDER BY categoryid;

--    3. Выведите данные о количестве заказов, оформленных каждым сотрудником
SELECT 
    empid AS "ID сотрудника", 
    COUNT(orderid) AS "Количество заказов"
FROM "Sales"."Orders"
GROUP BY empid
ORDER BY "Количество заказов" DESC;

--    4. Выберите 5 самых выгодных заказчиков, с точки зрения суммарной 
--	стоимости их заказов:
--	Соединяем клиентов с их заказами, а заказы — с их содержимым 
--	(ценами и количеством), чтобы получить доступ к денежным данным:
-- 	для начала вычислим общую выручку от каждого клиента
--  из таблицы Sales.OrderDetails od:
--  SUM(od.unitprice * od.qty * (1 - od.discount))
SELECT 
    c.companyname AS "Название заказчика", 
    ROUND(SUM(od.unitprice * od.qty * (1 - od.discount))::numeric, 2) AS "Суммарная стоимость"
FROM "Sales"."Customers" AS c
JOIN "Sales"."Orders" AS o ON c.custid = o.custid
JOIN "Sales"."OrderDetails" AS od ON o.orderid = od.orderid
GROUP BY c.companyname  --объединияем все заказы одного и того же клиента в одну строку.
ORDER BY "Суммарная стоимость" DESC
LIMIT 5;

--    5. Выведите год, количество сделанных заказов в этом году и 
--	количество уникальных заказчиков, которые делали эти заказы.
SELECT
	-- вырезаем год из полной даты
    EXTRACT(YEAR FROM orderdate) AS "Год",
    -- считаем абсолютно все заказы, попавшие в данный год
    COUNT(orderid) AS "Количество заказов",
    -- Считаем количество уникальных заказчиков
    COUNT(DISTINCT custid) AS "Уникальных заказчиков"
FROM "Sales"."Orders"
-- Обьединяем данные по годовым периодам
GROUP BY "Год"
-- Упорядочеваем результат
ORDER BY "Год";

--    6. Выведите список только тех заказов, общая стоимость которых превышает 
--	1000 ВНИМАНИЕ: Вычисляемые столбцы должны иметь соответствующие наименования.
SELECT 
    orderid AS "Номер заказа",
    -- суммируем стоимость всех позиций внутри заказа
    ROUND(SUM(unitprice * qty * (1 - discount))::numeric, 2) AS "Общая стоимость"
FROM "Sales"."OrderDetails"
-- группируем все строки с одинаковым номером заказа
GROUP BY orderid
-- фильтруем после того как суммы посчитаны
HAVING SUM(unitprice * qty * (1 - discount))::numeric > 1000
ORDER BY "Общая стоимость" DESC;

