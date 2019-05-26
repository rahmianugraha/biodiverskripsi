#REMINDER
class(bio_data1)
head(bio_data1)
levels(bio_data1$stateProvince)
unique(bio_data1)
str(bio_data2)
names(bio_data2)
summary(merged_loc$stateProvince)
list(bio_data2)

#Save to xls
install.packages("writexl")
library(writexl)
write_xlsx(x = bio_data2, path = "bio_data2_clean.xlsx", col_names = TRUE)
write_xlsx(x = taksa_count, path = "taksa_count_table.xlsx", col_names = TRUE)
write_xlsx(x = state_count, path = "state_count.xlsx", col_names = TRUE)

install.packages("rio")
# Converting different file type
library(rio)
library(csvy)
library(feather)
library(fst)
library(hexView)
library(readODS)
library(rmatio)
library(xml2)
library(yaml)
library(rlist)

setwd("F:/TAMBORA MUDA/PENULISAN MANUSCRIPT/Biodivers")

#PR
#1. Hilangin NA di year
#2. Buat year yg 5 taksa

# Convert xls to csv
regex_xls = "xlsx|xls"
xls <- dir(pattern = regex_xls)
# created <- mapply(convert, xls, MoreArgs=list(gsub(regex_xls, "csv", xls), in_opts=list(which=2)))

# Branching Example
x <- 3
if (x > 0) {
  print("haha")
} else {
  print("wkwk")
}
y <- 3
if (length(y) < 50) {
  print("haha")
} else {
  print("wkwk")
}

length(z) == 1<length(z)<100
z <- c(1,2,3)
if (length(z) > 100) {
  print("haha")
}


# Merged all csv (Sheet 1)
bio_data1 = data.frame()
selected_column1 = c("eventID", "stateProvince")
for (i in 1:length(xls)){
  filename_output = paste("sheet1", gsub(regex_xls, "csv", xls[i]), sep="_")
  convert(xls[i], filename_output, in_opts=list(which=1))
  data_in_file = read.csv(
    file = filename_output,
    header = TRUE)
  bio_data1 = rbind(bio_data1, subset(data_in_file, select=selected_column1))
}


#Save a cleaned dataset as an R data file
write.table(bio_data1, file= "Sheet1_clean.csv", sep=";", row.names=FALSE)
save(bio_data1, file= "Sheet1_clean.RData")

# Merged all csv (Sheet 2)
bio_data2 = data.frame()
selected_column2 = c("eventID", "occurrenceID", "basisOfRecord", "eventDate", "kingdom", "scientificName", "taxonRank", "vernacularName", "decimalLatitude", "decimalLongitude", "geodeticDatum", "countryCode", "individualCount", "organismQuantity", "organismQuantityType", "occurrenceStatus", "remarks")
for (i in 1:length(xls)){
  filename_output = paste("sheet2", gsub(regex_xls, "csv", xls[i]), sep="_")
  convert(xls[i], filename_output, in_opts=list(which=2))
  data_in_file = read.csv(
    file = filename_output,
    header = TRUE)
  bio_data2 = rbind(bio_data2, subset(data_in_file, select=selected_column2))
}

#Save a cleaned dataset as an R data file
write.table(bio_data2, file= "Sheet2_clean.csv", sep=";", row.names=FALSE)
save(bio_data2, file= "Sheet2_clean.RData")

#print(names(subse,..;;   p t(data_in_file, select=selected_column2)))
# Same number columns
# Merged <- do.call(rbind, lapply(list.files(path = "."), read.csv))

#USU-2015DA-AH001-ST001-MA001
# TAKSA, LOKASI, TAHUN
# IN -> FN
pattern1 <- "(\\w+-\\d+\\w+-\\w+\\d+-.+-)IN(\\d+)"
temp_occ <- c()
for (i in bio_data2$occurrenceID) {
  temp_occ <- c(temp_occ, gsub(pattern1, '\\1FN\\2', i))
}
bio_data2$occurrenceID <- temp_occ
temp_occ

# AR -> TN
pattern2 <- "(\\w+-\\d+\\w+-\\w+\\d+-.+-)AR(\\d+)"
temp_occ1 <- c()
for (i in bio_data2$occurrenceID) {
  temp_occ1 <- c(temp_occ1, gsub(pattern2, '\\1TN\\2', i))
}
bio_data2$occurrenceID <- temp_occ1
temp_occ1

head(bio_data2$occurrenceID)
bio_data2$eventID
#data <- data.frame(lapply(data, function(x) { gsub("< ", "<", x) }))

install.packages("stringr")
library(stringr)
# eventID cleaning
pattern3 <- "(\\w+-2\\d{3}\\w{2}-\\w{2}\\d{3}-.+)"
for (i in bio_data2$eventID) {
  matched_pattern <- str_match(i, pattern3)
  if (is.na(matched_pattern[1])) {
    print(i)
  }
}

