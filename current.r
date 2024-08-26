# Load necessary libraries
library(lpjmlkit)
library(tidyverse)
library(magrittr)
library(terra)
library(geodata)
library(readxl)
library(dplyr)
library(purrr)

# Read the land use and Germany's federal states data
landuse <- readRDS("landuse.rds")

landuse

outpath <- "C:/Users/s9dhc/OneDrive/Documents/PIK/NUTS/GER_NUTS1"

ger <- gadm("DEU", ".", level = 1)

# Read the land use fractions for Germany
crops <- c(
  "tece", "rice", "maize", "trce", "pulses", "tero", "trro",
  "oil crops sunflower", "oil crops soybean", "oil crops groundnut",
  "oil crops rapeseed", "sugar cane", "other crops", "managed grass",
  "bio-energy grass", "bio-energy tree"
)

irrig <- c("rf", "sf", "sp", "dr")

subset <- list(
  band = paste(crops[c(1:13)], rep(irrig, each = 13), sep = "_"),
  year = "2000"
)


# Calculate the area of each grid cell (in square kilometers)
#cell_area <- cellSize(landuse)
# Read the cell area data
terr_area <- read_io(filename = paste0(
  outpath, "/terr_area.bin.json"
)) %>% as_terra()


# Calculate the cropland area for each grid cell
cropland_area <- landuse * terr_area

# Mask the cropland area raster to the boundaries of Germany's federal states
masked_cropland_area <- mask(cropland_area, ger)

# Extract state information for each grid cell by rasterizing the state boundaries
state_raster <- rasterize(ger, masked_cropland_area, field = "NAME_1")

# Convert the masked cropland area raster to a tibble
cropland_df <- as.data.frame(masked_cropland_area, xy = TRUE, na.rm = TRUE) %>%
  as_tibble() %>%
  rename(cropland_area = LPJLUSE)

# Convert the state raster to a tibble and rename the column
state_df <- as.data.frame(state_raster, xy = TRUE, na.rm = TRUE) %>%
  as_tibble() %>%
  rename(state = NAME_1)

# Join the cropland data with the state data based on coordinates
cropland_state_df <- cropland_df %>%
  inner_join(state_df, by = c("x", "y"))

# Group by state and calculate the land use fractions for each federal state
landuse_fraction_df <- cropland_state_df %>%
  group_by(state) %>%
  mutate(cropland_fraction = cropland_area / sum(cropland_area)) %>%
  ungroup() %>%
  select(x, y, state, cropland_fraction)

# Write the final tibble to a file (CSV format)
#write_csv(landuse_fraction_df, "germany_cropland_fractions.csv")



file_path <- "C:/Users/s9dhc/OneDrive/Documents/PIK/NUTS/GER_NUTS1/data.csv"
first_sheet_data <- read_csv(file_path)
filtered_data <- first_sheet_data %>%
  filter(.[[1]] == 2050)







# Define the mapping between NUTS codes and state names
nuts_to_state <- c(
  "DE1" = "Baden-Württemberg",
  "DE2" = "Bayern",
  "DE3" = "Berlin",
  "DE4" = "Brandenburg",
  "DE5" = "Bremen",
  "DE6" = "Hamburg",
  "DE7" = "Hessen",
  "DE8" = "Mecklenburg-Vorpommern",
  "DE9" = "Niedersachsen",
  "DEA" = "Nordrhein-Westfalen",
  "DEB" = "Rheinland-Pfalz",
  "DEC" = "Saarland",
  "DED" = "Sachsen",
  "DEE" = "Sachsen-Anhalt",
  "DEF" = "Schleswig-Holstein",
  "DEG" = "Thüringen"
)


# Replace NUTS codes with state names in the filtered_data dataframe
filtered_data <- filtered_data %>%
  mutate(State = nuts_to_state[State])






# Rename columns for clarity
filtered_data <- filtered_data %>%
  rename(state_name = State, land_used_ha = `land used in ha`)




# Merge filtered_data with landuse_fraction_df based on state names
merged_data <- filtered_data %>%
  inner_join(landuse_fraction_df, by = c("state_name" = "state"))

#merged_data

# Merge filtered_data with landuse_fraction_df based on state names
merged_data <- filtered_data %>%
  inner_join(landuse_fraction_df, by = c("state_name" = "state"))

# Add a new column by multiplying land_used_ha and cropland_fraction
merged_data <- merged_data %>%
  mutate(cropland_area_ha = land_used_ha * cropland_fraction)


# View the resulting data
#merged_data

# Reorganize the columns in the desired order
merged_data <- merged_data %>%
  select(Year, x, y, state_name, land_used_ha, cropland_fraction, cropland_area_ha) %>%
  rename(year = Year)  # Rename 'Year' to 'year' to match your desired format



# View the resulting data
#merged_data

# Calculate the sum of the 'land_used_ha' column
total_land_used_ha <- sum(filtered_data$land_used_ha, na.rm = TRUE)




merged_data <- merged_data %>%
  mutate(land_percentage = (cropland_area_ha / total_land_used_ha) * 100)


# View the updated dataframe
df = merged_data

# Load required libraries
library(dplyr)

# Assuming you have a tibble named 'df'
# df <- tibble(year = ..., x = ..., y = ..., state_name = ..., land_used_ha = ..., cropland_fraction = ..., cropland_area_ha = ..., land_percentage = ...)

# 1. Select a value of land_percentage and the corresponding row_number
df <- df %>%
  mutate(row_number = row_number())  # Add a column with row numbers

# 2. Function to create a 'zehn_group' such that the total sum of land_percentage is 10
create_zehn_group <- function(data) {
  # Sample rows until their sum of land_percentage equals or exceeds 10
  sampled_rows <- data %>%
    sample_n(size = nrow(data), replace = FALSE) %>%
    mutate(cumulative_sum = cumsum(land_percentage)) %>%
    filter(cumulative_sum <= 10) %>%
    bind_rows(
      data %>%
        filter(row_number == min(data$row_number[data$cumulative_sum > 10]))
    )
  
  # Ensure that the cumulative sum is as close to 10 as possible
  final_group <- sampled_rows %>%
    filter(cumulative_sum <= 10) %>%
    slice(1:max(which(sampled_rows$cumulative_sum <= 10)))
  
  return(final_group)
}

# 3. Find 10 such 'zehn_groups'
zehn_groups <- replicate(10, create_zehn_group(df), simplify = FALSE)

# Display the 10 'zehn_groups'
zehn_groups

# Each element of 'zehn_groups' is a tibble containing the row numbers and land_percentage values for that group


#merged_data %>% sample_n(10)
