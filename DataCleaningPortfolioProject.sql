/****** Script for SelectTopNRows command from SSMS  ******/
SELECT TOP (1000) *
  FROM [PortfoliooProject].[dbo].[NashvilleHousing]


  /*
  Cleaning data in SQL Queries
  */

select saledate from portfoliooproject..nashvillehousing;

update nashvillehousing
set saledate = convert(date, saledate);

alter table nashvillehousing
add saledateConverted date;

update nashvillehousing
set saledateConverted = convert(date, saledate);

---------------------------------------------------------

--populate propertyAddress coloumn if it is null


select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress--, isnull(a.PropertyAddress, b.PropertyAddress)
from NashvilleHousing a
join NashvilleHousing b
on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
where b.propertyAddress is null;

update a
set PropertyAddress = isnull(a.PropertyAddress, b.PropertyAddress)
from NashvilleHousing a
join NashvilleHousing b
on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
where a.propertyAddress is null;


-----------------------------------------------------------------------------


--Breaking out address into individual coloumns (address, city, state, country)


select PropertyAddress 
from PortfoliooProject.dbo.NashvilleHousing;

select
substring(PropertyAddress, 1, charindex(',', propertyAddress) -1) as address,
substring(PropertyAddress, charindex(',', PropertyAddress) +1, len(PropertyAddress)) as address

from PortfoliooProject.dbo.nashvillehousing;

alter table nashvillehousing
add PropertyStreet nvarchar(255),
Propertycity nvarchar(255);

update nashvillehousing
set PropertyStreet = substring(PropertyAddress, 1, charindex(',', propertyAddress) -1);

update NashvilleHousing 
set PropertyCity = substring(PropertyAddress, charindex(',', PropertyAddress) +1, len(PropertyAddress));


--owner(easy method to split address
-------

select 
parsename(replace(OwnerAddress, ',', '.'), 3),
parsename(replace(OwnerAddress, ',', '.'), 2),
parsename(replace(OwnerAddress, ',', '.'), 1)
from PortfoliooProject.dbo.NashvilleHousing;

alter table NashvilleHousing
add OwnerStreet nvarchar(50),
OwnerTown nvarchar(15),
OwnerState nvarchar(20);


update NashvilleHousing
set OwnerStreet = parsename(replace(OwnerAddress, ',', '.'), 3);

update NashvilleHousing
set OwnerTown = parsename(replace(OwnerAddress, ',', '.'), 2);

update NashvilleHousing
set OwnerState = parsename(replace(OwnerAddress, ',', '.'), 1);



--------------------------------------------------------------------------------------

--Change y and N to Yes and No in SoldAsVacant field

select distinct(Soldasvacant), count(soldasvacant)
from PortfoliooProject.dbo.NashvilleHousing
group by SoldAsVacant
order by 2;


select soldasvacant,
  case when soldasvacant = 'Y' then 'Yes'
	   when soldasvacant = 'N' then 'No'
	   else soldasvacant
	   end
from PortfoliooProject.dbo.NashvilleHousing;


update NashvilleHousing
set SoldAsVacant = case when SoldAsVacant = 'Y' then 'Yes'
						when SoldAsVacant = 'N' then 'No'
						else SoldAsVacant
						end;



----------------------------------------------------------------------------------------------------------


--Remove Duplicates

--For deleting duplicate values
with RowNumCTE as (
select *, 
	ROW_NUMBER() over(
	partition by parcelid,
				 propertyaddress,
				 saleprice,
				 saledate,
				 legalreference
				 order by
				   uniqueid
				   ) row_num

from PortfoliooProject.dbo.NashvilleHousing
--order by ParcelID
)

Delete from RowNumCTE
where row_num > 1;
--order by propertyaddress;



--for viewing duplicate values
with RowNumCTE as (
select *, 
	ROW_NUMBER() over(
	partition by parcelid,
				 propertyaddress,
				 saleprice,
				 saledate,
				 legalreference
				 order by
				   uniqueid
				   ) row_num

from PortfoliooProject.dbo.NashvilleHousing
--order by ParcelID
)

select * from RowNumCTE
where row_num > 1
order by propertyaddress;






------------------------------------------------------------------------------------------



--Delete unused coloumn

alter table PortfoliooProject.dbo.NashvilleHousing
drop column OwnerAddress, TaxDistrict, PropertyAddress;