CREATE TABLE employees (
    employee_id INTEGER,
    first_name TEXT,
    last_name TEXT,
    age INTEGER CHECK (age BETWEEN 18 AND 65),
    salary NUMERIC CHECK (salary > 0)
);

INSERT INTO employees VALUES
(1, 'Alex', 'Smith', 25, 50000),
(2, 'Anna', 'Brown', 30, 65000);

SELECT * FROM employees;

CREATE TABLE products_catalog (
    product_id INTEGER,
    product_name TEXT,
    regular_price NUMERIC,
    discount_price NUMERIC,

    CONSTRAINT valid_discount CHECK (
        regular_price > 0
        AND discount_price > 0
        AND discount_price < regular_price
    )
);

INSERT INTO products_catalog VALUES
(1, 'Laptop', 500000, 450000),
(2, 'Mouse', 10000, 8000);

SELECT * FROM products_catalog;

CREATE TABLE bookings (
    booking_id INTEGER,
    check_in_date DATE,
    check_out_date DATE,
    num_guests INTEGER,

    CHECK (num_guests BETWEEN 1 AND 10),
    CHECK (check_out_date > check_in_date)
);

INSERT INTO bookings VALUES
(1, '2026-10-15', '2026-10-20', 3),
(2, '2026-11-01', '2026-11-05', 5);

SELECT * FROM bookings;

CREATE TABLE customers (
    customer_id INTEGER NOT NULL,
    email TEXT NOT NULL,
    phone TEXT,
    registration_date DATE NOT NULL
);

INSERT INTO customers VALUES
(1, 'alex@gmail.com', '87001234567', '2026-10-14'),
(2, 'anna@gmail.com', NULL, '2026-10-14');

SELECT * FROM customers;

CREATE TABLE inventory (
    item_id INTEGER NOT NULL,
    item_name TEXT NOT NULL,
    quantity INTEGER NOT NULL CHECK (quantity >= 0),
    unit_price NUMERIC NOT NULL CHECK (unit_price > 0),
    last_updated TIMESTAMP NOT NULL
);

INSERT INTO inventory VALUES
(1, 'Laptop', 10, 450000, NOW()),
(2, 'Mouse', 50, 5000, NOW());

SELECT * FROM inventory;

CREATE TABLE users (
    user_id INTEGER,
    username TEXT UNIQUE,
    email TEXT UNIQUE,
    created_at TIMESTAMP
);

INSERT INTO users VALUES
(1, 'alex123', 'alex@gmail.com', NOW()),
(2, 'anna456', 'anna@gmail.com', NOW());

SELECT * FROM users;

CREATE TABLE course_enrollments (
    enrollment_id INTEGER,
    student_id INTEGER,
    course_code TEXT,
    semester TEXT,

    UNIQUE (student_id, course_code, semester)
);

INSERT INTO course_enrollments VALUES
(1, 101, 'CS101', 'Fall2026'),
(2, 101, 'CS101', 'Spring2027'),
(3, 102, 'CS101', 'Fall2026');

SELECT * FROM course_enrollments;

-- Invalid: duplicate combination
-- INSERT INTO course_enrollments VALUES (4, 101, 'CS101', 'Fall2026');


/*
Task 3.3: Named UNIQUE Constraints

Rename existing UNIQUE constraints.
*/

ALTER TABLE users
RENAME CONSTRAINT users_username_key TO unique_username;

ALTER TABLE users
RENAME CONSTRAINT users_email_key TO unique_email;

-- Invalid: duplicate username
-- INSERT INTO users VALUES (3, 'alex123', 'john@gmail.com', NOW());

-- Invalid: duplicate email
-- INSERT INTO users VALUES (4, 'john123', 'alex@gmail.com', NOW());

/*
Test results:
1. Unique usernames inserted successfully.
2. Unique emails inserted successfully.
3. Duplicate username violates unique_username.
4. Duplicate email violates unique_email.
5. Duplicate enrollment combination is rejected.
*/


