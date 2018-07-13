# See main Makefile for Docker setup, etc.

#################
# DOWNLOAD DATA #
#################

data/gz/LAC_PPP_2020_adj_v2.zip:
	mkdir -p $(dir $@)
	echo visit http://www.worldpop.org.uk/data/files/index.php?dataset=329&zip_title=Latin%20America%20and%20the%20Caribbean%201km%20Population&action=group
	echo save to $@
	sleep 10

data/gz/LatinAmericaandtheCaribbean1kmAgestructures.7z:
	mkdir -p $(dir $@)
	echo visit http://www.worldpop.org.uk/data
	echo get data/gz/LatinAmericaandtheCaribbean1kmAgestructures.7z from Worldpop, remove the spaces from the filename.
	echo save to $@
	sleep 10

#################
# UNCOMPRESS DATA #
#################

data/tif/LAC_PPP_2020_adj_v2.tif: data/gz/LAC_PPP_2020_adj_v2.zip
	rm -rf $(basename $@)
	mkdir -p $(basename $@)
	unzip -d $(basename $@) $<
	for file in $(basename $@)/*; do chmod 644 $$file; mv $$file $(basename $@).$${file##*.}; done
	rmdir $(basename $@)
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


#######################
# CLEAN & PROCESS RASTER DATA #
#######################

# Generate the adult age brackets for LAC
# https://gis.stackexchange.com/questions/84550/performing-raster-calculator-functions-using-python-and-open-source-modules?noredirect=1&lq=1

#TODO use Docker GDAL.
# Merge all the individual 4 year age brackets into one adult bracket
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

#TODO this section.

#TODO: convert area to PPsqkm
data/shp/continents-levels2-LAC_pop_density.shp: data/shp/continents-levels2-LAC_pop.shp
	mapshaper-xl -i $< \
	 -each "AREA=$$.area,dens20pop=all20pop_s/AREA,rurdense=rur20pop_s/AREA" \
	 -o format=shapefile $@


#######################
# Upload #
#######################

# See main Makefile.