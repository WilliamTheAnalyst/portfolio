-- 1. PRELIMINARY EXPLORATION
SELECT * 
FROM nashvillehousing 
LIMIT 50;

-- 2. STANDARDIZE DATE FORMAT
SELECT 
	SaleDate, 
    STR_TO_DATE(SaleDate, '%M %d, %Y') AS SaleDateFormatted
FROM
	nashvillehousing;

-- 2.1 commit
ALTER TABLE nashvillehousing
ADD COLUMN SaleDateFormatted datetime AFTER SaleDate;

UPDATE nashvillehousing
SET SaleDateFormatted = STR_TO_DATE(SaleDate, '%M %d, %Y');
    
-- 3. POPULATE EMPTY PropertyAddress COLUMN, BASED ON INFERENCE
SELECT COALESCE(CASE WHEN A.PropertyAddress = '' THEN B.PropertyAddress END, B.PropertyAddress), B.PropertyAddress, A.ParcelID, B.ParcelID
FROM nashvillehousing A 
INNER JOIN nashvillehousing B 
ON A.ParcelID = B.ParcelID AND A.UniqueID <> B.UniqueID
WHERE A.PropertyAddress = '' OR A.PropertyAddress IS NULL;

-- 3.1 commit
UPDATE nashvillehousing A 
INNER JOIN nashvillehousing B 
ON A.ParcelID = B.ParcelID AND A.UniqueID <> B.UniqueID
SET 
	A.PropertyAddress = COALESCE(CASE WHEN A.PropertyAddress = '' THEN B.PropertyAddress END, B.PropertyAddress)
WHERE 
	A.PropertyAddress = '' OR A.PropertyAddress IS NULL;

-- 4. EXTRACT ADDRESS, CITY, STATE FROM FULL ADDRESS
SELECT 
	PropertyAddress,
    SUBSTRING(PropertyAddress, 1, INSTR(PropertyAddress, ',') - 1) AS PAddress,
    SUBSTRING(PropertyAddress, INSTR(PropertyAddress, ',') + 2, LENGTH(PropertyAddress)) AS PCity
FROM
	nashvillehousing;

SELECT OwnerAddress,
	SUBSTRING(OwnerAddress, 1, INSTR(OwnerAddress, ',') - 1) AS OAddress,
    SUBSTRING(OwnerAddress, INSTR(OwnerAddress, ',') + 2, LENGTH(OwnerAddress) - LENGTH(SUBSTRING(OwnerAddress, 1, INSTR(OwnerAddress, ',') - 1))-6) AS OCity,
	RIGHT(OwnerAddress, 2) AS OwnerState
FROM nashvillehousing;

-- 4.1 commit
ALTER TABLE nashvillehousing
ADD COLUMN Address NVARCHAR(255) AFTER PropertyAddress;

ALTER TABLE nashvillehousing
ADD COLUMN City NVARCHAR(255) AFTER PropertyAddress;

ALTER TABLE nashvillehousing
ADD COLUMN OState NVARCHAR(255) AFTER OwnerAddress;

ALTER TABLE nashvillehousing
ADD COLUMN OCity NVARCHAR(255) AFTER OwnerAddress;

ALTER TABLE nashvillehousing
ADD COLUMN OAddress NVARCHAR(255) AFTER OwnerAddress;

UPDATE nashvillehousing
SET City = SUBSTRING(PropertyAddress, INSTR(PropertyAddress, ',') + 2, LENGTH(PropertyAddress));

UPDATE nashvillehousing
SET Address = SUBSTRING(PropertyAddress, 1, INSTR(PropertyAddress, ',') - 1);

UPDATE nashvillehousing
SET OState = RIGHT(OwnerAddress, 2);

UPDATE nashvillehousing
SET OCity = SUBSTRING(OwnerAddress, INSTR(OwnerAddress, ',') + 2, LENGTH(OwnerAddress) - LENGTH(SUBSTRING(OwnerAddress, 1, INSTR(OwnerAddress, ',') - 1))-6);

UPDATE nashvillehousing
SET OAddress = SUBSTRING(OwnerAddress, 1, INSTR(OwnerAddress, ',') - 1);

-- 5. STANDARDIZE VALUES
SELECT DISTINCT SoldAsVacant, COUNT(SoldAsVacant) AS PossibleValues
FROM nashvillehousing
GROUP BY SoldAsVacant;

SELECT
	SoldAsVacant,
	CASE
		WHEN SoldAsVacant = 'Y' THEN 'Yes'
        WHEN SoldAsVacant = 'N' THEN 'No'
        ELSE SoldAsVacant 
    END AS SoldAsVacantStd
FROM nashvillehousing;

-- 5.1 commit
UPDATE 
	nashvillehousing
SET 
	SoldAsVacant = 
    CASE
		WHEN SoldAsVacant = 'Y' THEN 'Yes'
        WHEN SoldAsVacant = 'N' THEN 'No'
        ELSE SoldAsVacant 
    END;

-- 6. REMOVE DUPLICATES

WITH RN_CTE AS (
SELECT *, 
    ROW_NUMBER() OVER (
    PARTITION BY ParcelID,
				 PropertyAddress,
                 SaleDate,
                 LegalReference
                 ORDER BY UniqueID) rn
FROM
	nashvillehousing
)
SELECT * 
FROM RN_CTE
WHERE rn > 1;

-- 6.1 commit
WITH RN_CTE AS (
SELECT *, 
    ROW_NUMBER() OVER (
    PARTITION BY ParcelID,
				 PropertyAddress,
                 SaleDate,
                 LegalReference
                 ORDER BY UniqueID) rn
FROM
	nashvillehousing
)
DELETE FROM nashvillehousing USING RN_CTE JOIN nashvillehousing ON RN_CTE.UniqueID = nashvillehousing.UniqueID
WHERE RN_CTE.rn > 1; 

-- 7. DELETE UNUSED COLUMNS
ALTER TABLE nashvillehousing
DROP COLUMN TaxDistrict;

    
    
    
    
    
    
    
    
    
    
    
    
    


-- ALTERNATIVE: STANDARDIZE DATE FORMAT
SELECT 
	SaleDate, 
    RIGHT(SaleDate, 4) AS Year,
    CASE
		WHEN SaleDate LIKE 'Jan%' THEN 01
        WHEN SaleDate LIKE 'Feb%' THEN 02
        WHEN SaleDate LIKE 'Mar%' THEN 03
        WHEN SaleDate LIKE 'Apr%' THEN 04
        WHEN SaleDate LIKE 'May%' THEN 05
        WHEN SaleDate LIKE 'Jun%' THEN 06
        WHEN SaleDate LIKE 'Jul%' THEN 07
        WHEN SaleDate LIKE 'Aug%' THEN 08
        WHEN SaleDate LIKE 'Sept%' THEN 09
        WHEN SaleDate LIKE 'Oct%' THEN 10
        WHEN SaleDate LIKE 'Nov%' THEN 11
        WHEN SaleDate LIKE 'Dec%' THEN 12
        ELSE NULL
    END AS Month,
    SUBSTRING(SaleDate, INSTR(SaleDate, ' '), INSTR(SaleDate, ',') - INSTR(SaleDate, ' ')) AS Date
FROM nashvillehousing;

