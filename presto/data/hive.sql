CREATE SCHEMA IF NOT EXISTS hive.default;

USE hive.default;

-- ------------------------------
-- 1. Customer Table
-- ------------------------------
CREATE TABLE IF NOT EXISTS customer (
    custkey     BIGINT,
    name        VARCHAR,
    address     VARCHAR,
    nationkey   BIGINT,
    phone       VARCHAR,
    acctbal     DOUBLE,
    mktsegment  VARCHAR,
    comment     VARCHAR
);

INSERT INTO customer VALUES
(1, 'Customer1', 'Address1', 1, '111-111-1111', 1000.50, 'BUILDING', 'No comment'),
(2, 'Customer2', 'Address2', 2, '222-222-2222', 2000.00, 'AUTOMOBILE', 'No comment'),
(3, 'Customer3', 'Address3', 3, '333-333-3333', 1500.25, 'HOUSEHOLD', 'No comment'),
(4, 'Customer4', 'Address4', 4, '444-444-4444', 1200.75, 'FURNITURE', 'No comment'),
(5, 'Customer5', 'Address5', 5, '555-555-5555', 1800.00, 'MACHINERY', 'No comment'),
(6, 'Customer6', 'Address6', 1, '666-666-6666', 900.50, 'BUILDING', 'No comment'),
(7, 'Customer7', 'Address7', 2, '777-777-7777', 2200.00, 'AUTOMOBILE', 'No comment'),
(8, 'Customer8', 'Address8', 3, '888-888-8888', 1350.25, 'HOUSEHOLD', 'No comment'),
(9, 'Customer9', 'Address9', 4, '999-999-9999', 1400.75, 'FURNITURE', 'No comment'),
(10, 'Customer10', 'Address10', 5, '000-000-0000', 1600.00, 'MACHINERY', 'No comment');

-- ------------------------------
-- 2. Orders Table
-- ------------------------------
CREATE TABLE IF NOT EXISTS orders (
    orderkey      BIGINT,
    custkey       BIGINT,
    orderstatus   VARCHAR,
    totalprice    DOUBLE,
    orderdate     DATE,
    orderpriority VARCHAR,
    clerk         VARCHAR,
    shippriority  INT,
    comment       VARCHAR
);

INSERT INTO orders VALUES
(1, 1, 'O', 300.00, DATE '2023-01-01', 'HIGH', 'Clerk1', 0, 'First order'),
(2, 2, 'F', 150.50, DATE '2023-01-02', 'LOW', 'Clerk2', 0, 'Second order'),
(3, 3, 'O', 450.00, DATE '2023-01-03', 'MEDIUM', 'Clerk3', 0, 'Third order'),
(4, 4, 'F', 200.75, DATE '2023-01-04', 'HIGH', 'Clerk4', 0, 'Fourth order'),
(5, 5, 'O', 500.00, DATE '2023-01-05', 'LOW', 'Clerk5', 0, 'Fifth order'),
(6, 6, 'F', 320.50, DATE '2023-01-06', 'MEDIUM', 'Clerk6', 0, 'Sixth order'),
(7, 7, 'O', 410.00, DATE '2023-01-07', 'HIGH', 'Clerk7', 0, 'Seventh order'),
(8, 8, 'F', 290.25, DATE '2023-01-08', 'LOW', 'Clerk8', 0, 'Eighth order'),
(9, 9, 'O', 480.75, DATE '2023-01-09', 'MEDIUM', 'Clerk9', 0, 'Ninth order'),
(10, 10, 'F', 350.00, DATE '2023-01-10', 'HIGH', 'Clerk10', 0, 'Tenth order');

-- ------------------------------
-- 3. Lineitem Table
-- ------------------------------
CREATE TABLE IF NOT EXISTS lineitem (
    orderkey      BIGINT,
    partkey       BIGINT,
    suppkey       BIGINT,
    linenumber    INT,
    quantity      DOUBLE,
    extendedprice DOUBLE,
    discount      DOUBLE,
    tax           DOUBLE,
    returnflag    VARCHAR,
    linestatus    VARCHAR,
    shipdate      DATE,
    commitdate    DATE,
    receiptdate   DATE,
    shipinstruct  VARCHAR,
    shipmode      VARCHAR,
    comment       VARCHAR
);

INSERT INTO lineitem VALUES
(1, 101, 1001, 1, 5, 100.00, 0.05, 0.10, 'N', 'O', DATE '2023-01-03', DATE '2023-01-04', DATE '2023-01-05', 'DELIVER IN PERSON', 'REG AIR', 'Lineitem 1'),
(1, 102, 1002, 2, 10, 200.00, 0.10, 0.20, 'N', 'O', DATE '2023-01-03', DATE '2023-01-04', DATE '2023-01-05', 'TAKE BACK RETURN', 'MAIL', 'Lineitem 2'),
(2, 103, 1003, 1, 2, 50.00, 0.00, 0.05, 'R', 'F', DATE '2023-01-06', DATE '2023-01-07', DATE '2023-01-08', 'DELIVER IN PERSON', 'SHIP', 'Lineitem 3'),
(3, 104, 1004, 1, 7, 175.00, 0.05, 0.15, 'N', 'O', DATE '2023-01-09', DATE '2023-01-10', DATE '2023-01-11', 'COLLECT COD', 'AIR', 'Lineitem 4'),
(4, 105, 1005, 1, 4, 80.00, 0.00, 0.08, 'R', 'F', DATE '2023-01-12', DATE '2023-01-13', DATE '2023-01-14', 'DELIVER IN PERSON', 'SHIP', 'Lineitem 5'),
(5, 106, 1006, 1, 6, 150.00, 0.05, 0.12, 'N', 'O', DATE '2023-01-15', DATE '2023-01-16', DATE '2023-01-17', 'TAKE BACK RETURN', 'MAIL', 'Lineitem 6'),
(6, 107, 1007, 1, 8, 240.00, 0.10, 0.20, 'N', 'O', DATE '2023-01-18', DATE '2023-01-19', DATE '2023-01-20', 'DELIVER IN PERSON', 'REG AIR', 'Lineitem 7'),
(7, 108, 1008, 1, 3, 75.00, 0.00, 0.05, 'R', 'F', DATE '2023-01-21', DATE '2023-01-22', DATE '2023-01-23', 'COLLECT COD', 'AIR', 'Lineitem 8'),
(8, 109, 1009, 1, 9, 270.00, 0.05, 0.18, 'N', 'O', DATE '2023-01-24', DATE '2023-01-25', DATE '2023-01-26', 'DELIVER IN PERSON', 'REG AIR', 'Lineitem 9'),
(9, 110, 1010, 1, 5, 125.00, 0.00, 0.10, 'R', 'F', DATE '2023-01-27', DATE '2023-01-28', DATE '2023-01-29', 'TAKE BACK RETURN', 'MAIL', 'Lineitem 10');