/*
PART 4: PRIMARY KEY CONSTRAINTS
*/


/*
Task 4.1: Single Column Primary Key

PRIMARY KEY uniquely identifies each department.
It does not allow NULL or duplicate values.
*/

CREATE TABLE departments (
    dept_id INTEGER PRIMARY KEY,
    dept_name TEXT NOT NULL,
    location TEXT
);

INSERT INTO departments VALUES
(1, 'IT', 'Almaty'),
(2, 'HR', 'Astana'),
(3, 'Sales', 'Shymkent');

SELECT * FROM departments;

-- Invalid: duplicate PRIMARY KEY
-- INSERT INTO departments VALUES (1, 'Finance', 'Almaty');

-- Invalid: NULL PRIMARY KEY
-- INSERT INTO departments VALUES (NULL, 'Marketing', 'Almaty');


/*
Task 4.2: Composite Primary Key

The combination of student_id and course_id
uniquely identifies each enrollment.
*/

CREATE TABLE student_courses (
    student_id INTEGER,
    course_id INTEGER,
    enrollment_date DATE,
    grade TEXT,

    PRIMARY KEY (student_id, course_id)
);

INSERT INTO student_courses VALUES
(101, 1, '2026-09-01', 'A'),
(101, 2, '2026-09-01', 'B'),
(102, 1, '2026-09-01', 'A');

SELECT * FROM student_courses;

-- Invalid: duplicate composite PRIMARY KEY
-- INSERT INTO student_courses VALUES (101, 1, '2026-09-02', 'C');


/*
Task 4.3: Comparison Exercise

1. Difference between UNIQUE and PRIMARY KEY:

PRIMARY KEY uniquely identifies each row and does not
allow NULL values.

UNIQUE prevents duplicate values but allows NULL
values by default in PostgreSQL.


2. Single-column vs Composite PRIMARY KEY:

A single-column PRIMARY KEY is used when one column
can uniquely identify each row.

A composite PRIMARY KEY is used when a combination
of columns is required to uniquely identify each row.


3. Why only one PRIMARY KEY?

A table can have only one PRIMARY KEY constraint
because it defines the main identifier of each row.

However, a table can have multiple UNIQUE constraints
on different columns.
*/


/*
PART 5: FOREIGN KEY CONSTRAINTS
*/


/*
Task 5.1: Basic Foreign Key

dept_id references departments(dept_id).
*/

CREATE TABLE employees_dept (
    emp_id INTEGER PRIMARY KEY,
    emp_name TEXT NOT NULL,
    dept_id INTEGER REFERENCES departments(dept_id),
    hire_date DATE
);

INSERT INTO employees_dept VALUES
(1, 'Alex', 1, '2026-01-10'),
(2, 'Anna', 2, '2026-02-15'),
(3, 'John', 3, '2026-03-01');

SELECT * FROM employees_dept;

-- Invalid: department 99 does not exist
-- INSERT INTO employees_dept VALUES (4, 'David', 99, '2026-04-01');


/*
Task 5.2: Multiple Foreign Keys

Library database with authors, publishers and books.
*/

CREATE TABLE authors (
    author_id INTEGER PRIMARY KEY,
    author_name TEXT NOT NULL,
    country TEXT
);

CREATE TABLE publishers (
    publisher_id INTEGER PRIMARY KEY,
    publisher_name TEXT NOT NULL,
    city TEXT
);

CREATE TABLE books (
    book_id INTEGER PRIMARY KEY,
    title TEXT NOT NULL,
    author_id INTEGER REFERENCES authors(author_id),
    publisher_id INTEGER REFERENCES publishers(publisher_id),
    publication_year INTEGER,
    isbn TEXT UNIQUE
);

INSERT INTO authors VALUES
(1, 'Abai Kunanbayev', 'Kazakhstan'),
(2, 'George Orwell', 'United Kingdom'),
(3, 'J.K. Rowling', 'United Kingdom');