#Know the differences
setdiff(merged_loc$eventID, bio_data2$eventID)
eventID_clean
bio_data2$eventID

sorted_bio_data1 <- bio_data1[order(bio_data1$eventID),]
sorted_bio_data2 <- bio_data2[order(bio_data2$eventID),]
sorted_merged_loc <- merged_loc[order(merged_loc$eventID),]

head(sorted_merged_loc)
head(summary(sorted_bio_data2$eventID))
sorted_bio_data1[sorted_bio_data1$eventID == 'USU-2017RS-RS001-TR001',]

for(i in bio_data1$eventID) {
  is_matched = FALSE
  for(j in bio_data2$eventID) {
    if (i == j) {
      is_matched = TRUE
      break
    }
  }
  if (!is_matched) {
    print(i)
    print(j)
  }
}

# occurrenceID cleaning
pattern4 <- "(\\w+-2\\d{3}\\w{2}-\\w{2}\\d{3}-.+-\\w{2}\\d{3})"
for (i in bio_data1$occurrenceID) {
  matched_pattern1 <- str_match(i, pattern4)
  if (is.na(matched_pattern[1])) {
    print(i)
  }
}

#See rownumber
rowNumber <- 1
for (i in bio_data2$eventID) {
  matched_pattern <- str_match(i, pattern3)
  if (is.na(matched_pattern[1])) {
    print(i)
    print(rowNumber)
  }
  rowNumber <- rowNumber + 1
}
bio_data2[56,]

#stateProvince cleaning data
install.packages("car")
install.packages("carData")
library(car)
library(carData)
bio_data1$stateProvince <- recode(bio_data1$stateProvince, "'central kalimantan'= 'Central Kalimantan'")
bio_data1$stateProvince <- recode(bio_data1$stateProvince, "'West java'= 'West Java'")
bio_data1$stateProvince <- recode(bio_data1$stateProvince, "c('Special Region of Yogyakarta', 'Daerah Istimewa Yogyakarta')= 'D.I.Yogyakarta'")
bio_data1$stateProvince <- recode(bio_data1$stateProvince, "'Jawa Timur'= 'East Java'")
bio_data1$stateProvince <- recode(bio_data1$stateProvince, "c('Papua Barat', 'WEST PAPUA')= 'West Papua'")
bio_data1$stateProvince <- recode(bio_data1$stateProvince, "c('Middle Java', 'Cental Java')= 'Central Java'")
bio_data1$stateProvince <- recode(bio_data1$stateProvince, "'Sulawesi Selatan'= 'South Sulawesi'")
bio_data1$stateProvince <- recode(bio_data1$stateProvince, "'PAPUA'= 'Papua'")
bio_data1$stateProvince <- recode(bio_data1$stateProvince, "c('north sumatra', 'north Sumatra', 'sumatera utara', 'Sumatera Utara')= 'North Sumatra'")
bio_data1$stateProvince <- recode(bio_data1$stateProvince, "'Bogor | DKI Jakarta'= 'West Java | DKI Jakarta'")
bio_data1$stateProvince <- recode(bio_data1$stateProvince, "'Lampung| Bengkulu'= 'Lampung | Bengkulu'")
bio_data1$stateProvince <- recode(bio_data1$stateProvince, "'West Sumatera'= 'West Sumatra'")

#TAXA
library(stringr)
pattern <- "\\w+-.*-([A-Z]{2})\\d{3}"
taksa_count = c(VE=0, MA=0, EM=0, FN=0, TN=0)
taksa_list = names(taksa_count)
for (i in bio_data2$occurrenceID) {
  taksa <- str_match(i, pattern)[2]
  if (taksa %in% taksa_list) {
    taksa_count[taksa] = taksa_count[taksa] + 1
  } else {
    print(i)
  }
}

taksa_count
sum(taksa_count)
taksa_list

length(merged_loc$scientificName)

#Taksa vector to data frame
taksa_count <- matrix(taksa_count)
taksa_count <- as.data.frame(taksa_count, stringsAsFactors=FALSE)
taksa_count <- cbind(taksa_list, taksa_count)
colnames(taksa_count) <- c("taksa", "freq")

install.packages("ggplot2")
#Create	a taksa bar chart
#barplot(taksa_count, names.arg= taksa_list)
library(ggplot2)
taksa_plot <- ggplot(taksa_count, aes(x=taksa_count$taksa, y=taksa_count$freq, fill=taksa_count$taksa)) +
  geom_bar(stat = "identity") +
  xlab("Taksa") + ylab("Occurrence") + theme(legend.position="none")
taksa_plot

#Create own function
count.taksa <- function(data) {
  library(stringr)
  pattern <- "\\w+-.*-([A-Z]{2})\\d{3}"
  taksa_count = c(VE=0, MA=0, EM=0, FN=0, TN=0)
  taksa_list = names(taksa_count)
  for (i in data) {
    taksa <- str_match(i, pattern)[2]
    if (taksa %in% taksa_list) {
      taksa_count[taksa] = taksa_count[taksa] + 1
    } else {
      print(i)
    }
  }
  return(taksa_count)
}

