# Script for Downloading Geometric Data

library(sf)

# Download to Temp Function
tmp <- tempdir()
download <- function(url, temp = tmp){
  download.file(url, file.path(temp, basename(url)))
}

# Boundary
download('https://www.stlouis-mo.gov/data/upload/data-files/stl_boundary.zip')

# Wards and Neighborhoods
download('https://www.stlouis-mo.gov/data/upload/data-files/nbrhds_wards.zip')

# City Blocks
download('https://www.stlouis-mo.gov/data/upload/data-files/blocks_shape.zip')

# Districts
download('https://www.stlouis-mo.gov/data/boundaries/upload/STL-Police-Districts-2014-2.zip')

# Parks
download('https://www.stlouis-mo.gov/data/upload/data-files/parks.zip')

# Community Improvement Districts
download('https://www.stlouis-mo.gov/data/upload/data-files/CID.geojson')

# Election Precincts
download('https://www.stlouis-mo.gov/data/boundaries/upload/STL-PRECINCTS.zip')

# Zoning
download('https://www.stlouis-mo.gov/data/upload/data-files/zoning.zip')

# Parcels
download('https://www.stlouis-mo.gov/data/upload/data-files/prcl_shape.zip')

# Unzip all files in temp directory
for (i in list.files(tmp, '\\.zip')) {
  unzip(file.path(tmp, i), exdir = tmp)
}

# Parse All Shapes
for (i in list.files(tmp, '\\.shp$|\\.geojson$', recursive = TRUE)) {
  assign(i, st_read(file.path(tmp, i)))
}

# Reproject everything to WGS
for (i in ls(pattern = '\\.shp$|\\.geojson$')) {
  assign(i, st_transform(get(i), 4326))
}

# ~~~~~ Connect to Database and Insert ~~~~~ #
library(RPostgres);library(rpostgis)
source('https://bransonf.com/scripts/encryption.R')
creds <- decrypt_yaml('data/geo/creds2.yml.encrypted', Sys.getenv('pass'))

con <- RPostgreSQL::dbConnect("PostgreSQL",
                      dbname = creds$database,
                      host = creds$host,
                      port = 5432,
                      user = creds$username,
                      password = creds$password)

# Insert Statements
pgInsert(con, c('geo','boundary'), as_Spatial(stl_boundary.shp))
pgInsert(con, c('geo','blocks'), as_Spatial(blocks.shp))
pgInsert(con, c('geo','cid'), as_Spatial(CID.geojson))
pgInsert(con, c('geo','wards'), as_Spatial(`nbrhds_wards/POL_WRD_2010_Prec.shp`))
pgInsert(con, c('geo','neighborhood'), as_Spatial(`nbrhds_wards/BND_Nhd88_cw.shp`))
pgInsert(con, c('geo','parks'), as_Spatial(parks.shp))
pgInsert(con, c('geo','district'), as_Spatial(`STL POLICE DISTRICTS/GIS.STL.POLICE_DISTRICTS_2014.shp`))
pgInsert(con, c('geo','precinct'), as_Spatial(`STL PRECINCTS/GIS.STL.PRECINCTS_2010.shp`))
pgInsert(con, c('geo','parcel'), as_Spatial(prcl.shp))



