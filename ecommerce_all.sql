-- =========================================================
-- PART A: DDL
-- =========================================================

CREATE TABLE IF NOT EXISTS customers (
    customer_id INT PRIMARY KEY NOT NULL,
    email VARCHAR(200) UNIQUE,
    phone VARCHAR(20)
);


CREATE TABLE IF NOT EXISTS addresses (
    address_id INT PRIMARY KEY NOT NULL,
    customer_id INT NOT NULL,
    street VARCHAR(200),
    city VARCHAR(100),
    state VARCHAR(50),
    zip VARCHAR(20),

    FOREIGN KEY (customer_id)
        REFERENCES customers(customer_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);


CREATE TABLE IF NOT EXISTS products (
    product_id INT PRIMARY KEY NOT NULL,
    name VARCHAR(200) UNIQUE,
    price DECIMAL(10,2),

    CONSTRAINT chk_price CHECK (price >= 0)
);


CREATE TABLE IF NOT EXISTS orders (
    order_id INT PRIMARY KEY NOT NULL,
    customer_id INT NOT NULL,
    address_id INT,
    order_date DATE DEFAULT CURRENT_DATE,
    status VARCHAR(20),

    FOREIGN KEY (customer_id)
        REFERENCES customers(customer_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE,

    FOREIGN KEY (address_id)
        REFERENCES addresses(address_id)
        ON DELETE SET NULL
        ON UPDATE CASCADE,

    CONSTRAINT chk_status CHECK (
        status IN ('OPEN', 'PAID', 'SHIPPED', 'CANCELLED')
    )
);


CREATE TABLE IF NOT EXISTS order_lines (
    order_line_id INT PRIMARY KEY NOT NULL,
    order_id INT NOT NULL,
    product_id INT NOT NULL,
    quantity INT NOT NULL,
    unit_price DECIMAL(10,2) NOT NULL,

    FOREIGN KEY (order_id)
        REFERENCES orders(order_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE,

    FOREIGN KEY (product_id)
        REFERENCES products(product_id)
        ON DELETE RESTRICT
        ON UPDATE CASCADE,

    CONSTRAINT chk_qty CHECK (quantity > 0),
    CONSTRAINT chk_unit_price CHECK (unit_price >= 0)
);


-- Optional stretch (added after design)
ALTER TABLE customers
ADD COLUMN created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP;



-- =========================================================
-- PART B: DML (SEED DATA)
-- =========================================================

-- Customers (2 required)
INSERT INTO customers (customer_id, email, phone)
VALUES
(1, 'alice@email.com', '111-111-1111'),
(2, 'bob@email.com', '222-222-2222');


-- Addresses
INSERT INTO addresses (address_id, customer_id, street, city, state, zip)
VALUES
(1, 1, '10 Main St', 'Phoenix', 'AZ', '85001'),
(2, 2, '20 Oak Ave', 'Tempe', 'AZ', '85281');


-- Products (3 required)
INSERT INTO products (product_id, name, price)
VALUES
(1, 'Laptop', 1000.00),
(2, 'Mouse', 25.00),
(3, 'Keyboard', 50.00);


-- Orders (2 customers, required)
INSERT INTO orders (order_id, customer_id, address_id, status)
VALUES
(1, 1, 1, 'OPEN'),
(2, 2, 2, 'PAID');


-- Order lines (multiple per order)
INSERT INTO order_lines (order_line_id, order_id, product_id, quantity, unit_price)
VALUES
-- Order 1
(1, 1, 1, 1, 1000.00),
(2, 1, 2, 2, 25.00),

-- Order 2
(3, 2, 3, 1, 50.00),
(4, 2, 2, 1, 25.00);



-- =========================================================
-- PART C: REQUIRED OPERATIONS
-- =========================================================

-- Update product price AFTER orders exist (test historical integrity)
UPDATE products
SET price = 1200.00
WHERE product_id = 1;


-- Cancel a single order (safe WHERE clause)
UPDATE orders
SET status = 'CANCELLED'
WHERE order_id = 1;


-- Multi-row INSERT requirement
INSERT INTO products (product_id, name, price)
VALUES
(4, 'Headphones', 80.00),
(5, 'Webcam', 70.00);



-- =========================================================
-- PART D: TEST CASE (should FAIL FK constraint)
-- =========================================================

-- This should fail because customer_id 999 does not exist
INSERT INTO orders (order_id, customer_id, address_id, status)
VALUES (99, 999, 1, 'OPEN');