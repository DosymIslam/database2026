-- ============================================
-- PART 1: DATABASE SETUP
-- ============================================

SELECT * FROM employees;
SELECT * FROM departments;
SELECT * FROM projects;


-- ============================================
-- PART 2: CREATING BASIC VIEWS
-- ============================================

-- Exercise 2.1

CREATE OR REPLACE VIEW employee_details AS
SELECT
    e.emp_name,
    e.salary,
    d.dept_name,
    d.building
FROM employees e
INNER JOIN departments d
ON e.dept_id::VARCHAR = d.dept_id;

SELECT * FROM employee_details;


-- Exercise 2.2

CREATE OR REPLACE VIEW dept_statistics AS
SELECT
    d.dept_name,
    COUNT(e.emp_id) AS employee_count,
    AVG(e.salary) AS average_salary,
    MAX(e.salary) AS maximum_salary,
    MIN(e.salary) AS minimum_salary
FROM departments d
LEFT JOIN employees e
ON e.dept_id::VARCHAR = d.dept_id
GROUP BY d.dept_id, d.dept_name;

SELECT *
FROM dept_statistics
ORDER BY employee_count DESC;


-- Exercise 2.3

CREATE OR REPLACE VIEW project_overview AS
SELECT
    p.project_name,
    p.budget,
    d.dept_name,
    d.building,
    COUNT(DISTINCT e.emp_id) AS team_size
FROM projects p
LEFT JOIN departments d
ON p.dept_id::VARCHAR = d.dept_id
LEFT JOIN employees e
ON e.dept_id::VARCHAR = d.dept_id
GROUP BY
    p.project_id,
    p.project_name,
    p.budget,
    d.dept_name,
    d.building;

SELECT * FROM project_overview;


-- Exercise 2.4

CREATE OR REPLACE VIEW high_earners AS
SELECT
    e.emp_name,
    e.salary,
    d.dept_name
FROM employees e
LEFT JOIN departments d
ON e.dept_id::VARCHAR = d.dept_id
WHERE e.salary > 55000;

SELECT * FROM high_earners;


-- ============================================
-- PART 3: MODIFYING AND MANAGING VIEWS
-- ============================================

-- Exercise 3.1

CREATE OR REPLACE VIEW employee_details AS
SELECT
    e.emp_name,
    e.salary,
    d.dept_name,
    d.building,
    CASE
        WHEN e.salary > 60000 THEN 'High'
        WHEN e.salary > 50000 THEN 'Medium'
        ELSE 'Standard'
    END AS salary_grade
FROM employees e
INNER JOIN departments d
ON e.dept_id::VARCHAR = d.dept_id;

SELECT * FROM employee_details;


-- Exercise 3.2

ALTER VIEW high_earners
RENAME TO top_performers;

SELECT * FROM top_performers;


-- Exercise 3.3

CREATE OR REPLACE VIEW temp_view AS
SELECT *
FROM employees
WHERE salary < 50000;

SELECT * FROM temp_view;

DROP VIEW temp_view;


-- ============================================
-- PART 4: UPDATABLE VIEWS
-- ============================================

-- Exercise 4.1

CREATE OR REPLACE VIEW employee_salaries AS
SELECT
    emp_id,
    emp_name,
    dept_id,
    salary
FROM employees;


-- Exercise 4.2

UPDATE employee_salaries
SET salary = 52000
WHERE emp_name = 'John Smith';

SELECT *
FROM employees
WHERE emp_name = 'John Smith';


-- Exercise 4.3

DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM employees WHERE emp_id = 6
    ) THEN
        INSERT INTO employee_salaries
        (emp_id, emp_name, dept_id, salary)
        VALUES (6, 'Alice Johnson', 102, 58000);
    END IF;
END $$;

SELECT * FROM employees;


-- Exercise 4.4

CREATE OR REPLACE VIEW it_employees AS
SELECT emp_id, emp_name, dept_id, salary
FROM employees
WHERE dept_id = 101
WITH LOCAL CHECK OPTION;

DO $$
BEGIN
    INSERT INTO it_employees
    (emp_id, emp_name, dept_id, salary)
    VALUES (7, 'Bob Wilson', 103, 60000);

EXCEPTION
    WHEN SQLSTATE '44000' THEN
        RAISE NOTICE 'Insert rejected: employee must belong to IT';
END $$;


