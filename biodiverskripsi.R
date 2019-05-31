#install.packages("rio")
#install.packages("tidyverse")
#install.packages("car")
#install.packages("writexl")

#install.packages('stringr')
#install.packages('openxlsx')

setwd(".")
#Convert xls & xlsx to csv
library(rio)
regex_xls = "xlsx|xls"
xls <- dir(path = "./input_xlsx", pattern = regex_xls, full.names = TRUE)

# Merged all csv (Sheet 1)
bio_data1 = data.frame()
selected_column1 = c('parentEventID', "eventID", "stateProvince")
for (i in 1:length(xls)){
  filename = gsub('./input_xlsx/', '', xls[i]) # remove dir
  filename = gsub(regex_xls, "csv", filename) # rename xlsx/xls to csv
  filename_output = paste("./output_csv/sheet1", filename, sep="_")
  convert(xls[i], filename_output, in_opts=list(which=1))
  data_in_file = read.csv(
    file = filename_output,
    header = TRUE)
  bio_data1 = rbind(bio_data1, subset(data_in_file, select=selected_column1))
}

# Merged all csv (Sheet 2)
bio_data2 = data.frame()
selected_column2 = c("eventID", "occurrenceID", "basisOfRecord", "eventDate", "kingdom", "scientificName", "taxonRank", "vernacularName", "decimalLatitude", "decimalLongitude", "geodeticDatum", "countryCode", "individualCount", "organismQuantity", "organismQuantityType", "occurrenceStatus", "remarks")
for (i in 1:length(xls)){
  filename = gsub('./input_xlsx/', '', xls[i]) # remove dir
  filename = gsub(regex_xls, "csv", filename) # rename xlsx/xls to csv
  filename_output = paste("./output_csv/sheet2", filename, sep="_")
  convert(xls[i], filename_output, in_opts=list(which=2))
  data_in_file = read.csv(
    file = filename_output,
    header = TRUE)
  bio_data2 = rbind(bio_data2, subset(data_in_file, select=selected_column2))
}


# TAKSA CLEANING
# IN -> FN
pattern_INFN <- "(\\w+-\\d+\\w+-\\w+\\d+-.+-)IN(\\d+)"
temp_occ <- c()
for (i in bio_data2$occurrenceID) {
  temp_occ <- c(temp_occ, gsub(pattern_INFN, '\\1FN\\2', i))
}
bio_data2$occurrenceID <- temp_occ

# AR -> TN
pattern_ARTN <- "(\\w+-\\d+\\w+-\\w+\\d+-.+-)AR(\\d+)"
temp_occ1 <- c()
for (i in bio_data2$occurrenceID) {
  temp_occ1 <- c(temp_occ1, gsub(pattern_ARTN, '\\1TN\\2', i))
}
bio_data2$occurrenceID <- temp_occ1


library("tidyverse")
# PARENTEVENTID CLEANING
pattern_parentEventID <- "(\\w+-2\\d{3}\\w{2}-\\w{2}\\d{3})"
for (i in bio_data1$parentEventID) {
  matched_pattern <- str_match(i, pattern_parentEventID)
  if (is.na(matched_pattern[1])) {
    print(i)
  }
}

# EVENTID CLEANING
pattern_eventID <- "(\\w+-2\\d{3}\\w{2}-\\w{2}\\d{3}-.+)"
for (i in bio_data2$eventID) {
  matched_pattern <- str_match(i, pattern_eventID)
  if (is.na(matched_pattern[1])) {
    print(i)
  }
}

#Know the differences
setdiff(bio_data1$eventID, bio_data2$eventID)
setdiff(bio_data2$eventID, bio_data1$eventID)

#cek eventID bio_data1 = eventID bio_data2
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


# OCCURRENCEID CLEANING
pattern_occurrenceID <- "(\\w+-2\\d{3}\\w{2}-\\w{2}\\d{3}-.+-\\w{2}\\d{3})"
for (i in bio_data1$occurrenceID) {
  matched_pattern1 <- str_match(i, pattern_occurrenceID)
  if (is.na(matched_pattern[1])) {
    print(i)
  }
}


