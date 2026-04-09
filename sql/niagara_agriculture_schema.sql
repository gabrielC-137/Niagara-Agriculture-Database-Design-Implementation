DROP DATABASE IF EXISTS niagara_agriculture;
CREATE DATABASE niagara_agriculture;
USE niagara_agriculture;

-- Industry Table
CREATE TABLE Industry (
    industry_id TINYINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    industry_name VARCHAR(100) NOT NULL UNIQUE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Country Table
CREATE TABLE Country (
    country_id SMALLINT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
    country_name VARCHAR(100) NOT NULL,
    INDEX idx_country_name (country_name)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- State Table
CREATE TABLE State (
    state_id SMALLINT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
    state_name VARCHAR(100) NOT NULL,
    country_id SMALLINT UNSIGNED NOT NULL,
    INDEX idx_state_country (country_id),
    INDEX idx_state_name (state_name),
    CONSTRAINT fk_state_country FOREIGN KEY (country_id) REFERENCES Country(country_id) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- City Table
CREATE TABLE City (
    city_id SMALLINT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
    city_name VARCHAR(100) NOT NULL,
    state_id SMALLINT UNSIGNED NOT NULL,
	INDEX idx_city_state (state_id),
    INDEX idx_city_name (city_name),
    CONSTRAINT fk_city_state FOREIGN KEY (state_id) REFERENCES State(state_id) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Address Table
CREATE TABLE Address (
    address_id INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
    address VARCHAR(50) NOT NULL,
    address2 VARCHAR(50) DEFAULT NULL,
    city_id SMALLINT UNSIGNED NOT NULL,
    postal_code VARCHAR(10) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    modified_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
	INDEX idx_address_city (city_id),
    INDEX idx_postal_code (postal_code),
    CONSTRAINT fk_address_city FOREIGN KEY (city_id) REFERENCES City(city_id) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Company Table
CREATE TABLE Company (
    company_id SMALLINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) NOT NULL UNIQUE,
    address_id INT UNSIGNED NOT NULL UNIQUE,
    website_url VARCHAR(2083) DEFAULT NULL,
    phone_number VARCHAR(20) DEFAULT NULL,
    email VARCHAR(255) UNIQUE DEFAULT NULL,
    industry_id TINYINT UNSIGNED NOT NULL,
    established_year YEAR DEFAULT NULL,
    status ENUM('Active', 'Inactive', 'Closed') DEFAULT 'Active',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    modified_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
	INDEX idx_company_industry (industry_id),
    INDEX idx_company_address (address_id),
    INDEX idx_company_email (email),
    CONSTRAINT fk_company_industry FOREIGN KEY (industry_id) REFERENCES Industry(industry_id) ON DELETE RESTRICT ON UPDATE CASCADE,
	CONSTRAINT fk_company_address FOREIGN KEY (address_id) REFERENCES Address(address_id) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Store Table
CREATE TABLE Store (
    store_id SMALLINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    company_id SMALLINT UNSIGNED NOT NULL,
    store_name VARCHAR(255) NOT NULL,
    address_id INT UNSIGNED NOT NULL UNIQUE,
    store_phone VARCHAR(20) NOT NULL,
    store_email VARCHAR(255) UNIQUE NOT NULL,
    store_type ENUM('Retail', 'Wholesale', 'Online', 'Distributor') DEFAULT 'Retail',
    status ENUM('Active', 'Inactive', 'Closed') DEFAULT 'Active',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    modified_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
	INDEX idx_store_company (company_id),
    INDEX idx_store_address (address_id),
	INDEX idx_store_email (store_email),
    CONSTRAINT fk_store_company FOREIGN KEY (company_id) REFERENCES Company(company_id) ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_store_address FOREIGN KEY (address_id) REFERENCES Address(address_id) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Employee Table
CREATE TABLE Employee (
    employee_id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    store_id SMALLINT UNSIGNED NOT NULL,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    position VARCHAR(100) NOT NULL,
    phone_number VARCHAR(20) DEFAULT NULL,
    email VARCHAR(255) UNIQUE DEFAULT NULL,
    hire_date DATE NOT NULL,
    employment_type ENUM('Part-Time', 'Full-Time', 'Contract') NOT NULL,
    hourly_salary DECIMAL(10, 2) NOT NULL CHECK (hourly_salary >= 15),
    status ENUM('Active', 'Resigned', 'Terminated') DEFAULT 'Active',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    modified_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
	INDEX idx_employee_store (store_id),
    INDEX idx_employee_email (email),
    CONSTRAINT fk_employee_store FOREIGN KEY (store_id) REFERENCES Store(store_id) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ProductCategory Table
CREATE TABLE ProductCategory (
    category_id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) UNIQUE NOT NULL,
    description TEXT DEFAULT NULL,
    parent_category_id INT UNSIGNED DEFAULT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    modified_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_product_category_parent (parent_category_id),
    INDEX idx_product_category_name (name),
	CONSTRAINT fk_parent_category FOREIGN KEY (parent_category_id) REFERENCES ProductCategory(category_id) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Product Table
CREATE TABLE Product (
    product_id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    company_id SMALLINT UNSIGNED NOT NULL,
    category_id INT UNSIGNED NOT NULL,
    product_name VARCHAR(255) NOT NULL,
    description TEXT DEFAULT NULL,
    sku VARCHAR(100) UNIQUE NOT NULL,
    price DECIMAL(10, 2) NOT NULL CHECK (price >= 0),
    unit_of_measurement ENUM('unit', 'kg', 'liter', 'm²', 'box') DEFAULT 'unit',
    is_available BOOLEAN DEFAULT TRUE,
    product_image_url VARCHAR(2083) DEFAULT NULL,
    status ENUM('Active', 'Inactive', 'Discontinued') DEFAULT 'Active',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    modified_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
	INDEX idx_product_company (company_id),
    INDEX idx_product_category (category_id),
    INDEX idx_product_sku (sku),
    INDEX idx_product_name (product_name),
    CONSTRAINT fk_product_company FOREIGN KEY (company_id) REFERENCES Company(company_id) ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_product_category FOREIGN KEY (category_id) REFERENCES ProductCategory(category_id) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Stock Table
CREATE TABLE Stock (
    stock_id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    store_id SMALLINT UNSIGNED NOT NULL,
    product_id INT UNSIGNED NOT NULL,
    delivered_stock INT UNSIGNED DEFAULT 0 CHECK (delivered_stock >= 0),
    sold_stock INT UNSIGNED DEFAULT 0 CHECK (sold_stock >= 0),
    remaining_stock INT UNSIGNED NOT NULL CHECK (remaining_stock >= 0),
    stock_status ENUM('Available', 'Low Stock', 'Out of Stock') DEFAULT 'Available',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    modified_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
	INDEX idx_stock_store (store_id),
    INDEX idx_stock_product (product_id),
    CONSTRAINT fk_stock_store FOREIGN KEY (store_id) REFERENCES Store(store_id) ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_stock_product FOREIGN KEY (product_id) REFERENCES Product(product_id) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Customer Table
CREATE TABLE Customer (
    customer_id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    phone_number VARCHAR(15) NOT NULL,
    address_id INT UNSIGNED DEFAULT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    modified_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
	INDEX idx_customer_address (address_id),
    INDEX idx_customer_email (email),
	CONSTRAINT fk_customer_address FOREIGN KEY (address_id) REFERENCES Address(address_id) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Order Table
CREATE TABLE Orders (
    order_id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    customer_id INT UNSIGNED NOT NULL,
    store_id SMALLINT UNSIGNED NOT NULL,
    order_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    tax_amount DECIMAL(10, 2) NOT NULL CHECK (tax_amount >= 0),
    shipping_amount DECIMAL(10, 2) NOT NULL CHECK (shipping_amount >= 0),
    total_amount DECIMAL(10, 2) NOT NULL CHECK (total_amount >= 0),
    order_status ENUM('Pending', 'Shipped', 'Completed', 'Cancelled') DEFAULT 'Pending',
    order_type ENUM('Local', 'International') DEFAULT 'Local',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    modified_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
	INDEX idx_orders_customer (customer_id),
    INDEX idx_orders_store (store_id),
    INDEX idx_orders_status (order_status),
    CONSTRAINT fk_orders_customer FOREIGN KEY (customer_id) REFERENCES Customer(customer_id) ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_orders_store FOREIGN KEY (store_id) REFERENCES Store(store_id) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- OrderDetails Table
CREATE TABLE OrderDetails (
    order_detail_id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    order_id INT UNSIGNED NOT NULL,
    product_id INT UNSIGNED NOT NULL,
    quantity INT UNSIGNED NOT NULL ,
    unit_price DECIMAL(10, 2) NOT NULL CHECK (unit_price > 0),
    tax_amount DECIMAL(10, 2) NOT NULL CHECK (tax_amount > 0),
    shipping_amount DECIMAL(10, 2) NOT NULL CHECK (shipping_amount > 0),
    total_price DECIMAL(10, 2) NOT NULL CHECK (total_price > 0),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    modified_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
	INDEX idx_ordersdetails_order (order_id),
    INDEX idx_ordersdetails_product (product_id),
    CONSTRAINT fk_orderdetails_order FOREIGN KEY (order_id) REFERENCES Orders(order_id) ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_orderdetails_product FOREIGN KEY (product_id) REFERENCES Product(product_id) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ShippingDetails Table
CREATE TABLE ShippingDetails (
    shipping_id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    order_id INT UNSIGNED NOT NULL,
    shipping_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    tracking_number VARCHAR(100) DEFAULT NULL,
	shipping_address_id INT UNSIGNED NOT NULL,
    customs_declaration TEXT DEFAULT NULL,
    customs_duty DECIMAL(10, 2) DEFAULT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    modified_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
	INDEX idx_shippingdetails_order (order_id),
    INDEX idx_shippingdetails_address (shipping_address_id),
    CONSTRAINT fk_shippingdetails_order FOREIGN KEY (order_id) REFERENCES Orders(order_id) ON DELETE RESTRICT ON UPDATE CASCADE,
	CONSTRAINT fk_shippingdetails_address FOREIGN KEY (shipping_address_id) REFERENCES Address(address_id) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Supplier Table
CREATE TABLE Supplier (
    supplier_id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    supplier_name VARCHAR(255) NOT NULL,
    contact_person VARCHAR(255) NOT NULL,
    phone_number VARCHAR(20) NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
	address_id INT UNSIGNED DEFAULT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    modified_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
	INDEX idx_supplier_address (address_id),
    INDEX idx_supplier_email (email),
	CONSTRAINT fk_supplier_address FOREIGN KEY (address_id) REFERENCES Address(address_id) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- SupplyOrder Table
CREATE TABLE SupplyOrder (
    supply_order_id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    supplier_id INT UNSIGNED NOT NULL,
    store_id SMALLINT UNSIGNED NOT NULL,
    order_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    expected_delivery_date DATE DEFAULT NULL,
    total_amount DECIMAL(10, 2) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    modified_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
	INDEX idx_supplierorder_supplier (supplier_id),
    INDEX idx_supplierorder_store (store_id),
    CONSTRAINT fk_supplyorder_supplier FOREIGN KEY (supplier_id) REFERENCES Supplier(supplier_id) ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_supplyorder_store FOREIGN KEY (store_id) REFERENCES Store(store_id) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- SupplyOrderDetails Table
CREATE TABLE SupplyOrderDetails (
    supply_order_detail_id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    supply_order_id INT UNSIGNED NOT NULL,
    product_id INT UNSIGNED NOT NULL,
    quantity INT UNSIGNED NOT NULL,
    unit_price DECIMAL(10, 2) NOT NULL,
    total_price DECIMAL(10, 2) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    modified_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
	INDEX idx_supplierorderdetails_supplierorder (supply_order_id),
    INDEX idx_supplierorderdetails_product (product_id),
    CONSTRAINT fk_supplyorderdetails_supplyorder FOREIGN KEY (supply_order_id) REFERENCES SupplyOrder(supply_order_id) ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_supplyorderdetails_product FOREIGN KEY (product_id) REFERENCES Product(product_id) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Payment Table
CREATE TABLE Payment (
    payment_id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    payment_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    payment_method ENUM('Credit Card', 'PayPal', 'Bank Transfer', 'Cash on Delivery', 'Cheque') DEFAULT 'Credit Card',
    payment_status ENUM('Pending', 'Completed', 'Failed', 'Cancelled') DEFAULT 'Pending',
    amount DECIMAL(10, 2) NOT NULL CHECK (amount >= 0),
    order_id INT UNSIGNED NOT NULL,
    payment_reference VARCHAR(100) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    modified_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
	INDEX idx_payment_order (order_id),
    INDEX idx_payment_payment_status (payment_status),
    CONSTRAINT fk_payment_order FOREIGN KEY (order_id) REFERENCES Orders(order_id) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ALTER COMMAND: Add column to company table
-- ALTER TABLE Company
-- ADD COLUMN parent_company_name VARCHAR(20);

-- ALTER COMMAND: Modify column to company table
-- ALTER TABLE Company
-- MODIFY COLUMN parent_company_name VARCHAR(50);

-- ALTER COMMAND: Drop column to company table
-- ALTER TABLE Company
-- DROP COLUMN parent_company_name;

-- DROP COMMAND: permanently remove a table, column, or index from the database
-- DROP TABLE ShippingDetails;
-- DROP INDEX idx_company_industry ON Company;

-- Trigger
DELIMITER //

CREATE TRIGGER trg_after_orderdetails_insert
AFTER INSERT ON OrderDetails
FOR EACH ROW
BEGIN
    DECLARE current_stock INT;
    DECLARE updated_remaining_stock INT;
    DECLARE order_store_id SMALLINT;

    -- Get the store_id from the Orders table based on order_id in OrderDetails
    SELECT store_id INTO order_store_id
    FROM Orders
    WHERE order_id = NEW.order_id;
    
    -- Get the current remaining stock for the product in the specific store
    SELECT remaining_stock INTO current_stock
    FROM Stock
    WHERE store_id = order_store_id AND product_id = NEW.product_id
    FOR UPDATE;

    -- Check if sufficient stock is available
    IF current_stock >= NEW.quantity THEN
        -- Calculate the updated remaining stock after the sale
        SET updated_remaining_stock = current_stock - NEW.quantity;
        
        -- Update the sold stock and remaining stock in the Stock table
        UPDATE Stock
        SET sold_stock = sold_stock + NEW.quantity,
            remaining_stock = updated_remaining_stock,
            stock_status = CASE
                WHEN updated_remaining_stock <= 0 THEN 'Out of Stock'
                WHEN updated_remaining_stock < 10 THEN 'Low Stock'
                ELSE 'Available'
            END
        WHERE store_id = order_store_id AND product_id = NEW.product_id;
    ELSE
        -- Raise an error if there is not enough stock
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Not enough stock for this product';
    END IF;
END;
//

DELIMITER ;