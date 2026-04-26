# OIBSIP_Data-Analytics_2

## Project Overview

**Project Title**: Retail Sales Analysis  
**Level**: Beginner  
**Database**: `ab_nyc_2019`

This project is part of the OIBSIP internship program and demonstrates SQL skills applied to retail sales data. The goal is to import, clean, and analyze transactional data to uncover customer behavior, product performance, and sales trends. The project involves setting up a retail sales database, performing exploratory data analysis (EDA), and answering business-driven questions through SQL queries. It is designed for learners starting their journey in data analytics and aiming to build a solid foundation in SQL with practical insights.

## Objectives

- *Dataset Input:* Import the provided retail dataset into the `retail_sales` database using MySQL Workbench for analysis.  
- *Database Setup:* Create and populate tables with retail sales records.  
- *Data Cleaning:* Handle missing values, duplicates, and ensure data consistency.  
- *Exploratory Data Analysis (EDA):* Run SQL queries to understand customer demographics, product categories, and monthly sales trends.  
- *Business Insights:* Use SQL to answer targeted business questions (e.g., top spending age group, gender spending share, seasonal peaks).  
- *Visualization:* Export query results to CSV and build charts (bar, pie, line, heatmap) in Excel for clear communication.  
- *Final Report:* Document queries, outputs, and insights in a professional format for internship submission.

## Project Structure

### 1. Database Setup

- **Database Creation**: The project starts by creating a database named `ab_nyc_2019`.
- **Table Creation**: A table named `listings` is created to store the sales data. The table structure includes columns for id, price, minimum_nights, number_of_reviews, reviews_per_month, calculated_host_listings_count and availability_365.

```sql
USE DATABASE ab_nyc_2019;

CREATE TABLE listings (
    id INT,
    name VARCHAR(255),
    host_id INT,
    host_name VARCHAR(255),
    neighbourhood_group VARCHAR(50),
    neighbourhood VARCHAR(100),
    latitude DECIMAL(9,6),
    longitude DECIMAL(9,6),
    room_type VARCHAR(50),
    price INT,
    minimum_nights INT,
    number_of_reviews INT,
    last_review DATE,
    reviews_per_month DECIMAL(5,2),
    calculated_host_listings_count INT,
    availability_365 INT
);
```

### 2. Data Cleaning on Dataset

The following SQL queries were developed to clean dataset:

1. **Data Integrity – Completeness & Validity**:
```sql
SELECT COUNT(*) AS invalid_rows
FROM listings
WHERE id IS NULL OR id <= 0
   OR name IS NULL OR TRIM(name)=''
   OR host_id IS NULL OR host_id <= 0
   OR host_name IS NULL OR TRIM(host_name)=''
   OR neighbourhood_group IS NULL OR TRIM(neighbourhood_group)=''
   OR neighbourhood IS NULL OR TRIM(neighbourhood)=''
   OR latitude NOT BETWEEN -90 AND 90
   OR longitude NOT BETWEEN -180 AND 180
   OR room_type IS NULL OR TRIM(room_type)=''
   OR price IS NULL OR price < 0
   OR minimum_nights IS NULL OR minimum_nights < 0
   OR number_of_reviews IS NULL OR number_of_reviews < 0
   OR last_review IS NULL OR last_review > CURDATE()
   OR reviews_per_month IS NULL OR reviews_per_month < 0
   OR calculated_host_listings_count IS NULL OR calculated_host_listings_count < 0
   OR availability_365 IS NULL OR availability_365 NOT BETWEEN 0 AND 365;
```

2. **Missing Data Handling – Imputation**:
   