# STATEPROVINCE CLEANING
library(car)
bio_data1$stateProvince <- car::recode(bio_data1$stateProvince, "c('central kalimantan', 'Kalimantan Tengah', 'Central Borneo')= 'Central Kalimantan'")
bio_data1$stateProvince <- car::recode(bio_data1$stateProvince, "'West java'= 'West Java'")
bio_data1$stateProvince <- car::recode(bio_data1$stateProvince, "c('Special Region of Yogyakarta', 'Daerah Istimewa Yogyakarta')= 'D.I.Yogyakarta'")
bio_data1$stateProvince <- car::recode(bio_data1$stateProvince, "'Jawa Timur'= 'East Java'")
bio_data1$stateProvince <- car::recode(bio_data1$stateProvince, "c('Papua Barat', 'WEST PAPUA')= 'West Papua'")
bio_data1$stateProvince <- car::recode(bio_data1$stateProvince, "c('Middle Java', 'Cental Java')= 'Central Java'")
bio_data1$stateProvince <- car::recode(bio_data1$stateProvince, "'Sulawesi Selatan'= 'South Sulawesi'")
bio_data1$stateProvince <- car::recode(bio_data1$stateProvince, "'PAPUA'= 'Papua'")
bio_data1$stateProvince <- car::recode(bio_data1$stateProvince, "'BALI'= 'Bali'")
bio_data1$stateProvince <- car::recode(bio_data1$stateProvince, "c('north sumatra', 'north Sumatra', 'sumatera utara', 'Sumatera Utara')= 'North Sumatra'")
bio_data1$stateProvince <- car::recode(bio_data1$stateProvince, "'Bogor | DKI Jakarta'= 'West Java | DKI Jakarta'")
bio_data1$stateProvince <- car::recode(bio_data1$stateProvince, "'Lampung| Bengkulu'= 'Lampung | Bengkulu'")
bio_data1$stateProvince <- car::recode(bio_data1$stateProvince, "'West Sumatera'= 'West Sumatra'")
bio_data1$stateProvince <- car::recode(bio_data1$stateProvince, "'Minahasa'= 'North Sulawesi'")
bio_data1$stateProvince <- car::recode(bio_data1$stateProvince, "'D.I.Y Yogyakarta'= 'D.I.Yogyakarta'")
bio_data1$stateProvince <- car::recode(bio_data1$stateProvince, "'Sulawesi Tenggara'= 'Southeast Sulawesi'")
bio_data1$stateProvince <- car::recode(bio_data1$stateProvince, "'CENTRAL JAVA'= 'Central Java'")
bio_data1$stateProvince <- car::recode(bio_data1$stateProvince, "'East Borneo'= 'East Kalimantan'")
bio_data1$stateProvince <- car::recode(bio_data1$stateProvince, "'West Borneo'= 'West Kalimantan'")
levels(bio_data1$stateProvince)
summary(bio_data1$stateProvince)


#Merged Sheet 1 & Sheet 2
merged_data <- merge(unique(bio_data1), bio_data2, by = "eventID", incomparables = NA)

# CHECK DUPLICATE
merged_data <- merged_data %>% distinct()


#Bikin kolom baru kode taksa ke merged_data
pattern_taksa <- "\\w+-.*-([A-Z]{2})\\d{3}"
taksa<-c()
for (i in merged_data$occurrenceID) {
  taksa <- c(taksa,str_match(i, pattern_taksa)[2])
}
merged_data$taxaCode <- taksa
#Cek
#merged_data %>% select(occurrenceID,taxaCode)


#Bikin kolom baru tahun publikasi ke merged_data
pattern_year <- "\\w+-(2\\d{3})\\w{2}-\\w{2}\\d{3}-.+-\\w{2}\\d{3}"
year<-c()
for (i in merged_data$occurrenceID) {
  year <- c(year,str_match(i, pattern_year)[2])
}
merged_data$publicationYear <- year
#cek
#merged_data %>% select(occurrenceID,publicationYear)


