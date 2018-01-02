DB = ownership

parcels.geojson :
	esri2geojson http://gis1.cookcountyil.gov/arcgis/rest/services/cookVwrDynmc/MapServer/44 $@

exempt.geojson : parcels.geojson
	cat $< | python filter.py > $@

exempt : exempt.geojson
	ogr2ogr -f PostgreSQL PG:dbname=$(DB) -t_srs EPSG:3435 -nln $@ $<

CommAreas.zip :
	wget -O $@ "https://data.cityofchicago.org/api/geospatial/cauq-8yn6?method=export&format=Original"

CommAreas.shp : CommAreas.zip
	unzip $<

community_area : CommAreas.shp
	ogr2ogr -f PostgreSQL PG:dbname=$(DB) -t_srs EPSG:3435 -nlt MULTIPOLYGON -lco precision=NO -nln $@ $<

exempt_properties.csv :
	psql -d $(DB) -c "copy (select distinct on (pin14) pin14, address, community from exempt inner join community_area on st_intersects(exempt.wkb_geometry, community_area.wkb_geometry) where area_numbe in ('40', '41', '42')) to stdout with csv header" > $@
