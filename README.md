# PoliticalAtlas
**Have you ever wanted to...**

* know how densely settled a particular area of the world is?
* know why a particular region far from the capital is prominent?
* understand why more projects are happening in one area versus another?

* <a href="/PoliticalAtlas/africa"><button type="button" class="btn btn-primary">View Africa Atlas</button></a> &nbsp;
* <a href="/PoliticalAtlas/asia"><button type="button" class="btn btn-primary">View Asia Atlas</button></a> 

*Then, the maps buttons above or the underlying data/code below might help!*

Starting with Africa and Asia continent data, Latin America to come.

World Atlas combining GADM3.6 with 2020 WorldPop population data at the ADM2 (typically, district) level, formatted to be particularly browsable in Carto. 

### Use the Data Produced in this Project!
* [CSV data for Administrative Level 2 population for Africa](https://github.com/thadk/PoliticalAtlas/raw/master/data/csv/continents-levels2-AFR_pop_density.csv) 
* [CSV data for Administrative Level 2 population for Asia](https://github.com/thadk/PoliticalAtlas/raw/master/data/csv/continents-levels2-Asia_pop_density.csv)
* [Uploadable Carto file for Africa](https://s3.amazonaws.com/peacecorps-osm/AfricaAtlas.carto) Create Carto account, drag/drop into profile and start customizing your own map in 3 clicks (~51mb)
* [Uploadable Carto file for Asia](https://s3.amazonaws.com/peacecorps-osm/AsiaAtlas.carto) (~91mb)
* [Embed Link for Carto Map Africa](https://thadk.carto.com/viz/dd2db8f7-8173-43ff-898e-64aa998796cb/public_map) - saves your place in the URL 
* [Embed Link for Carto Map Asia](https://thadk.carto.com/viz/4d9839ce-d594-4a79-bf16-d0f716e12b4a/public_map) - saves your place in the URL


### Data Sources

* http://gadm.org/ (for ADM2 boundaries)
* http://www.worldpop.org.uk/ (for Total, Adult\* and Rural\* population) -[more](https://www.nature.com/articles/sdata20171)
* https://www.naturalearthdata.com/ (for Africa Region names)

\* Derived from this source using external analysis.
![popmap4](https://user-images.githubusercontent.com/283343/41951032-f0072980-7996-11e8-8e56-620c4881a40c.gif)


**This atlas is not affiliated with any organization and does not attempt to represent any boundaries in an authoritative way.** Each country has its own representation of international boundaries and labels but only one version is offered here.

WorldPop gridded population models covers most all of Latin America and the Caribbean, Africa and Asia. The models may not be exactly designed for this purpose but results tend to be only a small margin different from other more official census and UN sources (especially around the equator).


### Dependencies
* New York Times' [mapshaper](https://github.com/mbloch/mapshaper) `npm install
  mapshaper -g`
* [Docker](https://www.docker.com/community-edition)
* Make
* curl

### Instructions
After installing dependencies, use:
* `make` (on my MacBook Pro 2016, this takes about 8min)
* upload `data/gz/continents-levels2-2_pop_density.zip` (containing a
  shapefile) to the
Carto as a new map.

### This work would not be possible without
* [Kartoza's Dockerized QGIS](https://github.com/kartoza/docker-qgis-desktop)
* New York Times' team devotion to mapshaper
* the fantastic Carto.com builder automatic aggregations
* [Farm Radio International](http://www.farmradio.org/) support to explore the toolchain.

### Makefile resources:
* Similar Makefile which this format was inspired by: https://github.com/scities-data/metro-atlas_2014/blob/master/Makefile
* To a lesser extent, this guide https://github.com/datamade/data-making-guidelines and
* also Mike Bostock's article: https://bost.ocks.org/mike/make/
