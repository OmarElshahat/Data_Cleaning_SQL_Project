/*
Data Cleaning
*/


SELECT *
FROM `data_cleaning`.`nashville housing`;

-- Fixing Date Format

Select saleDateConverted, CAST(SaleDate AS Date)
From `data_cleaning`.`nashville housing`

Update `data_cleaning`.`nashville housing`
SET SaleDate = CAST(SaleDate AS Date)

-- Exploring Duplicate Address data

Select *
From `data_cleaning`.`nashville housing`
Where PropertyAddress is null
order by ParcelID

-- Fixing Duplicate Address Data Problem

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, IFNULL(a.PropertyAddress,b.PropertyAddress)
From `data_cleaning`.`nashville housing` a
JOIN `data_cleaning`.`nashville housing` b
	on a.ParcelID = b.ParcelID
	AND a.UniqueID  <> b.UniqueID 
Where a.PropertyAddress is  null


Update a
SET PropertyAddress = IFNULL(a.PropertyAddress,b.PropertyAddress)
From `data_cleaning`.`nashville housing` a
JOIN `data_cleaning`.`nashville housing` b
	on a.ParcelID = b.ParcelID
	AND a.UniqueID  <> b.UniqueID 
Where a.PropertyAddress is null

-- Spliting Address into Columns (Address, City)

SELECT
SUBSTRING(PropertyAddress, 1, LOCATE(',', PropertyAddress) -1 ) as Address
, SUBSTRING(PropertyAddress, LOCATE(',', PropertyAddress) + 1 , LENGTH(PropertyAddress)) as Address
FROM `data_cleaning`.`nashville housing`;

ALTER TABLE `data_cleaning`.`nashville housing`
Add PropertySplitAddress Nvarchar(255);

Update `data_cleaning`.`nashville housing`
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, LOCATE(',', PropertyAddress) -1 )


ALTER TABLE `data_cleaning`.`nashville housing`
Add PropertySplitCity Nvarchar(255);

Update `data_cleaning`.`nashville housing`
SET PropertySplitCity =  SUBSTRING(PropertyAddress, LOCATE(',', PropertyAddress) + 1 , LENGTH(PropertyAddress))


SELECT OwnerAddress,
SUBSTRING(OwnerAddress, 1, LOCATE(',', OwnerAddress) -1 ) as Address
, SUBSTRING(OwnerAddress, LOCATE(',', OwnerAddress) + 1 , INSTR(OwnerAddress, RIGHT(OwnerAddress,3)))
 as City ,
Right(OwnerAddress,2) as State
FROM `data_cleaning`.`nashville housing`;

ALTER TABLE `data_cleaning`.`nashville housing`
Add Address Nvarchar(255);

Update `data_cleaning`.`nashville housing`
SET Address = SUBSTRING(OwnerAddress, 1, LOCATE(',', OwnerAddress) -1 ) 

ALTER TABLE `data_cleaning`.`nashville housing`
Add City Nvarchar(255);

Update `data_cleaning`.`nashville housing`
SET City =  SUBSTRING(OwnerAddress, LOCATE(',', OwnerAddress) + 1 , INSTR(OwnerAddress, RIGHT(OwnerAddress,3)))

ALTER TABLE `data_cleaning`.`nashville housing`
Add State Nvarchar(255);

Update `data_cleaning`.`nashville housing`
SET State =  Right(OwnerAddress,2)

-- Change Yes and No to Y and N in "Sold as Vacant" field

SELECT DISTINCT SoldAsVacant
FROM `data_cleaning`.`nashville housing`;

SELECT DISTINCT SoldAsVacant ,replace(SoldAsVacant,'No','N') ,replace(SoldAsVacant,'Yes','Y')
FROM `data_cleaning`.`nashville housing`;

Update `data_cleaning`.`nashville housing`
SET SoldAsVacant =  REPLACE(SoldAsVacant,'No','N')

Update `data_cleaning`.`nashville housing`
SET SoldAsVacant =  REPLACE(SoldAsVacant,'Yes','Y')



-- Remove Duplicates

WITH RowNumCTE AS(
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,				
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num

From `data_cleaning`.`nashville housing`
order by ParcelID
)
Select *
From RowNumCTE
Where row_num > 1
Order by PropertyAddress

WITH RowNumCTE AS(
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,				
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num

From `data_cleaning`.`nashville housing`
order by ParcelID
)
DELETE
From RowNumCTE
Where row_num > 1
Order by PropertyAddress




-- Delete Unused Columns



ALTER TABLE PortfolioProject.dbo.NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate

