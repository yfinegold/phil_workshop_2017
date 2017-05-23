####################################################################################
#######    object: CLEAN AND COMBINE SHAPEFILES                 ####################
#######    Update : 2017/05/23                                  ####################
#######    contact: yelena.finegold@fao.org                      ####################
####################################################################################

#################### READ SHAPEFILES
shp03 <- readOGR("landcover_2003_IPCC.shp")
shp10 <- readOGR("landcover_2010_IPCC.shp")

crs(shp03)
crs(shp10)
# force the shapefiles into the same projection system if they are not already the same
proj4string(shp10) <- proj4string(shp03)

#################### DETERMINE EXTENT OF BOTH SHAPEFILES
ext <- extent(shp03)
extent(shp10)


#################### EXTRACT DBF AND CHECK DISTRIBUTION OF CLASSES
dbf03 <- shp03@data
dbf10 <- shp10@data

table(dbf03$Class_2)
table(dbf10$AGG14)

dbf03$fnf <- 0
dbf03$fnf[dbf03$Class_2 %in% c('Forest')] <- 1
dbf03$fnf[!dbf03$Class_2 %in% c('Forest')] <- 2

dbf10$fnf <- 0
dbf10$fnf[dbf10$AGG14 %in% c("Closed Forest",'Mangrove Forest','Open Forest')] <- 1
dbf10$fnf[!dbf10$AGG14 %in% c("Closed Forest",'Mangrove Forest','Open Forest')] <- 2

names(dbf03)
names(dbf10)

#################### GENERATE UNIQUE POLYGON ID AND STANDARDIZE NAMES
dbf03$polyid <- row(dbf03)[,1]
dbf10$polyid <- row(dbf10)[,1]

dbf03 <- dbf03[,c("polyid","fnf")]
dbf10 <- dbf10[,c("polyid","fnf")]

names(dbf03) <- c("polyid_03","fnf03")
names(dbf10) <- c("polyid_10","fnf10")


#################### DETERMINE LIST OF CLASSES FOR EACH DATASET
list_class03 <- unique(dbf03$fnf03)
list_class10 <- unique(dbf10$fnf10)
list_class   <- unique(list_class10,list_class03)
list_class   <- list_class[order(list_class)]


#################### CREATE NUMERIC CODE FOR EACH CLASS
code_class <- data.frame(cbind(list_class,1:length(list_class)))
names(code_class) <- c("class","code")
write.csv(code_class,"code_class.csv",row.names = F)

#################### MERGE THESE CODES IN DBF
dbf03 <- merge(dbf03,code_class,by.x="fnf03",by.y="class",all.x=T)
dbf10 <- merge(dbf10,code_class,by.x="fnf10",by.y="class",all.x=T)


#################### EXPORT THE HARMONIZED SHAPEFILES
shp03@data <- arrange(dbf03,polyid_03)
shp10@data <- arrange(dbf10,polyid_10)

writeOGR(shp03,"shp2003.shp","shp2003",driver="ESRI Shapefile",overwrite_layer = T)
writeOGR(shp10,"shp2010.shp","shp2010",driver="ESRI Shapefile",overwrite_layer = T)


#################### RASTERIZE FIRST SHAPEFILE AT 10m RESOLUTION
system(sprintf("gdal_rasterize -a %s -l %s -co COMPRESS=LZW -te %s %s %s %s -tr %s %s -ot Byte %s %s",
               "fnf03",
               "shp2003",
               ext@xmin,ext@ymin,ext@xmax,ext@ymax,
               30,30,
               "shp2003.shp",
               "shp2003.tif"
))
## in qgis
# gdal_rasterize -a fnf03 -tr 30.0 30.0 -te -170734.5 511386.7 898033 2330517 -co COMPRESS=LZW -ot Byte -l shp2003 C:/Users/finegold/Desktop/philippines/maps/phil/shp2010.shp C:/Users/finegold/Desktop/philippines/maps/phil/shp2010.tifgdal_rasterize -a fnf10 -tr 30.0 30.0 -te -170734.5 511386.7 898033 2330517 -co COMPRESS=LZW -ot Byte -l shp2010 C:/Users/finegold/Desktop/philippines/maps/phil/shp2003.shp C:/Users/finegold/Desktop/philippines/maps/phil/shp2003.tif


