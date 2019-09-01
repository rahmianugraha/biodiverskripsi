### Coordinate cleaning script
### Author: Sabhrina Gita Aninta
### Start Date: 09/08/2019

source("01_datecleaning.R") # clean the dates
str(sE.df)

### Cleaning coordinates -------------------------------------------------------------------------------
# creating a trial data set
sE.df.2 <- sE.df %>% mutate(decimalLatitude=as.factor(decimalLatitude),
                            decimalLongitude=as.factor(decimalLongitude))
levels(sE.df.2$decimalLatitude) # apparently not all coordinates are written as decimals
levels(sE.df.2$decimalLongitude)
length(levels(sE.df.2$decimalLatitude)) # it will takes time to fix one by one

# First, checking all entries that are not decimal numbers
lat_nn<-which(is.na(as.numeric(as.character(sE.df.2$decimalLatitude))))
long_nn<-which(is.na(as.numeric(as.character(sE.df.2$decimalLongitude))))
length(lat_nn)==length(long_nn)
lat_nn[long_nn %in% lat_nn==F]
long_nn[long_nn %in% lat_nn==F]

sE.df[313,"decimalLatitude"]
sE.df[313,"decimalLatitude"]<-"-7.9070484"
sE.df[314,"decimalLongitude"]
sE.df[314,"decimalLongitude"]<-"110.422149"

# re-ran the entry-checking code
sE.df.2 <- sE.df %>% mutate(decimalLatitude=as.factor(decimalLatitude),
                            decimalLongitude=as.factor(decimalLongitude))
lat_nn<-which(is.na(as.numeric(as.character(sE.df.2$decimalLatitude))))
long_nn<-which(is.na(as.numeric(as.character(sE.df.2$decimalLongitude))))
length(lat_nn)==length(long_nn)
lat_nn[long_nn %in% lat_nn==F]

# Second, view all these non-decimals
sE.df[lat_nn,"decimalLatitude"] 
sE.df[long_nn,"decimalLatitude"]
# some entries are simply NAs
# assign the row number with NAs
lat_NA<-sE.df.2[,"decimalLatitude"] %>% is.na() %>% which()
long_NA<-sE.df.2[,"decimalLongitude"] %>% is.na() %>% which()

# refferring the ones that are not NA
which(lat_nn %in% lat_NA==F)
# is it the same with longitude?
which(lat_nn %in% lat_NA==F) == which(long_nn %in% long_NA==F) # YES
# then we can refer to the row of interest from only either decimalLatitude or decimalLongitude
sE.df[lat_nn[which(lat_nn %in% lat_NA==F)],c("decimalLatitude","decimalLongitude")] %>% head()
sE.df[lat_nn[which(lat_nn %in% lat_NA==F)],]

# we saw that some coordinates consistently have special characters at the end, we want to trim that
sE.df[,"decimalLatitude"]<-gsub("[^\x20-\x7E]","",sE.df[,"decimalLatitude"])
sE.df[,"decimalLongitude"]<-gsub("[^\x20-\x7E]","",sE.df[,"decimalLongitude"])
sE.df[lat_nn[50:55],] # okay it is working

# re-ran the entry-checking code
sE.df.2 <- sE.df %>% mutate(decimalLatitude=as.factor(decimalLatitude),
                            decimalLongitude=as.factor(decimalLongitude))
lat_nn<-which(is.na(as.numeric(as.character(sE.df.2$decimalLatitude))))
long_nn<-which(is.na(as.numeric(as.character(sE.df.2$decimalLongitude))))
sE.df.2[lat_nn[50:55],]
length(lat_nn)==length(long_nn)
which(long_nn %in% lat_nn==F)
sE.df.2[long_nn[463],]

sE.df[long_nn[463],"decimalLongitude"]<-"106.59694444"

sE.df.2 <- sE.df %>% mutate(decimalLatitude=as.factor(decimalLatitude),
                            decimalLongitude=as.factor(decimalLongitude))
lat_nn<-which(is.na(as.numeric(as.character(sE.df.2$decimalLatitude))))
long_nn<-which(is.na(as.numeric(as.character(sE.df.2$decimalLongitude))))
length(lat_nn)==length(long_nn)
which(lat_nn %in% lat_NA==F) # all invalid entries that are not NA
sE.df[lat_nn[53:55],]

# Updating the number of latitude that needs to be corrected
lat_nn_2<-lat_nn[which(lat_nn %in% lat_NA==F)]
long_nn_2<-long_nn[which(long_nn %in% long_NA==F)]
lat_nn_2 == long_nn_2

sE.df[lat_nn_2,"decimalLatitude"] # getting all invalid coordinate entries that are bounding box

### Correcting coordinates based on eventID and localities------------------------------------------------
## Extracting the IDs of problematic theses
sE.df[lat_nn_2,] %>% group_by(parentEventID) %>%  summarise(n=n()) # there were 34 theses, each having more than one eventID
sE.df[lat_nn_2,] %>% group_by(parentEventID) %>%  count(eventID)
prob.theses<-sE.df[lat_nn_2,] %>% group_by(parentEventID) %>% dplyr::summarise(n=n())
prob.theses<-as.vector(prob.theses$parentEventID)

