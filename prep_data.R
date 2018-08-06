## Install and attach packages
library(readr)
library(leaflet)
library(rgdal)
library(crosstalk)
library(DT)
library(data.table)
library(stringr)
library(dplyr)
library(summarywidget)
library(reshape2)
library(d3scatter)
library(ICPIutilities)

## This app is meant to help us understand how clusters of sites perform as a group.
# 

# Load geospatial data-----
# for South Africa.  You need other shape files for other countries.
## You can skip to the next section if you have the .rdata file and don't need to update sites

sa <- sf::st_read(dsn="South_Africa_Facilities.shp", quiet = FALSE)  %>%
   mutate(lat=y, lon=x, FacilityUID=id) %>%
   select(-x, -y, -id)

psnu <- sf::st_read(dsn="South_Africa_PSNU.shp", quiet = FALSE)

# this one for site aggregator 
 PSNU <- readOGR("South_Africa_PSNU.shp",
                 layer = "South_Africa_PSNU", GDAL1_integer64_policy = TRUE)
# 
# You need a dataframe containing the coordinates of the PSNU centroids so leaflet can
# pan to the correct location on the map
centroid_data <- read.csv("~/ICPI/Innovation/Shiny site aggregator/centroid_data.csv")
#----- 


#Load MER data and process the dataset-----

sitexIM <- ICPIutilities::read_msd("C:/Users/wvp3/Desktop/Large data files/MER_Structured_Dataset_Site_IM_FY17-18_SouthAfrica_20180622_v2_1.txt",to_lower=FALSE)

# select total numerator for linkage-related indicators
site_tots <- sitexIM %>%
  filter(indicator %in% c("TX_CURR","TX_NEW","HTS_TST","HTS_TST_POS","TX_RET") & 
           (PSNU!="_Military South Africa") &
           (standardizedDisaggregate=="Total Numerator" | standardizedDisaggregate=="Total Denominator") ) %>%
  
  # dplyr::select minimum set - aggregates DSD+TA; Num & Den are implied from disaggregation
  select(PSNU, PSNUuid, Community, CommunityUID, Facility, FacilityUID, 
         indicator, standardizedDisaggregate, matches) %>%
  
  # for this visual, we will keep numerator and denominator separate (because TX_RET is in here)
  mutate(numeratorDenominator = ifelse(grepl("Numerator",standardizedDisaggregate), "N", 
                                       ifelse(grepl("Denominator",standardizedDisaggregate), "D", ""))) %>%
  select(-standardizedDisaggregate) %>%
  
  group_by(PSNU, PSNUuid, Community, CommunityUID, Facility, FacilityUID, 
           indicator, numeratorDenominator) %>%
  
  # Roll up everything else
  summarise_all(funs(sum), na.rm=TRUE) %>%
  ungroup() 
#-----

#Calculate proxy linkage-----
#This section could be replaced by other types of
## calculations, for example, percent achievement of targets

site_wide <- site_tots %>%
  reshape2::melt() %>%
  reshape2::dcast(... ~ indicator + numeratorDenominator) %>%
  mutate(linkage = TX_NEW_N / HTS_TST_POS_N) %>%
  
  # create a "capped" linkage at 300%
  mutate(linkcap = ifelse((linkage>3 & HTS_TST_POS_N!=0),3,linkage))
#-----

# merge wide MER dataset together with the site coordinate data

sitedata <- left_join(site_wide,sa,by="FacilityUID")

# parse DATIM site names (text) to try to assign site type for visualizations
sitedata <- sitedata %>%
  mutate(sitetype = case_when(grepl("Clinic",Facility,ignore.case=TRUE) ~ "Clinic",
                              grepl("Hospital",Facility,ignore.case=TRUE) ~ "Hospital",
                              grepl("CHC",Facility,ignore.case=TRUE) ~ "Health Centre",
                              grepl("CDC",Facility,ignore.case=TRUE) ~ "Health Centre",
                              grepl("dispensary",Facility,ignore.case=TRUE) ~ "Dispensary/pharmacy",
                              grepl("pharmacy",Facility,ignore.case=TRUE) ~ "Dispensary/pharmacy",
                              grepl("Maternity",Facility,ignore.case=TRUE) ~ "Maternity clinic/hospital",
                              grepl("Mobile",Facility,ignore.case=TRUE) ~ "Mobile" )
  ) %>%
  mutate(sitetype=ifelse(is.na(sitetype),"Other",sitetype))

# for the app, further streamline .rdata file by removing unnecessary / unused columns and dfs

# remove facility UID only for the aggregator tool NOT for the radius tool
sitedata <- sitedata %>% select(-PSNUuid,-CommunityUID,-FacilityUID,-name, -geometry, -level)


# infinite values can cause problems with DT::data.table - replace with NA
sitedata$linkage[is.infinite(sitedata$linkage)] <- NA
sitedata$linkage[is.nan(sitedata$linkage)] <- NA

# cleanup environment
remove(site_tots)
remove(sitexIM)
remove(site_wide)
remove(temp)
save.image()

## For the 10/10 initiative - specific to South Africa

library(readxl)
tenten <- read_excel("~/ICPI/Innovation/Shiny site aggregator/CDC_10-10_Facility_List_namesonly_06.04.2018.xlsx")
tenten$ten <- "yes"

sitedata <- left_join(sitedata,tenten,by="Facility")

#check merge
unique(testsitedata$Facility[testsitedata$ten=="yes"])