count.taksa(bio_data2$occurrenceID)

#LOCATION
#merged_loc <- merge(bio_data1, bio_data2, by = "eventID")
merged_loc <- merge(unique(bio_data1), bio_data2, by = "eventID", incomparables = NA)
merged_loc
length(bio_data2$eventID)
length(merged_loc$eventID)
bio_data1$stateProvince
levels(bio_data1$stateProvince)
unique(bio_data1$stateProvince)
ggplot(merged_loc, aes(fill=merged_loc$stateProvince, x=merged_loc$stateProvince)) + geom_bar(stat="count") + coord_flip()


# data frame 1
df1 = data.frame(CustomerId = c(1:3), Product = c("Oven", "Television", "Kulkas"))
df1
# data frame 2
df2 = data.frame(CustomerId = c(rep(1,3), rep(2,5), rep(3,7)), State = c(rep("California", 3), rep("Texas", 5), rep("Bogor",7)))
df2
merged_df <- merge(x=df1,y=df2,by="CustomerId")
merged_df

#Location vector to data frame
loc_count <- as.data.frame(bio_data1$stateProvince, stringsAsFactors=FALSE)
loc_count


state_count = c()
for (state in merged_loc$stateProvince) {
  if (state %in% names(state_count)) {
    state_count[state] <- state_count[state] + 1
  } else if (!is.na(state)){
    state_count[state] <- 1
  }
}
state_count
state_list <- names(state_count)

state_count <- matrix(state_count)
state_count <- as.data.frame(state_count, stringsAsFactors=FALSE)
state_count <- cbind(state_list, state_count)
colnames(state_count) <- c("state", "freq")

#Create	a location bar chart
#barplot(taksa_count, names.arg= taksa_list)
library(ggplot2)
loc_plot <- ggplot(loc_count, aes(x=bio_data1$stateProvince, fill=bio_data1$stateProvince)) +
  geom_bar() + xlab("Province") + ylab("Frequency") + coord_flip() + theme(legend.position="none")
loc_plot

#YEAR
pattern <- "\\w+-(2\\d{3})\\w{2}-\\w{2}\\d{3}-.+-\\w{2}\\d{3}"
year_count = c()
for (i in bio_data2$occurrenceID) {
  year <- str_match(i, pattern)[2]
  if (year %in% names(year_count)) {
    year_count[year] <- year_count[year] + 1
  } else if (!is.na(year)){
    year_count[year] <- 1
  }
}

# per taxa
pattern <- "\\w+-(2\\d{3})\\w{2}-\\w{2}\\d{3}-.+-(\\w{2})\\d{3}"
year_count_by_taxa = list()
for (i in bio_data2$occurrenceID) {
  year <- str_match(i, pattern)[2]
  taxa <- str_match(i, pattern)[3]
  if (taxa %in% names(year_count_by_taxa) && year %in% names(year_count_by_taxa[[taxa]])) {
    year_count_by_taxa[[taxa]][[year]] <- year_count_by_taxa[[taxa]][[year]] + 1
  } else if (!is.na(year) && !is.na(taxa)){
    year_count_by_taxa[[taxa]][[year]] <- 1
  }
}

year_count

#Year vector to data frame
year_list = names(year_count)
year_count <- as.data.frame(year_count, stringsAsFactors=TRUE)
year_count <- cbind(year_list, year_count)
colnames(year_count) <- c("Year", "Frequency")
year_count

#Create	a year line chart
library(ggplot2)
year_plot <- ggplot(year_count, aes(x=year_count$Year, y=year_count$Frequency, fill=year_count$Year, group=1)) +
  geom_line(stat="identity") + xlab("Year") + ylab("Occurrence")
year_plot

#Create stacked barplot
pattern5 <- "\\w+-(2\\d{3})\\w{2}-\\w{2}\\d{3}-\\w+-(\\w{2})\\d{3}"
stacked_year_taxa = matrix(ncol=2)
for (i in bio_data2$occurrenceID) {
  matched_pattern <- str_match(i, pattern5)
  year = matched_pattern[2]
  taxa = matched_pattern[3]
  if (is.na(stacked_year_taxa[1,1])) {
    stacked_year_taxa <- c(year, taxa)
  } else {
    stacked_year_taxa <- rbind(stacked_year_taxa , c(year, taxa))
  }
}
rownames(stacked_year_taxa) <- seq(1, nrow(stacked_year_taxa))
colnames(stacked_year_taxa) <- c("year", "taxa")
stacked_year_taxa <- as.data.frame(stacked_year_taxa)
print(stacked_year_taxa)

# Stacked
ggplot(stacked_year_taxa, aes(fill=stacked_year_taxa$taxa, x=stacked_year_taxa$year)) + geom_bar(stat="count")


#Taksa= categorical
#Year= categorical
#Location= categorical