prob.lit<-lit.df[lit.df$parentEventID %in% prob.theses == T,]
prob.lit
nrow(prob.lit) # 29 problematic theses

## Checking localities within problematic theses----------------------------------------------------------
# correcting implicit NAs
sE.df.2<-sE.df.2 %>% mutate(locality = fct_explicit_na(locality, na_level="NA"))
lat_nn<-which(is.na(as.numeric(as.character(sE.df.2$decimalLatitude))))
long_nn<-which(is.na(as.numeric(as.character(sE.df.2$decimalLongitude))))
length(lat_nn)==length(long_nn)
which(lat_nn %in% lat_NA==F)

sE.df<-sE.df %>% mutate(locality = as.factor(locality))
sE.df<-sE.df %>% mutate(locality = fct_explicit_na(locality, na_level="NA"))

# Filling possible localities
sE.df %>% group_by(locality) %>% dplyr::summarise(n=n())
levels(sE.df$locality)

sE.df %>% filter(locality=="-")
lit.df %>% filter(parentEventID=="IPB-2004DR-RN016")
occ.df %>% filter(eventID=="IPB-2011HJ-MF005-CM003")

## Locate the centroid by calculating median
# Easiest to do per volunteer
prob.theses.ID<-which(sE.df$parentEventID %in% prob.theses == T)
prob.theses

# Start from the least ones -------------------------------------------------------------------
sE.df %>% filter(parentEventID=="USU-2017RS-RS001")
lit.df %>% filter(parentEventID=="UGM-2015AS-AN015")

panggilSkripsi<-function(id,jenisID,dataset){
  dataset[jenisID==id,]
}
panggilSkripsi("IPB-2013SW-MF006",sE.df$parentEventID,sE.df)

# Imam's prob.theses ----------------------------------------------------------------------------------------
sE.df %>% filter(parentEventID=="IPB-2013SW-MF006")
sE.df %>% filter(parentEventID=="IPB-2016PG-MF001")
lit.df %>% filter(parentEventID=="IPB-2013SW-MF006")
occ.df %>% filter(parentEventID=="IPB-2004DR-RN016")

# Triana's prob.theses --------------------------------------------------------------------------------------
sE.df %>% filter(parentEventID=="UI-2006WP-TL005")
occ.df %>% filter(eventID=="UI-2006WP-TL005-BS01")
lit.df %>% filter(parentEventID=="UI-2006WP-TL005")

sE.df %>% filter(parentEventID=="UI-2007DP-TL006")
occ.df %>% filter(eventID=="UI-2007DP-TL006-SH06")
lit.df %>% filter(parentEventID=="UI-2007DP-TL006")

sE.df %>% filter(parentEventID=="UI-2009YF-TL024")
occ.df %>% filter(eventID=="UI-2009YF-TL024-ST02")
lit.df %>% filter(parentEventID=="UI-2014MS-TL043")

sE.df %>% filter(parentEventID=="IUI-2007DP-TL006")

# Basith --------------------------------------------------------------------------------------------
sE.df %>% filter(parentEventID=="UGM-2017DN-BA001") # locality beda2 tapi koordinat sama semua
sE.df %>% filter(parentEventID=="UGM-2017RF-BA003") 
sE.df %>% filter(parentEventID=="UGM-2017DA-BA018")
sE.df %>% filter(parentEventID=="UGM-2017EN-BA012")

occ.df %>% filter(eventID=="UGM-2017DN-BA001-SHK04")
lit.df %>% filter(parentEventID=="UGM-2017DN-BA001")

# Misc efforts -------------------------------------------------------------------------------------
prob.theses.ID
lat.test<-sE.df$decimalLatitude[lat_nn_2]
lat.test
lat.test<-gsub("/",",",lat.test[lat_nn_2])
lat.vec<-sapply(lat.test, as.vector)
names(lat.vec[100])
lat.mean<-sapply(lat.vec, mean)
lat.mean
# Using as.numeric, we apply brute force to discard everything that is not validly written
sE.df.3 <- sE.df %>% mutate(decimalLatitude=as.numeric(decimalLatitude),
                          decimalLongitude=as.numeric(decimalLongitude))

# checking entries
sE.df %>% filter(decimalLatitude=="601350,77 - -06.2412111 ")


numextract <- function(string){ 
  str_extract(string, "\\-*\\d+\\.*\\d*")
} 

numextract(as.character(sE.df$decimalLatitude))

sE.df %>% filter(decimalLatitude=="-0.406761|0.406594444")

sum(is.na(str_extract(" | ", as.character(sE.df$decimalLatitude))))
sum(is.na(str_extract(" | ", as.character(sE.df$decimalLongitude))))
