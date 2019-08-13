### Coordinate cleaning script
### Author: Sabhrina Gita Aninta
### Start Date: 09/08/2019

source("00_fileReading.R") # reading files from input_xlsx
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
lat_nn_2<-which(is.na(as.numeric(as.character(sE.df.2$decimalLatitude))))
long_nn_2<-which(is.na(as.numeric(as.character(sE.df.2$decimalLongitude))))
sE.df.2[lat_nn_2[50:55],]
length(lat_nn_2)==length(long_nn_2)
which(long_nn_2 %in% lat_nn_2==F)
sE.df.2[long_nn_2[463],]

sE.df[long_nn_2[463],"decimalLongitude"]<-"106.59694444"

sE.df.2 <- sE.df %>% mutate(decimalLatitude=as.factor(decimalLatitude),
                            decimalLongitude=as.factor(decimalLongitude))
lat_nn_2<-which(is.na(as.numeric(as.character(sE.df.2$decimalLatitude))))
long_nn_2<-which(is.na(as.numeric(as.character(sE.df.2$decimalLongitude))))
length(lat_nn_2)==length(long_nn_2)
which(lat_nn_2 %in% lat_NA==F) # all invalid entries that are not NA
sE.df[lat_nn_2[53:89],]
lat_nn_2[lat_nn_3]
# Updating the number of latitude that needs to be corrected
lat_nn_3<-lat_nn_2[which(lat_nn_2 %in% lat_NA==F)]
long_nn_3<-long_nn_2[which(long_nn_2 %in% long_NA==F)]
lat_nn_3 == long_nn_3

sE.df[lat_nn_3,"decimalLatitude"] # getting all invalid coordinate entries that are bounding box

### Checking the localities
sE.df[lat_nn_3,] %>% group_by(parentEventID) %>% select(parentEventID,eventID,locationID,decimalLatitude,decimalLongitude,locality,countryCode,islandGroup,stateProvince,county,municipality,remarks) %>% summarise(n=n())
## it was coming from 34 theses, we could investigate the coordinate by the theses

## We will locate the centroid of the poligon to standardize

lat_nn_2
# Checking the locality of weird coordinates
sE.df %>% filter(decimalLongitude=="98º31'37,2\" - 98º39'38,0\"")
sE.df %>% filter(decimalLatitude=="-0.406761|0.406594444")

# Using as.numeric, we apply brute force to discard everything that is not validly written
sE.df <- sE.df %>% mutate(decimalLatitude=as.numeric(decimalLatitude),
                          decimalLongitude=as.numeric(decimalLongitude))

class(sE.df$decimalLatitude)




numextract <- function(string){ 
  str_extract(string, "\\-*\\d+\\.*\\d*")
} 

numextract(as.character(sE.df$decimalLatitude))

sE.df %>% filter(decimalLatitude=="-0.406761|0.406594444")

sum(is.na(str_extract(" | ", as.character(sE.df$decimalLatitude))))
sum(is.na(str_extract(" | ", as.character(sE.df$decimalLongitude))))
