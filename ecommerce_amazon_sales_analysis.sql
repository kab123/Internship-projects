

/*DROP TABLE IF EXISTS raw_amazon_sales;

CREATE TABLE raw_amazon_sales (
    row_num              INT,               -- original “index” column
    order_id             VARCHAR(25),
    order_date           DATE,
    status               VARCHAR(50),
    fulfilment           VARCHAR(30),
    sales_channel        VARCHAR(50),
    ship_service_level   VARCHAR(40),
    style                VARCHAR(40),
    sku                  VARCHAR(40),
    category             VARCHAR(40),
    size                 VARCHAR(10),
    asin                 VARCHAR(15),
    courier_status       VARCHAR(40),
    qty                  INT,
    currency             CHAR(3),
    amount               DECIMAL(12,2),
    ship_city            VARCHAR(60),
    ship_state           VARCHAR(60),
    ship_postal_code     VARCHAR(20),
    ship_country         VARCHAR(10),
    promotion_ids        TEXT,
    b2b                  TINYINT(1),
    fulfilled_by         VARCHAR(30)
);

*/

DROP TABLE IF EXISTS currency_rates;
CREATE TABLE currency_rates (
    currency_code  CHAR(3)  PRIMARY KEY,
    rate_to_usd    DECIMAL(10,6)   -- 1 unit = n USD
);
INSERT INTO currency_rates VALUES
    ('USD',1.000000),
    ('INR',0.012000),  -- example; plug in current rates
    ('EUR',1.080000);


   -- 3.  CLEANED / MODEL TABLE
DROP TABLE IF EXISTS amazon_sales;
CREATE TABLE amazon_sales (
    order_id          VARCHAR(25) PRIMARY KEY,
    order_date        DATE,
    month_key         CHAR(7),
    status            VARCHAR(50),
    fulfilment        VARCHAR(30),
    sales_channel     VARCHAR(50),
    ship_service_lvl  VARCHAR(40),
    style             VARCHAR(40),
    sku               VARCHAR(40),
    category          VARCHAR(40),
    size              VARCHAR(10),
    asin              VARCHAR(15),
    courier_status    VARCHAR(40),
    qty               INT,
    currency          CHAR(3),
    amount_orig       DECIMAL(12,2),
    amount_usd        DECIMAL(12,2),
    cost_usd          DECIMAL(12,2),
    profit_usd        DECIMAL(12,2),
    b2b               TINYINT(1),
    fulfilled_by      VARCHAR(30)
);

INSERT INTO amazon_sales
SELECT
    TRIM(order_id),
    order_date,
    DATE_FORMAT(order_date,'%Y-%m')                    AS month_key,
    TRIM(status),
    TRIM(fulfilment),
    TRIM(sales_channel),
    TRIM(ship_service_level)                           AS ship_service_lvl,
    TRIM(style),
    TRIM(sku),
    TRIM(category),
    TRIM(size),
    TRIM(asin),
    TRIM(courier_status),
    COALESCE(qty,0),
    UPPER(TRIM(currency)),
    ROUND(amount,2),
    ROUND(amount*COALESCE(cr.rate_to_usd,1),2),
    ROUND(amount*COALESCE(cr.rate_to_usd,1)*0.70,2),   -- example 70 % cost
    ROUND(amount*COALESCE(cr.rate_to_usd,1)*0.30,2),   -- example 30 % margin
    COALESCE(b2b,0),
    TRIM(fulfilled_by)
FROM raw_amazon_sales ras
LEFT JOIN currency_rates cr
       ON UPPER(ras.currency)=cr.currency_code
WHERE amount IS NOT NULL
  AND order_id IS NOT NULL
  AND NOT EXISTS (SELECT 1
                  FROM amazon_sales a2
                  WHERE a2.order_id = ras.order_id);

-- 4.  DATA‑QUALITY QUICK CHECKS
-- Null counts
SELECT
    SUM(amount_usd IS NULL)           AS null_amount,
    SUM(courier_status='')            AS blank_courier_status,
    SUM(size='')                      AS blank_size
FROM amazon_sales;

-- Duplicate SKU / ASIN combos
SELECT sku, asin, COUNT(*) dupes
FROM amazon_sales
GROUP BY sku, asin
HAVING dupes>1;


   -- 5.  BUSINESS‑QUESTION QUERIES

-- 5a. Top categories by revenue
SELECT category,
       ROUND(SUM(amount_usd),2) rev,
       SUM(qty) qty
FROM amazon_sales
GROUP BY category
ORDER BY rev DESC;

-- 5b. Monthly trend
SELECT month_key,
       ROUND(SUM(amount_usd),2) rev,
       SUM(qty) qty
FROM amazon_sales
GROUP BY month_key
ORDER BY month_key;

-- 5c. Fulfilment efficiency
SELECT fulfilment,
       ROUND(SUM(amount_usd),2) rev,
       COUNT(*) orders
FROM amazon_sales
GROUP BY fulfilment
ORDER BY rev DESC;

-- 5d. Courier status impact
SELECT courier_status,
       COUNT(*) orders,
       ROUND(SUM(amount_usd),2) rev
FROM amazon_sales
GROUP BY courier_status
ORDER BY rev DESC;

-- 5e. B2B vs B2C
SELECT (b2b=1) is_b2b,
       ROUND(SUM(amount_usd),2) rev,
       SUM(qty) qty
FROM amazon_sales
GROUP BY is_b2b;

-- 6.  INDEXES FOR FASTER REPORTS
CREATE INDEX idx_amazon_sales_month     ON amazon_sales(month_key);
CREATE INDEX idx_amazon_sales_category  ON amazon_sales(category);
CREATE INDEX idx_amazon_sales_fulfil    ON amazon_sales(fulfilment);
CREATE INDEX idx_amazon_sales_b2b       ON amazon_sales(b2b);
