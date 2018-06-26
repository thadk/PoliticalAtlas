# WorldPoliticalPopulation

Makefile combining GADM3.6 with 2020 WorldPop population data at the ADM2 (typically, district) level, formatted to be particularly browsable in Carto. Starting with Africa continent data. 

WorldPop population models covers most all of Latin America and the Caribbean, Africa and Asia.

### Data Sources

* http://gadm.org/ (for ADM2 boundaries)
* http://www.worldpop.org.uk/ (for Total, Adult\* and Rural\* population)
* https://www.naturalearthdata.com/ (for Africa Region names)

\* Derived from this source using external analysis.

![image](https://user-images.githubusercontent.com/283343/41881725-d6d3cfd4-78b2-11e8-9e48-bd51a9f943a4.png)

### Dependencies
* New York Times' [mapshaper](https://github.com/mbloch/mapshaper) `npm install
  mapshaper -g`
* [Docker](https://www.docker.com/community-edition)
* Make
* curl

### This work would not be possible without
* [Kartoza's Dockerized QGIS](https://github.com/kartoza/docker-qgis-desktop)
* New York Times' team devotion to mapshaper
* the fantastic Carto.com builder automatic aggregations
* [Farm Radio International](http://www.farmradio.org/) support to explore the toolchain.
