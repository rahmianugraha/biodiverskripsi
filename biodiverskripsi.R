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
  # Check whether is there any empty parentEventID 
  if ("" %in% data_in_file$parentEventID) {
    print(paste("Empty data: ", filename))
  }
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


library(tidyverse)
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


# DATA CLEANING

# SCIENTIFICNAME
##
# Abnormal data cases:

# 0. Ada 3 kata, kata ke-3 huruf kecil V > ignore | DONE
# 1. Ada tanda kurung, double space pada spesies x, dan titik pada genus x > cleanup | DONE
# 2. Ada kata setelah genus yang membuat genusnya tidak jelas > cleanup | DONE
# 3. Ada kombinasi sp., sp ., Sp., dan spp. setelah genus X > cleanup | DONE
# 4. Ada sp. setelah genus tanpa spasi > cleanup | DONE
# 5. Ada 3 kata, kata ke-3 huruf besar V > hapus author | DONE
# 6. Ada L X > hapus L nya | DONE (digabung dengan cleaning poin 5)
# 7. Ada angka X > copy ke kolom remarks, hapus angka x beserta kombinasi sp.nya | DONE
# 8. Ada jenis yang tidak teridentifikasi > ubah jadi "Plantae" | DONE
# 9. Ada tanda kurung di spesies V > ignore | DONE
# 10. Ada dash di tengah V > ignore | DONE
# 11. Ada dash di akhir V > hapus dashnya | DONE
# 12. Ada cf ditengah V > kasih titik setelah cf | DONE
# 13. Ada typos X > cek internet (Harpegnatus, Harbonatus, Calcotropis)
##

# Check for invalid rows
normal.subspecies.rows <- function(value = FALSE) {
  return(grep("^[A-Za-z]+\\s(?!cf)[A-Za-z]+\\s[a-z]+$", merged_data$scientificName, perl=TRUE, value=value))
}
normal.species.rows <- function(value = FALSE) {
  return(grep("^[A-Za-z]+\\s[A-Za-z]+(?:\\-[a-z]+)?$", merged_data$scientificName, perl=TRUE, value=value))
}
normal.genus.rows <- function(value = FALSE) {
  return(grep("\\b(?!Plantae)^[A-Za-z]+$", merged_data$scientificName, perl=TRUE, value=value))
}
normal.kingdom.rows <- function(value = FALSE) {
  return(grep("Plantae", merged_data$scientificName, perl = TRUE, value = value))
}
species.rows.with.brackets <- function(value = FALSE) {
  return(grep("^[A-Za-z]+\\s\\([A-Za-z]+\\)\\s[A-Za-z]+$", merged_data$scientificName, perl=TRUE, value=value))
}
species.rows.with.cfs <- function(value = FALSE) {
  return(grep("^[A-Za-z]+\\scf\\.\\s[a-z]+$", merged_data$scientificName, perl=TRUE, value=value))
}
check.invalid.scientific.names <- function() {
  # V and "ignore" abnormal cases will be placed here
  na_rows <- which(is.na(merged_data$scientificName))
  print(paste('NA:', length(na_rows)))
  print(paste('Subspecies:', length(normal.subspecies.rows())))
  print(paste('Species:', length(normal.species.rows()) + length(species.rows.with.brackets()) + length(species.rows.with.cfs())))
  print(paste('Genus:', length(normal.genus.rows())))
  print(paste('Kingdom:', length(normal.kingdom.rows())))
  print('INVALID DATA:')
  merged_data$scientificName[-c(
    na_rows,
    normal.subspecies.rows(),
    normal.species.rows(),
    normal.genus.rows(),
    normal.kingdom.rows(),
    species.rows.with.brackets(),
    species.rows.with.cfs()
  )]
}
check.invalid.scientific.names() # we know that 2939 scientific names are still invalid
which(merged_data$scientificName == "-")

# Cleaning 1
# Recode words that have brackets, double space on species x, and dot (.) on genus x
merged_data$scientificName <- car::recode(merged_data$scientificName, "'Balanus sp. (Nauplius)'= 'Balanus'")
merged_data$scientificName <- car::recode(merged_data$scientificName, "'Palaquium  burckii'= 'Palaquium burckii'")
merged_data$scientificName <- car::recode(merged_data$scientificName, "'Hylarana  chalconota'= 'Hylarana chalconota'")
merged_data$scientificName <- car::recode(merged_data$scientificName, "'Didymoplexis  pallens'= 'Didymoplexis pallens'")
merged_data$scientificName <- car::recode(merged_data$scientificName, "c('Diadema  Savignyi', 'Diadema  savignyi')= 'Diadema savignyi'")
merged_data$scientificName <- car::recode(merged_data$scientificName, "'Chaetodon  triangulum'= 'Chaetodon triangulum'")
merged_data$scientificName <- car::recode(merged_data$scientificName, "'C.cyperoides'= 'Cyperus cyperoides'")
merged_data$scientificName <- car::recode(merged_data$scientificName, "'E.crusgalli'= 'Echinochloa crusgalli'")

