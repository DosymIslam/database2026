-- =========================================================
-- LABORATORY WORK 9
-- STORED PROCEDURES AND USER-DEFINED FUNCTIONS
-- =========================================================


-- =========================================================
-- PART 1: DATABASE SETUP
-- =========================================================

DROP TABLE IF EXISTS rentals, bikes, members, stations CASCADE;


-- 1.1 CREATE TABLES

CREATE TABLE stations (
    station_id INT PRIMARY KEY,
    station_name VARCHAR(50) NOT NULL,
    city VARCHAR(40) NOT NULL,
    capacity INT NOT NULL
);
-- Create table: bikes
CREATE TABLE bikes (
    bike_id    INT PRIMARY KEY,
    model      VARCHAR(50) NOT NULL,
    station_id INT REFERENCES stations(station_id),
    daily_rate NUMERIC(8,2) NOT NULL
);

-- Create table: members
CREATE TABLE members (
    member_id INT PRIMARY KEY,
    full_name VARCHAR(60) NOT NULL,
    city      VARCHAR(40) NOT NULL,
    joined_on DATE NOT NULL
);

-- Create table: rentals
CREATE TABLE rentals (
    rental_id  INT PRIMARY KEY,
    member_id  INT REFERENCES members(member_id),
    bike_id    INT REFERENCES bikes(bike_id),
    start_date DATE NOT NULL,
    end_date   DATE,
    fee        NUMERIC(8,2)
);

INSERT INTO stations VALUES
 (10, 'Central Park', 'Almaty',   4),
 (20, 'Riverside',    'Almaty',   3),
 (30, 'Expo Gate',    'Astana',   5),
 (40, 'Old Town',     'Shymkent', 2),
 (50, 'Depot',        'Astana',   0);

INSERT INTO bikes VALUES
 (101, 'City Cruiser', 10,  4.50),
 (102, 'City Cruiser', 10,  4.50),
 (103, 'Mountain X',   20,  7.00),
 (104, 'Mountain X',   30,  7.00),
 (105, 'Road Sprint',  30,  9.25),
 (106, 'Folding Mini', 40,  3.75),
 (107, 'Cargo Hauler', 20, 12.00),
 (108, 'Road Sprint',  10,  9.25);

INSERT INTO members VALUES
 (1, 'Aisha Nurlanova', 'Almaty',   DATE '2023-03-14'),
 (2, 'Daniyar Serik',   'Almaty',   DATE '2023-07-02'),
 (3, 'Marta Kowalski',  'Astana',   DATE '2024-01-20'),
 (4, 'Chen Wei',        'Astana',   DATE '2024-05-11'),
 (5, 'Omar Haddad',     'Shymkent', DATE '2024-09-30'),
 (6, 'Elena Petrova',   'Almaty',   DATE '2025-02-05');

INSERT INTO rentals VALUES
 ( 1, 1, 101, DATE '2024-04-05', DATE '2024-04-08', 13.50),
 ( 2, 1, 103, DATE '2024-06-11', DATE '2024-06-16', 35.00),
 ( 3, 1, 108, DATE '2025-02-02', DATE '2025-02-04', 18.50),
 ( 4, 1, 102, DATE '2025-05-20', DATE '2025-05-27', 31.50),
 ( 5, 2, 101, DATE '2024-05-01', DATE '2024-05-02',  4.50),
 ( 6, 2, 107, DATE '2024-11-15', DATE '2024-11-19', 48.00),
 ( 7, 2, 107, DATE '2025-03-08', DATE '2025-03-14', 72.00),
 ( 8, 3, 104, DATE '2024-02-14', DATE '2024-02-18', 28.00),
 ( 9, 3, 105, DATE '2024-08-03', DATE '2024-08-06', 27.75),
 (10, 3, 104, DATE '2025-01-09', DATE '2025-01-10',  7.00),
 (11, 3, 105, DATE '2025-06-01', DATE '2025-06-09', 74.00),
 (12, 4, 104, DATE '2024-07-19', DATE '2024-07-21', 14.00),
 (13, 4, 105, DATE '2025-04-12', DATE '2025-04-15', 27.75),
 (14, 4, 103, DATE '2025-07-23', DATE '2025-07-29', 42.00),
 (15, 5, 106, DATE '2024-10-05', DATE '2024-10-12', 26.25),
 (16, 5, 106, DATE '2025-01-18', DATE '2025-01-20',  7.50),
 (17, 5, 106, DATE '2025-08-14', DATE '2025-08-21', 26.25),
 (18, 2, 102, DATE '2025-09-02', DATE '2025-09-05', 13.50),
 (19, 1, 101, DATE '2025-10-10', NULL,              NULL),
 (20, 4, 108, DATE '2024-12-28', DATE '2025-01-03', 55.50),
 (21, 3, 103, DATE '2025-02-26', DATE '2025-03-02', 28.00),
 (22, 5, 104, DATE '2025-05-05', DATE '2025-05-08', 21.00);


