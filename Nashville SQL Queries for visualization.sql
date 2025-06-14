Select * From NashvilleHousing

-- Data visualization on housing data.

update NashvilleHousing
Set saleprice = Replace(Replace(saleprice, '$', ''), ',', '')

-- 1st visualization on property price trends per year.
-- No data on 2017 and 2018 for this data set.


Select  TO_CHAR(saledate, 'YYYY') AS Year, 
		COUNT(Distinct(saledate)) AS Houses_owned_per_year, 
		ROUND(AVG(saleprice :: NUMERIC), 0) AS Avg_price		
From NashvilleHousing
Group by TO_CHAR(saledate, 'YYYY')
Order by TO_CHAR(saledate, 'YYYY')


-- 2nd visualization on family housing price trends per year.

Select  TO_CHAR(saledate, 'YYYY') AS Year, 
		landuse AS Property_type,
		COUNT(Distinct(saledate)) AS Houses_owned_per_year, 
		ROUND(AVG(saleprice :: NUMERIC), 0) AS Avg_price		
From NashvilleHousing
Where landuse In (
'SINGLE FAMILY',
    'DUPLEX',
    'TRIPLEX',
    'QUADPLEX',
    'RESIDENTIAL CONDO',
    'CONDO',
    'APARTMENT: LOW RISE (BUILT SINCE 1960)',
    'MOBILE HOME',
    'PARSONAGE'
)
Group by TO_CHAR(saledate, 'YYYY'), landuse
Order by TO_CHAR(saledate, 'YYYY'), landuse


-- 3rd data visualization
-- 10 top property distribution types in Nashville.
-- 39 total property types which can be not appealing visually so Limit was used.

SELECT 
    landuse, 
    COUNT(*) AS Property_Count
FROM NashvilleHousing
GROUP BY landuse
ORDER BY Property_Count DESC
Limit 10


-- 4th Data Visualization
-- Average sale price by property type.

SELECT 
    landuse, 
    ROUND(AVG(saleprice::NUMERIC), 0) AS Avg_Sale_Price
FROM NashvilleHousing
GROUP BY landuse
ORDER BY Avg_Sale_Price DESC


-- 5th Data Visualization
-- Average sale price based on the number of bedrooms and bathrooms.
-- Where statement to remove data that is incomplete.

SELECT 
    bedrooms, fullbath, halfbath,
    ROUND(AVG(saleprice::NUMERIC), 0) AS Avg_Sale_Price
FROM NashvilleHousing
Where bedrooms is not Null AND bedrooms >= 1
		AND fullbath is not Null AND fullbath >= 1
		AND halfbath is not Null
GROUP BY bedrooms, fullbath, halfbath
ORDER BY bedrooms, fullbath, halfbath


-- 6th visualization
-- Property sales by the cities

SELECT 
    propertysplitcity, 
    COUNT(*) AS Total_Sales
FROM NashvilleHousing
Where propertysplitcity <> ' UNKNOWN'
GROUP BY propertysplitcity
ORDER BY Total_Sales DESC