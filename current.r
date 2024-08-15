# Load necessary libraries
library(lpjmlkit)
library(tidyverse)
library(magrittr)
library(terra)
library(geodata)
library(readxl)

# Read the land use and Germany's federal states data
landuse <- readRDS("landuse.rds")
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
cell_area <- cellSize(landuse)

# Calculate the cropland area for each grid cell
cropland_area <- landuse * cell_area

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

landuse_fraction_df

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




colnames(landuse_fraction_df)

# Rename columns for clarity
filtered_data <- filtered_data %>%
  rename(state_name = State, land_used_ha = `land used in ha`)


filtered_data

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

# Print the result
total_land_used_ha


merged_data <- merged_data %>%
  mutate(land_percentage = (cropland_area_ha / total_land_used_ha) * 100)


# View the updated dataframe
merged_data

# Filter rows where land_percentage is 10% or more
filtered_percentage_data <- merged_data %>%
  filter(land_percentage >= 10)

# View the filtered dataframe
filtered_percentage_data


