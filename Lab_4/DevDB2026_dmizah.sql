-- 1. Справочник должностей
CREATE TABLE Positions (
    position_id INT PRIMARY KEY,
    name VARCHAR(255) NOT NULL UNIQUE,
    min_salary DECIMAL(15, 2) NOT NULL CHECK (min_salary > 0),
    max_salary DECIMAL(15, 2) NOT NULL,
    CONSTRAINT chk_salary_range CHECK (max_salary >= min_salary)
);

-- 2. Приказы
CREATE TABLE Orders (
    order_id INT PRIMARY KEY,
    order_number VARCHAR(50) NOT NULL,
    order_date DATE NOT NULL CHECK (order_date <= CURRENT_DATE),
    signer_name VARCHAR(255) NOT NULL,
    CONSTRAINT uq_order_number_date UNIQUE (order_number, order_date)
);

-- 3. Сотрудники
CREATE TABLE Employees (
    employee_id INT PRIMARY KEY,
    last_name VARCHAR(100) NOT NULL,
    first_name VARCHAR(100) NOT NULL,
    middle_name VARCHAR(100),
    birth_date DATE NOT NULL,
    reg_address TEXT NOT NULL,
    phone VARCHAR(20) UNIQUE,
    email VARCHAR(100) UNIQUE CHECK (email LIKE '%@%'),
    hire_date DATE NOT NULL,
    hire_order_id INTEGER NOT NULL REFERENCES Orders(order_id),
    fire_date DATE,
    fire_order_id INTEGER REFERENCES Orders(order_id),
    -- Валидация: возраст при приеме >= 14 лет (учитывает високосные годы)
    CONSTRAINT chk_emp_age CHECK (hire_date >= (birth_date + INTERVAL '14 years')),
    -- Валидация: логика дат
    CONSTRAINT chk_emp_dates CHECK (fire_date IS NULL OR fire_date >= hire_date),
    -- Валидация: наличие приказа при увольнении
    CONSTRAINT chk_fire_order_req CHECK (
        (fire_date IS NULL AND fire_order_id IS NULL) OR 
        (fire_date IS NOT NULL AND fire_order_id IS NOT NULL)
    )
);

-- 4. Подразделения
CREATE TABLE Departments (
    dept_id INT PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    parent_id INTEGER REFERENCES Departments(dept_id),
    manager_id INTEGER REFERENCES Employees(employee_id),
    open_date DATE NOT NULL,
    open_order_id INTEGER NOT NULL REFERENCES Orders(order_id),
    close_date DATE,
    close_order_id INTEGER REFERENCES Orders(order_id),
    -- Валидация: защита от простого цикла
    CONSTRAINT chk_no_self_parent CHECK (parent_id != dept_id),
    -- Валидация: логика дат
    CONSTRAINT chk_dept_dates CHECK (close_date IS NULL OR close_date >= open_date),
    -- Валидация: наличие приказа при закрытии
    CONSTRAINT chk_close_order_req CHECK (
        (close_date IS NULL AND close_order_id IS NULL) OR 
        (close_date IS NOT NULL AND close_order_id IS NOT NULL)
    )
);

-- 5. Штатная расстановка
CREATE TABLE Staffing (
    staffing_id INT PRIMARY KEY,
    employee_id INTEGER NOT NULL REFERENCES Employees(employee_id),
    dept_id INTEGER NOT NULL REFERENCES Departments(dept_id),
    position_id INTEGER NOT NULL REFERENCES Positions(position_id),
    employment_rate DECIMAL(3, 2) NOT NULL CHECK (employment_rate IN (0.25, 0.5, 0.75, 1.0, 1.5)),
    actual_salary DECIMAL(15, 2) NOT NULL,
    start_date DATE NOT NULL,
    appointment_order_id INTEGER NOT NULL REFERENCES Orders(order_id),
    end_date DATE,
    release_order_id INTEGER REFERENCES Orders(order_id),
    -- Валидация: проверка гарантирует, что время в кадровой истории течет только вперед  
    CONSTRAINT chk_staff_dates CHECK (end_date IS NULL OR end_date >= start_date)
);

CREATE OR REPLACE VIEW v_current_staffing AS
SELECT 
    e.last_name || ' ' || e.first_name || ' ' || COALESCE(e.middle_name, '') AS employee_fio,
    d.name AS department_name,
    p.name AS position_name,
    s.employment_rate AS rate,
    s.actual_salary AS salary,
    -- Расчет соответствия оклада вилке должностей
    CASE 
        WHEN s.actual_salary < p.min_salary THEN 'Ниже минимума'
        WHEN s.actual_salary > p.max_salary THEN 'Выше максимума'
        ELSE 'В норме'
    END AS salary_status,
    s.start_date AS assignment_date,
    o.order_number AS order_ref
FROM Staffing s
JOIN Employees e ON s.employee_id = e.employee_id
JOIN Departments d ON s.dept_id = d.dept_id
JOIN Positions p ON s.position_id = p.position_id
JOIN Orders o ON s.appointment_order_id = o.order_id
WHERE s.end_date IS NULL; -- Фильтр только по активным сотрудникам

CREATE OR REPLACE VIEW v_org_structure AS
SELECT 
    d.name AS department,
    COALESCE(p.name, '--- ГОЛОВНОЙ ОФИС ---') AS parent_department,
    COALESCE(m.last_name || ' ' || m.first_name, 'ВАКАНСИЯ') AS manager_fio,
    d.open_date,
    -- Подсчет численности через подзапрос
    (SELECT COUNT(DISTINCT st.employee_id) 
     from Staffing st 
     WHERE st.dept_id = d.dept_id AND st.end_date IS NULL) AS total_employees
FROM Departments d
LEFT JOIN Departments p ON d.parent_id = p.dept_id
LEFT JOIN Employees m ON d.manager_id = m.employee_id
WHERE d.close_date IS NULL; -- Показываем только действующие отделы

SELECT * FROM v_current_staffing;
SELECT * FROM v_org_structure;



