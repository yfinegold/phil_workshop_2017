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
# workshop_folder <- "C:/Users/finegold/Desktop" 
# if(!file.exists(file.path(workshop_folder,"workshop_PHL_2017.zip"))){
#   download.file("https://www.dropbox.com/sh/kvambfjgcil2f79/AACDW66-t97Vf7f_pO4fiUKQa?dl=1",
#                 file.path(workshop_folder,"workshop_PHL_2017.zip"),"auto",mode="wb")
#   unzip(file.path(workshop_folder,"workshop_PHL_2017.zip"),exdir=file.path(workshop_folder,"workshop_PHL_2017"))
#   unzip(file.path(paste0(workshop_folder,"workshop_PHL_2017/data/"),'landcover_2003_2010_IPCC.zip'),exdir=file.path(paste0(workshop_folder,"workshop_PHL_2017/data"),'landcover_2003_2010_IPCC.zip'))
#   
# }

## Loading the input data for analysis ####
## Linux version

list <- list.files("~/workshop_PHL_2017/data")
is.na(list)
if(length(list)==0){
  setwd('~/workshop_PHL_2017/data')
  system("wget https://www.dropbox.com/s/v9f11umprbxpr9c/landcover_2003_2010_IPCC.zip?dl=0")
  system('mv landcover_2003_2010_IPCC.zip?dl=0 landcover_2003_2010_IPCC.zip')
  system('unzip landcover_2003_2010_IPCC.zip')
}



############### SET WORKING ENVIRONMENT
rootdir <- paste0('~/workshop_PHL_2017/data')


setwd(rootdir)
