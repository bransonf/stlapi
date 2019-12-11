# Script for Downloading and Cleaning Crime Data

library(compstatr);library(dplyr);library(sf);library(lubridate)

# Create Index of Available Data
idx <- cs_create_index()

# Define Range of Years
cur_year <- as.numeric(format(Sys.Date(), '%Y'))
years <- 2008:cur_year

# Define and Iterate over List of Years
crime_dta <- vector('list', length(years))

for (i in seq_along(crime_dta)) {
  crime_dta[[i]] <- cs_get_data(year = (2008:2019)[i], index = idx)  
}

## Fix outliers (Standardize to 20 Columns)
# 2008-2012: 18 Column Release
for (i in 1:5) {
  crime_dta[[i]] <- cs_standardize(crime_dta[[i]], all, config = 18)
}

# 2013 Jan - May, July, Aug: 18 Column Release
crime_dta[[6]][["January"]]  <- cs_standardize(crime_dta[[6]], "January", config = 18)$January
crime_dta[[6]][["February"]] <- cs_standardize(crime_dta[[6]], "February", config = 18)$February
crime_dta[[6]][["March"]]    <- cs_standardize(crime_dta[[6]], "March", config = 18)$March
crime_dta[[6]][["April"]]    <- cs_standardize(crime_dta[[6]], "April", config = 18)$April
crime_dta[[6]][["May"]]      <- cs_standardize(crime_dta[[6]], "May", config = 18)$May
crime_dta[[6]][["July"]]     <- cs_standardize(crime_dta[[6]], "July", config = 18)$July
crime_dta[[6]][["August"]]   <- cs_standardize(crime_dta[[6]], "August", config = 18)$August

# 2017 May: 26 Column Release
crime_dta[[10]][["May"]] <- cs_standardize(crime_dta[[10]], "May", config = 26)$May

# Build full dataset by binding rows
crime_dta <- lapply(crime_dta, dplyr::bind_rows)
full_df <- dplyr::bind_rows(crime_dta)

# Add unique id for each row in Dataset
full_df <- dplyr::mutate(full_df, db_id = row_number())

# create sf to reprojected coordinates
sf <- dplyr::filter(full_df, x_coord != 0 & y_coord != 0) %>%
      dplyr::select(db_id, x_coord, y_coord) %>%
      sf::st_as_sf(coords = c("x_coord", "y_coord"), crs = "+proj=tmerc +lat_0=35.83333333333334 +lon_0=-90.5 +k=0.9999333333333333 +x_0=250000 +y_0=0 +datum=NAD83 +units=us-ft +no_defs") %>%
      sf::st_transform(crs = 4326)

sf <- dplyr::mutate(sf,
                    wgs_x = st_coordinates(sf)[,1],
                    wgs_y = st_coordinates(sf)[,2]) %>%
      sf::st_drop_geometry()

# join new coordinates
join <- dplyr::left_join(full_df, sf, by = "db_id")

# add names to Crime Codes
join %>%
  dplyr::mutate(crime = as.numeric(crime),
         ucr_category = case_when(
           between(crime, 10000, 19999) ~ "Homicide",
           between(crime, 20000, 29999) ~ "Rape",
           between(crime, 30000, 39999) ~ "Robbery",
           between(crime, 40000, 49999) ~ "Aggravated Assault",
           between(crime, 50000, 59999) ~ "Burglary",
           between(crime, 60000, 69999) ~ "Larceny",
           between(crime, 70000, 79999) ~ "Vehicle Theft",
           between(crime, 80000, 89999) ~ "Arson",
           between(crime, 90000, 99999) ~ "Simple Assault",
           between(crime, 100000, 109999) ~ "Forgery",
           between(crime, 110000, 119999) ~ "Fraud",
           between(crime, 120000, 129999) ~ "Embezzlement",
           between(crime, 130000, 139999) ~ "Stolen Property",
           between(crime, 140000, 149999) ~ "Destruction of Property",
           between(crime, 150000, 159999) ~ "Weapons Offense",
           between(crime, 170000, 179999) ~ "Sex Offense",
           between(crime, 180000, 189999) ~ "VMCSL",
           between(crime, 200000, 209999) ~ "Offense Against Family",
           between(crime, 210000, 219999) ~ "DWI/DUI",
           between(crime, 220000, 229999) ~ "Liquor Laws",
           between(crime, 240000, 249999) ~ "Disorderly Conduct",
           between(crime, 250000, 259999) ~ "Loitering/Begging",
           TRUE ~ "Other"
         ),
         gun_crime = ifelse(
           crime == 10000 | (crime > 41000 & crime < 42000) | crime %in% c(31111, 31112,32111,32112,33111,34111,35111,35112,36112,37111,37112,38111,38112),
           TRUE,FALSE
         ),
         year_occur = lubridate::year(lubridate::mdy_hm(date_occur)),
         month_occur = lubridate::month(lubridate::mdy_hm(date_occur)),
         date_occur = as.Date(lubridate::mdy_hm(date_occur))
        ) -> crimeDB

# Fit to Specific Database Schema
schema <- crimeDB %>%
  transmute(
    id = as.integer(db_id),
    dateOccur = as.Date(date_occur),
    flagCrime = as.logical(if_else(flag_crime == 'Y', TRUE, FALSE, missing = FALSE)),
    flagUnfounded = as.logical(if_else(flag_unfounded == 'Y', TRUE, FALSE, missing = FALSE)),
    flagAdmin = as.logical(if_else(flag_administrative == 'Y', TRUE, FALSE, missing = FALSE)),
    count = as.logical(if_else(count == 1, TRUE, FALSE)),
    crimeCode = as.integer(crime),
    crimeCat = as.character(ucr_category),
    district = as.integer(district),
    description = as.character(description),
    neighborhood = as.integer(neighborhood),
    nadX = as.numeric(x_coord),
    nadY = as.numeric(y_coord),
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
dbWriteTable(con, 'crime', schema, overwrite = TRUE)

# Send Update Confirmation
## TODO