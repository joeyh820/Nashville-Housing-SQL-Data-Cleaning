/*

Cleaning Data in SQL Queries
`
*/

SELECT * 
FROM SQL_Project_ETL.dbo.NashvilleHousing
----------------------------------------------------------------------------------------------------------------------

-- Standardize Date Format

SELECT SaleDateConverted, CONVERT(Date, SaleDate)
FROM SQL_Project_ETL.dbo.NashvilleHousing

--- Create a new column and assign type=Date 
ALTER TABLE NashvilleHousing
ADD SaleDateConverted Date;

----  Update the column by converting SaleDate in Data Format
Update NashvilleHousing
SET SaleDateConverted = CONVERT(DATE, SaleDate)

----------------------------------------------------------------------------------------------------------------------

---- Populate Property Address Data

SELECT *
FROM SQL_Project_ETL.dbo.NashvilleHousing
--- Where PropertyAddress is null
Order by ParcelID

--- Create a self-join to see how the Property Address is full of nulls and we will assign it the ISNULL(a.PropertyAddress, b.PropertyAddress)
SELECT 
	a.ParcelID,
	a.PropertyAddress,
	b.ParcelID,
	b.PropertyAddress,
	ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM SQL_Project_ETL.dbo.NashvilleHousing a
JOIN SQL_Project_ETL.dbo.NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID] <> b.[UniqueID] /* For every row where the unique values are different, return a matching Property Address i*/
WHERE a.PropertyAddress is null

-- Update Table a and set the PropertyAddress columns 


UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM SQL_Project_ETL.dbo.NashvilleHousing a
JOIN SQL_Project_ETL.dbo.NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID] <> b.[UniqueID]
WHERE a.PropertyAddress IS NULL

--- Run the penultimate code to check that the table is empty since a.PropertyAddress is no longer null


--------------------------------------------------------------------------------------------------------------------------

-- Breaking out Address into Individual Columns (Address, City, State)

SELECT PropertyAddress
FROM SQL_Project_ETL.dbo.NashvilleHousing

--- Use Substring to Break out address into Address and City
SELECT 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) as Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress)) as Address
FRom SQL_Project_ETL.dbo.NashvilleHousing


ALTER TABLE NashvilleHousing 
Add PropertySplitAddress Nvarchar(255);

UPDATE NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1)


ALTER TABLE NashvilleHousing 
Add PropertySplitCity Nvarchar(255);

UPDATE NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress))


--- Now see the updated changes by creating a view of all the columns, including new ones created above

SELECT * 
FROM SQL_Project_ETL.dbo.NashvilleHousing


----- SEPARATING THE OWNER ADDRESS

SELECT OwnerAddress
FROM SQL_Project_ETL.dbo.NashvilleHousing

-- Extracting City, State, and ZIP Code from the OwnerAddress field
-- The OwnerAddress field contains addresses in the format "Street, City, State"
-- This query uses REPLACE to substitute commas with periods, making the address appear as a dot-separated string.
-- Then, PARSENAME is used to split the address into parts as if they were components of a SQL object name:
-- 1. PARSENAME(...,3) extracts the City as the third part from the right after replacing commas with periods.
-- 2. PARSENAME(...,2) extracts the State as the second part from the right.
-- 3. PARSENAME(...,1) extracts the ZIP Code (or additional address information) as the first part from the right.
-- Note: This assumes the address format consistently follows the pattern "Street, City, State" in the OwnerAddress column.
SELECT 
PARSENAME(REPLACE(OwnerAddress,',', '.'),3),
PARSENAME(REPLACE(OwnerAddress, ',', '.'),2),
PARSENAME(REPLACE(OwnerAddress, ',', '.'),1)
FROM SQL_Project_ETL.dbo.NashvilleHousing

-- Adds a new column 'OwnerSplitAddress' to store the city part of the address
ALTER TABLE NashvilleHousing
Add OwnerSplitAddress Nvarchar(255); -- This column is intended to store a part of the split address

-- Updates the newly added 'OwnerSplitAddress' column with the city extracted from 'OwnerAddress'
UPDATE NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress,',', '.'),3);

