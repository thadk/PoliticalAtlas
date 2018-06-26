#Similar Makefile which this format was inspired by: https://github.com/scities-data/metro-atlas_2014/blob/master/Makefile
# To a lesser extent, this guide https://github.com/datamade/data-making-guidelines and
# also Mike Bostock's article: https://bost.ocks.org/mike/make/

# := assignment only gets run once at the beginning of everything
# = assignment gets run each time (but can cause an infinite loop)

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

#visit http://www.worldpop.org.uk/data/files/index.php?dataset=328&zip_title=Africa%201km%20Population&action=group
data/gz/AFR_PPP_2020_adj_v2.zip:
	mkdir -p $(dir $@)
	echo visit http://www.worldpop.org.uk/data/files/index.php?dataset=328&zip_title=Africa%201km%20Population&action=group
	echo save to $@
	sleep 10

#Used WorldPop's disaggregated population data to get 15 to 65+ year olds only.
data/gz/AFR_PPP_A1565PL_farmer_aged.zip:
	mkdir -p $(dir $@)
	curl 'https://s3.amazonaws.com/peacecorps-osm/AFR_PPP_A1565PL_farmer_aged.zip' -o $@.download
	mv $@.download $@	

#an experiment to start with adm4 and dissolve up
# data/gz/gadm36_shp.zip:
# 	mkdir -p $(dir $@)
# 	curl 'https://data.biogeo.ucdavis.edu/data/gadm3.6/gadm36_shp.zip' -o $@.download
# 	mv $@.download $@

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

