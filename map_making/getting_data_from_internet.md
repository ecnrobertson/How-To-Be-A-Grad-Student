---
title: "Getting_data_from_internet"
output: html_document
---

This is a little extension of the original map_making.Rmd that has a fun thing I figured out for downloading soil data from soilgrids.org... This could likely be adapted to download a lot of different stuff. Basically, the entire of North America is too big to download the whole thing in one go, so this bash script breaks that whole extent into 10x10 degree boxes and downloads tiles of data for each of those. Then you input it into R, aggregate it, merge them together, clip it to North America (because it orginally include greenland) and then export it into a manageable file. This one was about 50MB at the end, so I probably didn't even need to aggregate it to use it!

# LANDCOVER DATA
## SOIL GRID DATA
Accessed from https://soilgrids.org/... clay, coarse fragments, and sand content.

```{bash, label="downloading_clay_data"}
#!/bin/bash

# Bounding box for USA + Canada
minLon=-170
maxLon=-52
minLat=24
maxLat=83

# Step size (degrees per tile)
step=10

# Loop through longitude
for lon in $(seq $minLon $step $(($maxLon - $step))); do
# Loop through latitude
for lat in $(seq $minLat $step $(($maxLat - $step))); do
lon1=$lon
lon2=$(($lon + $step))
lat1=$lat
lat2=$(($lat + $step))

# Build filename
out="clay_${lon1}_${lon2}_${lat1}_${lat2}.tif"

# Build URL
url="https://maps.isric.org/mapserv?map=/map/clay.map&SERVICE=WCS&VERSION=2.0.1&REQUEST=GetCoverage&COVERAGEID=clay_30-60cm_mean&FORMAT=image/tiff&SUBSET=long(${lon1},${lon2})&SUBSET=lat(${lat1},${lat2})&SUBSETTINGCRS=http://www.opengis.net/def/crs/EPSG/0/4326&OUTPUTCRS=http://www.opengis.net/def/crs/EPSG/0/4326"

echo "Downloading tile: $out"
curl -s "$url" -o "$out"
done
done

## then just the extra bit of Canada
# Additional eastern tiles for Canada
for lon1 in -52; do
lon2=-42
for lat1 in 24 34 44 54 64 74; do
lat2=$((lat1 + 10))
out="clay_${lon1}_${lon2}_${lat1}_${lat2}.tif"
url="https://maps.isric.org/mapserv?map=/map/clay.map&SERVICE=WCS&VERSION=2.0.1&REQUEST=GetCoverage&COVERAGEID=clay_30-60cm_mean&FORMAT=image/tiff&SUBSET=long(${lon1},${lon2})&SUBSET=lat(${lat1},${lat2})&SUBSETTINGCRS=http://www.opengis.net/def/crs/EPSG/0/4326&OUTPUTCRS=http://www.opengis.net/def/crs/EPSG/0/4326"
echo "Downloading tile: $out"
curl -s "$url" -o "$out"
done
done

```

```{bash, label="downloading_data"}
#!/bin/bash

# Bounding box for USA, Canada, Greenland
minLon=-170
maxLon=-30
minLat=24
maxLat=83

# Step size in degrees
step=10

# Set the layer to download: clay, cfvo, or sand
layer="clay"   # change to cfvo or sand
mapfile="${layer}.map"
coverage="${layer}_30-60cm_mean"

# Loop through longitudes
for lon in $(seq $minLon $step $(($maxLon - $step))); do
# Loop through latitudes
for lat in $(seq $minLat $step $(($maxLat - $step))); do
lon1=$lon
lon2=$(($lon + $step))
lat1=$lat
lat2=$(($lat + $step))

# Output filename
out="${layer}_${lon1}_${lon2}_${lat1}_${lat2}.tif"

# Build WCS URL
url="https://maps.isric.org/mapserv?map=/map/${mapfile}&SERVICE=WCS&VERSION=2.0.1&REQUEST=GetCoverage&COVERAGEID=${coverage}&FORMAT=image/tiff&SUBSET=long(${lon1},${lon2})&SUBSET=lat(${lat1},${lat2})&SUBSETTINGCRS=http://www.opengis.net/def/crs/EPSG/0/4326&OUTPUTCRS=http://www.opengis.net/def/crs/EPSG/0/4326"

echo "Downloading tile: $out"
curl -s "$url" -o "$out"
done
done
```

```{r, label="working_with_clay_data"}
library(raster)
test_raster <- raster("data/spatial_files/sand_230m/sand_-110_-100_24_34.tif")
plot(test_raster)

#reading in all the files
file_list <- list.files(path="data/spatial_files/sand_230m/", pattern="*.tif", all.files=TRUE, full.names=TRUE)
allrasters <- lapply(file_list, raster)
plot(allrasters[[1]])

###### Aggregating Rasters ######
allrasters <- list()

for (i in seq_along(file_list)) {
  raster <- raster(file_list[i])
  aggregated_raster <- raster::aggregate(raster, fact=4, fun=mean)
  allrasters[[i]] <- aggregated_raster
  print(paste("Completed aggregation for:", basename(file_list[i])))
}

###### Merging Rasters ######
merged <- do.call(merge, allrasters)

###### Clipping to just the US ######
library(rnaturalearth)
countries_sf <- ne_countries(
  scale = 10,
  country = c("United States of America", "Canada"),
  returnclass = "sf"
)
#make this into a SpatVector
countries_vect <- vect(countries_sf)
#make this into a SpatRaster so they're compatible 
merged_r <- rast(merged)
# Mask SpatRaster with SpatVector to only get the data for those countries
masked_r <- mask(merged_r, countries_vect)

plot(masked_r)

###### Writing Output ######
writeRaster(masked_r, "data/spatial_files/land_cover/sand_NA_1x1km_ag.tif", overwrite=T)

# merged.10 <- raster::aggregate(land.mask, fact=10, fun=mean)
# writeRaster(merged.10,"data/spatial_files/land_cover/clay_NA_2.5x2.5km_ag.tif", overwrite=TRUE)
```