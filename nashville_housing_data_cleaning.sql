/*
SQL PROJECT
Title: Cleaning Data in SQL Queries
Dateset: Nashville Housing Data 
Last updated: 2/3/2024

By: Assim Alharbi
Potfolio: github.com/AssimAlahmadi
*/

-- View the data
Select *
FROM NashvilleHousing

--------------------------------------------------------------------------------------------------------------------------

-- Standardize Date Format

-- Creating new SaleDateConverted column
ALTER TABLE NashvilleHousing
Add SaleDateConverted DATE;

-- Updating the SaleDateConverted column
UPDATE NashvilleHousing
SET SaleDateConverted = CONVERT(DATE,SaleDate)

-- Droping the old SaleDate column
ALTER TABLE NashvilleHousing
DROP COLUMN SaleDate

-- Renaming the new column to SaleDate
EXEC sp_rename 'NashvilleHousing.[SaleDateConverted]', 'SaleDate', 'COLUMN'
 --------------------------------------------------------------------------------------------------------------------------

 -- Populate Property Address data

 -- Creating join on the same table to fill the missing values in PropertyAddress
 -- If the UniqueID is the same, on row will go to table a and the other to b 
 SELECT a.ParcelID, b.ParcelID, a.PropertyAddress, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress) MissingPropertyAddress
 FROM NashvilleHousing a
 JOIN NashvilleHousing b
 ON a.ParcelID = b.ParcelID
 AND a.[UniqueID ] <> b.[UniqueID ]
 WHERE a.PropertyAddress IS NULL

 -- Filling the a table with corresponding values from the b table
 UPDATE a
 SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
 FROM NashvilleHousing a
 JOIN NashvilleHousing b
 ON a.ParcelID = b.ParcelID
 AND a.[UniqueID ] <> b.[UniqueID ]
 WHERE a.PropertyAddress IS NULL

 -- Filling the b table with corresponding values from the a table
 UPDATE b
 SET PropertyAddress = ISNULL(b.PropertyAddress, a.PropertyAddress)
 FROM NashvilleHousing a
 JOIN NashvilleHousing b
 ON a.ParcelID = b.ParcelID
 AND a.[UniqueID ] <> b.[UniqueID ]
 WHERE b.PropertyAddress IS NULL

-- No Null values remaining in PropertyAddress
 SELECT PropertyAddress
 FROM NashvilleHousing
 WHERE PropertyAddress IS NULL

--------------------------------------------------------------------------------------------------------------------------

-- Breaking out Address into Individual Columns (Address, City, State)

-- Splitting the PropertyAddress into PropertySplitAddress and PropertySplitCity using SUBSTRING function
SELECT PropertyAddress, SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) as Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 2, LEN(PropertyAddress)) as City
FROM NashvilleHousing

-- Creating new PropertySplitAddress column
ALTER TABLE NashvilleHousing
ADD PropertySplitAddress nvarchar(255);

-- Update the PropertySplitAddress column
UPDATE NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)

-- Creating new PropertySplitCity column
ALTER TABLE NashvilleHousing
ADD PropertySplitCity nvarchar(255);

-- Update the PropertySplitCity column
UPDATE NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 2, LEN(PropertyAddress))

 SELECT *
 FROM NashvilleHousing

 -- Splitting the OwnerAddress into OwnerSplitAddress, OwnerSplitCity and OwnerSplitState using PARSENAME function
 -- We replace the comma with a period to fit the PARSENAME function
 SELECT OwnerAddress, 
 PARSENAME(REPLACE(OwnerAddress,',','.'),3),
 PARSENAME(REPLACE(OwnerAddress,',','.'),2),
 PARSENAME(REPLACE(OwnerAddress,',','.'),1)
 FROM NashvilleHousing

 -- Creating new OwnerSplitAddress column
ALTER TABLE NashvilleHousing
ADD OwnerSplitAddress nvarchar(255);

-- Update the OwnerSplitAddress column
UPDATE NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress,',','.'),3)

-- Creating new OwnerSplitCity column
ALTER TABLE NashvilleHousing
ADD OwnerSplitCity nvarchar(255);

-- Update the OwnerSplitCity column
UPDATE NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress,',','.'),2)

-- Creating new OwnerSplitState column
ALTER TABLE NashvilleHousing
ADD OwnerSplitState nvarchar(255);

-- Update the OwnerSplitState column
UPDATE NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress,',','.'),1)

 -- Before we forget, the columns we just created have spaces at the start
 -- So as a last step we must remove those spaces
 SELECT LEN(OwnerSplitState)
 FROM NashvilleHousing

 -- Remove the first char 
 UPDATE NashvilleHousing
 SET OwnerSplitState = RIGHT(OwnerSplitState, LEN(OwnerSplitState) -1 )

 UPDATE NashvilleHousing
 SET OwnerSplitCity = RIGHT(OwnerSplitCity, LEN(OwnerSplitCity) -1 )

 -- Viewing the table after the changes
 SELECT *
 FROM NashvilleHousing
--------------------------------------------------------------------------------------------------------------------------


-- Change Y and N to Yes and No in "Sold as Vacant" field

-- Using CASE function to replace the values
SELECT SoldAsVacant,
CASE WHEN SoldAsVacant = 'N' THEN 'No'
	 WHEN SoldAsVacant = 'Y' THEN 'Yes'
	 ELSE SoldAsVacant
	 END
FROM NashvilleHousing

-- Updating the SoldAsVacant column
UPDATE NashvilleHousing
SET SoldAsVacant = 
CASE WHEN SoldAsVacant = 'N' THEN 'No'
	 WHEN SoldAsVacant = 'Y' THEN 'Yes'
	 ELSE SoldAsVacant
	 END

-- Viewing the column after the changes
SELECT SoldAsVacant
FROM NashvilleHousing
GROUP BY SoldAsVacant
-----------------------------------------------------------------------------------------------------------------------------------------------------------

-- Remove Duplicates

-- Creating a CTE with a new row_num column representing the duplicates
WITH RowNumCTE AS (
SELECT *,
ROW_NUMBER() OVER (
			PARTITION BY ParcelID,
			PropertyAddress,
			SalePrice,
			SaleDate,
			LegalReference
			ORDER BY UniqueID )
			row_num 
FROM NashvilleHousing
)

-- Delete all duplicates
DELETE
FROM RowNumCTE
WHERE row_num > 1

 -- Viewing the table after the changes
 SELECT *
 FROM NashvilleHousing
---------------------------------------------------------------------------------------------------------

-- Delete Unused Columns

-- Droping unused columns
ALTER TABLE NashvilleHousing
DROP COLUMN OwnerAddress,
			PropertyAddress,
			TaxDistrict

-- Renaming columns to more understandable names
EXEC sp_rename 'NashvilleHousing.[PropertySplitAddress]', 'PropertyAddress', 'COLUMN'
EXEC sp_rename 'NashvilleHousing.[PropertySplitCity]', 'PropertyCity', 'COLUMN'
EXEC sp_rename 'NashvilleHousing.[OwnerSplitAddress]', 'OwnerAddress', 'COLUMN'
EXEC sp_rename 'NashvilleHousing.[OwnerSplitCity]', 'OwnerCity', 'COLUMN'
EXEC sp_rename 'NashvilleHousing.[OwnerSplitState]', 'OwnerState', 'COLUMN'



 -- Viewing the table after the changes
 SELECT *
 FROM NashvilleHousing