#Bikin kolom baru kode univ ke merged_data
pattern_univ <- "(\\w+)-.*-[A-Z]{2}\\d{3}"
univ<-c()
for (i in merged_data$occurrenceID) {
  univ <- c(univ,str_match(i, pattern_univ)[2])
}
merged_data$univCode <- univ
#Cek
#merged_data %>% select(occurrenceID,univCode)


#Delete all 2018 data
merged_data <- merged_data %>% filter(publicationYear != "2018")


# COUNT TAKSA
taksa_count <- plyr::count(merged_data, "taxaCode")
taksa_count <- taksa_count %>% filter(!is.na(taxaCode))
taksa_count
sum(taksa_count$freq)

# COUNT YEAR
year_count <- plyr::count(merged_data, "publicationYear")
year_count
sum(year_count$freq)

# COUNT UNIV
univ_count <- plyr::count(merged_data, "univCode")
univ_count <- univ_count %>% filter(!is.na(univCode))
univ_count
sum(univ_count$freq)


#library(writexl)
#write_xlsx(x = merged_data, path = "All Occurrences_20043_17 May.xlsx", col_names = TRUE)


# Create + export barchart (TAXA)
png("./output_figure/1a Taxa.png", width = 3000, height = 1500, units = 'px', res = 300)
ggplot(taksa_count, aes(x=taksa_count$taxaCode, y=taksa_count$freq, fill=taksa_count$taxaCode)) +
  geom_bar(stat = "identity") +
  xlab("Taxa") + ylab("Occurrence") + theme(legend.position="right") +
  scale_fill_discrete(name = "Taxa", labels = c("Embriophyta", "Freshwater Invertebrate", "Marine Biota", "Terrestrial Invertebrate", "Vertebrate"))
  #geom_text(aes(label=freq), position=position_dodge(width=0.9), vjust=-0.25)
dev.off()

# Create + export barchart (TAXA WITH YEAR)
merged_data_taxayear <- merged_data[,c('taxaCode','publicationYear')]
merged_data_taxayear <- merged_data_taxayear[complete.cases(merged_data_taxayear),]

png("./output_figure/1b TaxaYear.png", width = 2000, height = 2000, units = 'px', res = 300)
ggplot(subset(merged_data_taxayear, !is.na(merged_data_taxayear$taxaCode) || !is.na(merged_data_taxayear$publicationYear)), aes(publicationYear)) +
  geom_bar() + 
  facet_wrap( ~ taxaCode, ncol= 1) +
  theme(axis.text.x = element_text(angle = 45, hjust = 1, vjust = 0.5)) +
  xlab('Year') + ylab('Occurrence')
dev.off()

# Create + export barchart (TAXA WITH LOCATION)
merged_data$stateProvince <- as.character(merged_data$stateProvince)
merged_data_taxaloc <- merged_data[FALSE,]
for (i in 1:nrow(merged_data)) {
  row <- merged_data[i,]
  if (grepl('\\|', row$stateProvince)) {
    splitted <- strsplit(row$stateProvince, " | ", fixed=TRUE)[[1]]
    row_a <- row
    row_a$stateProvince <- splitted[1] 
    row_b <- row
    row_b$stateProvince <- splitted[2]
    merged_data_taxaloc <- rbind(merged_data_taxaloc, row_a)
    merged_data_taxaloc <- rbind(merged_data_taxaloc, row_b)
  } else {
    merged_data_taxaloc <- rbind(merged_data_taxaloc, row)
  } 
}
merged_data_taxaloc1 <- merged_data_taxaloc[,c('taxaCode','stateProvince')]
merged_data_taxaloc1 <- merged_data_taxaloc1[complete.cases(merged_data_taxaloc1),]

png("./output_figure/1c TaxaLocation.png", width = 2500, height = 2000, units = 'px', res = 300)
ggplot(subset(merged_data_taxaloc1, !is.na(merged_data_taxaloc1$taxaCode) || !is.na(merged_data_taxaloc1$stateProvince)), aes(stateProvince)) +
  geom_bar() + 
  facet_wrap( ~ taxaCode, ncol= 1) +
  theme(axis.text.x = element_text(angle = 45, hjust = 1, vjust = 0.5)) +
  xlab('Province') + ylab('Occurrence')
