FROM rocker/geospatial:3.6.2

LABEL maintainer='Branson Fox <bransonf@wustl.edu>'

# Arg for Password
ARG pass=''

# Install Dependencies

# Probably need postgres...

RUN R -e "install.packages(c('compstatr', 'DBI', 'RPostgres', 'sodium', 'cyphr', 'getPass'))"

# Copy Script to Image
RUN mkdir /scripts
COPY crime.R /scripts/crime.R

# Execute
CMD ["R", "-e", "source('/scripts/crime.R')"]