INSERT INTO publishers VALUES
(1, 'Kazakh Publishing', 'Almaty'),
(2, 'Penguin Books', 'London'),
(3, 'Bloomsbury', 'London');

INSERT INTO books VALUES
(1, 'Abai Poems', 1, 1, 2020, 'ISBN001'),
(2, '1984', 2, 2, 1949, 'ISBN002'),
(3, 'Harry Potter', 3, 3, 1997, 'ISBN003');

SELECT * FROM authors;
SELECT * FROM publishers;
SELECT * FROM books;

-- Invalid: author 99 does not exist
-- INSERT INTO books VALUES (4, 'Unknown Book', 99, 1, 2025, 'ISBN004');

-- Invalid: publisher 99 does not exist
-- INSERT INTO books VALUES (5, 'Another Book', 1, 99, 2025, 'ISBN005');

-- Invalid: duplicate ISBN
-- INSERT INTO books VALUES (6, 'New Book', 1, 1, 2025, 'ISBN001');


/*
Task 5.3: ON DELETE Options

ON DELETE RESTRICT prevents deletion of referenced records.

ON DELETE CASCADE automatically deletes related child records.
*/

CREATE TABLE categories (
    category_id INTEGER PRIMARY KEY,
    category_name TEXT NOT NULL
);

CREATE TABLE products_fk (
    product_id INTEGER PRIMARY KEY,
    product_name TEXT NOT NULL,
    category_id INTEGER REFERENCES categories(category_id)
        ON DELETE RESTRICT
);

CREATE TABLE orders (
    order_id INTEGER PRIMARY KEY,
    order_date DATE NOT NULL
);

CREATE TABLE order_items (
    item_id INTEGER PRIMARY KEY,
    order_id INTEGER REFERENCES orders(order_id)
        ON DELETE CASCADE,
    product_id INTEGER REFERENCES products_fk(product_id),
    quantity INTEGER CHECK (quantity > 0)
);

INSERT INTO categories VALUES
(1, 'Electronics'),
(2, 'Clothing');

INSERT INTO products_fk VALUES
(1, 'Laptop', 1),
(2, 'T-Shirt', 2);

INSERT INTO orders VALUES
(1, '2026-10-14'),
(2, '2026-10-15');

INSERT INTO order_items VALUES
(1, 1, 1, 2),
(2, 2, 2, 3);

-- RESTRICT test
-- Expected error: category 1 is referenced by products_fk
-- DELETE FROM categories WHERE category_id = 1;

-- CASCADE test
-- Deleting order 1 automatically deletes its order_items.
-- ROLLBACK restores the test data.

BEGIN;

DELETE FROM orders
WHERE order_id = 1;

SELECT * FROM order_items
WHERE order_id = 1;

ROLLBACK;

/*
Test results:

RESTRICT:
Deleting a category with related products is rejected.

CASCADE:
Deleting an order automatically deletes its related
order_items.

ROLLBACK restores the original data after the test.
*/


/*
PART 6: PRACTICAL APPLICATION
TASK 6.1: E-COMMERCE DATABASE DESIGN
*/


/*
Create a separate schema to avoid conflicts
with tables created in previous tasks.
*/

CREATE SCHEMA ecommerce;


/*
Table 1: Customers

PRIMARY KEY ensures unique customer IDs.
UNIQUE prevents duplicate emails.
NOT NULL requires essential customer information.
*/

CREATE TABLE ecommerce.customers (
    customer_id INTEGER PRIMARY KEY,
    name TEXT NOT NULL,
    email TEXT NOT NULL UNIQUE,
    phone TEXT,
    registration_date DATE NOT NULL
);


/*
Table 2: Products

PRIMARY KEY ensures unique product IDs.
CHECK ensures price and stock_quantity are non-negative.
*/

