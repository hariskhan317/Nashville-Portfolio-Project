-- SQL PROJECT
select *
from Nashville_Portfolio_Project..nashville


--Strandardize Date Format--

-- Add the column with its data type using alter
Alter table nashville
add ConvertedSaleDate Date;

-- Update the column type using updata methode by convert function
update Nashville_Portfolio_Project..nashville
set ConvertedSaleDate = convert(date,SaleDate)
 

-- where Property address is Null --
select *
from Nashville_Portfolio_Project..nashville
where Propertyaddress is NUll


--Using Union to check the null values
select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, isnull(a.PropertyAddress,b.PropertyAddress)
from Nashville_Portfolio_Project..nashville a
JOIN Nashville_Portfolio_Project..nashville b
 ON a.ParcelId = b.ParcelID and
	a.UniqueID <> b.UniqueID
	where a.PropertyAddress is null

--Using the Union in the Update methode to fill up the null values with right one
update a
set PropertyAddress = isnull(a.PropertyAddress,b.PropertyAddress)
from Nashville_Portfolio_Project..nashville a
JOIN Nashville_Portfolio_Project..nashville b
 ON a.ParcelId = b.ParcelID and
	a.UniqueID <> b.UniqueID
	where a.PropertyAddress is null


-- Breaking the PropertyAddress into (address, City)

select PropertyAddress,Address, city
from Nashville_Portfolio_Project..nashville

--Breaking PropertyAddress into Property Address and Property city
select 
PropertyAddress,
SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress) -1) as Addres1s, 
SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,len(PropertyAddress)) as City
from Nashville_Portfolio_Project..nashville

--Creating a column for Property address
Alter table Nashville_Portfolio_Project..nashville
add Split_Property_Address varchar(200);

--Populating the Property address column by breaking the PropertyAddress
update Nashville_Portfolio_Project..nashville
set Split_Property_Address = SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress) -1) 
from Nashville_Portfolio_Project..nashville

--Creating a column for Property City
Alter table Nashville_Portfolio_Project..nashville
add Split_Property_City varchar(200);

--Populating the Property City column by breaking the PropertyAddress
update Nashville_Portfolio_Project..nashville
set Split_Property_City = SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,len(PropertyAddress))
from Nashville_Portfolio_Project..nashville


-- Breaking the Owner Address into (address, City, State)
 select OwnerAddress
 from Nashville_Portfolio_Project..nashville

-- Query for Breaking the Owner Address into (address, City, State) using parsename()
 select OwnerAddress, parsename(replace(OwnerAddress,',','.'),3) as Owner_split_Address, parsename(replace(OwnerAddress,',','.'),2) as Owner_split_City, parsename(replace(OwnerAddress,',','.'),1) as Owner_split_State
  from Nashville_Portfolio_Project..nashville


-- Creating columns Owner_split_Address, Owner_split_CIty, Owner_split_State in the Table
Alter table Nashville_Portfolio_Project..nashville
add Owner_split_Address varchar(200), Owner_split_City varchar(200), Owner_split_State  varchar(200);

-- Populating the Owner_split_Address Column in the Table 
update Nashville_Portfolio_Project..nashville
set Owner_split_Address = parsename(replace(OwnerAddress,',','.'),3)

-- Populating the Owner_split_Address Column in the Table 
update Nashville_Portfolio_Project..nashville
set Owner_split_City = parsename(replace(OwnerAddress,',','.'),2)

-- Populating the Owner_split_Address Column in the Table 
update Nashville_Portfolio_Project..nashville
set Owner_split_State = parsename(replace(OwnerAddress,',','.'),1)


-- Fixing the SoldAsVacant by converting the Y and N into Yes and NO
select distinct(SoldAsVacant), count(SoldAsVacant)
from Nashville_Portfolio_Project..nashville
group by SoldAsVacant

--Case statment for converting the Y and N into Yes and NO
select SoldAsVacant,
case	
	when SoldAsVacant = 'Y' then 'Yes'
	when SoldAsVacant = 'N' then 'No'
	Else SoldAsVacant
	end
from Nashville_Portfolio_Project..nashville

--Updating the column with converting the Y and N into Yes and NO
update Nashville_Portfolio_Project..nashville
set SoldAsVacant = 
 case	
	when SoldAsVacant = 'Y' then 'Yes'
	when SoldAsVacant = 'N' then 'No'
	Else SoldAsVacant
	end
from Nashville_Portfolio_Project..nashville



-- Removing Duplicates

--identify the duplicates
select *, ROW_NUMBER() over(
		partition by ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference
		order by UniqueID
) as rowindex
from Nashville_Portfolio_Project..nashville
order by rowindex desc

--Delete those Duplicates using CTE
with ROW_CTE as(
select *, ROW_NUMBER() over(
		partition by ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference
		order by UniqueID
) as rowindex
from Nashville_Portfolio_Project..nashville 
)
Delete
 from ROW_CTE
 where rowindex >1

-- Confirm it Using this
 Select *
 from ROW_CTE
 where rowindex >1


-- Removing unused Columns

alter table Nashville_Portfolio_Project..nashville
Drop column PropertyAddress, SaleDate, TaxDistrict, OwnerAddress


--View the final Data using this query
select *
from Nashville_Portfolio_Project..nashville