## download the data
### click on SOURCE




####################################################################################
#######    object: SETUP YOUR LOCAL PARAMETERS                  ####################
#######    Update : 2017/05/23                                  ####################
#######    contact: yelena.finegold@fao.org                      ####################
####################################################################################

####################################################################################
# FAO declines all responsibility for errors or deficiencies in the database or 
# software or in the documentation accompanying it, for program maintenance and 
# upgrading as well as for any # damage that may arise from them. FAO also declines 
# any responsibility for updating the data and assumes no responsibility for errors 
# and omissions in the data provided. Users are, however, kindly asked to report any 
# errors or deficiencies in this product to FAO.
####################################################################################

#################### SET OPTIONS AND NECESSARY PACKAGES
options(stringsAsFactors = FALSE)

library(raster)
library(rgdal)
library(rgeos)
library(ggplot2)
library(foreign)
library(dplyr)

############### DOWNLOAD WORKSHOP DATA
## change this to your username
workshop_folder <- "C:/Users/finegold/Desktop/" 
if(!file.exists(file.path(workshop_folder,"phil_workshop_2017.zip"))){
  download.file("https://www.dropbox.com/sh/kvambfjgcil2f79/AACDW66-t97Vf7f_pO4fiUKQa?dl=1",
                file.path(workshop_folder,"phil_workshop_2017.zip"),"auto",mode="wb")
  unzip(file.path(workshop_folder,"phil_workshop_2017.zip"),exdir=file.path(workshop_folder,"phil_workshop_2017"))
}

# Loading the input data for analysis ####
## Linux version
# list <- list.files("~/workshop_PHL_2017/data")
# is.na(list)
# if(length(list)==0){
#   system("wget https://www.dropbox.com/sh/kvambfjgcil2f79/AACDW66-t97Vf7f_pO4fiUKQa?dl=1")
#   system('mv AACDW66-t97Vf7f_pO4fiUKQa?dl=1 workshop_PHL_2017.zip')
#   system('unzip workshop_PHL_2017.zip -d workshop_PHL_2017')
#   system('unzip data/landcover_2003_2010_IPCC_wgs84.zip -d data')
# }



############### SET WORKING ENVIRONMENT
rootdir <- paste0(workshop_folder,"phil_workshop_2017/data")


setwd(rootdir)