dev.off()

# Create + export barchart (TAXA WITH UNIV)
merged_data_taxauniv <- merged_data[,c('taxaCode','univCode')]
merged_data_taxauniv <- merged_data_taxauniv[complete.cases(merged_data_taxauniv),]

png("./output_figure/1d TaxaUniv.png", width = 2000, height = 2000, units = 'px', res = 300)
ggplot(subset(merged_data_taxauniv, !is.na(merged_data_taxauniv$taxaCode) || !is.na(merged_data_taxauniv$univCode)), aes(univCode)) +
  geom_bar() + 
  facet_wrap( ~ taxaCode, ncol= 1) +
  theme(axis.text.x = element_text(angle = 45, hjust = 1, vjust = 0.5)) +
  xlab('University') + ylab('Occurrence')
dev.off()


# Create + export barchart (UNIV WITH TAXA)
merged_data_univtaxa <- merged_data[,c('taxaCode','univCode')]
merged_data_univtaxa <- merged_data_univtaxa[complete.cases(merged_data_univtaxa),]

png("./output_figure/1d UnivTaxa.png", width = 2000, height = 2000, units = 'px', res = 300)
ggplot(subset(merged_data_univtaxa, !is.na(merged_data_univtaxa$univCode) || !is.na(merged_data_univtaxa$taxaCode)), aes(taxaCode)) +
  geom_bar() + 
  facet_wrap( ~ univCode, ncol= 1) +
  theme(axis.text.x = element_text(angle = 45, hjust = 1, vjust = 0.5)) +
  xlab('Taxa') + ylab('Occurrence')
dev.off()

# Create + export barchart (UNIV WITH YEAR)
merged_data_univyear <- merged_data[,c('univCode','publicationYear')]
merged_data_univyear <- merged_data_univyear[complete.cases(merged_data_univyear),]

png("./output_figure/1e UnivYear.png", width = 2000, height = 2000, units = 'px', res = 300)
ggplot(subset(merged_data_univyear, !is.na(merged_data_univyear$univCode) || !is.na(merged_data_univyear$publicationYear)), aes(publicationYear)) +
  geom_bar() + 
  facet_wrap( ~ univCode, ncol= 1) +
  theme(axis.text.x = element_text(angle = 45, hjust = 1, vjust = 0.5)) +
  xlab('Year') + ylab('Occurrence')
dev.off()

#Create + export barchart (UNIV WITH LOCATION)
merged_data$stateProvince <- as.character(merged_data$stateProvince)
merged_data_univloc <- merged_data[FALSE,]
for (i in 1:nrow(merged_data)) {
  row <- merged_data[i,]
  if (grepl('\\|', row$stateProvince)) {
    splitted <- strsplit(row$stateProvince, " | ", fixed=TRUE)[[1]]
    row_a <- row
    row_a$stateProvince <- splitted[1] 
    row_b <- row
    row_b$stateProvince <- splitted[2]
    merged_data_univloc <- rbind(merged_data_univloc, row_a)
    merged_data_univloc <- rbind(merged_data_univloc, row_b)
  } else {
    merged_data_univloc <- rbind(merged_data_univloc, row)
  } 
}
merged_data_univloc1 <- merged_data_univloc[,c('univCode','stateProvince')]
merged_data_univloc1 <- merged_data_univloc1[complete.cases(merged_data_univloc1),]

png("./output_figure/1f UnivLocation.png", width = 2000, height = 2000, units = 'px', res = 300)
ggplot(subset(merged_data_univloc1, !is.na(merged_data_univloc1$univCode) || !is.na(merged_data_univloc1$stateProvince)), aes(stateProvince)) +
  geom_bar() + 
  facet_wrap( ~ univCode, ncol= 1) +
  theme(axis.text.x = element_text(angle = 45, hjust = 1, vjust = 0.5)) +
  xlab('Province') + ylab('Occurrence')
dev.off()