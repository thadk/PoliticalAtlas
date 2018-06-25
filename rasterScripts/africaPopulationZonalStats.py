# run with qgis --code meh-china.py ../adm1-asiawide/adm1-asiawide.shp
# based on http://gis.stackexchange.com/a/50125/4911 , worked with qgis 2.8 in mac homebrew

from qgis.analysis import QgsZonalStatistics
from qgis.core import *
from qgis.utils import *
from timeit import default_timer as timer
from time import sleep

import yaml
with open('/opt/data/rasterScripts/populationTif.yaml') as f:
    # use safe_load instead load
    dataMap = yaml.safe_load(f)
    for i in dataMap:
        print "Starting " + i['detailLabel'] + " aka " + i["prefixColumn"]

        #Symlinks to the TIF files does not work

        #Use the layer already loaded in QGIS by command line options
        polygonLayer = iface.activeLayer()
        print "Found layer:", iface.activeLayer()
        zoneStat = QgsZonalStatistics (polygonLayer, i["filePath"], i["prefixColumn"])

        start = timer()
        oneOutput = zoneStat.calculateStatistics(None)
        end = timer()
        print "Done-"+ i["prefixColumn"]  + str(oneOutput) + " in " + str(end - start)


QgsApplication.exitQgis()
QgsApplication.exitQgis()