CREATE TABLE ecommerce.products (
    product_id INTEGER PRIMARY KEY,
    name TEXT NOT NULL,
    description TEXT,
    price NUMERIC(10,2) NOT NULL CHECK (price >= 0),
    stock_quantity INTEGER NOT NULL CHECK (stock_quantity >= 0)
);


/*
Table 3: Orders

FOREIGN KEY connects orders to customers.
ON DELETE RESTRICT prevents deleting customers with orders.
CHECK restricts order status to allowed values.
*/

CREATE TABLE ecommerce.orders (
    order_id INTEGER PRIMARY KEY,
    customer_id INTEGER NOT NULL,
    order_date DATE NOT NULL,
    total_amount NUMERIC(10,2) NOT NULL CHECK (total_amount >= 0),

    status TEXT NOT NULL CHECK (
        status IN (
            'pending',
            'processing',
            'shipped',
            'delivered',
            'cancelled'
        )
    ),

    FOREIGN KEY (customer_id)
        REFERENCES ecommerce.customers(customer_id)
        ON DELETE RESTRICT
);


/*
Table 4: Order Details

FOREIGN KEY connects order_details to orders and products.
ON DELETE CASCADE removes details when an order is deleted.
ON DELETE RESTRICT protects products used in orders.
CHECK ensures quantity is positive.
*/

CREATE TABLE ecommerce.order_details (
    order_detail_id INTEGER PRIMARY KEY,
    order_id INTEGER NOT NULL,
    product_id INTEGER NOT NULL,
    quantity INTEGER NOT NULL CHECK (quantity > 0),
    unit_price NUMERIC(10,2) NOT NULL CHECK (unit_price >= 0),

    FOREIGN KEY (order_id)
        REFERENCES ecommerce.orders(order_id)
        ON DELETE CASCADE,

    FOREIGN KEY (product_id)
        REFERENCES ecommerce.products(product_id)
        ON DELETE RESTRICT
);


/*
INSERT SAMPLE DATA
At least 5 records per table.
*/


/*
Customers
*/

INSERT INTO ecommerce.customers VALUES
(1, 'Alex', 'alex@mail.com', '87001111111', '2026-10-01'),
(2, 'Anna', 'anna@mail.com', '87002222222', '2026-10-02'),
(3, 'John', 'john@mail.com', '87003333333', '2026-10-03'),
(4, 'Diana', 'diana@mail.com', '87004444444', '2026-10-04'),
(5, 'David', 'david@mail.com', '87005555555', '2026-10-05');


/*
Products
*/

INSERT INTO ecommerce.products VALUES
(1, 'Laptop', 'Gaming laptop', 450000, 10),
(2, 'Mouse', 'Wireless mouse', 5000, 50),
(3, 'Keyboard', 'Mechanical keyboard', 25000, 20),
(4, 'Monitor', '24 inch monitor', 85000, 15),
(5, 'Headphones', 'Gaming headphones', 30000, 25);


/*
Orders
*/

INSERT INTO ecommerce.orders VALUES
(1, 1, '2026-10-10', 450000, 'pending'),
(2, 2, '2026-10-11', 10000, 'processing'),
(3, 3, '2026-10-12', 25000, 'shipped'),
(4, 4, '2026-10-13', 85000, 'delivered'),
(5, 5, '2026-10-14', 60000, 'cancelled');


/*
Order Details
*/

INSERT INTO ecommerce.order_details VALUES
(1, 1, 1, 1, 450000),
(2, 2, 2, 2, 5000),
(3, 3, 3, 1, 25000),
(4, 4, 4, 1, 85000),
(5, 5, 5, 2, 30000);


/*
DISPLAY ALL TABLES
*/

SELECT * FROM ecommerce.customers;

SELECT * FROM ecommerce.products;

SELECT * FROM ecommerce.orders;

SELECT * FROM ecommerce.order_details;


/*
TESTING CONSTRAINTS
*/


/*
Test 1: PRIMARY KEY

Expected result:
Duplicate customer_id is rejected.
*/

