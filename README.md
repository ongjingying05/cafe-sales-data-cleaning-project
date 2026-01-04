# cafe-sales-data-cleaning-project
In this data cleaning case study project, I will be practicing data cleaning with SQL on a cafe sales dataset from Kaggle. This dataset contains 10,000 rows of synthetic data representing sales transactions in a cafe. It is intentionally "dirty," with missing values, inconsistent data, and errors introduced to provide a realistic scenario for data cleaning and exploratory data analysis. I will also be performing basic data exploration using the cleaned dataset by answering some simple made up business questions.  

BigQuery is used for this project. Data obtained from Kaggle: [Cafe Sales - Dirty Data for Cleaning Training](https://www.kaggle.com/datasets/ahmedmohamed2003/cafe-sales-dirty-data-for-cleaning-training)  

Queries used in this project:
+	CAST  
+	CASE WHEN  
+	GROUP BY  
+	UNION ALL  
+ Arithmetic and logical operators  
+	Aggregate functions  
+	Temporary tables  

Analysis questions:
+	When do we tend to be busiest?
+	Most popular menu item during peak period?
+	Best and worst selling menu item
+	Average order cost
+	Is dine-in or takeaway more popular?

## Step 1: Data cleaning
### Handling wrong data
<img width="398" height="597" alt="Screenshot 2026-01-04 200556" src="https://github.com/user-attachments/assets/b9bf8c81-3d62-4184-a674-ff3c517e026b" />  

Many rows across multiple columns have data entered as ‘UNKNOWN’ and ‘ERROR’

Removing the wrong data entries can be done with the CASE() function, checking for ‘UNKNOWN’ or ‘ERROR’ entries and changing them into NULL values, without making any changes to the other rows. I choose to replace them with null values as aside from wrong data entries, multiple columns also contains numerous null values. Having all the dirty data standardised as null values would make them easier to deal with together later on.

### Changing data types
<img width="1083" height="474" alt="Screenshot 2025-12-14 205326" src="https://github.com/user-attachments/assets/ce59845a-7c4c-4824-9e5f-2a78bb92968c" />  

The dataset has every column set to STRING data type, which is incorrect for columns Quantity, Price Per Unit, Total Spent and Transaction Date.  

I will change the columns into their respective correct data types with the CAST() function.  
Quantity -> Integer  
Price Per Unit -> Float  
Total Spent -> Float  
Transaction Date -> Date  

The CAST() function can be combined with the CASE() function from before as such: (Quantity column as example)  
CASE  
&nbsp; WHEN Quantity = 'UNKNOWN' OR Quantity = 'ERROR' THEN NULL  
&nbsp; ELSE CAST(Quantity AS INT64)

### Replacing null values
<img width="1335" height="754" alt="Screenshot 2025-12-14 232745" src="https://github.com/user-attachments/assets/a9173ea3-56aa-4c27-ba34-ceb49158a535" />

Many null values exist within the dataset. In this case, deleting rows with null values would significantly impact our dataset and any future analysis as a large number of them exists. Hence, I need to consider other options. 

Starting with the Item column, I figured that it is actually possible to find out which item was purchased in some of these transactions using the Price Per Unit column, since I assume a few menu items would have a unique price per unit. 

You can check which menu items have a unique price per unit with SELECT DISTINCT()  
<img width="424" height="647" alt="Screenshot 2025-12-20 103816" src="https://github.com/user-attachments/assets/62a8b69a-7708-4f22-896b-127cf28cf6f3" />  
From the results, I can infer that only Cookie has a 1.0 price per unit, Tea 1.5, Coffee 2.0 and Salad 5.0 respectively. The only exceptions would be Cake/Juice, both with a 3.0 and Sandwich/Smootie, both with a 4.0.  

With this info, I can fill up null values with Cookies, Tea, Coffee or Salad by matching their Price Per Unit value using CASE().
<img width="1557" height="755" alt="Screenshot 2025-12-15 101427" src="https://github.com/user-attachments/assets/f426bf9f-4d5e-4f5e-a39c-71e4664a4d8b" />  

The Item column should've had all null values replaced now, less those whose price per unit is 3.0/ 4.0 since we couldn’t be sure which item they were.  

### Calculating null values
Now the quantity, price_per_unit and total_spent columns contain null values as well. Fixing this is easy since we know that total spent = quantity x price per unit.  

With CASE(), WHEN & AND operators, we can calculate the total spent using quantity and price per unit columns, but only when neither of them contain null values as we do not want to replace rows already containing total spent data with null in the case either the quantity/ price_per_unit column contains a null value.  

The WHEN and AND operators ensure that calculation of total spent is only performed when neither quantity nor price per unit contain a null value as that would cause total spent to be null as well. As such, I will have to clean them one by one, accounting for null values in each column when using them to calculate one another.  

Afterwards, with newly filled data in our price_per_unit column, we repeat the step we took previously matching item names.

### Final result
<img width="1554" height="712" alt="Screenshot 2025-12-15 111150" src="https://github.com/user-attachments/assets/808493ec-c9be-44aa-a8d8-b1ef2551592b" />  

Excluding payment_method, location and transaction_date columns, null values in the dataset only exists now when
+ null value item - price_per_unit is either 3.0/ 4.0, meaning it could either be cake or juice (for 3.0) and sandwich or smoothie (for 4.0). Hence, field is left null since we cannot be sure which item it is
+ null value quantity - either price_per_unit or total_spent is a null value as well, hence, it is not possible to calculate quantity
+ null value price_per_unit - likewise, either quantity or total_spent is a null value as well
+ null value total_spent - both quantity & price_per_unit are null values too

## Step 2: Data analysis  
### Question 1: When do we tend to be busiest?
Finding out the busiest times can be done either on a daily, weekly or yearly basis. I will need to look at the transaction_date column. This information can help the cafe divide their manpower better throughout a day and week

First, I will create two new columns in my table, transaction_month & day_of_the_week
<img width="552" height="336" alt="Screenshot 2025-12-15 134747" src="https://github.com/user-attachments/assets/271c9bc1-a3b8-4cae-a968-41b21826ae40" />  

With COUNT(), GROUP BY & ORDER BY, I can easily see which month/ day of the week has the highest number of transactions
<img width="430" height="406" alt="Screenshot 2025-12-15 140122" src="https://github.com/user-attachments/assets/ef5d73cd-931a-40db-aa66-c28504fcb257" />
<img width="438" height="405" alt="Screenshot 2025-12-15 140613" src="https://github.com/user-attachments/assets/0b6a3059-1780-4548-8dcd-e39a16313f90" />  

Answer: The busiest day for the cafe is on Fridays, and during the month of October.

### Question 2: Most popular menu item during peak period?
In order to find this, I would first need to filter my data to during peak periods (Fridays) only using WHERE. Then, group menu items by type and count their total quantity sold with SUM(), GROUP BY & ORDER BY. This information can help the cafe better prepare item stocks.
<img width="436" height="408" alt="Screenshot 2025-12-15 141539" src="https://github.com/user-attachments/assets/16c22862-6492-4adc-bde1-9189d199a2f9" />  
Answer: The most popular item during peak period (Fridays) is the Coffee

Addition: Adding a total_earned column calculated from the total_spent column using SUM()
<img width="587" height="405" alt="Screenshot 2025-12-15 142100" src="https://github.com/user-attachments/assets/840f4696-d0fb-4f95-9da8-bae3a0ebec02" />  

With this, you realise that although Coffee is the most popular menu item during peak period, it is not what earns the cafe the most money

### Question 3: Best and worst selling menu item
Finding the best and worst selling menu item is straightforward. All you need to do is find the Min and Max values of total quantity sold, grouped by item.
Theoretically, I could just run something like  

SELECT item, SUM (quantity) AS total_sold  
FROM cafe_sales
GROUP BY item
ORDER BY total_sold DESC

for the best selling menu item at the top, and scroll down or change DESC to AESC for the worst selling item. However, what if I want to see just the best & worse selling item only?  

Utilising UNION ALL, I can get this result:  
-- Creating table with item and total_sold column  
WITH cafe_sales AS(  
SELECT item, SUM(quantity) AS total_sold  
FROM myfirstproject-438114.cafesales.cleaned_cafe_sales  
GROUP BY item  
)  
-- Using subquery to extract MIN and MAX from total_sold  
SELECT * FROM cafe_sales WHERE total_sold = (SELECT MIN(total_sold) FROM cafe_sales)  
UNION ALL  
SELECT * FROM cafe_sales WHERE total_sold = (SELECT MAX(total_sold) FROM cafe_sales)  
<img width="428" height="175" alt="Screenshot 2025-12-15 161301" src="https://github.com/user-attachments/assets/dd9e5389-e460-47a1-8d4e-5a0a3c487d4d" />  

However, we do not want the null value. Thus, I add WHERE item IS NOT NULL into the SELECT MIN() code.
<img width="424" height="171" alt="Screenshot 2025-12-15 161810" src="https://github.com/user-attachments/assets/90dbc2f2-f69c-4313-a5e9-d29f96e422bc" />  

Answer: The best selling menu item would be Coffee, and the worst selling menu item is Smoothie

### Question 4: Average order cost
Finding average among earned with the total_spent column. This can be done easily with AVG()  
<img width="239" height="139" alt="Screenshot 2025-12-15 163209" src="https://github.com/user-attachments/assets/37949a95-edb5-45b7-89cc-c795564884a4" />  

Answer: Average amount earned per transaction is 8.93

### Question 5: Is dine-in or takeaway more popular?
Finding out whether dine-in or takeaway is the more popular option can be done by comparing COUNT of transactions done per location type
<img width="424" height="197" alt="Screenshot 2025-12-15 163652" src="https://github.com/user-attachments/assets/01bf5dda-a890-439b-8439-c2f7829e52db" />  
As the results between In-store orders and Takeaway orders are really close, it is not possible to determine which is the more popular transaction location type. In this case, a significant amount of location data being missing could possibly be impacting our analysis on this question.

[Link to BigQuery dataset](https://console.cloud.google.com/bigquery?ws=!1m4!1m3!3m2!1smyfirstproject-438114!2scafesales)
