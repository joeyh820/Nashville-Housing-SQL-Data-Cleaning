# Housing Data Cleaning Project

This project entailed the meticulous cleaning of a dataset detailing the Nashville housing market. The source of the data was an `.xlsx` file which was subsequently imported into SSMS and housed in a table named 'NashvilleHousing'.

### Initial Steps:

- **Review of Raw Data**: Started with a thorough examination of the raw data contained within the 'NashvilleHousing' table.

### Cleaning Procedures:

- **'SaleDate' Column**: Utilized the `CONVERT` function to format dates, removing the time component.
- **'PropertyAddress' Column**: Employed the `ISNULL` function to fill null entries using values from rows sharing the same Parcel ID.
- **Column Division - 'PropertyAddress'**: Split into two new columns to separate Address and City using the `SUBSTRING` function.
- **Column Division - 'OwnerAddress'**: Split into three new columns for Address, City, and State using the `PARSENAME` function.
- **'SoldAsVacant' Column**: Transformed 'Y' and 'N' to 'Yes' and 'No' with a `CASE` statement.
- **Removing Duplicates**: Implemented the `ROW_NUMBER` function within a CTE to identify and remove duplicates.
- **Useless Columns Removal**: Deleted obsolete columns post-manipulation and those lacking valuable information, such as 'TaxDistrict'.

### Finalizing:

- **Final Check**: Conducted a last review to ensure the integrity and cleanliness of the updated table.

## Results:

The original dataset comprising 56,477 rows was condensed to a clean, analysis-ready table of 56,373 rows. The cleaning process resulted in the elimination of merely 104 rows, which constitutes roughly 0.002% of the total data, ensuring a dataset primed for future analysis.

## Nashville-Housing-Data-Cleaning

I applied a variety of SQL techniques, such as Aggregate Functions, Joins, Window Functions, CTEs, and Views to refine the dataset.

This project followed a step-by-step tutorial: [SQL Tutorial](https://www.youtube.com/watch?v=8rO7ztF4NtU&list=PLUaB-1hjhk8H48Pj32z4GZgGWyylqv85f&index=3)

### Technologies Used:

- SQL/SSMS
- Excel

### Cleaning Process Overview:

1. Download the dataset.
2. Load the data into SSMS.
3. Execute the cleaning operations.
