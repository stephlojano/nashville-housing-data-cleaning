-- Cleaning Data in SQL Queries! 


--SELECT *
--FROM Housing.dbo.NashvilleHousing

---------------------------------------------------------------------------------------

-- Standardize Data Format (eliminating time, only keeping YYYY/MM/DD)

--SELECT SaleDateConverted, CONVERT(DATE, SaleDate)
--FROM Housing.dbo.NashvilleHousing


------ for some reason, this isn't working !! :/
--UPDATE NashvilleHousing
--SET SaleDate = CONVERT(DATE, SaleDate)


------ the following works!
--ALTER TABLE NashvilleHousing
--ADD SaleDateConverted DATE

--UPDATE NashvilleHousing
--SET SaleDateConverted = CONVERT(DATE, SaleDate)

---------------------------------------------------------------------------------------

-- Populate Property Address Data

--SELECT *
--FROM Housing.dbo.NashvilleHousing
--ORDER BY ParcelID


-- need to do self join to populate property address since ParcelID = PropertyAddress
--SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
--FROM Housing.dbo.NashvilleHousing a 
--JOIN Housing.dbo.NashvilleHousing b
--ON a.ParcelID = b.ParcelID
--AND a.[UniqueID] <> b.[UniqueID]
--WHERE a.PropertyAddress IS NULL


--UPDATE a
--SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
--FROM Housing.dbo.NashvilleHousing a
--JOIN Housing.dbo.NashvilleHousing b
--ON a.ParcelID = b.ParcelID
--AND a.[UniqueID] <> b.[UniqueID]
--WHERE a.PropertyAddress IS NULL

-- nice! now there are none that are NULL ! :)

---------------------------------------------------------------------------------------

-- Breaking out Address into Individual Columns (Address, City, State)

--SELECT PropertyAddress
--FROM Housing.dbo.NashvilleHousing

-- 1 column split into 2 (address, city)
--SELECT 
--	-- - 1  bc we want to eliminate the comma 
--	SUBSTRING(PropertyAddress, 1, CHARINDEX(',' , PropertyAddress) - 1) AS Address,
--	SUBSTRING(PropertyAddress, CHARINDEX(',' , PropertyAddress) + 1, LEN(PropertyAddress)) AS AddressComma
--FROM Housing.dbo.NashvilleHousing

---- another way
--ALTER TABLE NashvilleHousing
--ADD PropertySplitAddress nvarchar(255);

--UPDATE NashvilleHousing
--SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',' , PropertyAddress) - 1) 

--ALTER TABLE NashvilleHousing
--ADD PropertySplitCity nvarchar(255);

--UPDATE NashvilleHousing
--SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',' , PropertyAddress) + 1, LEN(PropertyAddress))

--SELECT *
--FROM Housing.dbo.NashvilleHousing


---------------------------------------------------------------------------------------

-- doing the same for the owner's address!

--SELECT OwnerAddress
--FROM Housing.dbo.NashvilleHousing

---- super easy method to split columns!!
--SELECT 
--	PARSENAME(REPLACE(OwnerAddress, ',','.'), 3),
--	PARSENAME(REPLACE(OwnerAddress, ',','.'), 2),
--	PARSENAME(REPLACE(OwnerAddress, ',','.'), 1)
--FROM Housing.dbo.NashvilleHousing
 

--ALTER TABLE NashvilleHousing
--ADD OwnerSplitAddress nvarchar(255);

--UPDATE NashvilleHousing
--SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',','.'), 3) 


--ALTER TABLE NashvilleHousing
--ADD OwnerSplitCity nvarchar(255);

--UPDATE NashvilleHousing
--SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',','.'), 2)

--ALTER TABLE NashvilleHousing
--ADD OwnerSplitState nvarchar(255);

--UPDATE NashvilleHousing
--SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',','.'), 1)

--SELECT *
--FROM Housing.dbo.NashvilleHousing

---- in case we make mistakes, we can delete columns
--ALTER TABLE NashvilleHousing
--DROP COLUMN OwnerSplitState


---------------------------------------------------------------------------------------

-- change Y and N to Yes and No  in "Sold as Vacant"

--SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
--FROM Housing.dbo.NashvilleHousing
--GROUP BY SoldAsVacant
--ORDER BY 2

--SELECT 
--	SoldAsVacant,
--	CASE 
--		WHEN SoldAsVacant = 'Y' THEN 'Yes'
--		WHEN SoldAsVacant = 'N' THEN 'No'
--		ELSE SoldAsVacant
--	END
--FROM Housing.dbo.NashvilleHousing


---- yay it worked!
--UPDATE NashvilleHousing
--SET SoldAsVacant =
--	CASE 
--		WHEN SoldAsVacant = 'Y' THEN 'Yes'
--		WHEN SoldAsVacant = 'N' THEN 'No'
--		ELSE SoldAsVacant
--	END



---------------------------------------------------------------------------------------

-- Remove Duplicates

WITH rowNumCTE AS
	(
	SELECT *,
		ROW_NUMBER() OVER (PARTITION BY ParcelID,
										PropertyAddress,	
										SalePrice,
										SaleDate,
										LegalReference
										ORDER BY UniqueID) AS row_num
	FROM Housing.dbo.NashvilleHousing
	--ORDER BY ParcelID
	)

SELECT * 
FROM rowNumCTE
WHERE row_num > 1

-- nice ! now there are no duplicates
DELETE 
FROM rowNumCTE
WHERE row_num > 1



---------------------------------------------------------------------------------------

-- Delete Unused Columns

SELECT *
FROM Housing.dbo.NashvilleHousing

ALTER TABLE NashvilleHousing
DROP COLUMN TaxDistrict