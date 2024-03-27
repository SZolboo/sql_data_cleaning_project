# Nashville Housing Data Cleaning Project  🧹

## Overview
This project focuses on cleaning and preparing a dataset sourced from Kaggle, utilizing PostgreSQL as the primary tool. The dataset, centered around Nashville Housing data, serves as a valuable resource for demonstrating proficiency in data cleaning techniques, as well as highlighting the importance of data preparation in the analytics workflow.

### Data Source
The dataset used in this project is obtained from Kaggle, a popular platform for sharing datasets and data science projects. The Nashville Housing dataset contains information about properties, including addresses, sale prices, ownership details, and other relevant attributes.

### Importance of Data Cleaning
Data cleaning is a critical step in the data analysis process, as it ensures that the data is accurate, consistent, and ready for analysis. By showcasing the importance of data cleaning through practical application, this project emphasizes the significance of ensuring data quality and reliability in decision-making processes. 

## Tools and Technologies Used
- **SQL:** The backbone of my analysis, allowing me to query the database and unearth critical insights.
- **PostgreSQL:** The chosen database management system.
- **Visual Studio Code:** My go-to for database management and executing SQL queries.
- **Git & GitHub:** Essential for version control and sharing my SQL scripts and analysis, ensuring collaboration and project tracking.

### Quick Overview of SQL Functions
- **COALESCE() Function:** Used to fill empty columns with values from another column.
- **SELF-JOIN Clause:** Utilized to join tables and perform operations on multiple columns simultaneously.
- **SPLIT_PART() Function:** Utilized to split the owneraddress into different parts, such as address, city, and state.
- **REPLACE() Function:** Used to replace commas in owneraddress with dots to facilitate splitting.
- **CASE Statement:** Employed to transform values in the soldasvacant column from 'Y' and 'N' to 'Yes' and 'No' respectively.
- **Common Table Expressions (CTEs):** Used to generate temporary result sets that were later used for data cleaning tasks.
- **ROW_NUMBER() Window Function:** Used to assign a unique row number to each row within specified partitions, facilitating identification and removal of duplicates.
- **DELETE Statement:** Used to remove duplicate records from the table based on certain criteria.


## SQL Queries
### 1. Filling Empty Columns
This query fills in missing values in the propertyaddress column of the house table by updating them with non-null values from other records in the same table **(SELF-JOIN)**, where the parcelid matches but the uniqueid is different.

```sql
SELECT 
    h1.parcelid, 
    h1.propertyaddress,
    h2.parcelid,
    h2.propertyaddress,
    COALESCE(h1.propertyaddress, h2.propertyaddress) AS updated_propertyaddress
FROM house h1
JOIN house h2
    ON h1.parcelid = h2.parcelid AND
    h1.uniqueid <> h2.uniqueid
WHERE h1.propertyaddress IS NULL;

UPDATE house
SET propertyaddress = COALESCE(h1.propertyaddress, h2.propertyaddress)
FROM house AS h1
JOIN house AS h2
    ON h1.parcelid = h2.parcelid AND
    h1.uniqueid <> h2.uniqueid
WHERE h1.propertyaddress IS NULL;
```

### 2. Breaking Down Property Address
Breaking out Address into Individual Columns (Address, City):
```sql
SELECT 
    SUBSTRING(propertyaddress, 1, POSITION(',' IN propertyaddress) - 1) AS address,
    SUBSTRING(propertyaddress, POSITION(',' IN propertyaddress) + 1, LENGTH(propertyaddress)) AS city
FROM house;

ALTER TABLE house
ADD propertysplitaddress VARCHAR(255)

UPDATE house
SET propertysplitaddress = SUBSTRING(propertyaddress, 1, POSITION(',' IN propertyaddress) - 1)

ALTER TABLE house
ADD propertysplitcity VARCHAR(255)

UPDATE house
SET propertysplitcity = SUBSTRING(propertyaddress, POSITION(',' IN propertyaddress) + 1, LENGTH(propertyaddress))
```
Breaking down owneraddress into Different Parts (Address, City, State):
```sql
SELECT 
    SPLIT_PART(REPLACE(owneraddress, ',', '.'), '.', 3) AS Part3,
    SPLIT_PART(REPLACE(owneraddress, ',', '.'), '.', 2) AS Part2,
    SPLIT_PART(REPLACE(owneraddress, ',', '.'), '.', 1) AS Part1
FROM house;

ALTER TABLE house
ADD ownersplitaddress VARCHAR(255)

UPDATE house
SET ownersplitaddress = SPLIT_PART(REPLACE(owneraddress, ',', '.'), '.', 3)

ALTER TABLE house
ADD ownersplitcity VARCHAR(255)

UPDATE house
SET ownersplitcity = SPLIT_PART(REPLACE(owneraddress, ',', '.'), '.', 2)

ALTER TABLE house
ADD ownersplitstate VARCHAR(255)

UPDATE house
SET ownersplitstate = SPLIT_PART(REPLACE(owneraddress, ',', '.'), '.', 1)

```

