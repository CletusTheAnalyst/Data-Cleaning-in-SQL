-- Data Cleaning IN SQL

select *
from PortfolioProject.dbo.NashvilleHousing

-- Standadize date format

Select SaleDate
from PortfolioProject.dbo.NashvilleHousing

-- It happened to be in dataetime format. SO to remove the time

Select SaleDate, convert(date, SaleDate)
from PortfolioProject.dbo.NashvilleHousing

-- could have used the update syntax but update does not change data type. So I  decided to use this instead

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
ALTER COLUMN SaleDate Date

select SaleDate
from PortfolioProject.dbo.NashvilleHousing

--ALTER TABLE PortfolioProject.dbo.NashvilleHousing
--Add SaleDateConverted Date

--Update PortfolioProject.dbo.NashvilleHousing
--SET SaleDateConverted = convert(date, SaleDate)

--Select SaleDateConverted, convert(date, SaleDate)
--from PortfolioProject.dbo.NashvilleHousing

-- Work on the Property Address. Populate the PropertyAddress data

Select PropertyAddress
from PortfolioProject.dbo.NashvilleHousing
where PropertyAddress is NULL

Select *
from PortfolioProject.dbo.NashvilleHousing
--where PropertyAddress is NULL
order by ParcelID

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
from PortfolioProject.dbo.NashvilleHousing a
Join PortfolioProject.dbo.NashvilleHousing b
 on a.ParcelID = b.ParcelID
 and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is NULL


UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
from PortfolioProject.dbo.NashvilleHousing a
Join PortfolioProject.dbo.NashvilleHousing b
 on a.ParcelID = b.ParcelID
 and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is NULL


-- Breaking out Address into individual columns (Address, City, State)

Select PropertyAddress
from PortfolioProject.dbo.NashvilleHousing
--where PropertyAddress is NULL

Select SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) as Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) as Address
from PortfolioProject.dbo.NashvilleHousing

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
Add PropertySplitAddress Nvarchar(255)

UPDATE PortfolioProject.dbo.NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
Add PropertySplitCity Nvarchar(255)

UPDATE PortfolioProject.dbo.NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))


Select *
from PortfolioProject.dbo.NashvilleHousing

-- Let us look at the owner's address

Select OwnerAddress
from PortfolioProject.dbo.NashvilleHousing

-- The ownerAddress happen to have number, city and state all together. We need to separate them (deliminating) so as to have minimum information in a single column 

Select 
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3) as Address
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2) as City,
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1) as State
from PortfolioProject.dbo.NashvilleHousing



ALTER TABLE PortfolioProject.dbo.NashvilleHousing
Add OwnerSplitAddress Nvarchar(255)

UPDATE PortfolioProject.dbo.NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
Add OwnerSplitCity Nvarchar(255)

UPDATE PortfolioProject.dbo.NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
Add OwnerSplitState Nvarchar(255)

UPDATE PortfolioProject.dbo.NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)


Select *
from PortfolioProject.dbo.NashvilleHousing

-- Change Y and N to Yes and No in "Sold as Vacant Field

Select Distinct(SoldAsVacant), count(SoldAsVacant)
from PortfolioProject.dbo.NashvilleHousing
GROUP BY SoldAsVacant
order by 2

Select SoldAsVacant
, CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
       WHEN SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END
from PortfolioProject.dbo.NashvilleHousing



UPDATE PortfolioProject.dbo.NashvilleHousing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
       WHEN SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END


-- Remove Duplicates. I will use CTE and some window values to find where they are

WITH RowNumCTE AS(
Select *,
   ROW_NUMBER() OVER (
   PARTITION BY ParcelID,
				PropertyAddress,
				SalePrice,
				SaleDate,
				LegalReference
				ORDER BY
					UniqueID
					) row_num

from PortfolioProject.dbo.NashvilleHousing
--order by ParcelID
)
Select *    -- WITH THE DELETE we delete all the duplicates rows, then we check back to see using the Select *
from RowNumCTE
where row_num > 1
Order by PropertyAddress



-- Delete Unused Columns


Select *
from PortfolioProject.dbo.NashvilleHousing


ALTER TABLE PortfolioProject.dbo.NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress


ALTER TABLE PortfolioProject.dbo.NashvilleHousing
DROP COLUMN SaleDate

--from PortfolioProject.dbo.NashvilleHousing




