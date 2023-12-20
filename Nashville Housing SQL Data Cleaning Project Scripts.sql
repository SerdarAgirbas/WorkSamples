/* CLEANING DATA IN SQL QUERIES */

SELECT SaleDateConverted
FROM dbo.NashvilleHousing


-- STANDARDIZE DATE FORMAT

SELECT SaleDate, CONVERT(Date, SaleDate)
FROM NashvilleHousing

UPDATE NashvilleHousing
SET SaleDate = CONVERT(Date, SaleDate)

ALTER TABLE NashvilleHousing
Add SaleDateConverted Date;

UPDATE NashvilleHousing
SET SaleDateConverted = CONVERT(Date, SaleDate)

-- POPULATE PROPERTY ADDRESS DATA

SELECT *
FROM PortfolioProject.dbo.NashvilleHousing
--WHERE PropertyAddress is null
order by ParcelID

-- SELF JOIN TO IDENTIFY DUPLICATE ADDRESS INFO WITH NULL VALUES IN PROPERTY ADDRESS COLUMN and REPLACING NULL VALUE WITH VALUE IN PROPERTY ADDRESS COLUMN

SELECT A.ParcelID, A.PropertyAddress, B.ParcelID, B.PropertyAddress, ISNULL(A.PropertyAddress, B.PropertyAddress)
FROM NashvilleHousing A
JOIN NashvilleHousing B
	ON A.ParcelID = B.ParcelID
	AND A.[UniqueID ] != B.[UniqueID ]
WHERE A.PropertyAddress is null

UPDATE A
SET PropertyAddress = ISNULL(A.PropertyAddress, B.PropertyAddress)
FROM NashvilleHousing A
JOIN NashvilleHousing B
	ON A.ParcelID = B.ParcelID
	AND A.[UniqueID ] != B.[UniqueID ]
WHERE A.PropertyAddress is null

-- BREAKING OUT PROPERTY ADDRESS INTO INDIVIDUAL COLUMNS (ADDRESS, CITY) WITH SUBSTRING

SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 ) as Address,
substring(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) as Address
FROM NashvilleHousing

ALTER TABLE NashvilleHousing
Add PropertyStreet Nvarchar(255);

UPDATE NashvilleHousing
SET PropertyStreet = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 )

ALTER TABLE NashvilleHousing
Add PropertyCity Nvarchar(255);

UPDATE NashvilleHousing
SET PropertyCity = substring(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))

SELECT PropertyStreet, PropertyCity
FROM NashvilleHousing

-- BREAKING OUT OWNER ADDRESS INTO INDIVIDUAL COLUMNS (ADDRESS, CITY, STATE) WITH PARSENAME

SELECT TOP 1000 *
FROM NashvilleHousing

ALTER TABLE NashvilleHousing
Add OwnerStreet Nvarchar(255);

UPDATE NashvilleHousing
SET OwnerStreet = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)

ALTER TABLE NashvilleHousing
Add OwnerCity Nvarchar(255);

UPDATE NashvilleHousing
SET OwnerCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)

ALTER TABLE NashvilleHousing
Add OwnerState Nvarchar(255);

UPDATE NashvilleHousing
SET OwnerState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)

-- CHANGE Y and N to YES and NO in "Sold as Vacant" field

SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM PortfolioProject.dbo.NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2;

SELECT SoldAsVacant,
	CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
		WHEN SoldAsVacant = 'N' THEN 'No'
		ELSE SoldAsVacant
		END
FROM NashvilleHousing

UPDATE NashvilleHousing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
		WHEN SoldAsVacant = 'N' THEN 'No'
		ELSE SoldAsVacant
		END

-- REMOVE DUPLICATES

WITH RowNumCTE AS(
SELECT *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				PropertyAddress,
				SalePrice,
				SaleDate,
				LegalReference
				ORDER BY
					UniqueID
					) row_num
FROM NashvilleHousing
--ORDER BY ParcelID
)
SELECT *
FROM RowNumCTE
WHERE row_num > 1
--ORDER BY PropertyAddress

-- DELETING UNUSED COLUMNS

ALTER TABLE NashvilleHousing
DROP COLUMN PropertyAddress, SaleDate, OwnerAddress, TaxDistrict

SELECT *
FROM NashvilleHousing











-- 