### 3. Transforming Values
The combined query retrieves unique values from the 'soldasvacant' column, replacing 'Y' and 'N' with 'Yes' and 'No' respectively, and updates the dataset accordingly. It also displays each distinct value alongside its count, sorted by count.

```sql
SELECT 
    DISTINCT(soldasvacant), 
    COUNT(soldasvacant)
FROM house
GROUP BY soldasvacant
ORDER BY COUNT(soldasvacant);

SELECT 
    soldasvacant,
    CASE 
        WHEN soldasvacant = 'Y' THEN 'Yes'
        WHEN soldasvacant = 'N' THEN 'No'
        ELSE soldasvacant
    END
FROM house

UPDATE house
SET soldasvacant = 
    CASE
        WHEN soldasvacant = 'Y' THEN 'Yes'
        WHEN soldasvacant = 'N' THEN 'No'
        ELSE soldasvacant
    END
```

### 4. Removing Duplicates

The query utilizes a Common Table Expression (CTE) named RowNumCTE to assign row numbers within partitions based on specific columns. It selects rows where the row number is greater than 1, indicating duplicates.

```sql
WITH RowNumCTE as (
    SELECT *,
        ROW_NUMBER() OVER(
            PARTITION BY 
                parcelid, 
                propertyaddress, 
                saleprice, 
                saledate, 
                legalreference 
            ORDER BY uniqueid) AS row_num
    FROM house
)

SELECT *
FROM RowNumCTE
WHERE row_num > 1;
```

Subsequently, it employs a subquery to identify duplicate unique IDs within partitions and deletes those records from the 'house' table, effectively removing duplicates based on the specified criteria.

```sql
DELETE FROM house
WHERE uniqueid IN (
    SELECT uniqueid
    FROM (
        SELECT 
            uniqueid,
            ROW_NUMBER() OVER(
                PARTITION BY 
                    parcelid, 
                    propertyaddress, 
                    saleprice, 
                    saledate, 
                    legalreference 
                ORDER BY uniqueid
            ) AS row_num
        FROM house
    ) AS RowNumSubquery
    WHERE row_num > 1
);
```
## Conclusion
The data cleaning process for the Nashville Housing dataset yielded several key outcomes and insights:

- **Data Integrity Improvement:** By filling empty columns with values from another column and splitting complex address fields into separate components (address, city), the overall integrity and completeness of the dataset were significantly enhanced. This ensures that the dataset is more reliable and ready for analysis.
- **Enhanced Data Structure:** The creation of new columns for split property address and owner address components facilitated easier data manipulation and analysis. Having structured data enables more efficient querying and reporting processes.
- **Standardized Values:** Transformation of values in the soldasvacant column from 'Y' and 'N' to 'Yes' and 'No' respectively ensures consistency and simplifies interpretation during analysis. This standardization streamlines data interpretation and reduces ambiguity.
- **Duplicate Data Removal:** Identification and removal of duplicate records using advanced SQL techniques such as Common Table Expressions (CTEs) and the ROW_NUMBER window function resulted in a cleaner and more streamlined dataset. Eliminating duplicates improves data accuracy and avoids skewing analysis results.
- **Optimized Dataset:** Dropping unused columns from the dataset further streamlined the data structure, reducing unnecessary clutter and optimizing storage efficiency. This ensures that only relevant and actionable data is retained for analysis, improving overall dataset manageability.

Overall, the data cleaning process has transformed the Nashville Housing dataset into a more reliable, structured, and actionable resource for further analysis. These improvements lay a solid foundation for conducting insightful data analysis and deriving valuable insights to inform decision-making processes in the realm of real estate and housing trends in Nashville.