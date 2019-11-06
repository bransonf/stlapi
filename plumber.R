# Plumber API for REST Access

library(plumber)
library(odbc);library(RPostgres)

# Set connection to the database

creds <- yaml::read_yaml('credentials.yaml') # need decryption, obviously

db <- odbc::dbConnect(RPostgres::Postgres(),
                      creds$database,
                      creds$ip,
                      creds$port,
                      creds$user,
                      creds$password
                      )

#* @apiTitle St. Louis Data

# ~~~~~~~~~~~ Crime Section ~~~~~~~~~ #

#* Get latest available date for Crime data
#* @get /crime/latest
function(){
  
}

#* Get Crime with Coordinates
#* @get /crime/coords
function(){
  
}

#* Get Crime by Neighborhood
#* @get /crime/neighborhood
function(){
  
}

#* Get Crime by Ward
#* @get /crime/ward
function(){
  
}

#* Get Detailed Information about a Crime
#* @get /crime/detail
function(){
  
}

# ~~~~~~~~~~~ CSB Section ~~~~~~~~~~~ #

#* Get latest available date for CSB data
#* @get /csb/latest
function(){
  
}

#* Get Crime with Coordinates
#* @param start begin date of query in (YYYY-MM-DD), inclusive
#* @param end end date of query in (YYYY-MM-DD), inclusive. If unspecified, returns only data from date of start
#* @get /csb/coords
function(){
  
}

#* Get Crime by Neighborhood
#* @get /csb/neighborhood
function(){
  
}

#* Get Crime by Ward
#* @get /csb/ward
function(){
  
}

#* Get Detailed Information about a Crime
#* @get /csb/detail
function(){
  
}

# ~~~~~~~~~~~ Demo Section ~~~~~~~~~~ #

#* Get latest available date for Demo data
#* @get /demo/latest
function(){
  
}

#* Get Demolition with Coordinates
#* @get /demo/coords
function(){
  
}

#* Get Demolition by Neighborhood
#* @get /demo/neighborhood
function(){
  
}

#* Get Demolition by Ward
#* @get /demo/ward
function(){
  
}

#* Get Detailed Information about a Demolition
#* @get /demo/detail
function(){
  
}
