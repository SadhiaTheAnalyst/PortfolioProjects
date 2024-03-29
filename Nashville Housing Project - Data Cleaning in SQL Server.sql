/*

Clean data using SQL server 

*/


Select *
From PortfolioProject.dbo.NashvilleHousing

--------------------------------------------------------------------------------------------------------------------------

-- Standardize Date Format


Select saleDateConverted, CONVERT(Date,SaleDate)
From PortfolioProject.dbo.NashvilleHousing


Update NashvilleHousing
SET SaleDate = CONVERT(Date,SaleDate)

-- If it doesn't Update properly

ALTER TABLE NashvilleHousing
Add SaleDateConverted Date;

Update NashvilleHousing
SET SaleDateConverted = CONVERT(Date,SaleDate)


 --------------------------------------------------------------------------------------------------------------------------

-- Populate Property Address data

Select *
From PortfolioProject.dbo.NashvilleHousing
--Where PropertyAddress is null
order by ParcelID



Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
From PortfolioProject.dbo.NashvilleHousing As a
JOIN PortfolioProject.dbo.NashvilleHousing As b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null


Update a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
From PortfolioProject.dbo.NashvilleHousing As a
JOIN PortfolioProject.dbo.NashvilleHousing As b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null



--------------------------------------------------------------------------------------------------------------------------

-- Breaking out Address into Individual Columns (Address, City, State)

Select PropertyAddress
From PortfolioProject.dbo.NashvilleHousing
--Where PropertyAddress is null
--order by ParcelID

SELECT 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) As Address -- the -1 gets rid of the coma 
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+ 1, LEN(PropertyAddress)) As City -- here +1 gets rid of the Comma 

From PortfolioProject.dbo.NashvilleHousing

ALTER TABLE NashvilleHousing
Add PropertySplitAddress Nvarchar(255);

Update NashvilleHousing
SET  PropertySplitAddress= SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1)

ALTER TABLE NashvilleHousing
Add PropertySplitCity Nvarchar(255);

Update NashvilleHousing
SET PropertySplitCity= SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+ 1, LEN(PropertyAddress))


SELECT *

From PortfolioProject.dbo.NashvilleHousing



--now we will seperate OwnerAddress but this time using PARSENAME method, keep in mind PARSENAME Works backwrard like 3,2,1

SELECT OwnerAddress
From PortfolioProject.dbo.NashvilleHousing

SELECT
PARSENAME(REPLACE(OwnerAddress,',', '.'),3)  -- Since "parsename" only looks for period we replace the comma with period 
,PARSENAME(REPLACE(OwnerAddress,',', '.'),2) 
,PARSENAME(REPLACE(OwnerAddress,',', '.'),1) 
From PortfolioProject.dbo.NashvilleHousing


ALTER TABLE NashvilleHousing
Add OwnerSplitAddress Nvarchar(255);

Update NashvilleHousing
SET  OwnerSplitAddress= PARSENAME(REPLACE(OwnerAddress,',', '.'),3)

ALTER TABLE NashvilleHousing
Add OwnerSplitCity Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitCity= PARSENAME(REPLACE(OwnerAddress,',', '.'),2)

ALTER TABLE NashvilleHousing
Add OwnerSplitState Nvarchar(255);

Update NashvilleHousing
SET  OwnerSplitState= PARSENAME(REPLACE(OwnerAddress,',', '.'),1)


SELECT *

From PortfolioProject.dbo.NashvilleHousing
--------------------------------------------------------------------------------------------------------------------------


-- Change Y and N to Yes and No in "Sold as Vacant" field

SELECT DISTINCT(SoldAsVacant), Count(SoldAsVacant)
FROM PortfolioProject.dbo.NashvilleHousing
Group By SoldAsVacant
Order by 2


SELECT SoldAsVacant
, Case when SoldAsVacant='Y' Then 'Yes'
	   when SoldAsVacant = 'N' Then 'No'
	   ElSE SoldAsVacant
	   END
FROM PortfolioProject.dbo.NashvilleHousing;

Update NashvilleHousing
SET SoldAsVacant= Case when SoldAsVacant='Y' Then 'Yes'
	   when SoldAsVacant = 'N' Then 'No'
	   ElSE SoldAsVacant
	   END


-----------------------------------------------------------------------------------------------------------------------------------------------------------

-- Remove Duplicates


WITH RowNumCTE AS(
SELECT *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
		     PropertyAddress,
		     SalePrice,
		     SaleDate,
		     LegalReference
		     ORDER by 
		     UniqueID
		     ) row_num

From PortfolioProject.dbo.NashvilleHousing
--Order by ParcelID
)
SELECT *
From RowNumCTE
where row_num> 1
--Order by PropertyAddress



---------------------------------------------------------------------------------------------------------

-- Delete Unused Columns

SELECT *
From PortfolioProject.dbo.NashvilleHousing

ALTER Table PortfolioProject.dbo.NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, 



--if you forget to delete a column in the previous alter table ex you can add again to delete shown below and execute the below query and it will apply the chnages 

ALTER Table PortfolioProject.dbo.NashvilleHousing
DROP COLUMN SaleDate








