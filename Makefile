#Similar Makefile which this format was inspired by: https://github.com/scities-data/metro-atlas_2014/blob/master/Makefile
# To a lesser extent, this guide https://github.com/datamade/data-making-guidelines and
# also Mike Bostock's article: https://bost.ocks.org/mike/make/

#TODO transition from QGIS 2.08.9 to 3.2 using https://gis.stackexchange.com/questions/244828/automatisation-of-zonal-statistics-with-python-script?rq=1

# := assignment only gets run once at the beginning of everything
# = assignment gets run each time (but can cause an infinite loop)

.DEFAULT_GOAL := data/gz/continents-levels2-2_pop_density.zip

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

#Lake layer:
#http://naciscdn.org/naturalearth/10m/physical/ne_10m_lakes.zip

#an experiment to start with adm4 and dissolve up
# data/gz/gadm36_shp.zip:
# 	mkdir -p $(dir $@)
# 	curl 'https://data.biogeo.ucdavis.edu/data/gadm3.6/gadm36_shp.zip' -o $@.download
# 	mv $@.download $@


data/gz/Asia_PPP_2020_adj_v2.zip:
	mkdir -p $(dir $@)
	echo visit http://www.worldpop.org.uk/data/files/index.php?dataset=327&zip_title=Asia%201km%20Population&action=group
	echo save to $@
	sleep 10


data/gz/LAC_PPP_2020_adj_v2.zip:
	mkdir -p $(dir $@)
	echo visit http://www.worldpop.org.uk/data/files/index.php?dataset=329&zip_title=Latin%20America%20and%20the%20Caribbean%201km%20Population&action=group
	echo save to $@
	sleep 10
	
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

