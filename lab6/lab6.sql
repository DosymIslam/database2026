DROP TABLE IF EXISTS employees;
DROP TABLE IF EXISTS departments;
DROP TABLE IF EXISTS projects;

CREATE TABLE employees (
    emp_id INT PRIMARY KEY,
    emp_name VARCHAR(50),
    dept_id INT,
    salary DECIMAL(10, 2)
);

CREATE TABLE departments (
    dept_id INT PRIMARY KEY,
    dept_name VARCHAR(50),
    location VARCHAR(50)
);

CREATE TABLE projects (
    project_id INT PRIMARY KEY,
    project_name VARCHAR(50),
    dept_id INT,
    budget DECIMAL(10, 2)
);

INSERT INTO employees (emp_id, emp_name, dept_id, salary)
VALUES
(1, 'John Smith', 101, 50000),
(2, 'Jane Doe', 102, 60000),
(3, 'Mike Johnson', 101, 55000),
(4, 'Sarah Williams', 103, 65000),
(5, 'Tom Brown', NULL, 45000);

INSERT INTO departments (dept_id, dept_name, location)
VALUES
(101, 'IT', 'Building A'),
(102, 'HR', 'Building B'),
(103, 'Finance', 'Building C'),
(104, 'Marketing', 'Building D');

INSERT INTO projects (project_id, project_name, dept_id, budget)
VALUES
(1, 'Website Redesign', 101, 100000),
(2, 'Employee Training', 102, 50000),
(3, 'Budget Analysis', 103, 75000),
(4, 'Cloud Migration', 101, 150000),
(5, 'AI Research', NULL, 200000);

SELECT * FROM employees;
SELECT * FROM departments;
SELECT * FROM projects;

--part 2. Cross join
SELECT e.emp_name, d.dept_name
FROM employees e
CROSS JOIN departments d;

--exercise 2.2, variant A
SELECT e.emp_name, d.dept_name
FROM employees e, departments d;
-- variant B

SELECT e.emp_name, d.dept_name
FROM employees e
INNER JOIN departments d ON TRUE;

--exercise 2.3
SELECT e.emp_name, p.project_name
FROM employees e
CROSS JOIN projects p;

--part 3. Inner join
SELECT e.emp_name, d.dept_name, d.location
FROM employees e
INNER JOIN departments d
ON e.dept_id = d.dept_id;

-- exercise 3.2
SELECT emp_name, dept_name, location
FROM employees
INNER JOIN departments
USING (dept_id);

--exercise 3.3

SELECT emp_name, dept_name, location
FROM employees
NATURAL INNER JOIN departments;

--exercise 3.4

SELECT
    e.emp_name,
    d.dept_name,
    p.project_name
FROM employees e
INNER JOIN departments d
ON e.dept_id = d.dept_id
INNER JOIN projects p
ON d.dept_id = p.dept_id;

--part 4. Left join
--exercise 4.1
SELECT
    e.emp_name,
    e.dept_id AS emp_dept,
    d.dept_id AS dept_dept,
    d.dept_name
FROM employees e
LEFT JOIN departments d
ON e.dept_id = d.dept_id;

--exercise 4.2
SELECT
    emp_name,
    dept_id,
    dept_name
FROM employees
LEFT JOIN departments
USING (dept_id);

--exercise 4.3
SELECT
    e.emp_name,
    e.dept_id
FROM employees e
LEFT JOIN departments d
ON e.dept_id = d.dept_id
WHERE d.dept_id IS NULL;

--exercise 4.4

SELECT
    d.dept_name,
    COUNT(e.emp_id) AS employee_count
FROM departments d
LEFT JOIN employees e
ON d.dept_id = e.dept_id
GROUP BY d.dept_id, d.dept_name
ORDER BY employee_count DESC;

--part 5. Right join
--exercise 5.1
SELECT
    e.emp_name,
    d.dept_name
FROM employees e
RIGHT JOIN departments d
ON e.dept_id = d.dept_id;

--exercise 5.2
SELECT
    e.emp_name,
    d.dept_name
FROM departments d
LEFT JOIN employees e
ON d.dept_id = e.dept_id;

--exercise 5.3
SELECT
    d.dept_name,
    d.location
FROM employees e
RIGHT JOIN departments d
ON e.dept_id = d.dept_id
WHERE e.emp_id IS NULL;

--part 6
SELECT
    e.emp_name,
    e.dept_id AS emp_dept,
    d.dept_id AS dept_dept,
    d.dept_name
FROM employees e
FULL JOIN departments d
ON e.dept_id = d.dept_id;

--6.2
SELECT
    d.dept_name,
    p.project_name,
    p.budget
FROM departments d
FULL JOIN projects p
ON d.dept_id = p.dept_id;

--6.3
SELECT
    CASE
        WHEN e.emp_id IS NULL THEN 'Department without employees'
        WHEN d.dept_id IS NULL THEN 'Employee without department'
        ELSE 'Matched'
    END AS record_status,
    e.emp_name,
    d.dept_name