```sql
UPDATE listings
SET id = COALESCE(id, 999999),
    name = COALESCE(name, 'Unknown'),
    host_id = COALESCE(host_id, 0),
    host_name = COALESCE(host_name, 'Unknown'),
    neighbourhood_group = COALESCE(neighbourhood_group, 'Unknown'),
    neighbourhood = COALESCE(neighbourhood, 'Unknown'),
    latitude = COALESCE(latitude, 0),
    longitude = COALESCE(longitude, 0),
    room_type = COALESCE(room_type, 'Unknown'),
    price = COALESCE(price, 0),
    minimum_nights = COALESCE(minimum_nights, 1),
    number_of_reviews = COALESCE(number_of_reviews, 0),
    last_review = COALESCE(last_review, '2000-01-01'),
    reviews_per_month = COALESCE(reviews_per_month, 0),
    calculated_host_listings_count = COALESCE(calculated_host_listings_count, 0),
    availability_365 = COALESCE(availability_365, 0);
```

3. **Duplicate Removal – Listing IDs + Full Row**:
```sql
DELETE l1 FROM listings l1
JOIN listings l2
ON l1.id = l2.id AND l1.id > l2.id;


-- Full row duplicates across all 16 columns
DELETE l1 FROM listings l1
JOIN listings l2
ON l1.id = l2.id
AND l1.name = l2.name
AND l1.host_id = l2.host_id
AND l1.host_name = l2.host_name
AND l1.neighbourhood_group = l2.neighbourhood_group
AND l1.neighbourhood = l2.neighbourhood
AND l1.latitude = l2.latitude
AND l1.longitude = l2.longitude
AND l1.room_type = l2.room_type
AND l1.price = l2.price
AND l1.minimum_nights = l2.minimum_nights
AND l1.number_of_reviews = l2.number_of_reviews
AND l1.last_review = l2.last_review
AND l1.reviews_per_month = l2.reviews_per_month
AND l1.calculated_host_listings_count = l2.calculated_host_listings_count
AND l1.availability_365 = l2.availability_365
AND l1.id > l2.id;
```

4. **Standardization – Text, Numeric, Date**:
```sql
UPDATE listings
SET name = TRIM(CONCAT(UCASE(LEFT(name,1)), LCASE(SUBSTRING(name,2)))),
    host_name = TRIM(CONCAT(UCASE(LEFT(host_name,1)), LCASE(SUBSTRING(host_name,2)))),
    neighbourhood_group = UPPER(TRIM(neighbourhood_group)),
    neighbourhood = TRIM(CONCAT(UCASE(LEFT(neighbourhood,1)), LCASE(SUBSTRING(neighbourhood,2)))),
    room_type = TRIM(CONCAT(UCASE(LEFT(room_type,1)), LCASE(SUBSTRING(room_type,2)))),
    price = ABS(price),
    minimum_nights = ABS(minimum_nights),
    number_of_reviews = ABS(number_of_reviews),
    reviews_per_month = ABS(reviews_per_month),
    calculated_host_listings_count = ABS(calculated_host_listings_count),
    availability_365 = LEAST(GREATEST(availability_365,0),365),
    last_review = STR_TO_DATE(last_review,'%Y-%m-%d');
```

5. **Outlier Detection – Price, Nights, Reviews**:
```sql
SELECT id, price, minimum_nights, number_of_reviews, reviews_per_month,
       calculated_host_listings_count, availability_365
FROM listings
WHERE price > 1000
   OR minimum_nights > 365
   OR number_of_reviews > 1000
   OR reviews_per_month > 30
   OR calculated_host_listings_count > 100
   OR availability_365 > 365;
```

6. **Outlier Capping – Numeric Columns**:
```sql
UPDATE listings
SET price = LEAST(price,1000),
    minimum_nights = LEAST(minimum_nights,365),
    number_of_reviews = LEAST(number_of_reviews,1000),
    reviews_per_month = LEAST(reviews_per_month,30),
    calculated_host_listings_count = LEAST(calculated_host_listings_count,100),
    availability_365 = LEAST(availability_365,365);
```


## Findings