data/shp/ne_10m_admin_0_countries.shp: data/gz/ne_10m_admin_0_countries.zip
	rm -rf $(basename $@)
	mkdir -p $(basename $@)
	unzip -d $(basename $@) $<
	for file in $(basename $@)/*; do chmod 644 $$file; mv $$file $(basename $@).$${file##*.}; done
	rmdir $(basename $@)
	touch $@

#The zip file behind this must be manually downloaded
data/tif/AFR_PPP_2020_adj_v2.tif: data/gz/AFR_PPP_2020_adj_v2.zip
	rm -rf $(basename $@)
	mkdir -p $(basename $@)
	unzip -d $(basename $@) $<
	for file in $(basename $@)/*; do chmod 644 $$file; mv $$file $(basename $@).$${file##*.}; done
	rmdir $(basename $@)
	touch $@

data/tif/AFR_PPP_A1565PL_farmer_aged_2020_adj_v5.tif: data/gz/AFR_PPP_A1565PL_farmer_aged.zip
	rm -rf $(basename $@)
	mkdir -p $(basename $@)
	unzip -d $(basename $@) $<
	for file in $(basename $@)/*; do chmod 644 $$file; mv $$file $(basename $@).$${file##*.}; done
	rmdir $(basename $@)
	touch $@

data/tif/AFR_PPP_A1565PL_farmer_aged_lt400ppp_2020_adj_v5.tif: data/gz/AFR_PPP_A1565PL_farmer_aged.zip
	rm -rf $(basename $@)
	mkdir -p $(basename $@)
	unzip -d $(basename $@) $<
	for file in $(basename $@)/*; do chmod 644 $$file; mv $$file $(basename $@).$${file##*.}; done
	rmdir $(basename $@)
	touch $@

africa_2020_tifs = data/tif/AFR_PPP_2020_adj_v2.tif data/tif/AFR_PPP_A1565PL_farmer_aged_lt400ppp_2020_adj_v5.tif data/tif/AFR_PPP_A1565PL_farmer_aged_2020_adj_v5.tif

#an experiment to start with adm4 and dissolve up
# data/shp/gadm36.shp: data/gz/gadm36_shp.zip
# 	rm -rf $(basename $@)
# 	mkdir -p $(basename $@)
# 	unzip -d $(basename $@) $<
# 	for file in $(basename $@)/*; do chmod 644 $$file; mv $$file $(basename $@).$${file##*.}; done
# 	rmdir $(basename $@)
# 	touch $@

#######################
# RESHAPE POLYGON DATA  #
#######################

#continents-levels2-2.shp is Africa, 
# throw away the other continents to keep size down on Carto and because I only have WorldPop prepared for those.
data/shp/continents-levels2-2.shp: data/shp/gadm36_2.shp data/shp/ne_10m_admin_0_countries.shp
	mkdir -p $(dir $@)
	mapshaper-xl -i $< \
	-join keys="GID_0,ISO_A3" $(word 2,$^) fields="NAME,ISO_A3,FORMAL_EN,NAME_SORT,SUBREGION,CONTINENT" \
	-rename-fields "Country=NAME,FormalCountryName=FORMAL_EN,CountrySort=NAME_SORT,AfricaRegion=SUBREGION" \
    -split CONTINENT \
	-o format=shapefile $(dir $@)/continents-levels2-.shp
	-rm $(dir $@)continents-levels2-{0,1,3,4,5,6,7,8,9}.*


#UGANDA and ETHIOPIA have some problem areas that crash QGIS when using them as INTERSECT layers.
#We do not use intersect in this Makefile so far, but keeping this for later.
data/shp/africa-carefulregions.shp: data/shp/continents-levels2-2.shp
	mkdir -p $(dir $@)
	mapshaper-xl -i $< \
	-filter "GID_0!=='UGA'" \
	-filter "GID_0!=='ETH'" \
	-o format=shapefile $@


#######################
# CONVERT RASTER DATA TO VECTOR  #
#######################

DOCKERID := $(shell cat data/docker.pid) #"98aa123a0d43"

data/docker.pid:
	mkdir -p $(dir $@)
	#echo DISPLAY IP address must be your local machine IP.
	#on Mac you must run socat as described at http://kartoza.com/en/blog/how-to-run-a-linux-gui-application-on-osx-using-docker/
	@echo "Docker was freshly started, you may need to reinitiate the process"
	docker run --detach  -e DISPLAY=10.253.73.71:0 -i -t \
	 -v $$(pwd)/rasterScripts/.config:/root/.config \
	 -v /Users/thadk:/home/thadk  \
	 -v $$(pwd):/opt/data kartoza/qgis-desktop:2.8 /bin/bash > $@

data/docker.aptgetupdate:
	@echo "Trying to run apt-get for java: Docker was freshly started, you may need to reinitiate the process"
	mkdir -p $(dir $@)
	docker exec -i -t $(DOCKERID) apt-get update
	docker exec -i -t $(DOCKERID) apt-get install xvfb -y
	docker exec -i -t $(DOCKERID) apt-get install python-yaml -y
	#Turn off QGIS initial tooltip so QGIS headless doesn't hang endlessly:
	docker exec -i -t $(DOCKERID) printf "[Qgis]\nshowTips=false" > /root/.config/QGIS/QGIS2.conf
	touch $@


#######################
# USE RASTER DATA AGAINST VECTOR #
#######################

#On my MBP2016, each raster takes about 100sec to run on the polygons.
data/shp/continents-levels2-2_pop.shp: data/shp/continents-levels2-2.shp data/docker.pid data/docker.aptgetupdate ${africa_2020_tifs}
#	on linux use xvfb-run to make it headless
	cp $(basename $<).shp $(basename $@).shp
	cp $(basename $<).dbf $(basename $@).dbf
	cp $(basename $<).shx $(basename $@).shx
	cp $(basename $<).prj $(basename $@).prj
	-docker exec -t $(DOCKERID) \
	qgis  \
	 --code /opt/data/rasterScripts/africaPopulationZonalStats.py \
	 --nologo \
		/opt/data/$@

data/shp/continents-levels2-2_pop_density.shp: data/shp/continents-levels2-2_pop.shp
	mapshaper-xl -i $< \
	 -each "AREA=$$.area,dens20pop=all20pop_s/AREA,rurdense=rur20pop_s/AREA" \
	 -o format=shapefile $@

#######################
# Upload #
#######################
carto-upload: CARTO_USER:=$(shell cat ../creds/CARTO_USER)
carto-upload: CARTO_APIKEY:=$(shell cat ../creds/CARTO_APIKEY)
carto-upload: 
	curl -v -F file=@$(realpath $<) \
	"https://$(CARTO_USER).carto.com/api/v1/imports/?api_key=$(CARTO_APIKEY)"


#######################
#  Cleanup #
#######################

clean: DATESHORT:=$(shell date +%Y-%m-%d-%H-%M-%S)
clean: JUNKBIN= ~/Downloads/VMs
clean:
	mkdir -p ${JUNKBIN}
	-rm data/docker.pid
	-rm data/docker.aptgetupdate
	-mv data/shp ${JUNKBIN}/shp-$(DATESHORT)
	-mv data/geojson ${JUNKBIN}/geojson-$(DATESHORT)
	-mv data/csv ${JUNKBIN}/csv-$(DATESHORT)