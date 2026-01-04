--Question 1: When do we tend to be the busiest?
--Creating columns transaction_month & day_of_the_week
WITH cafe_sales AS(
SELECT *,
FORMAT_DATE('%B', transaction_date) AS transaction_month,
FORMAT_DATE('%A', transaction_date) AS day_of_the_week
FROM myfirstproject-438114.cafesales.cleaned_cafe_sales
)

-- Counting total number of transactions per day of the week
SELECT day_of_the_week, COUNT (*) AS no_of_transactions
FROM cafe_sales
GROUP BY day_of_the_week
ORDER BY no_of_transactions DESC

-- Counting total number of transactions per month
SELECT transaction_month, COUNT (*) AS no_of_transactions
FROM cafe_sales
GROUP BY transaction_month
ORDER BY no_of_transactions DESC

--Question 2: Most popular menu item during peak period
SELECT item, SUM (quantity) AS total_sold, SUM(total_spent) AS total_earned
FROM cafe_sales
WHERE day_of_the_week = 'Friday'
GROUP BY item
ORDER BY total_sold DESC

--Question 3: Best and worst selling menu items
-- Option 1: UNION ALL
WITH cafe_sales AS(
SELECT item, SUM(quantity) AS total_sold
FROM myfirstproject-438114.cafesales.cleaned_cafe_sales
GROUP BY item
)
-- Using subquery to extract MIN and MAX from total_sold
SELECT * FROM cafe_sales WHERE total_sold = (SELECT MIN(total_sold) FROM cafe_sales WHERE item IS NOT NULL)
UNION ALL
SELECT * FROM cafe_sales WHERE total_sold = (SELECT MAX(total_sold) FROM cafe_sales)

-- Option 2: MIN MAX subquery
SELECT
  MIN(total_sold) AS worst_selling,
  MAX(total_sold) AS best_selling
FROM
  (
    SELECT
      item,
      SUM(quantity) AS total_sold
    FROM
      cafe_sales
    GROUP BY
      item
  )

--Question 4: Average order cost
SELECT AVG(total_spent) AS avg_earned
FROM myfirstproject-438114.cafesales.cleaned_cafe_sales

--Question 5: Dine-in or Takeaway?
SELECT location, COUNT (*) AS no_of_transactions
FROM myfirstproject-438114.cafesales.cleaned_cafe_sales
GROUP BY location