-- =========================================================
-- PART 2: YOUR FIRST FUNCTION
-- =========================================================


-- EXERCISE 2.1: rental_days()

CREATE OR REPLACE FUNCTION rental_days(p_rental_id INT)
RETURNS INT AS $$
DECLARE
    result INT;
BEGIN
    SELECT end_date - start_date
    INTO result
    FROM rentals
    WHERE rental_id = p_rental_id;

    RETURN result;
END;
$$ LANGUAGE plpgsql;


SELECT rental_days(2);
SELECT rental_days(11);
SELECT rental_days(19);
SELECT rental_days(999);


-- EXERCISE 2.2: member_rental_count()

CREATE OR REPLACE FUNCTION member_rental_count(p_member_id INT)
RETURNS INT AS $$
DECLARE
    result INT;
BEGIN
    SELECT COUNT(*)
    INTO result
    FROM rentals
    WHERE member_id = p_member_id;

    RETURN result;
END;
$$ LANGUAGE plpgsql;


SELECT member_rental_count(1);
SELECT member_rental_count(5);
SELECT member_rental_count(6);
SELECT member_rental_count(99);


-- EXERCISE 2.3: station_city()

CREATE OR REPLACE FUNCTION station_city(p_station_id INT)
RETURNS VARCHAR AS $$
DECLARE
    result VARCHAR;
BEGIN
    SELECT city
    INTO result
    FROM stations
    WHERE station_id = p_station_id;

    RETURN result;
END;
$$ LANGUAGE plpgsql;


SELECT station_city(30);
SELECT station_city(77);


-- EXERCISE 2.4: FUNCTION INSIDE A QUERY

SELECT
    rental_id,
    member_id,
    rental_days(rental_id) AS duration
FROM rentals
WHERE rental_days(rental_id) > 4
ORDER BY duration DESC;


-- =========================================================
-- PART 3: PARAMETER MODES
-- =========================================================


-- EXERCISE 3.1: IN PARAMETERS

CREATE OR REPLACE FUNCTION fee_with_discount(
    p_fee NUMERIC,
    p_percent NUMERIC
)
RETURNS NUMERIC AS $$
BEGIN
    RETURN ROUND(p_fee * (1 - p_percent / 100), 2);
END;
$$ LANGUAGE plpgsql;


SELECT fee_with_discount(74.00, 15);


-- EXERCISE 3.2: OUT PARAMETERS

CREATE OR REPLACE FUNCTION member_stats(
    p_member_id INT,
    OUT rental_cnt INT,
    OUT total_fee NUMERIC,
    OUT last_start DATE
)
AS $$
BEGIN
    SELECT
        COUNT(*)::INT,
        COALESCE(SUM(fee), 0),
        MAX(start_date)
    INTO
        rental_cnt,
        total_fee,
        last_start
    FROM rentals
    WHERE member_id = p_member_id;
END;
$$ LANGUAGE plpgsql;


SELECT member_stats(3);
SELECT * FROM member_stats(3);
SELECT * FROM member_stats(6);


-- EXERCISE 3.3: INOUT PARAMETERS

CREATE OR REPLACE FUNCTION apply_late_fee(
    INOUT p_fee NUMERIC
)
AS $$
BEGIN
    p_fee := p_fee + 5.00;
END;
$$ LANGUAGE plpgsql;


SELECT apply_late_fee(13.50);


-- EXERCISE 3.4: VARIADIC PARAMETERS