FROM employees e
FULL JOIN departments d
ON e.dept_id = d.dept_id
WHERE e.emp_id IS NULL
   OR d.dept_id IS NULL;

--part 7. Filtering in ON Clause
SELECT
    e.emp_name,
    d.dept_name,
    e.salary
FROM employees e
LEFT JOIN departments d
ON e.dept_id = d.dept_id
AND d.location = 'Building A';


--7.2
SELECT
    e.emp_name,
    d.dept_name,
    e.salary
FROM employees e
LEFT JOIN departments d
ON e.dept_id = d.dept_id
WHERE d.location = 'Building A';

--7.3
SELECT
    e.emp_name,
    d.dept_name,
    e.salary
FROM employees e
INNER JOIN departments d
ON e.dept_id = d.dept_id
AND d.location = 'Building A';

--part 8. complex join scenarios
SELECT
    d.dept_name,
    e.emp_name,
    e.salary,
    p.project_name,
    p.budget
FROM departments d
LEFT JOIN employees e
ON d.dept_id = e.dept_id
LEFT JOIN projects p
ON d.dept_id = p.dept_id
ORDER BY d.dept_name, e.emp_name;

--8.2
ALTER TABLE employees
ADD COLUMN manager_id INT;

UPDATE employees
SET manager_id = 3
WHERE emp_id = 1;

UPDATE employees
SET manager_id = 3
WHERE emp_id = 2;

UPDATE employees
SET manager_id = NULL
WHERE emp_id = 3;

UPDATE employees
SET manager_id = 3
WHERE emp_id = 4;

UPDATE employees
SET manager_id = 3
WHERE emp_id = 5;

--self join
SELECT
    e.emp_name AS employee,
    m.emp_name AS manager
FROM employees e
LEFT JOIN employees m
ON e.manager_id = m.emp_id;

--8.3

SELECT
    d.dept_name,
    AVG(e.salary) AS avg_salary
FROM departments d
INNER JOIN employees e
ON d.dept_id = e.dept_id
GROUP BY d.dept_id, d.dept_name
HAVING AVG(e.salary) > 50000;


--lab answers for questions

-- 1. What is the difference between INNER JOIN and LEFT JOIN?
-- INNER JOIN returns only matching rows from both tables.
-- LEFT JOIN returns all rows from the left table and matching rows from the right table. If there is no match, NULL is returned.
-- 2. When would you use CROSS JOIN in a practical scenario?
-- CROSS JOIN is useful when we need all possible combinations, for example, pairing all employees with all available projects.
-- 3. Why does the position of a filter condition (ON vs WHERE) matter for outer joins but not for inner joins?
-- In OUTER JOIN, ON filters matching records but preserves unmatched rows. WHERE filters the final result and can remove unmatched rows.
-- In INNER JOIN, both conditions produce the same result in this example.
-- 4. What is the result of COUNT(*) if table1 has 5 rows and table2 has 10 rows using CROSS JOIN?
--The result is 50 rows because:
-- $$ 5 \times 10 = 50 $$
-- 5. How does NATURAL JOIN determine which columns to join on?
-- NATURAL JOIN automatically joins tables using all columns with identical names.
-- 6. What are the potential risks of using NATURAL JOIN?
-- If new columns with identical names are added to both tables, NATURAL JOIN may automatically use them and change the query result unexpectedly.
--7. Convert this LEFT JOIN to a RIGHT JOIN:
--original:
SELECT *
FROM A
LEFT JOIN B ON A.id = B.id;

--converted;
SELECT *
FROM A
RIGHT JOIN B ON A.id = B.id;

-- 8. When should you use FULL OUTER JOIN instead of other JOIN types?
-- Use FULL OUTER JOIN when you need all records from both tables, including records without matching rows.

--ADDITIONAL CHALLENGES

--Challenge 1 — Simulate FULL OUTER JOIN using UNION
SELECT *
FROM employees e
LEFT JOIN departments d
ON e.dept_id = d.dept_id

UNION

SELECT *
FROM employees e
RIGHT JOIN departments d
ON e.dept_id = d.dept_id;

-- Challenge 2 — Employees in departments with more than one project
SELECT
    e.emp_name,
    d.dept_name
FROM employees e
INNER JOIN departments d
ON e.dept_id = d.dept_id
WHERE d.dept_id IN (
    SELECT dept_id
    FROM projects
    GROUP BY dept_id
    HAVING COUNT(*) > 1
);

--Challenge 3 — Organizational structure using Self Join
SELECT
    e.emp_name AS employee,
    m.emp_name AS manager,
    mm.emp_name AS manager_of_manager
FROM employees e
LEFT JOIN employees m
ON e.manager_id = m.emp_id
LEFT JOIN employees mm
ON m.manager_id = mm.emp_id;

--Challenge 4 — All pairs of employees in the same department
SELECT
    e1.emp_name AS employee1,
    e2.emp_name AS employee2,
    e1.dept_id
FROM employees e1
INNER JOIN employees e2
ON e1.dept_id = e2.dept_id
AND e1.emp_id < e2.emp_id;