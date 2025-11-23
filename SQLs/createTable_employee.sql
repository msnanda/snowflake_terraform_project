-- createTable_employee.sql
-- Snowflake DDL: create an `employee` table
-- Create the target schema in the target database and then create the table
CREATE SCHEMA IF NOT EXISTS DEMO_DB.DEMO;

-- Create the table fully-qualified in DEMO_DB.DEMO
CREATE TABLE IF NOT EXISTS DEMO_DB.DEMO.employee2 (
    employee_id NUMBER(38,0) NOT NULL,
    first_name VARCHAR(100),
    last_name VARCHAR(100),
    email VARCHAR(255),
    phone VARCHAR(50),
    hire_date DATE,
    job_id VARCHAR(50),
    salary NUMBER(10,2),
    department_id NUMBER(38,0),
    created_at TIMESTAMP_LTZ DEFAULT CURRENT_TIMESTAMP(),
    updated_at TIMESTAMP_LTZ,
    CONSTRAINT pk_employee PRIMARY KEY (employee_id)
);

-- Notes:
-- 1) Snowflake treats primary key constraints as informational (not enforced).
-- 2) Adjust column types/lengths as needed for your data.
