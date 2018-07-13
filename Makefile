#Similar Makefile which this format was inspired by: https://github.com/scities-data/metro-atlas_2014/blob/master/Makefile
# To a lesser extent, this guide https://github.com/datamade/data-making-guidelines and
# also Mike Bostock's article: https://bost.ocks.org/mike/make/

#TODO transition from QGIS 2.08.9 to 3.2 using https://gis.stackexchange.com/questions/244828/automatisation-of-zonal-statistics-with-python-script?rq=1

# := assignment only gets run once at the beginning of everything
# = assignment gets run each time (but can cause an infinite loop)

.DEFAULT_GOAL := all

all: data/gz/continents-levels2-Asia_pop_density.zip data/gz/continents-levels2-AFR_pop_density.zip csvs

#These sections is broken out for each continent in these 3 files:
include AFR.mk Asia.mk LAC.mk

#################
# DOWNLOAD DATA #
#################

#details at https://gadm.org/data.html
data/gz/gadm36_levels_shp.zip:
	mkdir -p $(dir $@)
	curl 'https://data.biogeo.ucdavis.edu/data/gadm3.6/gadm36_levels_shp.zip' -o $@.download
	mv $@.download $@

data/gz/ne_10m_admin_0_countries.zip:
	mkdir -p $(dir $@)
	curl "http://naciscdn.org/naturalearth/10m/cultural/ne_10m_admin_0_countries.zip" -o $@.download
	mv $@.download $@

#Lake layer:
#http://naciscdn.org/naturalearth/10m/physical/ne_10m_lakes.zip

#################
# UNCOMPRESS DATA #
#################