-- Adds a new column 'OwnerSplitCity' to store the city part of the address
ALTER TABLE NashvilleHousing
Add OwnerSplitCity  Nvarchar(255); -- This column is specifically for the city component of the address

-- Updates the 'OwnerSplitCity' column with the city extracted from 'OwnerAddress'
UPDATE NashvilleHousing
SET OwnerSplitCity  = PARSENAME(REPLACE(OwnerAddress,',', '.'),2);

-- Adds a new column 'OwnerSplitState' to store the state part of the address
ALTER TABLE NashvilleHousing
Add OwnerSplitState  Nvarchar(255); -- This column is designated for the state component of the address

-- Updates the 'OwnerSplitState' column with the state extracted from 'OwnerAddress'
UPDATE NashvilleHousing
SET OwnerSplitState  = PARSENAME(REPLACE(OwnerAddress,',', '.'),1);

--------------------------------------------------------------------------------------------------------------------------

-- Change Y and N to Yes and No in "Sold as Vacant" field

SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM SQL_Project_ETL.dbo.NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2;


SELECT SoldAsVacant,
CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	 WHEN SoldAsVacant = 'N' THEN 'No'
	 ELSE SoldAsVacant
	 END
FROM SQL_Project_ETL.dbo.NashvilleHousing



--- Update the Table
UPDATE NashvilleHousing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	 WHEN SoldAsVacant = 'N' THEN 'No'
	 ELSE SoldAsVacant
	 END

-----------------------------------------------------------------------------------------------------------------------------------------------------------

-- Remove Duplicates Using a CTE

WITH RowNumCTE AS(
SELECT *,
	ROW_NUMBER() OVER(
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY UniqueID
				 ) row_num
		
FROM SQL_Project_ETL.dbo.NashvilleHousing
)

DELETE 
FROM RowNumCTE
WHERE row_num > 1


--- Test to see if the duplicates still exist. HEre, the table is empty, so it DID WORK!
WITH RowNumCTE AS(
SELECT *,
	ROW_NUMBER() OVER(
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY UniqueID
				 ) row_num
		
FROM SQL_Project_ETL.dbo.NashvilleHousing
)

SELECT * 
FROM RowNumCTE
WHERE row_num > 1
ORDER BY PropertyAddress
 
---------------------------------------------------------------------------------------------------------

-- Delete Unused Columns


SELECT * 
FROM SQL_Project_ETL.dbo.NashvilleHousing


--- We have SaleDateConverted and SaleDate, so we can remove SaleDate
ALTER TABLE SQL_Project_ETL.dbo.NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate


-----------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------

--- Importing Data using OPENROWSET and BULK INSERT	

--  More advanced and looks cooler, but have to configure server appropriately to do correctly
--  Wanted to provide this in case you wanted to try it


--sp_configure 'show advanced options', 1;
--RECONFIGURE;
--GO
--sp_configure 'Ad Hoc Distributed Queries', 1;
--RECONFIGURE;
--GO


--USE PortfolioProject 

--GO 

--EXEC master.dbo.sp_MSset_oledb_prop N'Microsoft.ACE.OLEDB.12.0', N'AllowInProcess', 1 

--GO 

--EXEC master.dbo.sp_MSset_oledb_prop N'Microsoft.ACE.OLEDB.12.0', N'DynamicParameters', 1 

--GO 


---- Using BULK INSERT

--USE PortfolioProject;
--GO
--BULK INSERT nashvilleHousing FROM 'C:\Temp\SQL Server Management Studio\Nashville Housing Data for Data Cleaning Project.csv'
--   WITH (
--      FIELDTERMINATOR = ',',
--      ROWTERMINATOR = '\n'
--);
--GO


---- Using OPENROWSET
--USE PortfolioProject;
--GO
--SELECT * INTO nashvilleHousing
--FROM OPENROWSET('Microsoft.ACE.OLEDB.12.0',
--    'Excel 12.0; Database=C:\Users\alexf\OneDrive\Documents\SQL Server Management Studio\Nashville Housing Data for Data Cleaning Project.csv', [Sheet1$]);
--GO










