-- Cleaning The Data

CREATE DATABASE NashvilleHousingData;
USE NashvilleHousingData;

-- Changing Table Name

-- Used Table Import Wizard w/o Table Defintion

ALTER TABLE nashvillehousingdata.`nashville housing data for data cleaning`
RENAME TO  nashvillehousingdata.nashville_housing_data;


-- Standardizing Date Format

UPDATE nashville_housing_data
 SET 
  SaleDate = replace(SaleDate, 'January', 1),
  SaleDate = replace(SaleDate, 'February', 2),
  SaleDate = replace(SaleDate, 'March', 3),
  SaleDate = replace(SaleDate, 'April', 4),
  SaleDate = replace(SaleDate, 'May', 5),
  SaleDate = replace(SaleDate, 'June', 6),
  SaleDate = replace(SaleDate, 'July', 7),
  SaleDate = replace(SaleDate, 'August', 8),
  SaleDate = replace(SaleDate, 'September', 9),
  SaleDate = replace(SaleDate, 'October', 10),
  SaleDate = replace(SaleDate, 'November', 11),
  SaleDate = replace(SaleDate, 'December', 12);
  
  
  UPDATE nashville_housing_data
  SET SaleDate = STR_TO_DATE(SaleDate, '%m' '%d,%Y');
  
-- Breaking out address into columns (Address, City, State)
-- Since MySQL does not suppport functions that split strings, I must first create my own.

CREATE FUNCTION SPLIT_STR(
  x VARCHAR(255),
  delim VARCHAR(12),
  pos INT
)
RETURNS VARCHAR(255) DETERMINISTIC
BEGIN 
    RETURN REPLACE(SUBSTRING(SUBSTRING_INDEX(x, delim, pos),
       LENGTH(SUBSTRING_INDEX(x, delim, pos -1)) + 1),
       delim, '')
END$$

DELIMITER ;



SELECT SUBSTRING_INDEX(SUBSTRING_INDEX(propertyaddress, ',', 1), ' ,', -12) as address,
       SUBSTRING_INDEX(SUBSTRING_INDEX(propertyaddress, ' ', 7), ' ', -1) as city
FROM   nashville_housing_data;

  
-- Adding the split strings to columns
  
 ALTER TABLE nashville_housing_data
 ADD COLUMN property_split_address Nvarchar(255);
 
 UPDATE nashville_housing_data
 SET property_split_address = SUBSTRING_INDEX(SUBSTRING_INDEX(propertyaddress, ',', 1), ' ,', -12);
 
 ALTER TABLE nashville_housing_data
 ADD COLUMN property_split_city Nvarchar(255);
 
 UPDATE nashville_housing_data
 SET property_split_city = SUBSTRING_INDEX(SUBSTRING_INDEX(propertyaddress, ' ', 7), ' ', -1);
 
 -- Converting the Y and N fields in soldasvacant to yes and no
 
 SELECT
		SoldAsVacant,                        
		CASE
        WHEN SoldAsVacant = 'Y' THEN 'Yes'
        WHEN SoldAsVacant = 'N' THEN 'No'
        ELSE SoldAsVacant
        END AS SoldAsVacant
 FROM nashville_housing_data;
 
 
UPDATE nashville_housing_data
SET SoldAsVacant = CASE
        WHEN SoldAsVacant = 'Y' THEN 'Yes'
        WHEN SoldAsVacant = 'N' THEN 'No'
        ELSE SoldAsVacant
        END;
        
        
        
        
-- Removing Duplicates

WITH rownumcte AS (

SELECT *,
ROW_NUMBER() OVER (PARTITION BY ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference ORDER BY UniqueID)
FROM nashville_housing_data
) 

DELETE
FROM rownumcte
WHERE parcelid > 1 AND propertyaddress > 1 And saleprice > 1 and saledate > 1 and legalreference > 1;