CREATE OR REPLACE FUNCTION fee_summary(
    VARIADIC p_fees NUMERIC[],
    OUT total NUMERIC,
    OUT average NUMERIC,
    OUT largest NUMERIC
)
AS $$
BEGIN
    SELECT
        COALESCE(SUM(p_fees[i]), 0),
        ROUND(AVG(p_fees[i]), 2),
        MAX(p_fees[i])
    INTO
        total,
        average,
        largest
    FROM generate_subscripts(p_fees, 1) AS g(i);
END;
$$ LANGUAGE plpgsql;


SELECT * FROM fee_summary(13.50, 35.00, 18.50, 31.50);


-- EXERCISE 3.5: CHOOSING A MODE

-- a) IN - row ID is an input value.
-- b) INOUT - running balance must be updated and returned.
-- c) VARIADIC - accepts an unknown number of station IDs.
-- d) OUT - returns two statistics together.


-- =========================================================
-- PART 4: DEFAULT VALUES AND FUNCTION OVERLOADING
-- =========================================================


-- EXERCISE 4.1: total_fees() WITH ONE PARAMETER

CREATE OR REPLACE FUNCTION total_fees(p_member_id INT)
RETURNS NUMERIC AS $$
DECLARE
    result NUMERIC;
BEGIN
    SELECT COALESCE(SUM(fee), 0)
    INTO result
    FROM rentals
    WHERE member_id = p_member_id;

    RETURN result;
END;
$$ LANGUAGE plpgsql;


SELECT total_fees(1);
SELECT total_fees(6);


-- EXERCISE 4.2: OVERLOADING WITH TWO PARAMETERS

CREATE OR REPLACE FUNCTION total_fees(
    p_member_id INT,
    p_from_date DATE
)
RETURNS NUMERIC AS $$
DECLARE
    result NUMERIC;
BEGIN
    SELECT COALESCE(SUM(fee), 0)
    INTO result
    FROM rentals
    WHERE member_id = p_member_id
      AND start_date >= p_from_date;

    RETURN result;
END;
$$ LANGUAGE plpgsql;


SELECT total_fees(1, DATE '2024-01-01');
SELECT total_fees(1, DATE '2025-01-01');


-- EXERCISE 4.3: DEFAULT VALUE

CREATE OR REPLACE FUNCTION total_fees(
    p_member_id INT,
    p_from_date DATE DEFAULT DATE '2025-01-01'
)
RETURNS NUMERIC AS $$
DECLARE
    result NUMERIC;
BEGIN
    SELECT COALESCE(SUM(fee), 0)
    INTO result
    FROM rentals
    WHERE member_id = p_member_id
      AND start_date >= p_from_date;

    RETURN result;
END;
$$ LANGUAGE plpgsql;


-- This call is intentionally ambiguous:
-- SELECT total_fees(1);

-- Expected error:
-- ERROR: function total_fees(integer) is not unique
-- HINT: Could not choose a best candidate function.
-- You might need to add explicit type casts.


-- EXERCISE 4.4: RESOLVING THE AMBIGUITY

DROP FUNCTION total_fees(INTEGER);


SELECT total_fees(1);


-- EXERCISE 4.5: OVERLOADING ON TYPE

CREATE OR REPLACE FUNCTION total_fees(
    p_member_name VARCHAR
)
RETURNS NUMERIC AS $$
DECLARE
    result NUMERIC;
BEGIN
    SELECT COALESCE(SUM(r.fee), 0)
    INTO result
    FROM members m
    LEFT JOIN rentals r
        ON m.member_id = r.member_id
    WHERE m.full_name = p_member_name;

    RETURN result;
END;
$$ LANGUAGE plpgsql;


SELECT total_fees('Aisha Nurlanova');
SELECT total_fees(1);


-- =========================================================
-- PART 5: FUNCTIONS THAT RETURN A TABLE
-- =========================================================


-- EXERCISE 5.1: find_bikes()

CREATE OR REPLACE FUNCTION find_bikes(p_pattern VARCHAR)
RETURNS TABLE (
    found_id INT,
    found_model VARCHAR,
    found_rate NUMERIC
)
AS $$
BEGIN
    RETURN QUERY
    SELECT
        b.bike_id,
        b.model,
        b.daily_rate
    FROM bikes b
    WHERE b.model ILIKE p_pattern
    ORDER BY b.bike_id;
END;
$$ LANGUAGE plpgsql;


SELECT * FROM find_bikes('%road%');
SELECT * FROM find_bikes('%Mini');

-- Returns a composite value instead of separate columns:
SELECT find_bikes('%road%');


