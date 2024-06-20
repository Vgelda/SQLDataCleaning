
/*
Cleaning Data with SQL Queries 
*/

select *
from DEPROJECT ..NashvilleHousing 

--Standardize date format

select SaleDate, (CONVERT(date, SaleDate)) as NewSaleDate
from DEPROJECT ..NashvilleHousing 

--Update NashvilleHousing
--SET SaleDate = (CONVERT(Date,SaleDate))
--from DEPROJECT ..NashvilleHousing 
 

Update NashvilleHousing
SET SaleDate = (Select CONVERT(Date,SaleDate) as NewSaleDate) 
from DEPROJECT ..NashvilleHousing 

USE DEPROJECT
ALTER TABLE NashvilleHousing
Add NewSaleDate Date;

--to see if table exist 
--USE DEPROJECT; -- Specify your database name
--SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'NashvilleHousing';

--USE DEPROJECT; -- Specify your database name
--EXEC sp_helprotect 'NashvilleHousing';

--USE DEPROJECT; -- Specify your database name
--SELECT *
--FROM INFORMATION_SCHEMA.TABLES
--WHERE TABLE_NAME = 'NashvilleHousing' AND TABLE_TYPE = 'BASE TABLE';


--use DEPROJECT
--Update NashvilleHousing
--SET SaleDate =  (CONVERT(date, SaleDate)) as NewSaleDate 
--from DEPROJECT..NashvilleHousing 


-- Standardize Date Format


Select saleDate, CONVERT(Date,SaleDate)
From DEPROJECT..NashvilleHousing

use DEPROJECT
Update NashvilleHousing
SET SaleDate = CONVERT(Date,SaleDate) 

-- If it doesn't Update properly

ALTER TABLE NashvilleHousing
Add NewSaleDate Date;


Update NashvilleHousing
SET  NewSaleDate = CONVERT(Date,SaleDate)



 --------------------------------------------------------------------------------------------------------------------------

 --Populate Property Address data

Select *
From DEPROJECT..NashvilleHousing
--where PropertyAddress is null
order by ParcelID


--create a self join 
Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
From DEPROJECT..NashvilleHousing a
JOIN DEPROJECT..NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null


Update a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
From DEPROJECT..NashvilleHousing a
JOIN  DEPROJECT..NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null


--------------------------------------------------------------------------------------------------------------------------

-- Breaking out Address into Individual Columns (Address, City, State)


Select PropertyAddress
From DEPROJECT..NashvilleHousing
--Where PropertyAddress is null
--order by ParcelID


SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 ) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress)) as Address
From DEPROJECT..NashvilleHousing



use DEPROJECT
ALTER TABLE NashvilleHousing
Add PropertySplitAddress Nvarchar(255);

Update NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 )


ALTER TABLE NashvilleHousing
Add PropertySplitCity Nvarchar(255);

Update NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress))



Select *
From DEPROJECT..NashvilleHousing





Select OwnerAddress
From DEPROJECT..NashvilleHousing



Select
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)
From DEPROJECT..NashvilleHousing


use DEPROJECT
ALTER TABLE NashvilleHousing
Add OwnerSplitAddress Nvarchar(255);

----trying this out
--ALTER TABLE NashvilleHousing
--Add  OwnerSplitAddress Nvarchar(255);

--Update NashvilleHousing
--SET OwnerSplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 )


--ALTER TABLE NashvilleHousing
--Add  OwnerSplitCity Nvarchar(255);

--Update NashvilleHousing
--SET  OwnerSplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress))


----end

Update NashvilleHousing
SET OwnerSlitAddress =SUBSTRING(PropertyAddress, 1, CHARINDEX(',', OwnerAddress) -1 )


use DEPROJECT
ALTER TABLE NashvilleHousing
Add OwnerSplitCity Nvarchar(255);



Update NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)



ALTER TABLE NashvilleHousing
Add OwnerSplitState Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)



Select *
From DEPROJECT..NashvilleHousing


-------------------------------------------------------------------------------------------------------------------------


-- Change Y and N to Yes and No in "Sold as Vacant" field

Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From DEPROJECT..NashvilleHousing
Group by SoldAsVacant
order by 2




Select SoldAsVacant, CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END
From DEPROJECT..NashvilleHousing


Update NashvilleHousing
	SET SoldAsVacant = CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END


-----------------------------------------------------------------------------------------------------------------------------------------------------------
-- Remove Duplicates

WITH RowNumCTE AS(
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID, PropertyAddress,SalePrice,SaleDate,LegalReference
		 ORDER BY UniqueID) row_num
From DEPROJECT..NashvilleHousing
--order by ParcelID
)
Select *
From RowNumCTE
Where row_num > 1
Order by PropertySplitAddress



Select *
From DEPROJECT..NashvilleHousing




---------------------------------------------------------------------------------------------------------

-- Delete Unused Columns



Select *
From DEPROJECT..NashvilleHousing


ALTER TABLE DEPROJECT..NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate

---------------------------------------------------------------------------------------------------------

-- Exploratory Data Analysis (EDA) Queries:

--visualized the distribution of properties across different cities


 --Properties per City

SELECT 
 PropertySplitCity,
 COUNT(propertySplitCity) AS Properties_Sold
FROM 
 DEPROJECT..NashvilleHousing
   GROUP BY 
     propertySplitCity
   ORDER BY 
     Properties_Sold DESC;
 ---------------------------------------------------------------------------------------------------------

 --Properties per Owner

 SELECT 
   OwnerName, 
   COUNT(ownername) AS Properties_Owned
FROM 
 DEPROJECT..NashvilleHousing
   WHERE 
      ownerName IS NOT NULL
      GROUP BY 
       OwnerName
      ORDER BY 
       COUNT(ownername) DESC;
---------------------------------------------------------------------------------------------------------
 --Sold Properties per Year

 SELECT 
   YEAR(NewSaleDate) AS year, 
   COUNT(NewSaleDate) AS Properties_Sold
 FROM 
 DEPROJECT..NashvilleHousing
     GROUP BY 
     YEAR(NewSaleDate)
     ORDER BY 
     Properties_Sold DESC
-----------------------------------------------------------------------------------------------------------

--Price Categories and Analysis

WITH PriceCat AS
(
 SELECT *,
 CASE
  WHEN SalePrice <= 100000 THEN 'Cheap'
  WHEN SalePrice > 100000 AND SalePrice <= 1000000 THEN 'Average'
  ELSE 'Expensive'
 END AS Price_Category
 FROM 
  DEPROJECT..NashvilleHousing
)
SELECT
 Price_Category,
 COUNT([UniqueID]) AS Total_Properties
FROM 
 PriceCat
GROUP BY 
 Price_Category;

 -----------------------------------------------------------------------------------------------------------

-- Price Range per City:

 WITH a AS
(
 SELECT *,
 CASE
  WHEN SalePrice <= 100000 THEN 'Cheap'
  WHEN SalePrice > 100000 AND SalePrice <= 1000000 THEN 'Average'
  ELSE 'Expensive'
 END AS Price_Category
 FROM 
  DEPROJECT..NashvilleHousing 
),
b AS
(
 SELECT 
 Price_Category, 
 propertysplitcity,
 COUNT([UniqueID]) AS Range
 FROM 
 a
 GROUP BY 
 Price_Category, 
 propertysplitcity
)
SELECT 
 propertysplitcity,
 Price_Category,
 SUM(range) AS Range
FROM 
 b
GROUP BY 
 propertysplitcity, Price_Category
ORDER BY 
 Range DESC;