#download all the admin levels and then throw away everything except adm2 (districts)
data/shp/gadm36_2.shp: data/gz/gadm36_levels_shp.zip
	rm -rf $(basename $@)
	mkdir -p $(basename $@)
	unzip -d $(basename $@) $<
	#We do not need all the other administrative levels except 2: a happy medium
	rm $(basename $@)/gadm36_{0,1,3,4,5}.*
	for file in $(basename $@)/*; do chmod 644 $$file; mv $$file $(basename $@).$${file##*.}; done
	rmdir $(basename $@)
	touch $@

#download all the admin levels and then throw away everything except adm2 (districts)
data/shp/gadm36_0.shp: data/gz/gadm36_levels_shp.zip
	rm -rf $(basename $@)
	mkdir -p $(basename $@)
	unzip -d $(basename $@) $<
	#We do not need all the other administrative levels except 2: a happy medium
	rm $(basename $@)/gadm36_{1,2,3,4,5}.*
	for file in $(basename $@)/*; do chmod 644 $$file; mv $$file $(basename $@).$${file##*.}; done
	rmdir $(basename $@)
	touch $@

#download all the admin levels and then throw away everything except adm2 (districts)
data/shp/gadm36_1.shp: data/gz/gadm36_levels_shp.zip
	rm -rf $(basename $@)
	mkdir -p $(basename $@)
	unzip -d $(basename $@) $<
	#We do not need all the other administrative levels except 2: a happy medium
	rm $(basename $@)/gadm36_{0,2,3,4,5}.*
	for file in $(basename $@)/*; do chmod 644 $$file; mv $$file $(basename $@).$${file##*.}; done
	rmdir $(basename $@)
	touch $@

data/shp/ne_10m_admin_0_countries.shp: data/gz/ne_10m_admin_0_countries.zip
	rm -rf $(basename $@)
	mkdir -p $(basename $@)
	unzip -d $(basename $@) $<
	for file in $(basename $@)/*; do chmod 644 $$file; mv $$file $(basename $@).$${file##*.}; done
	rmdir $(basename $@)
	touch $@

#######################
# RESHAPE POLYGON DATA  #
#######################

#See particular continent files for this section.
#e.g. AFR.mk, Asia.mk, LAC.mk	

#######################
# CONVERT RASTER DATA TO VECTOR  #
#######################

DOCKERID = $(shell cat data/docker.pid) #"98aa123a0d43"

data/docker.pid:
	mkdir -p $(dir $@)
	#echo DISPLAY IP address must be your local machine IP.
	#on Mac you must run socat as described at http://kartoza.com/en/blog/how-to-run-a-linux-gui-application-on-osx-using-docker/
	# then adjust DISPLAY
	@echo "Docker was freshly started, you may need to reinitiate the process"
	docker run --detach  -e DISPLAY=$(shell ipconfig getifaddr en0):0 -i -t \
	 -v $$(pwd)/rasterScripts/.config:/root/.config \
	 -v /Users/thadk:/home/thadk  \
	 -v $$(pwd):/opt/data thadk/qgis-desktop:2.8.9a /bin/bash > $@

data/docker.aptgetupdate:
	@echo "Trying to run apt-get for java: Docker was freshly started, you may need to reinitiate the process"
	mkdir -p $(dir $@)
	docker exec -i -t $(DOCKERID) apt-get update
	docker exec -i -t $(DOCKERID) apt-get install xvfb -y
	docker exec -i -t $(DOCKERID) apt-get install python-yaml -y
	#Turn off QGIS initial tooltip so QGIS headless doesn't hang endlessly
	# (remember to update this preference if you change versions of QGIS):
	#docker exec -i -t $(DOCKERID) mkdir -p /root/.config/QGIS/
	#docker exec -i -t $(DOCKERID) sh -c 'printf "[Qgis]\nshowTips208=false">/root/.config/QGIS/QGIS2.conf'
	touch $@


#######################
# CLEAN & PROCESS RASTER DATA #
#######################

#See particular continent files for this section.
#e.g. AFR.mk, Asia.mk, LAC.mk

#######################
# Compress & Upload #
#######################

csvs: data/csv/continents-levels2-Asia_pop_density.csv data/csv/continents-levels2-AFR_pop_density.csv

data/shp/continents-levels0-AFR.zip: data/shp/continents-levels0-AFR.shp
	zip $@ data/shp/continents-levels0-AFR.{shp,shx,prj,dbf}

data/gz/continents-levels2-AFR_pop_density.zip: data/shp/continents-levels2-AFR_pop_density.shp
	zip $@ data/shp/continents-levels2-AFR_pop_density.*

data/gz/continents-levels2-LAC_pop_density.zip: data/shp/continents-levels2-LAC_pop_density.shp
	zip $@ data/shp/continents-levels2-LAC_pop_density.*	

data/shp/continents-levels0-Asia.zip: data/shp/continents-levels0-Asia.shp
	zip $@ data/shp/continents-levels0-Asia.{shp,shx,prj,dbf}

data/gz/continents-levels2-Asia_pop_density.zip: data/shp/continents-levels2-Asia_pop_density.shp
	zip $@ data/shp/continents-levels2-Asia_pop_density.*	

carto-upload-AFR: CARTO_USER:=$(shell cat ../creds/CARTO_USER)
carto-upload-AFR: CARTO_APIKEY:=$(shell cat ../creds/CARTO_APIKEY)
carto-upload-AFR: data/gz/continents-levels2-AFR_pop_density.zip
	curl -v -F file=@$(realpath $<) \
	"https://$(CARTO_USER).carto.com/api/v1/imports/?api_key=$(CARTO_APIKEY)"

carto-upload-asia: CARTO_USER:=$(shell cat ../creds/CARTO_USER)
carto-upload-asia: CARTO_APIKEY:=$(shell cat ../creds/CARTO_APIKEY)
carto-upload-asia: data/gz/continents-levels2-Asia_pop_density.zip
	curl -v -F file=@$(realpath $<) \
	"https://$(CARTO_USER).carto.com/api/v1/imports/?api_key=$(CARTO_APIKEY)"



#######################
#  Cleanup #
#######################

clean: DATESHORT:=$(shell date +%Y-%m-%d-%H-%M-%S)
clean: JUNKBIN= ~/Downloads/VMs
clean:
	mkdir -p ${JUNKBIN}
	docker stop $(DOCKERID) 
	docker rm $(DOCKERID)
	-rm data/docker.pid
	-rm data/docker.aptgetupdate
	-mv data/shp ${JUNKBIN}/shp-$(DATESHORT)
	-mv data/geojson ${JUNKBIN}/geojson-$(DATESHORT)
	-mv data/csv ${JUNKBIN}/csv-$(DATESHORT)