-- EXERCISE 5.2: member_history()

CREATE OR REPLACE FUNCTION member_history(p_member_id INT)
RETURNS TABLE (
    rental_id INT,
    bike_model VARCHAR,
    station_name VARCHAR,
    duration INT,
    fee NUMERIC
)
AS $$
BEGIN
    RETURN QUERY
    SELECT
        r.rental_id,
        b.model,
        s.station_name,
        r.end_date - r.start_date,
        r.fee
    FROM rentals r
    JOIN bikes b
        ON r.bike_id = b.bike_id
    JOIN stations s
        ON b.station_id = s.station_id
    WHERE r.member_id = p_member_id
    ORDER BY r.start_date;
END;
$$ LANGUAGE plpgsql;


SELECT * FROM member_history(3);


-- EXERCISE 5.3: WHEN COLUMN NAMES COLLIDE

-- First version: intentionally problematic.

CREATE OR REPLACE FUNCTION bike_list(p_station_id INT)
RETURNS TABLE (
    bike_id INT,
    model VARCHAR
)
AS $$
BEGIN
    RETURN QUERY
    SELECT bike_id, model
    FROM bikes
    WHERE station_id = p_station_id;
END;
$$ LANGUAGE plpgsql;


-- This call can produce an ambiguous-column error:
-- SELECT * FROM bike_list(10);


-- FIX 1: RENAME OUTPUT COLUMNS

DROP FUNCTION bike_list(INT);

CREATE OR REPLACE FUNCTION bike_list(p_station_id INT)
RETURNS TABLE (
    found_bike_id INT,
    found_model VARCHAR
)
AS $$
BEGIN
    RETURN QUERY
    SELECT b.bike_id, b.model
    FROM bikes b
    WHERE b.station_id = p_station_id;
END;
$$ LANGUAGE plpgsql;


SELECT * FROM bike_list(10);


-- FIX 2: KEEP OUTPUT NAMES AND USE TABLE ALIAS

DROP FUNCTION bike_list(INT);

CREATE OR REPLACE FUNCTION bike_list(p_station_id INT)
RETURNS TABLE (
    bike_id INT,
    model VARCHAR
)
AS $$
BEGIN
    RETURN QUERY
    SELECT b.bike_id, b.model
    FROM bikes b
    WHERE b.station_id = p_station_id;
END;
$$ LANGUAGE plpgsql;


SELECT * FROM bike_list(10);


-- EXERCISE 5.4: station_board()

CREATE OR REPLACE FUNCTION station_board(p_city VARCHAR)
RETURNS TABLE (
    s_name VARCHAR,
    s_bikes INT,
    s_free INT
)
AS $$
BEGIN
    RETURN QUERY
    SELECT
        s.station_name,
        COUNT(b.bike_id)::INT,
        (s.capacity - COUNT(b.bike_id))::INT
    FROM stations s
    LEFT JOIN bikes b
        ON s.station_id = b.station_id
    WHERE s.city = p_city
    GROUP BY s.station_id, s.station_name, s.capacity
    ORDER BY s.station_id;
END;
$$ LANGUAGE plpgsql;


SELECT * FROM station_board('Almaty');
SELECT * FROM station_board('Astana');
SELECT * FROM station_board('Shymkent');


-- Without casting COUNT(*) to INT, PostgreSQL returns BIGINT.
-- Expected error:
-- ERROR: structure of query does not match function result type
-- Returned type bigint does not match expected type integer.


-- =========================================================
-- PART 6: BLOCK STRUCTURE, DO BLOCKS AND SUBBLOCKS
-- =========================================================


-- EXERCISE 6.1: AN ANONYMOUS BLOCK

DO $$
<<rental_report>>
DECLARE
    total_rentals INTEGER := 0;
BEGIN
    SELECT COUNT(*)
    INTO total_rentals
    FROM rentals;

    RAISE NOTICE 'The rentals table holds % rows.', total_rentals;
END rental_report;
$$;


-- EXERCISE 6.2: SUBBLOCK AND HIDDEN VARIABLE

DO $$
<<outer_block>>
DECLARE
    fee_total NUMERIC;
