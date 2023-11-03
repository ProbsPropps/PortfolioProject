SELECT *
FROM [Portfolio Project]..NashvilleHousing


-- Standardize SaleDate


ALTER TABLE NashvilleHousing ALTER COLUMN SaleDate DATE


-- Cleaning Property Address


SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress
FROM [Portfolio Project]..NashvilleHousing a
JOIN [Portfolio Project]..NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM [Portfolio Project]..NashvilleHousing a
JOIN [Portfolio Project]..NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL


--Separate Property Address into Individual Columns


SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress)+1, LEN(PropertyAddress)) as City
FROM [Portfolio Project]..NashvilleHousing

ALTER TABLE NashvilleHousing
ADD PropertySplitAddress nvarchar(255)

UPDATE NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1)

ALTER TABLE NashvilleHousing
ADD PropertySplitCity nvarchar(255)

UPDATE NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress)+1, LEN(PropertyAddress))


-- Split Owner Address into Individual Columns


SELECT
PARSENAME(REPLACE(OwnerAddress, ',','.'), 3)
, PARSENAME(REPLACE(OwnerAddress, ',','.'), 2)
, PARSENAME(REPLACE(OwnerAddress, ',','.'), 1)
FROM [Portfolio Project]..NashvilleHousing

ALTER TABLE NashvilleHousing
ADD OwnerSplitAddress nvarchar(255)

UPDATE NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',','.'), 3)

ALTER TABLE NashvilleHousing
ADD OwnerSplitCity nvarchar(255)

UPDATE NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',','.'), 2)

ALTER TABLE NashvilleHousing
ADD OwnerSplitState nvarchar(255)

UPDATE NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',','.'), 1)


-- Simplify 'Yes' 'No' 'Y' 'N' Responses in SoldAsVacant


SELECT SoldAsVacant
, CASE
	WHEN SoldAsVacant = 'Y' THEN 'Yes'
	WHEN SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
	END
FROM [Portfolio Project]..NashvilleHousing

UPDATE NashvilleHousing
SET SoldAsVacant = CASE
	WHEN SoldAsVacant = 'Y' THEN 'Yes'
	WHEN SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
	END


-- Remove Duplicates
-- I understand standard practice is to never fully delete data. For demonstration purposes I am choosing to do so.


WITH RowNumCTE AS(
SELECT *,
ROW_NUMBER() OVER( PARTITION BY ParcelID, PropertyAddress, SaleDate, SalePrice, LegalReference ORDER BY UniqueID) row_num
FROM [Portfolio Project]..NashvilleHousing
)
DELETE
FROM RowNumCTE
WHERE row_num > 1


-- Delete Unused Columns
-- Again, I understand this is against standard practice. For demonstration purposes only.


SELECT *
FROM [Portfolio Project]..NashvilleHousing

ALTER TABLE [Portfolio Project]..NashvilleHousing
DROP COLUMN PropertyAddress, OwnerAddress,TaxDistrict
