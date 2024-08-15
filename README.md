# README

## Project: Germany Cropland Area Analysis

### Overview
This project analyzes cropland areas within Germany's federal states using land use data from the LPJmL model. The analysis involves calculating the cropland area for each grid cell within Germany, associating these areas with specific federal states, and then determining the fraction of cropland in each state. The results are stored in a CSV file for further use.

### Files
- **`landuse.rds`**: RDS file containing land use data, likely derived from the LPJmL model.
- **`germany_cropland_fractions.csv`**: The final output CSV file that contains the calculated cropland fractions for each federal state.

### Requirements
The following R packages are required to run the provided script:
- `lpjmlkit`: For working with LPJmL model outputs.
- `tidyverse`: A collection of R packages designed for data science, including `dplyr`, `ggplot2`, `readr`, and `tibble`.
- `magrittr`: Provides the pipe operator (`%>%`) used to streamline code.
- `terra`: For handling raster data in R.
- `geodata`: Provides geographical data and functions to easily obtain administrative boundaries.

### Script Explanation
The main steps of the script are as follows:

1. **Load necessary libraries**:
   - Import the required packages.

2. **Read the land use and Germany's federal states data**:
   - Load the land use data from `landuse.rds`.
   - Obtain the administrative boundaries of Germany's federal states using the `gadm()` function from `geodata`.

3. **Subset the land use data**:
   - Define a list of crops and irrigation types to subset the land use data for the year 2000.

4. **Calculate the area of each grid cell**:
   - Use the `cellSize()` function from the `terra` package to compute the area of each grid cell in square kilometers.

5. **Calculate the cropland area**:
   - Multiply the land use data by the grid cell areas to obtain the cropland area for each cell.

6. **Mask the cropland area to Germany's federal state boundaries**:
   - Restrict the cropland area raster to the geographic boundaries of Germany's federal states using the `mask()` function.

7. **Extract state information**:
   - Rasterize the federal state boundaries and extract state information for each grid cell.

8. **Convert the masked cropland area raster to a tibble**:
   - Convert the raster data to a tibble format (a tidy data frame) for easier processing.

9. **Join the cropland data with state data**:
   - Merge the cropland area data with the state data based on grid cell coordinates.

10. **Calculate land use fractions**:
    - Group the data by federal state and calculate the cropland fraction for each state.

11. **Output the results**:
    - Write the final tibble to a CSV file named `germany_cropland_fractions.csv`.

### Running the Script
To run this script, ensure that all required libraries are installed and the `landuse.rds` file is in the working directory. Execute the script in an R environment. The final results will be saved in the `germany_cropland_fractions.csv` file.

### Output Description
- **`germany_cropland_fractions.csv`**:
  - This file contains the following columns:
    - `x`: x-coordinate (longitude) of the grid cell.
    - `y`: y-coordinate (latitude) of the grid cell.
    - `state`: The name of the federal state where the grid cell is located.
    - `cropland_fraction`: The fraction of the cropland area relative to the total cropland area in that state.


This README provides a summary of the analysis and instructions on how to run the script and interpret the output.