BEGIN
    SELECT COALESCE(SUM(fee), 0)
    INTO fee_total
    FROM rentals;

    RAISE NOTICE 'Outer value before subblock: %', fee_total;

    DECLARE
        fee_total NUMERIC;
    BEGIN
        SELECT COALESCE(SUM(fee), 0)
        INTO fee_total
        FROM rentals
        WHERE start_date >= DATE '2025-01-01';

        RAISE NOTICE 'Subblock value: %', fee_total;

        RAISE NOTICE 'Outer value from subblock: %',
            outer_block.fee_total;
    END;

    RAISE NOTICE 'Outer value after subblock: %', fee_total;
END outer_block;
$$;


-- EXERCISE 6.3: DECLARATIONS ARE LOCAL

-- This example intentionally produces an error because
-- first_value belongs to the first subblock.

-- DO $$
-- BEGIN
--     DECLARE
--         first_value INT := 100;
--     BEGIN
--         RAISE NOTICE 'First: %', first_value;
--     END;
--
--     DECLARE
--     BEGIN
--         RAISE NOTICE 'Second: %', first_value;
--     END;
-- END;
-- $$;


-- FIX: DECLARE THE VARIABLE IN THE OUTER BLOCK

DO $$
DECLARE
    shared_value INT := 100;
BEGIN
    DECLARE
    BEGIN
        RAISE NOTICE 'First subblock: %', shared_value;
    END;

    DECLARE
    BEGIN
        RAISE NOTICE 'Second subblock: %', shared_value;
    END;
END;
$$;


-- EXERCISE 6.4: fee_split()

CREATE OR REPLACE FUNCTION fee_split(
    p_from_date DATE,
    OUT before_total NUMERIC,
    OUT after_total NUMERIC
)
AS $$
BEGIN
    SELECT
        COALESCE(SUM(fee) FILTER (
            WHERE start_date < p_from_date
        ), 0),

        COALESCE(SUM(fee) FILTER (
            WHERE start_date >= p_from_date
        ), 0)
    INTO
        before_total,
        after_total
    FROM rentals;
END;
$$ LANGUAGE plpgsql;


SELECT * FROM fee_split(DATE '2025-01-01');

-- Verify that both values add up to the total.

SELECT
    before_total + after_total AS total_split,
    (SELECT SUM(fee) FROM rentals) AS total_fees
FROM fee_split(DATE '2025-01-01');


-- =========================================================
-- PART 7: PRACTICAL SCENARIOS
-- =========================================================


-- EXERCISE 7.1: STATION OCCUPANCY

CREATE OR REPLACE FUNCTION station_load(
    p_station_id INT,
    OUT bikes_parked INT,
    OUT capacity_pct NUMERIC
)
AS $$
DECLARE
    station_capacity INT;
BEGIN
    SELECT capacity
    INTO station_capacity
    FROM stations
    WHERE station_id = p_station_id;

    SELECT COUNT(*)::INT
    INTO bikes_parked
    FROM bikes
    WHERE station_id = p_station_id;

    IF station_capacity = 0 THEN
        capacity_pct := NULL;
    ELSE
        capacity_pct := ROUND(
            bikes_parked * 100.0 / station_capacity,
            1
        );
    END IF;
END;
$$ LANGUAGE plpgsql;


SELECT station_load(10);
SELECT station_load(20);
SELECT station_load(30);
SELECT station_load(40);
SELECT station_load(50);


-- ALL STATIONS AT ONCE

SELECT
    s.station_id,
    s.station_name,
    l.*
FROM stations s,
LATERAL station_load(s.station_id) l;


-- EXERCISE 7.2: TOP MEMBERS WITH DEFAULT

CREATE OR REPLACE FUNCTION top_members(
    p_limit INT DEFAULT 3
)
RETURNS TABLE (
    member_name VARCHAR,
    rental_count BIGINT,
    total_spent NUMERIC
)
AS $$
BEGIN
    RETURN QUERY
    SELECT
        m.full_name,
        COUNT(r.rental_id),
        COALESCE(SUM(r.fee), 0)
    FROM members m
    LEFT JOIN rentals r
        ON m.member_id = r.member_id
    GROUP BY m.member_id, m.full_name
    ORDER BY
        COALESCE(SUM(r.fee), 0) DESC,
        m.member_id
    LIMIT p_limit;
END;
$$ LANGUAGE plpgsql;


SELECT * FROM top_members();
SELECT * FROM top_members(6);


-- EXERCISE 7.3: RENTAL INVOICE

