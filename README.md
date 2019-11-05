# stlapi
A REST API for Various St Louis Data

PROJECT IS STILL IN DEVELOPMENT. Anticipated by End of 2019.

## Introduction
This project aims to greatly advance the accessibility of the City of St. Louis's Open Data. To do that, I'm building a REST API that connects to a Postgres Database. What does that mean?

It means with a simple GET request, you'll have access to clean crime data, categorized citizen service bureau requests, and whatever else anyone asks for.

Why a REST API? Maybe you want a spreadsheet or a shapefile. Don't worry, that will follow shortly. A REST API enables developers to build whatever they like, and it provides a standardized format for producing clean data in whatever format you like.

## Current Scope
- Crime Data
- Citizen Service Bureau Requests
- Vacancy Data
- Demolitions

## Benefits
This API will provide near realtime access to data, updating on a 24 hour basis. However, data will still be limited to the release schedule of the respective departments.

Crime data updates monthly, typically within the first two weeks of a month.

CSB data updates weekly, typically on Sunday evenings.

The Vacancy dataset is comprised of many data sources, but you can expect a monthly update.

Additionally, data comes in a standardized format. This means no more headache of downloading 100s of csv's and standarizing them yourself. No more trying to comprehend 400 different call types to the CSB.

## The Core API
Thanks to the support of the [Regional Data Alliance](https://stldata.org/), this API will be hosted at `api.stldata.org`

For sake of simplicity, endpoints will be standardized. All querys are expected to return valid JSON, and in the incident of an error, JSON denoting the error incurred.

URLs will be formatted as such:
```
https://api.stldata.org/<dataset>/<endpoint>
```

With valid datasets being:
```
/crime/
/csb/
/vacancy/
/demolitions/
```

And valid endpoints being:
```
/coords
/neighborhood
/ward
/detail
```

`coords` accepts the following query parameters:
`start` - 
`end` - 
`crs` -

Returns latitude/longitude coordinates (when available) for specified period.

`neighborhood` accepts the following query parameters:
`start` - 
`end` - 

Returns a summary of events by neighborhood for specified period.

`ward` accepts the following query parameters:
`start` - 
`end` - 

Returns a summary of events by ward for specified period.


`detail` accepts the following query parameters:
`db_id` - The unique event identifier

Returns extended information about the event queried. Up to 25 events can be queried at one time.

NOTE:
``` /vacancy/ ``` does not support querying by date. An error will be returned.

Valid queries:
```
https://api.stldata.org/crime/neighborhood?start=2019-01-01&end=2019-12-31
https://api.stldata.org/csb/coords?start=2019-07-04
https://api.stldata.org/vacancy/neighborhood
https://api.stldata.org/demolitions/ward?start=2017-01-01&end=2019-12-31
```

Additionally, one other endpoint exists to provide access to common city boundaries. Returns will be geoJSON (parsed the same as JSON)
```
/geo/
```

With valid endpoints being:
```
/neighborhood
/ward
/parcel
/block
/parks
```

Valid query:
```
https://api.stldata.org/geo/ward
```

## Request Additional Sources of Data

If you would like to see additional sources of data added, please [open an issue](https://github.com/bransonf/stlapi/issues/new)
