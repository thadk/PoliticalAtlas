# See main Makefile for Docker setup, etc.

#################
# DOWNLOAD DATA #
#################

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


#################
# UNCOMPRESS DATA #
#################

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

#######################
# RESHAPE POLYGON DATA  #
#######################

#MUS is not in the continent of africa in Natural Earth, but in Seven Seas (Open Ocean), override the continent value before the "split".
data/shp/gadm36_1_AFR_extras.shp: data/shp/gadm36_1.shp data/shp/ne_10m_admin_0_countries.shp
	time mapshaper-xl -i $< \
	-join keys="GID_0,ISO_A3" $(word 2,$^) fields="NAME,ISO_A3,FORMAL_EN,NAME_SORT,LASTCENSUS,SUBREGION,CONTINENT" \
	-rename-fields "Country=NAME,Formal=FORMAL_EN,CountrySo=NAME_SORT,AfricaReg=SUBREGION,Pre2012Ce=LASTCENSUS" \
	-filter '"CPV,LBY,ESH,LSO,REU,SYC,COM,MYT,MUS".indexOf(GID_0) > -1' \
	-each 'GID_2=GID_1, NAME_2=NAME_1, VARNAME_2="", NL_NAME_2="", TYPE_2=TYPE_1, ENGTYPE_2=ENGTYPE_1, CC_2="", HASC_2=HASC_1, CONTINENT="Africa"' \
	-filter-fields GID_0,NAME_0,NAME_1,GID_1,GID_2,CC_2,HASC_2,TYPE_2,NL_NAME_2,VARNAME_2,NAME_2,ISO_A3,Formal,CountrySo,Country,Pre2012Ce,AfricaReg,CONTINENT \
	-o format=shapefile $@

#continents-levels2-2.shp is Africa, 
#TODO: pull in level1 for CPV, LBY, ESH, LSO, MUS, REU
# throw away the other continents to keep size down on Carto and because I only have WorldPop prepared for those.
data/shp/continents-levels2-AFR.shp: data/shp/gadm36_2.shp data/shp/ne_10m_admin_0_countries.shp data/shp/gadm36_1_AFR_extras.shp
	mkdir -p $(dir $@)
	mapshaper-xl -i $< $(word 3,$^) combine-files \
	-join keys="GID_0,ISO_A3" $(word 2,$^) fields="NAME,ISO_A3,FORMAL_EN,NAME_SORT,LASTCENSUS,SUBREGION,CONTINENT" target="gadm36_2" \
	-rename-fields "Country=NAME,Formal=FORMAL_EN,CountrySo=NAME_SORT,AfricaReg=SUBREGION,Pre2012Ce=LASTCENSUS" target="gadm36_2" \
	-merge-layers force target="gadm36_2,gadm36_1_AFR_extras" \
    -split CONTINENT \
	-o format=shapefile $(dir $@)/continents-levels2-.shp
	-rm $(dir $@)continents-levels2-{1,3,4,5,6,7,8}.*
	mv $(dir $@)continents-levels2-2.shp $@
	mv $(dir $@)continents-levels2-2.shx $(basename $@).shx
	mv $(dir $@)continents-levels2-2.prj $(basename $@).prj
	mv $(dir $@)continents-levels2-2.dbf $(basename $@).dbf


#UGANDA and ETHIOPIA have some problem areas that crash QGIS when using them as INTERSECT layers.
#We do not use intersect in this Makefile so far, but keeping this for later.
data/shp/africa-carefulregions.shp: data/shp/continents-levels2-AFR.shp
	mkdir -p $(dir $@)
	mapshaper-xl -i $< \
	-filter "GID_0!=='UGA'" \
	-filter "GID_0!=='ETH'" \
	-o format=shapefile $@

#continents-levels0-3.shp is Africa, 
#TODO: pull in level1 for CPV, LBY, ESH, LSO, MUS, REU
# this is used for the layer with the boundaries between countries.
data/shp/continents-levels0-AFR.shp: data/shp/gadm36_0.shp data/shp/ne_10m_admin_0_countries.shp
	mkdir -p $(dir $@)
	mapshaper-xl -i $< \
	-join keys="GID_0,ISO_A3" $(word 2,$^) fields="NAME,ISO_A3,FORMAL_EN,NAME_SORT,SUBREGION,CONTINENT" \
	-rename-fields "Country=NAME,FormalCountryName=FORMAL_EN,CountrySort=NAME_SORT,AfricaRegion=SUBREGION" \
    -split CONTINENT \
	-innerlines \
	-simplify dp 10% \
	-o format=shapefile $(dir $@)/continents-levels0-.shp
	-rm $(dir $@)continents-levels0-{1,2,4,5,6,7,8,9}.*
	mv $(dir $@)continents-levels0-3.shp $@
	mv $(dir $@)continents-levels0-3.shx $(basename $@).shx
	mv $(dir $@)continents-levels0-3.prj $(basename $@).prj
	mv $(dir $@)continents-levels0-3.dbf $(basename $@).dbf


#######################
# CLEAN & PROCESS RASTER DATA  #
#######################

#TODO convert this into the new process instead of using saved AWS versions of these files.

#######################
# USE RASTER DATA AGAINST VECTOR #
#######################

#On my MBP2016, each raster takes about 100sec to run on the polygons.
data/shp/continents-levels2-AFR_pop.shp: data/shp/continents-levels2-AFR.shp data/docker.pid data/docker.aptgetupdate ${africa_2020_tifs}
#	on linux use xvfb-run to make it headless
	cp $(basename $<).shp $(basename $@).shp
	cp $(basename $<).dbf $(basename $@).dbf
	cp $(basename $<).shx $(basename $@).shx
	cp $(basename $<).prj $(basename $@).prj
	-docker exec -t $(DOCKERID) \
	xvfb-run qgis  \
	 --code /opt/data/rasterScripts/africaPopulationZonalStats.py \
	 --nologo \
		/opt/data/$@

data/shp/continents-levels2-AFR_pop_density.shp: data/shp/continents-levels2-AFR_pop.shp
	mapshaper-xl -i $< \
	 -each "AREA=$$.area,dens20pop=all20pop_s/AREA,rurdense=rur20pop_s/AREA,has_age_da=adu20pop_s!=rur20pop_s" \
	 -o format=shapefile $@

data/csv/continents-levels2-AFR_pop_density.csv: data/shp/continents-levels2-AFR_pop.shp
	mkdir -p $(dir $@)
	mapshaper-xl -i $< \
	 -each "AREA=$$.area,dens20pop=all20pop_s/AREA,rurdense=rur20pop_s/AREA,has_age_da=adu20pop_s!=rur20pop_s" \
	 -o format=csv $@

#######################
# Upload #
#######################

# See main Makefile.