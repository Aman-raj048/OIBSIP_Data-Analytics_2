USE ab_nyc_2019;

-- 1. Data Integrity (Completeness)
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

 -- 2. Missing Data Handling – Imputation
 UPDATE listings
    SET name = COALESCE(name,'Unknown'),
    host_name = COALESCE(host_name,'Unknown'),
    neighbourhood_group = COALESCE(neighbourhood_group,'Unknown'),
    neighbourhood = COALESCE(neighbourhood,'Unknown'),
    room_type = COALESCE(room_type,'Unknown'),
    latitude = COALESCE(latitude,0),
    longitude = COALESCE(longitude,0),
    last_review = COALESCE(last_review,'2000-01-01'),
    price = COALESCE(price,0),
    minimum_nights = COALESCE(minimum_nights,1),
    number_of_reviews = COALESCE(number_of_reviews,0),
    reviews_per_month = COALESCE(reviews_per_month,0),
    calculated_host_listings_count = COALESCE(calculated_host_listings_count,0),
    availability_365 = COALESCE(availability_365,0);

-- 3. Duplicate Removal – Listing IDs + Full Row
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

-- 4. Standardization – Text, Numeric, Date
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

-- 5. Outlier Detection – Price, Nights, Reviews
SELECT id, price, minimum_nights, number_of_reviews, reviews_per_month,
       calculated_host_listings_count, availability_365
FROM listings
WHERE price > 1000
   OR minimum_nights > 365
   OR number_of_reviews > 1000
   OR reviews_per_month > 30
   OR calculated_host_listings_count > 100
   OR availability_365 > 365;
   
-- 6. Outlier Capping – Numeric Columns
UPDATE listings
SET price = LEAST(price,1000),
    minimum_nights = LEAST(minimum_nights,365),
    number_of_reviews = LEAST(number_of_reviews,1000),
    reviews_per_month = LEAST(reviews_per_month,30),
    calculated_host_listings_count = LEAST(calculated_host_listings_count,100),
    availability_365 = LEAST(availability_365,365);

