# Script for Downloading Citizen Service Bureau Data

library(stlcsb);library(data.table);library(dplyr);library(sf)

# Download to Temp Directory and Unzip
tmp <- tempdir()
download.file('https://www.stlouis-mo.gov/data/upload/data-files/csb.zip', file.path(tmp, 'csb.zip'))
unzip(file.path(tmp, 'csb.zip'), exdir = tmp)

# Define Range of Years
cur_year <- as.numeric(format(Sys.Date(), '%Y'))
years <- 2008:cur_year

# Iterate through Years
csb <- vector('list', length(years))
for (i in seq_along(csb)) {
  file <- paste0(tmp, '/', years[i], '.csv')
  csb[[i]] <- fread(file) %>%
    dplyr::mutate(WARD = as.character(WARD),
                  NEIGHBORHOOD = as.character(NEIGHBORHOOD))
}

# Join all Years
csb <- dplyr::bind_rows(csb)

# Add Unique ID (Request ID has 28K Dupes)
csb <- dplyr::mutate(csb, id = row_number())

# Reproject Coordinates
sf <- stlcsb::csb_missingXY(csb, SRX, SRY, missing) %>%
      dplyr::filter(!missing) %>%
      dplyr::select(id, SRX, SRY) %>%
      sf::st_as_sf(coords = c("SRX", "SRY"), crs = "+proj=tmerc +lat_0=35.83333333333334 +lon_0=-90.5 +k=0.9999333333333333 +x_0=250000 +y_0=0 +datum=NAD83 +units=us-ft +no_defs") %>%
      sf::st_transform(crs = 4326)
sf <- dplyr::mutate(sf,
                    wgs_x = sf::st_coordinates(sf)[,1],
                    wgs_y = sf::st_coordinates(sf)[,2]) %>%
      sf::st_drop_geometry()

# Join new coordinates
csb <- left_join(csb, sf, by = "id")

# Categorize Problem Codes
csb <- stlcsb::csb_categorize(csb, PROBLEMCODE, Category)

# Add Logical for Indicators of Vacancy
csb <- stlcsb::csb_vacant(csb, PROBLEMCODE, vacant)

# Fit to Schema
schema <- transmute(csb,
                    id = as.integer(id),
                    dateInit = as.Date(DATETIMEINIT),
                    dateClosed = as.Date(DATETIMECLOSED),
                    problemCode = as.character(PROBLEMCODE),
                    description = as.character(DESCRIPTION),
                    neighborhood = as.integer(NEIGHBORHOOD),
                    ward = as.integer(WARD),
                    department = as.character(SUBMITTO),
                    status = as.logical(if_else(STATUS %in% c('CLOSED', 'CANCEL', 'Cancel','closed','Closed'), FALSE, TRUE, missing = TRUE)),
                    vacant = as.logical(vacant),
                    nadX = as.numeric(SRX),
                    nadY = as.numeric(SRY),
                    wgsX = as.numeric(wgs_x),
                    wgsY = as.numeric(wgs_y)
          )

# Check for Errors at this point and notify admin of any
## TODO

# Connect to Database and Insert Data to Crime Table
library(DBI);library(RPostgres);library(yaml)
creds <- yaml::read_yaml('creds.yml')

con <- DBI::dbConnect(RPostgres::Postgres(),
                      dbname = creds$database,
                      host = creds$host,
                      port = 5432,
                      user = creds$username,
                      password = creds$password)
# CAUTION on Overwrite, TODO Implement Append Instead
dbWriteTable(con, 'csb', schema, overwrite = TRUE)

# Send Update Confirmation
## TODO

