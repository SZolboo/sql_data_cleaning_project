CREATE TABLE House (
    UniqueID INT PRIMARY KEY,
    ParcelID VARCHAR(20),
    LandUse VARCHAR(255),
    PropertyAddress VARCHAR(255),
    SaleDate DATE,
    SalePrice VARCHAR(255),
    LegalReference VARCHAR(255),
    SoldAsVacant CHAR(10),
    OwnerName VARCHAR(255),
    OwnerAddress VARCHAR(255),
    Acreage DECIMAL,
    TaxDistrict VARCHAR(255),
    LandValue DECIMAL,
    BuildingValue DECIMAL,
    TotalValue DECIMAL,
    YearBuilt DECIMAL,
    Bedrooms DECIMAL,
    FullBath DECIMAL,
    HalfBath DECIMAL
)

DROP TABLE House;