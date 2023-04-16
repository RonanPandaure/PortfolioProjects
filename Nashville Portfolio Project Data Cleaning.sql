-- Data cleaning projet

Select *
From NashvilleHousing

--Standardize Date Format

Select SaleDate, convert(date,SaleDate)
From NashvilleHousing

Update NashvilleHousing
Set Saledate = convert(Date, Saledate)

Select SaleDate
From NashvilleHousing

			--Didn't work

Alter Table NashvilleHousing
Add SaleDateConverted Date; 

Update NashvilleHousing
Set SaleDateConverted = convert(Date, Saledate)

Select SaleDateConverted
From NashvilleHousing

-- Property Adress data cleaning

Select *
From NashvilleHousing
--Where PropertyAddress is null
order by ParcelID

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress
From NashvilleHousing a
Join NashvilleHousing b
	on a.parcelID = b.ParcelID
	And a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null

Update a
Set propertyAddress = isnull(a.propertyAddress, b.PropertyAddress)
From NashvilleHousing a
Join NashvilleHousing b
	on a.parcelID = b.ParcelID
	And a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null

--Seperate Adress Into Individual Colums (Adress, City, State)

Select propertyAddress
From NashvilleHousing

Select 
SUBSTRING(Propertyaddress, 1, CHARINDEX(',',PropertyAddress)-1) as Address
, SUBSTRING(Propertyaddress, CHARINDEX(',',PropertyAddress)+1,Len(propertyAddress)) as Address
FROM NashvilleHousing


Alter Table NashvilleHousing
Add PropertySplitAddress Nvarchar(255); 

Update NashvilleHousing
Set PropertySplitAddress = SUBSTRING(Propertyaddress, 1, CHARINDEX(',',PropertyAddress)-1)

Alter Table NashvilleHousing
Add PropertySplitCity Nvarchar(255); 

Update NashvilleHousing
Set PropertySplitCity = SUBSTRING(Propertyaddress, CHARINDEX(',',PropertyAddress)+1,Len(propertyAddress))

Select *
From NashvilleHousing

Select OwnerAddress
From NashvilleHousing

Select
PARSENAME(Replace(Owneraddress, ',','.'),3),
PARSENAME(Replace(Owneraddress, ',','.'),2),
PARSENAME(Replace(Owneraddress, ',','.'),1)
from nashvillehousing


Alter Table NashvilleHousing
Add OwnerSplitAdress Nvarchar(255); 

Update NashvilleHousing
Set OwnerSplitAdress = PARSENAME(Replace(Owneraddress, ',','.'),3)

Alter Table NashvilleHousing
Add OwnerSplitCity Nvarchar(255); 

Update NashvilleHousing
Set OwnerSplitCity = PARSENAME(Replace(Owneraddress, ',','.'),2)

Alter Table NashvilleHousing
Add OwnerSplitState Nvarchar(255); 

Update NashvilleHousing
Set OwnerSplitState = PARSENAME(Replace(Owneraddress, ',','.'),1)

Select *
From NashvilleHousing

--Change Y and N to Yes and No in "Sold as vacant" field

Select Distinct(SoldAsVacant), count(SoldAsVacant)
From NashvilleHousing
Group by SoldasVacant
Order By 2


Select SoldAsVacant
, Case When SoldASVacant = 'Y' Then'Yes'
	When Soldasvacant = 'N' then 'No'
	Else Soldasvacant
	End
From NashvilleHousing

Update NashvilleHousing
SET SoldAsVacant = Case When SoldASVacant = 'Y' Then'Yes'
	When Soldasvacant = 'N' then 'No'
	Else Soldasvacant
	End

--Remove duplicates

	--CTE
With RowNumCTE AS(
Select *,
	Row_Number() over (
	Partition by ParcelID,
				PropertyAddress,
				SalePrice,
				SaleDate,
				LegalReference
				Order by 
					UniqueID
					) row_num
From NashvilleHousing
)
Delete
From RowNumCTE
Where row_num >1


--Select Unused Columns

Select *
From NashvilleHousing

Alter Table NashvilleHousing
Drop column owneraddress, taxdistrict, propertyaddress, saledate


