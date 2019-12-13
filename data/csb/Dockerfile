FROM rocker/geospatial:3.6.1

LABEL maintainer='Branson Fox <bransonf@wustl.edu>'

# Arg for Password
ARG pass=''

# Install Dependencies
RUN apt-get update && apt-get install -y \
	libsodium-dev

RUN R -e "install.packages(c('stlcsb', 'DBI', 'RPostgres', 'sodium', 'cyphr', 'getPass'))"

# Copy Script to Image
RUN mkdir /scripts
COPY csb.R /scripts/
COPY creds2.yml.encrypted /scripts/

WORKDIR /scripts/

# Execute
CMD ["R", "-e", "source('csb.R')"]
