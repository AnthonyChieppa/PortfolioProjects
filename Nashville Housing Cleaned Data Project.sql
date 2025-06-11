Select * 
From NashvilleHousing

---- Populate Property Address data
-- COALESCE is used to return the address if b.address has a null value.
-- ISNULL does not work in this instance on PostgreSQL.
-- The inclusion of parcelid allows blank addresses (null values on table b)
-- to be filled in by matching parcelid that contain an address.

Select * 
From NashvilleHousing
--Where propertyaddress IS NULL
Order by parcelid

Update NashvilleHousing
SET propertyaddress = COALESCE(b.propertyaddress, NashvilleHousing.propertyaddress)
From NashvilleHousing b
Where NashvilleHousing.parcelid = b.parcelid
		AND NashvilleHousing.uniqueid <> b.uniqueid
		AND NashvilleHousing.propertyaddress IS NULL

-- CHECK to see if update fixed null values
Select propertyaddress
From NashvilleHousing
Where propertyaddress IS NULL


---- Breaking out Address into Individual Columns (Address, City, State)
-- CHARINDEX is used in MYSQL instead of Position.
-- -1 and +1 remove the delemiter (comma) from the address.

Select propertyaddress
From NashvilleHousing
--Where propertyaddress IS NULL
--Order by parcelid

Select 
Substring(propertyaddress, 1, Position(',' In propertyaddress) - 1) as Address
	--, Position(',' In propertyaddress)
	, Substring(propertyaddress, Position(',' In propertyaddress) + 1, Length(propertyaddress)) as Address
From NashvilleHousing

Alter Table NashvilleHousing 
Add PropertySplitAddress varchar(255)
	
Update NashvilleHousing
Set PropertySplitAddress = Substring(propertyaddress, 1, Position(',' In propertyaddress) - 1)

Alter Table NashvilleHousing 
Add PropertySplitCity varchar(255)
	
Update NashvilleHousing
Set PropertySplitCity = Substring(propertyaddress, Position(',' In propertyaddress) + 1, Length(propertyaddress))

Select owneraddress
From NashvilleHousing

Select 
SPLIT_PART(REPLACE(owneraddress, ',', '.'), '.', 1)
, SPLIT_PART(REPLACE(owneraddress, ',', '.'), '.', 2)
, SPLIT_PART(REPLACE(owneraddress, ',', '.'), '.', 3)
From NashvilleHousing


Alter Table NashvilleHousing 
Add OwnerSplitAddress varchar(255)
Alter Table NashvilleHousing 
Add OwnerSplitCity varchar(255)
Alter Table NashvilleHousing 
Add OwnerSplitSate varchar(255)

Update NashvilleHousing
Set OwnerSplitAddress = SPLIT_PART(REPLACE(owneraddress, ',', '.'), '.', 1)
	
Update NashvilleHousing
Set OwnerSplitCity = SPLIT_PART(REPLACE(owneraddress, ',', '.'), '.', 2)
	
Update NashvilleHousing
Set OwnerSplitSate = SPLIT_PART(REPLACE(owneraddress, ',', '.'), '.', 3)


---- Change Y and N to Yes and No in "Sold as Vacant" field

Select Distinct(soldasvacant), Count(soldasvacant)
From NashvilleHousing
Group by soldasvacant
Order by 2

Select soldasvacant
, Case When soldasvacant = 'Y' Then 'Yes'
		When soldasvacant = 'N' Then 'No'
		Else soldasvacant
		END
From NashvilleHousing

Update NashvilleHousing
Set soldasvacant = 
		Case When soldasvacant = 'Y' Then 'Yes'
		When soldasvacant = 'N' Then 'No'
		Else soldasvacant
		END


---- Remove Duplicates
-- RowNumCTE is inside a subsquery so it can be used as a refrence to be deleted. 

With RowNumCTE As(
Select uniqueid
	From (
	Select uniqueid,
		Row_number() Over (
		Partition by parcelid,
					propertyaddress,
					saleprice,
					saledate,
					legalreference
					Order by 
						uniqueid
						) as row_num
From NashvilleHousing
--Order by parcelid
) -- This is a subquery which allows to delete non-unique columns if they meet the requirements.
Where row_num > 1
)
--DELETE From NashvilleHousing
--Where uniqueid In (Select uniqueid From RowNumCTE)
Select *
From NashvilleHousing
Where uniqueid In (Select uniqueid From RowNumCTE)
Order by propertyaddress


---- Delete Unused Columns
-- Drop column has to be done individually in PostgreSQL

Select * 
From NashvilleHousing

Alter Table NashvilleHousing
Drop Column owneraddress, 
Drop Column taxdistrict, 
Drop Column propertyaddress, 
Drop Column saledate