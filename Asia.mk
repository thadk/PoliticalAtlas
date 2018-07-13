# See main Makefile for Docker setup, etc.

#################
# DOWNLOAD DATA #
#################

data/gz/Asia_PPP_2020_adj_v2.zip:
	mkdir -p $(dir $@)
	echo visit http://www.worldpop.org.uk/data/files/index.php?dataset=327&zip_title=Asia%201km%20Population&action=group
	echo save to $@
	sleep 10

data/gz/Asia1kmAgestructures.7z:
	mkdir -p $(dir $@)
	echo visit http://www.worldpop.org.uk/data/
	echo get the file data/gz/Asia1kmAgestructures.7z from Worldpop, remove the spaces in the file name.
	echo save to $@
	sleep 10

# 

#################
# UNCOMPRESS DATA #
#################

data/tif/Asia_PPP_2020_adj_v2.tif: data/gz/Asia_PPP_2020_adj_v2.zip
	rm -rf $(basename $@)
	mkdir -p $(basename $@)
	unzip -d $(basename $@) $<
	for file in $(basename $@)/*; do chmod 644 $$file; mv $$file $(basename $@).$${file##*.}; done
	rmdir $(basename $@)
	touch $@

#remove the spaces in the filename after your download
data/tif/Asia1kmAgestructures/README.txt: data/gz/Asia1kmAgestructures.7z
	7z x $< -o$(dir $@)
	rm -rf $(dir $@)Asia_PPP_{A0004,A0509,A1014}_{M,F}_{2000,2005,2010,2015,2020}_adj_v2.tif
	rm -rf $(dir $@)Asia_PPP_{A0004,A0509,A1014}_{M,F}_{2000,2005,2010,2015,2020}_adj_v2.tif.*
	rm -rf $(dir $@)Asia_PPP_{A1519,A65PL,A2024,A2529,A3034,A3539,A4044,A4549,A5054,A5559,A6064}_{M,F}_{2000,2005,2010,2015}_adj_v2.tif
	rm -rf $(dir $@)Asia_PPP_{A1519,A65PL,A2024,A2529,A3034,A3539,A4044,A4549,A5054,A5559,A6064}_{M,F}_{2000,2005,2010,2015}_adj_v2.tif.*
	touch $@


#######################
# RESHAPE POLYGON DATA  #
#######################


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
# CLEAN & PROCESS RASTER DATA  #
#######################

# Generate the adult age brackets for LAC
# https://gis.stackexchange.com/questions/84550/performing-raster-calculator-functions-using-python-and-open-source-modules?noredirect=1&lq=1

#TODO use Docker GDAL.
# http://www.gdal.org/gdal_calc.html
# Merge all the individual 4 year age brackets into one adult bracket
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

#######################
# USE RASTER DATA AGAINST VECTOR #
#######################

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

#######################
# Upload #
#######################

# See main Makefile.