-- INSERT INTO ecommerce.customers
-- VALUES (1, 'Test', 'test@mail.com', NULL, CURRENT_DATE);


/*
Test 2: UNIQUE

Expected result:
Duplicate customer email is rejected.
*/

-- INSERT INTO ecommerce.customers
-- VALUES (6, 'Test', 'alex@mail.com', NULL, CURRENT_DATE);


/*
Test 3: CHECK - Negative Price

Expected result:
Negative product price is rejected.
*/

-- INSERT INTO ecommerce.products
-- VALUES (6, 'Tablet', 'New tablet', -5000, 10);


/*
Test 4: FOREIGN KEY

Expected result:
Order with non-existent customer_id is rejected.
*/

-- INSERT INTO ecommerce.orders
-- VALUES (6, 99, CURRENT_DATE, 10000, 'pending');


/*
Test 5: NOT NULL

Expected result:
Customer without name is rejected.
*/

-- INSERT INTO ecommerce.customers
-- VALUES (7, NULL, 'test7@mail.com', NULL, CURRENT_DATE);


/*
Test 6: CHECK - Order Status

Expected result:
Invalid order status is rejected.
*/

-- INSERT INTO ecommerce.orders
-- VALUES (7, 1, CURRENT_DATE, 10000, 'unknown');


/*
Test 7: CHECK - Quantity

Expected result:
Negative order quantity is rejected.
*/

-- INSERT INTO ecommerce.order_details
-- VALUES (6, 1, 1, -2, 450000);


/*
Test 8: CHECK - Stock Quantity

Expected result:
Negative stock quantity is rejected.
*/

-- INSERT INTO ecommerce.products
-- VALUES (7, 'Tablet', 'New tablet', 50000, -5);


/*
Test 9: ON DELETE RESTRICT

Expected result:
Customer with existing orders cannot be deleted.
*/

-- DELETE FROM ecommerce.customers
-- WHERE customer_id = 1;


/*
Test 10: ON DELETE CASCADE

Expected result:
Deleting an order automatically deletes
related records from order_details.

ROLLBACK restores the original data.
*/

BEGIN;

DELETE FROM ecommerce.orders
WHERE order_id = 1;

SELECT * FROM ecommerce.order_details
WHERE order_id = 1;

ROLLBACK;


/*
FINAL VERIFICATION
*/


/*
Check number of records in each e-commerce table.
Each table must contain at least 5 records.
*/

SELECT COUNT(*) AS total_customers
FROM ecommerce.customers;

SELECT COUNT(*) AS total_products
FROM ecommerce.products;

SELECT COUNT(*) AS total_orders
FROM ecommerce.orders;

SELECT COUNT(*) AS total_order_details
FROM ecommerce.order_details;


/*
Verify relationships between orders and customers.
*/

SELECT
    o.order_id,
    c.name AS customer_name,
    o.order_date,
    o.total_amount,
    o.status
FROM ecommerce.orders o
JOIN ecommerce.customers c
ON o.customer_id = c.customer_id;


/*
Verify relationships between order details and products.
*/

SELECT
    od.order_detail_id,
    o.order_id,
    p.name AS product_name,
    od.quantity,
    od.unit_price
FROM ecommerce.order_details od
JOIN ecommerce.orders o
ON od.order_id = o.order_id
JOIN ecommerce.products p
ON od.product_id = p.product_id;


/*
FINAL RESULTS

Part 1: CHECK constraints implemented.
Part 2: NOT NULL constraints implemented.
Part 3: UNIQUE constraints implemented.
Part 4: PRIMARY KEY constraints implemented.
Part 5: FOREIGN KEY constraints implemented.
Part 6: E-commerce database created.

All valid sample records are inserted.

Invalid INSERT statements are commented out
and can be executed individually to verify constraints.

ON DELETE RESTRICT and CASCADE are demonstrated.

Laboratory Work 5 completed.
*/