- *Customer Demographics:*  
  - Dataset covers multiple age groups.  
  - Age group *46–55* contributed the highest overall spend (₹100,690).  
  - Age group *18–25* had the highest average spend per transaction (₹500.30).  
  - Gender analysis shows *Female customers* spent slightly more overall (₹232,840) compared to Males (₹223,160).  

- *High‑Value Transactions:*  
  - Maximum transaction value recorded was *₹2,000, minimum was *₹25**.  
  - Clear spending tiers observed: premium (₹2000), mid‑range (₹900–₹1500), and budget (<₹500).  
  - Standard deviation ≈ *₹559.71*, indicating wide variation in transaction amounts.  

- *Sales Trends:*  
  - *Quarterly Sales (2023):* Q4 (₹126,190) and Q2 (₹123,735) were strongest; Q3 dipped to ₹96,045.  
  - *Monthly Sales (2023):* Peaks in *May (₹53,150), **October (₹46,580), and **December (₹44,690)*.  
  - Lowest month: *September (₹23,620)*.  
  - 2024 data begins with January (₹1,530).  

- *Product Insights:*  
  - *Electronics (₹156,905)* and *Clothing (₹155,580)* were top revenue drivers.  
  - *Beauty (₹143,515)* followed closely.  
  - Average price per unit ranged between *₹174–₹184*, with min ₹25 and max ₹500 across categories.
 

- *Visualization:*  
  - Insights were presented through *bar charts (age groups, product categories), **pie charts (gender spending), **line charts (monthly sales trends), and **heatmaps (customer frequency)*.  
  - These visuals made the findings clear and professional for reporting.

## Reports

- *Sales Summary:*  
  1000 transactions analyzed across three product categories (Electronics, Clothing, Beauty).  

- *Trend Analysis:*  
  Seasonal peaks in May, October, and December highlight festive demand. September shows off‑season slowdown.  

- *Customer Insights:*  
  - Top spending age group: *46–55*.  
  - Highest average spend: *18–25*.  
  - Female customers slightly outspend males.  
  - Transaction tiers reveal premium, mid‑range, and budget shoppers.  

- *Product Analysis:*  
  - Electronics and Clothing dominate revenue, Beauty remains strong.  
  - Price distribution consistent across categories (₹25–₹500).
 
- *Visualization Report:*  
  Charts and graphs were created in Excel to highlight demographics, product performance, and seasonal trends.

## Conclusion

- This project demonstrates SQL‑based retail sales analysis using the retail_sales database.  
- By importing the dataset into MySQL Workbench, cleaning records, running exploratory queries, and visualizing results, we uncovered actionable insights on demographics, product performance, transaction behavior, and seasonal trends.  
- The combination of SQL queries and clear visualizations ensures findings are both data‑driven and easy to interpret, supporting business decisions effectively. 

## Recommendations
Based on the exploratory data analysis (EDA), the following recommendations can help improve retail performance:

- **Target High-Spending Age Groups:** Focus marketing campaigns on customers aged **46–55** (highest total spend) and **18–25** (highest average spend per transaction).
- **Gender-Based Promotions:** Since female customers slightly outspend males, design loyalty programs or offers tailored to female shoppers while encouraging male engagement.
- **Seasonal Campaigns:** Align promotions with peak months (**May, October, December**) and plan inventory accordingly. Address low-demand months like **September** with discounts or special events.
- **Product Strategy:** Electronics and Clothing drive the most revenue; prioritize these categories for promotions, while maintaining growth in Beauty products.
- **Transaction Segmentation:** Identify premium buyers (₹2000 transactions) for exclusive offers, mid-range buyers (₹900–₹1500) for bundled deals, and budget shoppers (<₹500) for volume-based discounts.
- **Pricing Optimization:** Maintain competitive pricing within the ₹25–₹500 range, ensuring affordability while sustaining margins.
- **Visualization Use:** Continue leveraging charts (bar, pie, line, heatmap) to monitor trends and communicate insights effectively to stakeholders.