# Cleaning 2
# Recode uncorrect genus
merged_data$scientificName <- car::recode(merged_data$scientificName, "'Steatoda Sp.male'= 'Steatoda Sp.'")
merged_data$scientificName <- car::recode(merged_data$scientificName, "'Pardosa Sp.el'= 'Pardosa Sp.'")
merged_data$scientificName <- car::recode(merged_data$scientificName, "c('Pardosael', 'Pardosae')= 'Pardosa'")

# Cleaning 3
# Check for anything ended with sp., sp ., Sp., and spp.
grep("^[A-Za-z]+\\s{1,2}[Ss]?p{1,2}\\s?\\.$", merged_data$scientificName, perl=TRUE, value=TRUE)
# Remove sp., sp ., Sp., and spp.
merged_data$scientificName <- trimws(gsub("^([A-Za-z]+)\\s{1,2}[Ss]?p{1,2}\\s?\\.$", '\\1', merged_data$scientificName))

# Cleaning 4
# Check for genus and sp. without space
grep("^[A-Za-z]+sp\\.$", merged_data$scientificName, perl=TRUE, value=TRUE)
# Remove sp.
merged_data$scientificName <- trimws(gsub("^([A-Za-z]+)sp\\.$", '\\1', merged_data$scientificName))

# Check for anything ended with p. and . (dot)
grep("^[A-Za-z ]+p\\.$", merged_data$scientificName, perl=TRUE, value=TRUE)
grep("^[A-Za-z ]+\\.$", merged_data$scientificName, perl=TRUE, value=TRUE)

# Cleaning 5 and 6
# Check "Ada 3 kata, kata ke-3 huruf besar" on scientificName field
grep("^[A-Za-z]+\\s[a-z]+\\s[A-Z](?:[a-z]+)?$", merged_data$scientificName, perl=TRUE, value=TRUE)
grep("^[A-Za-z]+\\s[a-z]+\\s[A-Z]\\.[A-Z]?(?:.[A-Z][a-z])?(?:[a-z])?$", merged_data$scientificName, perl=TRUE, value=TRUE)
# Remove all with capital letter on the third word
merged_data$scientificName <- trimws(gsub("^([A-Za-z]+\\s[a-z]+)\\s[A-Z](?:[a-z]+)?$", '\\1', merged_data$scientificName))
merged_data$scientificName <- trimws(gsub("^([A-Za-z]+\\s[a-z]+)\\s[A-Z]\\.[A-Z]?(?:.[A-Z][a-z])?(?:[a-z])?$", '\\1', merged_data$scientificName))

# Cleaning 7
# Check anything with number on scientificName field > make a variable
sp_number <- grep("^[A-Za-z]+\\s?[Ss]?p?\\.?\\s?\\.?[A-Za-z]?\\d\\.?$", merged_data$scientificName, perl=TRUE)
# Copy anything with number on scientificName field to remarks field
merged_data$remarks[sp_number] <- merged_data$scientificName[sp_number]
# Check unidentified species
grep("^[A-Za-z]+\\s\\d$", merged_data$scientificName, perl=TRUE, value = TRUE)
# Check anything with number on scientificName field
grep("^[A-Za-z]+\\s?[Ss]?p?\\.?\\s?\\.?[A-Za-z]?\\d\\.?$", merged_data$scientificName, perl=TRUE, value = TRUE)
# Remove number and words with number on scientificName field
merged_data$scientificName <- trimws(gsub("^([A-Za-z]+)\\s?[Ss]?p?\\.?\\s?\\.?[A-Za-z]?\\d\\.?$", '\\1', merged_data$scientificName))

# Cleaning 8
# Recode unidentified species to "Plantae"
merged_data$scientificName <- car::recode(merged_data$scientificName, "c('Morfospesies', 'Rumput', 'Paku', '-')= 'Plantae'")

# Cleaning 11
# Remove -- in the end
merged_data$scientificName <- trimws(gsub("^([A-Za-z ]+)--$", '\\1', merged_data$scientificName))

# Cleaning 12
firstup <- function(x) {
  substr(x, 1, 1) <- toupper(substr(x, 1, 1))
  return(x)
}
merged_data$scientificName <- trimws(gsub("^([A-Za-z]+\\s)cf(\\s[A-Za-z]+)$", '\\1cf.\\2', merged_data$scientificName))
cf.with.uppercase.species <- function(value = FALSE) {
  return(grep("^[A-Za-z]+\\scf\\.?\\s[A-Z][a-z]+$", merged_data$scientificName, perl=TRUE, value=value))
}
merged_data$scientificName[cf.with.uppercase.species()] <- firstup(tolower((cf.with.uppercase.species(TRUE))))

# Cleaning 13
# Recode typos
convert("typo_lookup.xlsx", "typo_lookup.csv")
typo_lookup <- read.csv(
  file = "typo_lookup.csv",
  header = TRUE)
unlink("typo_lookup.csv")
typos <- merged_data$scientificName %in% typo_lookup$typo
merged_data$scientificName[which(typos)]
typo_lookup_str <- setNames(as.character(typo_lookup$correction), typo_lookup$typo)
merged_data$scientificName <- dplyr::recode(merged_data$scientificName, !!!typo_lookup_str)
merged_data$scientificName[which(typos)]

library(writexl)
write_xlsx(x = merged_data, path = "All Occurrences_20043_scientificName clean.xlsx", col_names = TRUE)


# VISUALIZATION
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