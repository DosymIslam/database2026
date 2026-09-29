CREATE DATABASE advanced_lab;

--part a
CREATE TABLE employees (
    emp_id SERIAL PRIMARY KEY,
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    department VARCHAR(50) DEFAULT 'Unassigned',
    salary INTEGER DEFAULT 50000,
    hire_date DATE,
    status VARCHAR(20) DEFAULT 'Active'
);
CREATE TABLE departments (
    dept_id SERIAL PRIMARY KEY,
    dept_name VARCHAR(50),
    budget INTEGER,
    manager_id INTEGER
);

CREATE TABLE projects (
    project_id SERIAL PRIMARY KEY,
    project_name VARCHAR(100),
    dept_id INTEGER,
    start_date DATE,
    end_date DATE,
    budget INTEGER
);

--part B Advanced INSERT
--task 2
INSERT INTO employees (emp_id, first_name, last_name, department)
VALUES (1, 'John', 'Smith', 'IT');

--task 3

SELECT setval(
    pg_get_serial_sequence('employees', 'emp_id'),
    (SELECT MAX(emp_id) FROM employees)
);

INSERT INTO employees
(first_name, last_name, department, salary, hire_date, status)
VALUES
('Anna', 'Brown', 'Sales', DEFAULT, '2022-05-10', DEFAULT);


--task 4

INSERT INTO departments (dept_name, budget, manager_id)
VALUES
    ('IT', 150000, 1),
    ('Sales', 120000, 2),
    ('HR', 80000, 3);
--task 5

INSERT INTO employees
(first_name, last_name, department, salary, hire_date)
VALUES
('David', 'Wilson', 'IT', 50000 * 1.1, CURRENT_DATE);


INSERT INTO employees
(first_name, last_name, department, salary, hire_date, status)
VALUES
('Michael', 'Johnson', 'IT', 85000, '2019-03-15', 'Active'),
('Sarah', 'Davis', 'Sales', 65000, '2018-07-20', 'Active'),
('Robert', 'Miller', 'HR', 45000, '2021-01-10', 'Inactive'),
('Emily', 'Taylor', 'Sales', 70000, '2020-02-15', 'Active'),
('James', 'Anderson', NULL, 35000, '2024-01-15', 'Active'),
('Daniel', 'Thomas', 'IT', 90000, '2017-06-01', 'Terminated');

--task 6

CREATE TEMP TABLE temp_employees AS
SELECT *
FROM employees
WHERE FALSE;

INSERT INTO temp_employees
SELECT *
FROM employees
WHERE department = 'IT';

SELECT * FROM temp_employees;

--part c UPDATE

--task 7
UPDATE employees
SET salary = salary * 1.10;


--task 8
UPDATE employees
SET status = 'Senior'
WHERE salary > 60000
  AND hire_date < '2020-01-01';

--task 9
UPDATE employees
SET department =
    CASE
        WHEN salary > 80000 THEN 'Management'
        WHEN salary BETWEEN 50000 AND 80000 THEN 'Senior'
        ELSE 'Junior'
    END;

--task 10

UPDATE employees
SET department = DEFAULT
WHERE status = 'Inactive';


--task 11
UPDATE departments d
SET budget = (
    SELECT AVG(e.salary) * 1.20
    FROM employees e
    WHERE e.department = d.dept_name
);


--task 12
UPDATE employees
SET salary = salary * 1.15,
    status = 'Promoted'
WHERE department = 'Sales';

--part D DELETE
DELETE FROM employees
WHERE status = 'Terminated';

--task 14
DELETE FROM employees
WHERE salary < 40000
  AND hire_date > '2023-01-01'
  AND department IS NULL;

--task 15
DELETE FROM departments
WHERE dept_name NOT IN (
    SELECT DISTINCT department
    FROM employees
    WHERE department IS NOT NULL
);

--task 16 delete returning

INSERT INTO projects
(project_name, dept_id, start_date, end_date, budget)
VALUES
('Old Project', 1, '2021-01-01', '2022-12-31', 40000);

DELETE FROM projects
WHERE end_date < '2023-01-01'
RETURNING *;

--part E NULL

INSERT INTO employees
(first_name, last_name, salary, department)
VALUES
('Kevin', 'White', NULL, NULL);

--task 18
UPDATE employees
SET department = 'Unassigned'
WHERE department IS NULL;

--task 19
DELETE FROM employees
WHERE salary IS NULL
   OR department IS NULL;

--part F RETURNING
INSERT INTO employees
(first_name, last_name, department, salary, hire_date)
VALUES
('Alex', 'Martin', 'IT', 60000, CURRENT_DATE)
RETURNING
    emp_id,
    first_name || ' ' || last_name AS full_name;

--new and old salary
WITH old_data AS (
    SELECT emp_id, salary AS old_salary
    FROM employees
    WHERE department = 'IT'
),
updated AS (
    UPDATE employees
    SET salary = salary + 5000
    WHERE department = 'IT'
    RETURNING emp_id, salary AS new_salary
)
SELECT
    updated.emp_id,
    old_data.old_salary,
    updated.new_salary
FROM updated
JOIN old_data USING (emp_id);

--task 22
DELETE FROM employees
WHERE hire_date < '2020-01-01'
RETURNING *;

--part G advanced DML
--task 23 - NOT EXISTS

INSERT INTO employees
(first_name, last_name, department, salary)
SELECT
    'John',
    'Smith',
    'IT',
    70000
WHERE NOT EXISTS (
    SELECT 1
    FROM employees
    WHERE first_name = 'John'
      AND last_name = 'Smith'
);

--task 24
UPDATE employees e
SET salary = salary *
    CASE
        WHEN (
            SELECT d.budget
            FROM departments d
            WHERE d.dept_name = e.department
        ) > 100000
        THEN 1.10
        ELSE 1.05
    END
WHERE EXISTS (
    SELECT 1
    FROM departments d
    WHERE d.dept_name = e.department
);

--task 25
INSERT INTO employees
(first_name, last_name, department, salary, hire_date)
VALUES
('Tom', 'Green', 'IT', 50000, CURRENT_DATE),
('Sam', 'Black', 'IT', 52000, CURRENT_DATE),
('Kate', 'Young', 'Sales', 48000, CURRENT_DATE),
('Lisa', 'King', 'Sales', 51000, CURRENT_DATE),
('Mark', 'Scott', 'HR', 47000, CURRENT_DATE);

--with one UPDATE increase all salaries on 10%
UPDATE employees
SET salary = salary * 1.10
WHERE (first_name, last_name) IN (
    ('Tom', 'Green'),
    ('Sam', 'Black'),
    ('Kate', 'Young'),
    ('Lisa', 'King'),
    ('Mark', 'Scott')
);

--data migration

CREATE TABLE employee_archive (
    LIKE employees INCLUDING ALL
);

INSERT INTO employee_archive
SELECT *
FROM employees
WHERE status = 'Inactive';

DELETE FROM employees
WHERE status = 'Inactive';

--complex business logic

UPDATE projects p
SET end_date = end_date + INTERVAL '30 days'
WHERE budget > 50000
  AND (
      SELECT COUNT(*)
      FROM employees e
      JOIN departments d
        ON e.department = d.dept_name
      WHERE d.dept_id = p.dept_id
  ) > 3;

--check
SELECT * FROM employees;
SELECT * FROM departments;
SELECT * FROM projects;
SELECT * FROM employee_archive;