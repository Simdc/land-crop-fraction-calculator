# Load necessary libraries
library(lpjmlkit)
library(tidyverse)
library(magrittr)
library(terra)
library(geodata)

# Read the land use and Germany's federal states data
landuse <- readRDS("landuse.rds")
ger <- gadm("DEU", ".", level = 1)

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
write_csv(landuse_fraction_df, "germany_cropland_fractions.csv")


landuse_fraction_df


