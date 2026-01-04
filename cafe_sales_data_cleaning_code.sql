-- Step 1: cleaning wrong data and changing wrong data types
CREATE OR REPLACE TEMP TABLE dirty_cafe_sales2 AS (
SELECT *,
-- Clean Item field
CASE
  WHEN Item = 'UNKNOWN' OR Item = 'ERROR' THEN NULL
  ELSE Item
END AS Item_cleaned,

-- Clean Quantity field  + cast to INT64
CASE
  WHEN Quantity = 'UNKNOWN' OR Quantity = 'ERROR' THEN NULL
  ELSE CAST(Quantity AS INT64)
END AS Quantity_cleaned,

-- Clean Price Per Unit field + cast to FLOAT64
CASE
  WHEN `Price Per Unit` = 'UNKNOWN' OR `Price Per Unit` = 'ERROR' THEN NULL
  ELSE CAST(`Price Per Unit` AS FLOAT64)
END AS Price_per_unit_cleaned,

-- Clean Total Spent field + cast to FLOAT64
CASE
  WHEN `Total Spent` = 'UNKNOWN' OR `Total Spent` = 'ERROR' THEN NULL
  ELSE CAST(`Total Spent` AS FLOAT64)
END AS Total_spent_cleaned,

-- Clean Payment Method field
CASE
  WHEN `Payment Method` = 'UNKNOWN' OR `Payment Method` = 'ERROR' THEN NULL
  ELSE `Payment Method`
END AS Payment_method_cleaned,

-- Clean Location field
CASE
  WHEN `Location` = 'UNKNOWN' OR `Location` = 'ERROR' THEN NULL
  ELSE `Location`
END AS Location_cleaned,

-- Clean Transaction Date field + cast to DATE
CASE
  WHEN `Transaction Date` = 'UNKNOWN' OR `Transaction Date` = 'ERROR' THEN NULL
  ELSE CAST(`Transaction Date` AS DATE)
END AS Transaction_date_cleaned,
FROM myfirstproject-438114.cafesales.dirty_cafe_sales
)

-- Step 2: Checking for unique item prices
SELECT DISTINCT `Item_cleaned`, `Price_per_unit_cleaned`
FROM `dirty_cafe_sales2`
ORDER BY Price_er_unit_cleaned

-- Step 3: Matching item to Price Per Unit value
CREATE OR REPLACE TEMP TABLE dirty_cafe_sales2 AS (
SELECT `Transaction ID`, Item_cleaned, Quantity_cleaned, Price_per_unit_cleaned, Total_spent_cleaned, Payment_method_cleaned, Location_cleaned, Transaction_date_cleaned,
CASE
  WHEN Price_per_unit_cleaned = 1.0 then 'Cookie'
  WHEN Price_per_unit_cleaned = 1.5 then 'Tea'
  WHEN Price_per_unit_cleaned = 2.0 then 'Coffee'
  WHEN Price_per_unit_cleaned = 5.0 then 'Salad'
  ELSE Item_cleaned
END AS Item_cleaned_2
FROM dirty_cafe_sales2
)

-- Step 4: Filling in missing values
-- Calculating total spent*/
CREATE OR REPLACE TEMP TABLE dirty_cafe_sales2 AS (
SELECT `Transaction ID`, Item_cleaned_2, Quantity_cleaned, Price_per_unit_cleaned, Total_spent_cleaned, Payment_method_cleaned, Location_cleaned, Transaction_date_cleaned,
CASE
  WHEN Quantity_cleaned IS NOT NULL AND Price_per_unit_cleaned IS NOT NULL THEN Quantity_cleaned * Price_per_unit_cleaned
  ELSE Total_spent_cleaned
END AS Total_spent_cleaned_2
FROM dirty_cafe_sales2
)

-- Calculating price per unit*/
CREATE OR REPLACE TEMP TABLE dirty_cafe_sales2 AS (
SELECT `Transaction ID`, Item_cleaned_2, Quantity_cleaned, Price_per_unit_cleaned, Total_spent_cleaned_2, Payment_method_cleaned, Location_cleaned, Transaction_date_cleaned,
CASE
  WHEN Quantity_cleaned IS NOT NULL AND Total_spent_cleaned_2 IS NOT NULL THEN Total_spent_cleaned_2 / Quantity_cleaned
  ELSE Price_per_unit_cleaned
END AS Price_per_unit_cleaned_2
FROM dirty_cafe_sales2
)

-- Calculating quantity*/
CREATE OR REPLACE TEMP TABLE dirty_cafe_sales2 AS (
SELECT `Transaction ID`, Item_cleaned_2, Quantity_cleaned, Price_per_unit_cleaned_2, Total_spent_cleaned_2, Payment_method_cleaned, Location_cleaned, Transaction_date_cleaned,
CASE
  WHEN Price_per_unit_cleaned_2 IS NOT NULL AND Total_spent_cleaned_2 IS NOT NULL THEN Total_spent_cleaned_2 / Price_per_unit_cleaned_2
  ELSE Quantity_cleaned
END AS Quantity_cleaned_2
FROM dirty_cafe_sales2
)

-- Step 5: Matching item to Price Per Unit value again
CREATE OR REPLACE TEMP TABLE dirty_cafe_sales2 AS (
SELECT
  `Transaction ID`,
  Item_cleaned_2,
  Quantity_cleaned_2,
  Price_per_unit_cleaned_2,
  Total_spent_cleaned_2,
  Payment_method_cleaned,
  Location_cleaned,
  Transaction_date_cleaned,
CASE
  WHEN Price_per_unit_cleaned_2 = 1.0 then 'Cookie'
  WHEN Price_per_unit_cleaned_2 = 1.5 then 'Tea'
  WHEN Price_per_unit_cleaned_2 = 2.0 then 'Coffee'
  WHEN Price_per_unit_cleaned_2 = 5.0 then 'Salad'
  ELSE Item_cleaned_2
END AS Item_cleaned_3
FROM dirty_cafe_sales2
)

-- Step 6: Cleaning up datatable*/
CREATE OR REPLACE TEMP TABLE dirty_cafe_sales2 AS (
SELECT 
  `Transaction ID` AS transaction_id,
  Item_cleaned_3 AS item,
  Quantity_cleaned_2 AS quantity,
  Price_per_unit_cleaned_2 AS price_per_unit,
  Total_spent_cleaned_2 AS total_spent,
  Payment_method_cleaned AS payment_method,
  Location_cleaned AS location,
  Transaction_date_cleaned AS transaction_date,
FROM dirty_cafe_sales2
ORDER BY transaction_id ASC
)

-- Step 7: Creating table from temp table
CREATE TABLE myfirstproject-438114.cafesales.cleaned_cafe_sales AS (
  SELECT *
  FROM dirty_cafe_sales2
  ORDER BY transaction_id ASC
)