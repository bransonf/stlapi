# Script for Downloading and Cleaning Demolition Data

library(readxl);library(dplyr);library(Hmisc)

tmp <- tempdir()

# Stl Vacancy, Publically Funded Demos (Ugly file name = Not reproducible :| )
download.file('https://www.stlvacancy.com/uploads/8/7/1/3/87139164/publicdemos_sincejan2018_updated20190925v2.xlsx',
              file.path(tmp, 'publicdemos.xlsx'))

# Ugly Access Databases means Linux/MacOS Only on this script.

download.file('https://www.stlouis-mo.gov/data/upload/data-files/prmbdo.zip',
              file.path(tmp, 'permits.zip'))
unzip(file.path(tmp, 'permits.zip'), exdir = tmp)

bldg_prms <- mdb.get(file.path(tmp, 'prmbdo.mdb'), tables = 'PrmBldg')
