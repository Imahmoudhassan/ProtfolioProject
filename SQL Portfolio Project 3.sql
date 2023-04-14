/*
Cleaning Data in SQL Queries
*/

select *
from PortfolioProject.dbo.NashvilleHousing


--------------------------------------------------------------------------------------------------------------------------

-- Standardize Date Format


select SaleDateConverted, convert(Date,SaleDate)
from PortfolioProject.dbo.NashvilleHousing


update NashvilleHousing
Set SaleDate = convert(Date,SaleDate)



ALTER TABLE NashvilleHousing
add SaleDateConverted Date;


update NashvilleHousing
Set SaleDateConverted = convert(Date,SaleDate)



 --------------------------------------------------------------------------------------------------------------------------

-- Populate Property Address data

select *
from PortfolioProject.dbo.NashvilleHousing
--WHERE PropertyAddress IS NULL
ORDER BY ParcelID




select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, isnull(a.PropertyAddress,b.PropertyAddress)
from PortfolioProject.dbo.NashvilleHousing a
JOIN PortfolioProject.dbo.NashvilleHousing b
    ON a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null



update a
set PropertyAddress = isnull(a.PropertyAddress,b.PropertyAddress)
from PortfolioProject.dbo.NashvilleHousing a
JOIN PortfolioProject.dbo.NashvilleHousing b
    ON a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null





--------------------------------------------------------------------------------------------------------------------------

-- Breaking out Address into Individual Columns (Address, City, State)


select PropertyAddress
from PortfolioProject.dbo.NashvilleHousing
--WHERE PropertyAddress IS NULL
--ORDER BY ParcelID


select 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, len (PropertyAddress)) as Address

from PortfolioProject.dbo.NashvilleHousing


ALTER TABLE NashvilleHousing
add PropertySplitAddress nvarchar(255);


update NashvilleHousing
Set PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)


ALTER TABLE NashvilleHousing
add PropertySplitCity nvarchar(255);


update NashvilleHousing
Set PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, len (PropertyAddress))



select *
from PortfolioProject.dbo.NashvilleHousing


select OwnerAddress
from PortfolioProject.dbo.NashvilleHousing


select 
PARSENAME(replace(OwnerAddress,',', '.') ,3)
, PARSENAME(replace(OwnerAddress,',', '.') ,2)
, PARSENAME(replace(OwnerAddress,',', '.') ,1)
from PortfolioProject.dbo.NashvilleHousing



ALTER TABLE NashvilleHousing
add OwnerSplitAddress nvarchar(255);


update NashvilleHousing
Set OwnerSplitAddress = PARSENAME(replace(OwnerAddress,',', '.') ,3)


ALTER TABLE NashvilleHousing
add OwnerSplitCity nvarchar(255);


update NashvilleHousing
Set OwnerSplitCity = PARSENAME(replace(OwnerAddress,',', '.') ,2)


ALTER TABLE NashvilleHousing
add OwnerSplitState nvarchar(255);


update NashvilleHousing
Set OwnerSplitState =  PARSENAME(replace(OwnerAddress,',', '.') ,1)



select *
from PortfolioProject.dbo.NashvilleHousing



--------------------------------------------------------------------------------------------------------------------------


-- Change Y and N to Yes and No in "Sold as Vacant" field

select distinct(SoldAsVacant), count(SoldAsVacant)
from PortfolioProject.dbo.NashvilleHousing
group by SoldAsVacant
order by 2



select SoldAsVacant
, case when SoldAsVacant = 'Y' THEN 'YES'
       WHEN SoldAsVacant = 'N' THEN 'NO'
	   ELSE SoldAsVacant
	   END
from PortfolioProject.dbo.NashvilleHousing


UPDATE NashvilleHousing
SET SoldAsVacant = case when SoldAsVacant = 'Y' THEN 'YES'
       WHEN SoldAsVacant = 'N' THEN 'NO'
	   ELSE SoldAsVacant
	   END









-----------------------------------------------------------------------------------------------------------------------------------------------------------

-- Remove Duplicates

 WITH RowNumCTE AS(
 SELECT *,
       ROW_NUMBER()OVER(
       PARTITION BY ParcelID,
	               PropertyAddress,
				   SalePrice,
				   SaleDate,
				   LegalReference
				   ORDER BY 
				        UniqueID
				        ) row_num

 FROM PortfolioProject.dbo.NashvilleHousing
 --ORDER BY ParcelID
 --where 
 )
  
 --DELETE
 SELECT *
 FROM RowNumCTE
 WHERE row_num > 1
 ORDER BY PropertyAddress

 SELECT * 
 FROM PortfolioProject.dbo.NashvilleHousing













---------------------------------------------------------------------------------------------------------

-- Delete Unused Columns


 SELECT * 
 FROM PortfolioProject.dbo.NashvilleHousing



 ALTER TABLE PortfolioProject.dbo.NashvilleHousing
 DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress


 ALTER TABLE PortfolioProject.dbo.NashvilleHousing
 DROP COLUMN SaleDate





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

