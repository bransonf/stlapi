# Script for Downloading Citizen Service Bureau Data

library(stlcsb);library(data.table);library(dplyr);

# Download to Temp Directory and Unzip
tmp <- tempdir()
download.file('https://www.stlouis-mo.gov/data/upload/data-files/csb.zip', file.path(tmp, 'csb.zip'))
unzip(file.path(tmp, 'csb.zip'), exdir = tmp)

# Read all Years
csb <- vector('list', 12)
for (i in 1:12) {
  file <- paste0(tmp, '/', (2008:2019)[i], '.csv')
  csb[[i]] <- fread(file) %>%
    mutate(WARD = as.character(WARD),
           NEIGHBORHOOD = as.character(NEIGHBORHOOD))
}

# Join all Years
csb <- bind_rows(csb)

# Add Unique ID (Request ID has 28K Dupes)

# Reproject Coordinates
sf <- filter(csb, x_coord != 0 & y_coord != 0) %>%
  select(db_id, x_coord, y_coord) %>%
  st_as_sf(coords = c("x_coord", "y_coord"), crs = "+proj=tmerc +lat_0=35.83333333333334 +lon_0=-90.5 +k=0.9999333333333333 +x_0=250000 +y_0=0 +datum=NAD83 +units=us-ft +no_defs") %>%
  st_transform(crs = 4326) %>%
  mutate(wgs_x = st_coordinates(sf)[,1],
         wgs_y = st_coordinates(sf)[,2]) %>%
  st_drop_geometry()

# join new coordinates
join <- left_join(crimes08_19, sf, by = "db_id")

# Categorize Problem Codes