CREATE OR REPLACE FUNCTION rental_invoice(p_rental_id INT)
RETURNS TABLE (
    member_name VARCHAR,
    bike_model VARCHAR,
    days INT,
    amount_owed NUMERIC,
    status VARCHAR
)
AS $$
BEGIN
    RETURN QUERY
    SELECT
        m.full_name,
        b.model,
        CASE
            WHEN r.end_date IS NULL
                THEN CURRENT_DATE - r.start_date
            ELSE r.end_date - r.start_date
        END::INT,

        ROUND(
            (
                CASE
                    WHEN r.end_date IS NULL
                        THEN CURRENT_DATE - r.start_date
                    ELSE r.end_date - r.start_date
                END
                * b.daily_rate
            )::NUMERIC,
            2
        ),

        CASE
            WHEN r.end_date IS NULL THEN 'OPEN'
            ELSE 'CLOSED'
        END::VARCHAR

    FROM rentals r
    JOIN members m
        ON r.member_id = m.member_id
    JOIN bikes b
        ON r.bike_id = b.bike_id
    WHERE r.rental_id = p_rental_id;
END;
$$ LANGUAGE plpgsql;


SELECT * FROM rental_invoice(11);
SELECT * FROM rental_invoice(19);


-- EXERCISE 7.4: REPORT PER CITY

-- VERSION 1: WITHOUT DATE

CREATE OR REPLACE FUNCTION city_report(p_city VARCHAR)
RETURNS TABLE (
    member_count BIGINT,
    rental_count BIGINT,
    total_revenue NUMERIC
)
AS $$
BEGIN
    RETURN QUERY
    SELECT
        COUNT(DISTINCT m.member_id),
        COUNT(r.rental_id),
        COALESCE(SUM(r.fee), 0)
    FROM members m
    LEFT JOIN rentals r
        ON m.member_id = r.member_id
    WHERE m.city = p_city;
END;
$$ LANGUAGE plpgsql;


SELECT * FROM city_report('Almaty');
SELECT * FROM city_report('Astana');
SELECT * FROM city_report('Shymkent');


-- VERSION 2: WITH DATE

CREATE OR REPLACE FUNCTION city_report(
    p_city VARCHAR,
    p_from_date DATE
)
RETURNS TABLE (
    member_count BIGINT,
    rental_count BIGINT,
    total_revenue NUMERIC
)
AS $$
BEGIN
    RETURN QUERY
    SELECT
        COUNT(DISTINCT m.member_id),
        COUNT(r.rental_id),
        COALESCE(SUM(r.fee), 0)
    FROM members m
    LEFT JOIN rentals r
        ON m.member_id = r.member_id
       AND r.start_date >= p_from_date
    WHERE m.city = p_city;
END;
$$ LANGUAGE plpgsql;


SELECT * FROM city_report('Almaty', DATE '2025-01-01');
SELECT * FROM city_report('Astana', DATE '2025-01-01');
SELECT * FROM city_report('Shymkent', DATE '2025-01-01');

-- LAB QUESTIONS

-- 1. A function name identifies the function.
--    A signature includes its name and argument types.
--    DROP FUNCTION needs the signature to distinguish overloaded functions.

-- 2. Dollar quoting ($$) allows writing function bodies
--    without escaping single quotes inside the body.

-- 3. OUT parameters are useful for returning a few values.
--    RETURNS TABLE is better when returning multiple rows
--    with named columns.

-- 4. VARIADIC must be last because it collects all remaining
--    arguments into an array.

-- 5. RETURN sends back one value.
--    RETURN QUERY sends back rows from a SELECT statement.

-- 6. DEFAULT parameters can create ambiguity with existing
--    overloaded functions. Avoid overlapping signatures.

-- 7. A variable declared inside a subblock exists only
--    inside that subblock. A shadowed outer variable can be
--    accessed using the outer block label.

-- 8. Advantage: business logic can be reused by different applications.
--    Disadvantage: database-specific code is harder to migrate and test.

-- 9. PL/pgSQL is trusted, so ordinary users can create functions.
--    PL/Python is untrusted, so creating its functions requires superuser privileges.

-- 10. Changing argument types with CREATE OR REPLACE FUNCTION
--     creates a different function signature instead of replacing
--     the original function.


-- =========================================================
-- END
-- =========================================================