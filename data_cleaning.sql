SELECT *
FROM house;

-- Fills NULL property addresses by selecting non-null values from the other column using COALESCE.
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

-- Breaking out Address into Individual Columns (Address, City, State)
SELECT 
    SUBSTRING(propertyaddress, 1, POSITION(',' IN propertyaddress) - 1) AS address,
    SUBSTRING(propertyaddress, POSITION(',' IN propertyaddress) + 1, LENGTH(propertyaddress)) AS city
FROM house;

-- Creating new columns
ALTER TABLE house
ADD propertysplitaddress VARCHAR(255)

UPDATE house
SET propertysplitaddress = SUBSTRING(propertyaddress, 1, POSITION(',' IN propertyaddress) - 1)

ALTER TABLE house
ADD propertysplitcity VARCHAR(255)

UPDATE house
SET propertysplitcity = SUBSTRING(propertyaddress, POSITION(',' IN propertyaddress) + 1, LENGTH(propertyaddress))

-- Breaking down owneraddress into different parts assigning them into different columns using another method.
SELECT 
    SPLIT_PART(REPLACE(owneraddress, ',', '.'), '.', 3) AS Part3,
    SPLIT_PART(REPLACE(owneraddress, ',', '.'), '.', 2) AS Part2,
    SPLIT_PART(REPLACE(owneraddress, ',', '.'), '.', 1) AS Part1
FROM house;

-- Creating new columns
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

-- Changing the Y and N to univeral Yes and No in Sold As Vacant field.
SELECT DISTINCT(soldasvacant), COUNT(soldasvacant)
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

-- Remove Duplicates with CTE & Subquery
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

-- Subquery
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

-- Dropping unused table
ALTER TABLE house
DROP COLUMN owneraddress, 
DROP COLUMN taxdistrict, 
DROP COLUMN propertyaddress