#################### RASTERIZE SECOND SHAPEFILE AT 30m RESOLUTION
system(sprintf("gdal_rasterize -a %s -l %s -co COMPRESS=LZW -te %s %s %s %s -tr %s %s -ot Byte %s %s",
               "fnf03",
               "shp2010",
               ext@xmin,ext@ymin,ext@xmax,ext@ymax,
               30,30,
               "shp2010.shp",
               "shp2010.tif"
))
## in qgis
# gdal_rasterize -a fnf10 -tr 30.0 30.0 -te -170734.5 511386.7 898033 2330517 -co COMPRESS=LZW -ot Byte -l shp2010 C:/Users/finegold/Desktop/philippines/maps/phil/shp2010.shp C:/Users/finegold/Desktop/philippines/maps/phil/shp2010.tifgdal_rasterize -a fnf10 -tr 30.0 30.0 -te -170734.5 511386.7 898033 2330517 -co COMPRESS=LZW -ot Byte -l shp2010 C:/Users/finegold/Desktop/philippines/maps/phil/shp2010.shp C:/Users/finegold/Desktop/philippines/maps/phil/shp2010.tif
## r version (not tested)
# # Define RasterLayer object
# r.raster <- raster()
# 
# # Define raster extent
# extent(r.raster) <- extent(ext)
# 
# # Define pixel size
# res(r.raster) <- 30
# 
# rast2003 <- rasterize(shp03, r.raster, 'fnf03')
# rast2010 <- rasterize(shp10, r.raster, 'fnf10')

#################### COMBINE BOTH RASTERS INTO A 2_DATES_CODE RASTER
system(sprintf("gdal_calc.py -A %s -B %s --type=Byte --co COMPRESS=LZW --outfile=%s --calc=\"%s\"",
               "shp2003.tif",
               "shp2010.tif",
               "change_0310.tif",
               "A*10+B"
))
# # windows version
# rast2003 <- raster('shp2003.tif')
# rast2010 <- raster('shp2010.tif')
# change0310 <- (rast2003*10)+rast2010
# writeRaster(change0310,'change0310.tif')

#################### COMPUTE OCCURENCE OF THE TRANSITION RASTER
system(sprintf("oft-stat -i %s -o %s -um %s -nostd -maxval %s" ,
               "change_0310.tif",
               "stats_change.txt",
               "change_0310.tif",
               22
))
# ?freq
# stats_change <- freq(change0310)
# write.csv(stats_change,'stats_change.csv')
#################### READ STATISTICS AND RESEPARATE EACH DATE COMPONENT
df <- read.table("stats_change.txt")[,1:2]
# df <- read.table("stats_change.csv")

names(df) <- c("chg_code","pix_count")

df$code03 <- as.numeric(substr(as.character(10000 + df$chg_code),2,3))
df$code10 <- as.numeric(substr(as.character(10000 + df$chg_code),4,5))


#################### ORGANIZE AS A TRANSITION MATRIX
tmp <- data.frame(tapply(df$pix_count*10*10/10000,df[,c("code03","code10")],sum))
names(tmp) <- c("nodata",list_class10)
tmp$code03 <- c("nodata",list_class03)
tmp[is.na(tmp)]<- 0

#################### WHEN TRANSITIONS ARE NOT OCCURRING, FILL WITH ZEROS
matrix<-matrix(0,nrow=length(list_class)+1,ncol=length(list_class)+1)

for(i in 1:length(list_class)+1){
  for(j in 1:length(list_class)+1){
    tryCatch({
      print(paste0(i,j))
      matrix[i,j] <- tmp[tmp$code03 == c("nodata",list_class10)[i] ,c("nodata",list_class10)[j]]
    }, error=function(e)cat("Not relevant\n")
    )
  }
}

matrix <- data.frame(matrix)
names(matrix)<-c("nodata",list_class)
rownames(matrix) <- c("nodata",list_class)
matrix

#################### EXPORT AS CSV FILE
write.csv(matrix,"transition_0310.csv")

matrix <- as.matrix(read.csv("transition_0310.csv")[,-1])
rownames(matrix) <- colnames(matrix)

#################### PLOT MATRIX WITH COLOR GRADIENTS
matrix <- matrix/sum(matrix)
matrix <- matrix / max(matrix)
# matrix[matrix==0] <- NA
corrplot(matrix, 
         method = "color")