data/tif/LAC_PPP_2020_adj_v2.tif: data/gz/LAC_PPP_2020_adj_v2.zip
	rm -rf $(basename $@)
	mkdir -p $(basename $@)
	unzip -d $(basename $@) $<
	for file in $(basename $@)/*; do chmod 644 $$file; mv $$file $(basename $@).$${file##*.}; done
	rmdir $(basename $@)
	touch $@

data/tif/Asia_PPP_2020_adj_v2.tif: data/gz/Asia_PPP_2020_adj_v2.zip
	rm -rf $(basename $@)
	mkdir -p $(basename $@)
	unzip -d $(basename $@) $<
	for file in $(basename $@)/*; do chmod 644 $$file; mv $$file $(basename $@).$${file##*.}; done
	rmdir $(basename $@)
	touch $@

#an experiment to start with adm4 and dissolve up
# data/shp/gadm36.shp: data/gz/gadm36_shp.zip
# 	rm -rf $(basename $@)
# 	mkdir -p $(basename $@)
# 	unzip -d $(basename $@) $<
# 	for file in $(basename $@)/*; do chmod 644 $$file; mv $$file $(basename $@).$${file##*.}; done
# 	rmdir $(basename $@)
# 	touch $@


#remove the spaces in the filename after your download
data/tif/Asia1kmAgestructures/README.txt: data/gz/Asia1kmAgestructures.7z
	7z x $< -o$(dir $@)
	rm -rf $(dir $@)Asia_PPP_{A0004,A0509,A1014}_{M,F}_{2000,2005,2010,2015,2020}_adj_v2.tif
	rm -rf $(dir $@)Asia_PPP_{A0004,A0509,A1014}_{M,F}_{2000,2005,2010,2015,2020}_adj_v2.tif.*
	rm -rf $(dir $@)Asia_PPP_{A1519,A65PL,A2024,A2529,A3034,A3539,A4044,A4549,A5054,A5559,A6064}_{M,F}_{2000,2005,2010,2015}_adj_v2.tif
	rm -rf $(dir $@)Asia_PPP_{A1519,A65PL,A2024,A2529,A3034,A3539,A4044,A4549,A5054,A5559,A6064}_{M,F}_{2000,2005,2010,2015}_adj_v2.tif.*
	touch $@

#remove the spaces in the filename after your download
data/tif/LatinAmericaandtheCaribbean1kmAgestructures/README.txt: data/gz/LatinAmericaandtheCaribbean1kmAgestructures.7z
	7z x $< -o$(dir $@)
	rm -rf $(dir $@)LAC_PPP_{A0004,A0509,A1014}_{M,F}_{2000,2005,2010,2015,2020}_adj_v1.tif
	rm -rf $(dir $@)LAC_PPP_{A0004,A0509,A1014}_{M,F}_{2000,2005,2010,2015,2020}_adj_v1.tif.*
	rm -rf $(dir $@)LAC_PPP_{A1519,A65PL,A2024,A2529,A3034,A3539,A4044,A4549,A5054,A5559,A6064}_{M,F}_{2000,2005,2010,2015}_adj_v1.tif
	rm -rf $(dir $@)LAC_PPP_{A1519,A65PL,A2024,A2529,A3034,A3539,A4044,A4549,A5054,A5559,A6064}_{M,F}_{2000,2005,2010,2015}_adj_v1.tif.*
	touch $@


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

#continents-levels2-7.shp is Null continent, needed for French Guyana (GUF) and GLP.
#continents-levels2-6.shp is North America, needed for Mexico (MEX)
#continents-levels2-4.shp is South America
#pull in levels1 for BLZ, JAM, TTO, DMA, LCA, VCT, BHS, etc.
# throw away the other continents to keep size down on Carto and because I only have WorldPop prepared for those.
#TODO merge in MEX, GUF, GLP.
data/shp/continents-levels2-LAC.shp: data/shp/gadm36_2.shp data/shp/ne_10m_admin_0_countries.shp
	mkdir -p $(dir $@)
	mapshaper-xl -i $< \
	-join keys="GID_0,ISO_A3" $(word 2,$^) fields="NAME,ISO_A3,FORMAL_EN,NAME_SORT,SUBREGION,CONTINENT" \
	-rename-fields "Country=NAME,FormalCountryName=FORMAL_EN,CountrySort=NAME_SORT,AfricaRegion=SUBREGION" \
    -split CONTINENT \
	-o format=shapefile $(dir $@)/continents-levels2-.shp
	-rm $(dir $@)continents-levels2-{1,2,3,5,8}.*
	mv $(dir $@)continents-levels2-4.shp $@
	mv $(dir $@)continents-levels2-4.shx $(basename $@).shx
	mv $(dir $@)continents-levels2-4.prj $(basename $@).prj
	mv $(dir $@)continents-levels2-4.dbf $(basename $@).dbf


#continents-levels0-1.shp is Asia?, 
# this is used for the layer with the boundaries between countries.
data/shp/continents-levels0-Asia.shp: data/shp/gadm36_0.shp data/shp/ne_10m_admin_0_countries.shp
	mkdir -p $(dir $@)
	mapshaper-xl -i $< \
	-join keys="GID_0,ISO_A3" $(word 2,$^) fields="NAME,ISO_A3,FORMAL_EN,NAME_SORT,SUBREGION,CONTINENT" \
	-rename-fields "Country=NAME,FormalCountryName=FORMAL_EN,CountrySort=NAME_SORT,AfricaRegion=SUBREGION" \
    -split CONTINENT \
	-innerlines \
	-simplify dp 10% \
	-o format=shapefile $(dir $@)/continents-levels0-.shp
	-rm $(dir $@)continents-levels0-{1,3,4,5,6,7,8,9}.*	
	mv $(dir $@)continents-levels0-2.shp $@
	mv $(dir $@)continents-levels0-2.shx $(basename $@).shx
	mv $(dir $@)continents-levels0-2.prj $(basename $@).prj
	mv $(dir $@)continents-levels0-2.dbf $(basename $@).dbf

	# Maldives (MDV) has only adm_0
	# certain parts of Israel (ISR) and Armenia (ARM) are not subdivided past 1 and these are handled manually below.
data/shp/gadm36_1_Asia_extras.shp: data/shp/gadm36_1.shp
	time mapshaper-xl -i $< \
	-filter '"TKM,XCA,SAU,KWT,QAT,BHR,HKG,SGP".indexOf(GID_0) > -1 || "ISR.7_1,ISR.4_1,ISR.6_1,ISR.2_1,ISR.3_1,ISR.5_1,ISR.1_1,ARM.1_1,ARM.2_1,ARM.3_1,ARM.4_1,ARM.5_1,ARM.6_1,ARM.7_1,ARM.8_1,ARM.9_1,ARM.10_1,ARM.11_1".indexOf(GID_1) > -1' \
	-each 'GID_2=GID_1, NAME_2=NAME_1, VARNAME_2="", NL_NAME_2="", TYPE_2=TYPE_1, ENGTYPE_2=ENGTYPE_1, CC_2="", HASC_2=HASC_1' \
	-filter-fields GID_0,NAME_0,NAME_1,GID_1,GID_2,CC_2,HASC_2,TYPE_2,NL_NAME_2,VARNAME_2,NAME_2 \
	-o format=shapefile $@

#continents-levels2-1.shp is asia except it is missing central saudi arabia.
#TODO pull in levels1 for TKM, XCA?, SAU, MDV
# throw away the other continents to keep size down on Carto and because I only have WorldPop prepared for those.
data/shp/continents-levels2-Asia.shp: data/shp/gadm36_2.shp data/shp/ne_10m_admin_0_countries.shp data/shp/gadm36_1_Asia_extras.shp
	mkdir -p $(dir $@)
	mapshaper-xl -i $< $(word 3,$^) combine-files \
	-merge-layers force \
	-join keys="GID_0,ISO_A3" $(word 2,$^) fields="NAME,ISO_A3,FORMAL_EN,NAME_SORT,SUBREGION,CONTINENT" \
	-rename-fields "Country=NAME,FormalCountryName=FORMAL_EN,CountrySort=NAME_SORT,AfricaRegion=SUBREGION" \
    -split CONTINENT \
	-o format=shapefile $(dir $@)continents-levels2-.shp
	-rm $(dir $@)continents-levels2-{2,3,4,5,6,7,8}.*
	mv $(dir $@)continents-levels2-1.shp $@
	mv $(dir $@)continents-levels2-1.shx $(basename $@).shx
	mv $(dir $@)continents-levels2-1.prj $(basename $@).prj
	mv $(dir $@)continents-levels2-1.dbf $(basename $@).dbf
	

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

# Generate the adult age brackets for LAC
# https://gis.stackexchange.com/questions/84550/performing-raster-calculator-functions-using-python-and-open-source-modules?noredirect=1&lq=1

#TODO use Docker GDAL.
# http://www.gdal.org/gdal_calc.html
data/tif/Asia_PPP_A1565PL_2020_adj_v2.tif: data/tif/Asia1kmAgestructures/README.txt
	ls data/tif/Asia1kmAgestructures/Asia_PPP_{A1519,A65PL,A2024,A2529,A3034,A3539,A4044,A4549,A5054,A5559,A6064}_{M,F}_2020_adj_v2.tif
	/Library/Frameworks/GDAL.framework/Versions/2.2/Programs/gdal_calc.py -A $(dir $<)Asia_PPP_A1519_F_2020_adj_v2.tif \
		-B $(dir $<)Asia_PPP_A1519_M_2020_adj_v2.tif \
		-C $(dir $<)Asia_PPP_A2024_F_2020_adj_v2.tif \
		-D $(dir $<)Asia_PPP_A2024_M_2020_adj_v2.tif \
		-E $(dir $<)Asia_PPP_A2529_F_2020_adj_v2.tif \
		-F $(dir $<)Asia_PPP_A2529_M_2020_adj_v2.tif \
		-G $(dir $<)Asia_PPP_A3034_F_2020_adj_v2.tif \
		-H $(dir $<)Asia_PPP_A3034_M_2020_adj_v2.tif \
		-I $(dir $<)Asia_PPP_A3539_F_2020_adj_v2.tif \
		-J $(dir $<)Asia_PPP_A3539_M_2020_adj_v2.tif \
		-K $(dir $<)Asia_PPP_A4044_F_2020_adj_v2.tif \
		-L $(dir $<)Asia_PPP_A4044_M_2020_adj_v2.tif \
		-M $(dir $<)Asia_PPP_A4549_F_2020_adj_v2.tif \
		-N $(dir $<)Asia_PPP_A4549_M_2020_adj_v2.tif \
		-O $(dir $<)Asia_PPP_A5054_F_2020_adj_v2.tif \
		-P $(dir $<)Asia_PPP_A5054_M_2020_adj_v2.tif \
		-Q $(dir $<)Asia_PPP_A5559_F_2020_adj_v2.tif \
		-R $(dir $<)Asia_PPP_A5559_M_2020_adj_v2.tif \
		-S $(dir $<)Asia_PPP_A6064_F_2020_adj_v2.tif \
		-T $(dir $<)Asia_PPP_A6064_M_2020_adj_v2.tif \
		-U $(dir $<)Asia_PPP_A65PL_F_2020_adj_v2.tif \
		-V $(dir $<)Asia_PPP_A65PL_M_2020_adj_v2.tif \
		--outfile=$@ --calc="A+B+C+D+E+F+G+H+I+J+K+L+M+N+O+P+Q+R+S+T+U+V"

# data/tif/Asia_PPP_A1565PL_2020_adj_v2_ruralmask.tif: data/tif/Asia_PPP_A1565PL_2020_adj_v2.tif
# 	/Library/Frameworks/GDAL.framework/Versions/2.2/Programs/gdal_calc.py -A $< --A_band=1 \
# 	--outfile=$@ --calc="(A <=400) * A"

data/tif/Asia_PPP_A1565PL_lt400ppp_2020_adj_v2_qgis.tif: data/tif/Asia_PPP_A1565PL_2020_adj_v2.tif
	echo "open qgis and run the comment command below in raster calculator. I wasn't able to exactly replicate in gdal"
	sleep 10
	#That produced all 0's, I  used ("Asia_PPP_A1565PL_2020_adj_v2@1" <= 400) * "Asia_PPP_A1565PL_2020_adj_v2@1" in QGIS vector calculator instead
	# The only issue I see is it removed all the no-data.

Asia_2020_tifs = data/tif/Asia_PPP_2020_adj_v2.tif data/tif/Asia_PPP_A1565PL_lt400ppp_2020_adj_v2_qgis.tif data/tif/Asia_PPP_A1565PL_2020_adj_v2.tif


#TODO use Docker GDAL.
data/tif/LAC_PPP_A1565PL_2020_adj_v2.tif: data/tif/LatinAmericaandtheCaribbean1kmAgestructures/README.txt
	/Library/Frameworks/GDAL.framework/Versions/2.2/Programs/gdal_calc.py -A $(dir $<)LAC_PPP_A1519_F_2020_adj_v1.tif \
		-B $(dir $<)LAC_PPP_A1519_M_2020_adj_v1.tif \
		-C $(dir $<)LAC_PPP_A2024_F_2020_adj_v1.tif \
		-D $(dir $<)LAC_PPP_A2024_M_2020_adj_v1.tif \
		-E $(dir $<)LAC_PPP_A2529_F_2020_adj_v1.tif \
		-F $(dir $<)LAC_PPP_A2529_M_2020_adj_v1.tif \
		-G $(dir $<)LAC_PPP_A3034_F_2020_adj_v1.tif \
		-H $(dir $<)LAC_PPP_A3034_M_2020_adj_v1.tif \
		-I $(dir $<)LAC_PPP_A3539_F_2020_adj_v1.tif \
		-J $(dir $<)LAC_PPP_A3539_M_2020_adj_v1.tif \
		-K $(dir $<)LAC_PPP_A4044_F_2020_adj_v1.tif \
		-L $(dir $<)LAC_PPP_A4044_M_2020_adj_v1.tif \
		-M $(dir $<)LAC_PPP_A4549_F_2020_adj_v1.tif \
		-N $(dir $<)LAC_PPP_A4549_M_2020_adj_v1.tif \
		-O $(dir $<)LAC_PPP_A5054_F_2020_adj_v1.tif \
		-P $(dir $<)LAC_PPP_A5054_M_2020_adj_v1.tif \
		-Q $(dir $<)LAC_PPP_A5559_F_2020_adj_v1.tif \
		-R $(dir $<)LAC_PPP_A5559_M_2020_adj_v1.tif \
		-S $(dir $<)LAC_PPP_A6064_F_2020_adj_v1.tif \
		-T $(dir $<)LAC_PPP_A6064_M_2020_adj_v1.tif \
		-U $(dir $<)LAC_PPP_A65PL_F_2020_adj_v1.tif \
		-V $(dir $<)LAC_PPP_A65PL_M_2020_adj_v1.tif \
		--outfile=$@ --calc="A+B+C+D+E+F+G+H+I+J+K+L+M+N+O+P+Q+R+S+T+U+V"

data/tif/LAC_PPP_A1565PL_lt400ppp_2020_adj_v2_qgis.tif: data/tif/LAC_PPP_A1565PL_2020_adj_v2.tif
	echo "open qgis and run the comment command below in raster calculator. I wasn't able to exactly replicate in gdal"
	sleep 10
	# ("LAC_PPP_A1565PL_2020_adj_v2@1" <= 400) * "LAC_PPP_A1565PL_2020_adj_v2@1"

LAC_2020_tifs = data/tif/LAC_PPP_2020_adj_v2.tif data/tif/LAC_PPP_A1565PL_lt400ppp_2020_adj_v2_qgis.tif data/tif/LAC_PPP_A1565PL_2020_adj_v2.tif

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

#TODO for asia, figure out how to deal with the overflow in really really big cities automatically.
#On my MBP2016, each raster takes about 100sec to run on the polygons.
data/shp/continents-levels2-Asia_pop.shp: data/shp/continents-levels2-Asia.shp data/docker.pid data/docker.aptgetupdate ${Asia_2020_tifs}
#	on linux use xvfb-run to make it headless
	cp $(basename $<).shp $(basename $@).shp
	cp $(basename $<).dbf $(basename $@).dbf
	cp $(basename $<).shx $(basename $@).shx
	cp $(basename $<).prj $(basename $@).prj
	-docker exec -t $(DOCKERID) \
	xvfb-run qgis  \
	 --code /opt/data/rasterScripts/asiaPopulationZonalStats.py \
	 --nologo \
		/opt/data/$@

#FOR has_age_data column, check if poopulation is less than 5000 first, assign "maybe", otherwise yes or no.
#SIMPLIFY the polygons to fit within carto limits (82mb compressed is too big)
data/shp/continents-levels2-Asia_pop_density.shp: data/shp/continents-levels2-Asia_pop.shp
	mapshaper-xl -i $< \
	 -each "AREA=$$.area,dens20pop=all20pop_s/AREA,rurdense=rur20pop_s/AREA,has_age_da=adu20pop_s!=rur20pop_s" \
	 -simplify dp 50% \
	 -o format=shapefile $@

data/csv/continents-levels2-Asia_pop_density.csv: data/shp/continents-levels2-Asia_pop.shp
	mkdir -p $(dir $@)
	mapshaper-xl -i $< \
	 -each "AREA=$$.area,dens20pop=all20pop_s/AREA,rurdense=rur20pop_s/AREA,has_age_da=adu20pop_s!=rur20pop_s" \
	 -o format=csv $@


#On my MBP2016, each raster takes about 100sec to run on the polygons.
data/shp/continents-levels2-LAC_pop.shp: data/shp/continents-levels2-LAC.shp data/docker.pid data/docker.aptgetupdate ${LAC_2020_tifs}
#	on linux use xvfb-run to make it headless
	cp $(basename $<).shp $(basename $@).shp
	cp $(basename $<).dbf $(basename $@).dbf
	cp $(basename $<).shx $(basename $@).shx
	cp $(basename $<).prj $(basename $@).prj
	-docker exec -t $(DOCKERID) \
	xvfb-run qgis  \
	 --code /opt/data/rasterScripts/lacPopulationZonalStats.py \
	 --nologo \
		/opt/data/$@

#TODO: convert area to PPsqkm
data/shp/continents-levels2-LAC_pop_density.shp: data/shp/continents-levels2-LAC_pop.shp
	mapshaper-xl -i $< \
	 -each "AREA=$$.area,dens20pop=all20pop_s/AREA,rurdense=rur20pop_s/AREA" \
	 -o format=shapefile $@

#######################
# Upload #
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
