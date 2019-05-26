#BIODIVERSKRIPSI TAXONOMY BACKBONE
library(readxl)
bio_bone <- read_excel('All-Occurrences_20043_wo_sp.xlsx')
#convert("All-Occurrences_20043_wo_sp.xlsx", "All-Occurrences_20043_wo_sp.csv")
#bio_bone <- read.csv(
#file = "All-Occurrences_20043_wo_sp.csv",
#header = TRUE)

nrow(bio_bone)
sum(is.na(bio_bone_new$GBIF_genus))

# Remove API because it's format is in JSON
bio_bone <- bio_bone[, !(names(bio_bone) %in% c('API'))]

start_time <- Sys.time()

# Duplicate the data.frame
bio_bone_new <- bio_bone
# Create vectors for conditional checks inside the loop for performance optimization
is_empty_scientific_name <- bio_bone$scientificName == "" | is.na(bio_bone$scientificName)
is_empty_gbif_genus <- bio_bone$GBIF_genus == "" | is.na(bio_bone$GBIF_genus)
word_scientific_name <- trimws(word(bio_bone$scientificName))
word_gbif_genus <- trimws(word(bio_bone$GBIF_genus))

# Search and fill the corresponding values
## Loop each rows: For each row in bio_bone
for (i in 1:nrow(bio_bone)) {
  ## If current scientificName and GBIF_genus is empty
  if (!is_empty_scientific_name[i] && is_empty_gbif_genus[i]) {
    ## Search for other rows: For each row in bio_bone
    for (j in 1:nrow(bio_bone)) {
      ## If searched GBIF_genus is not empty
      ## AND current scientificName is similar with searched GBIF_genus
      if (!is_empty_gbif_genus[j] && word_scientific_name[i] == word_gbif_genus[j]) {
        ## Fill current empty values with the searched data
        bio_bone_new$GBIF_status[i] = bio_bone$GBIF_status[j]
        bio_bone_new$GBIF_matchType[i] = bio_bone$GBIF_matchType[j]
        bio_bone_new$GBIF_taxonRank[i] = bio_bone$GBIF_taxonRank[j]
        bio_bone_new$GBIF_kingdom[i] = bio_bone$GBIF_kingdom[j]
        bio_bone_new$GBIF_phylum[i] = bio_bone$GBIF_phylum[j]
        bio_bone_new$GBIF_class[i] = bio_bone$GBIF_class[j]
        bio_bone_new$GBIF_order[i] = bio_bone$GBIF_order[j]
        bio_bone_new$GBIF_family[i] = bio_bone$GBIF_family[j]
        bio_bone_new$GBIF_genus[i] = bio_bone$GBIF_genus[j]
        ## Stop searching and continue to next loop row
        break
      }
    }
  }
  print(i)
}

finish_time <- Sys.time()

# Processing summary
changed_rows <- sum(is.na(bio_bone$GBIF_genus)) - sum(is.na(bio_bone_new$GBIF_genus))
print(finish_time - start_time)
print(paste('Changed rows:', changed_rows))

# Export file
write.csv(
  bio_bone_new,
  file = "All-Occurrences_20043_wo_sp_filled.csv",
  quote = FALSE,
  row.names = FALSE,
  na =
)
library(writexl)
write_xlsx(read.csv("All-Occurrences_20043_wo_sp_filled.csv"), "All-Occurences_20043_wo_sp_filled.xlsx")
sum(!is.na(bio_bone_new$GBIF_genus))

sum(!is.na(bio_bone$eventID))



#GBIF
gbif_indo <- read.csv(
  file = "Dataset GBIF 2000 - 2017.csv",
  header = TRUE)

#GBIF_Taxa (Kingdom)
bio_bone$kingdom <- car::recode(bio_bone$kingdom, "c('Vertebrate', 'animalia', 'Animal')= 'Animalia'")
bio_bone$kingdom <- car::recode(bio_bone$kingdom, "'Embryophyta' = 'Plantae'")

bio_bone$kingdom <- trimws(bio_bone$kingdom)
gbif_indo$kingdom <- trimws(gbif_indo$kingdom)

bio_bone_count <- na.omit(plyr::count(bio_bone, 'kingdom'))
bio_bone_count <- cbind(data.frame(from=rep('Biodiverskripsi', nrow(bio_bone_count))), bio_bone_count)
names(bio_bone_count) <- c('from', 'Kingdom', 'Occurrence')

gbif_indo_count <- na.omit(plyr::count(gbif_indo, 'kingdom'))
gbif_indo_count <- cbind(data.frame(from=rep('GBIF', nrow(gbif_indo_count))), gbif_indo_count)
names(gbif_indo_count) <- c('from', 'Kingdom', 'Occurrence')

merged_kingdom <- rbind(bio_bone_count, gbif_indo_count)
print(merged_kingdom)

png("./output_figure/2a Taxa (Kingdom)_20 May.png", width = 5500, height = 2500, units = 'px', res = 430)
ggplot(merged_kingdom, aes(fill=from, x=Kingdom, y=Occurrence)) +
  geom_bar(position="dodge", stat="identity")
#geom_text(aes(label=Occurrence), position=position_dodge(width=0.9), vjust=-0.25)
dev.off()


#GBIF_Year
# Grouped barplot
bio_year <- merged_data[,c('eventID', 'publicationYear')]
gbif_year <- gbif_indo[,c('eventID', 'year')]

# remove 2018
bio_year <- bio_year[bio_year$publicationYear!='2018',]
gbif_year <- gbif_year[gbif_year$year!='2018',]

bio_year_count <- na.omit(plyr::count(bio_year, 'publicationYear'))
bio_year_count <- cbind(data.frame(from=rep('Biodiverskripsi', nrow(bio_year_count))), bio_year_count)
names(bio_year_count) <- c('from', 'year', 'freq')
gbif_year_count <- na.omit(plyr::count(gbif_year, 'year'))
gbif_year_count <- cbind(data.frame(from=rep('GBIF', nrow(gbif_year_count))), gbif_year_count)
names(gbif_year_count) <- c('from', 'year', 'freq')
merged_year <- rbind(bio_year_count, gbif_year_count)
print(merged_year)

png("./output_figure/2b Year_20 May.png", width = 3000, height = 1500, units = 'px', res = 300)
ggplot(merged_year, aes(fill=from, x=year, y=freq)) +
  geom_bar(position="dodge", stat="identity") +
  xlab('Year') + ylab('Occurrence') +
  theme(axis.text.x = element_text(angle = 45, hjust = 1, vjust = 0.5))
#geom_text(aes(label=freq), position=position_dodge(width=0.9), vjust=-0.25)
dev.off()

#GBIF_Location
library(car)
library(carData)
unique(gbif_indo$stateProvince)
gbif_indo$stateProvince <- car::recode(gbif_indo$stateProvince, "'Jawa Barat'= 'West Java'")
gbif_indo$stateProvince <- car::recode(gbif_indo$stateProvince, "'Sulawesi Selatan'= 'South Sulawesi'")
gbif_indo$stateProvince <- car::recode(gbif_indo$stateProvince, "'Sulawesi Tenggara'= 'Southeast Sulawesi'")
gbif_indo$stateProvince <- car::recode(gbif_indo$stateProvince, "'Maluku Islands'= 'Maluku'")
gbif_indo$stateProvince <- car::recode(gbif_indo$stateProvince, "'Nusa Tenggara Barat'= 'West Nusa Tenggara'")
gbif_indo$stateProvince <- car::recode(gbif_indo$stateProvince, "'Nusa Tenggara Barat'= 'East Nusa Tenggara'")
gbif_indo$stateProvince <- car::recode(gbif_indo$stateProvince, "'Sulawesi Utara'= 'North Sulawesi'")
gbif_indo$stateProvince <- car::recode(gbif_indo$stateProvince, "'Lampung, Sumatra'= 'Lampung'")
gbif_indo$stateProvince <- car::recode(gbif_indo$stateProvince, "'Jakarta Province'= 'DKI Jakarta'")
gbif_indo$stateProvince <- car::recode(gbif_indo$stateProvince, "'Central Sulawesi [Sulawesi Tengah'= 'Central Sulawesi'")
gbif_indo$stateProvince <- car::recode(gbif_indo$stateProvince, "'Sumatera Selatan Province'= 'South Sumatera'")
gbif_indo$stateProvince <- car::recode(gbif_indo$stateProvince, "'Kalimantan Barat Province'= 'West Kalimantan Barat'")
gbif_indo$stateProvince <- car::recode(gbif_indo$stateProvince, "c('Raja Ampat', 'Papua Barat')= 'West Papua'")
gbif_indo$stateProvince <- car::recode(gbif_indo$stateProvince, "c('East Kalimantan Province', 'Kalimantan Timur')= 'East Kalimantan'")
gbif_indo$stateProvince <- car::recode(gbif_indo$stateProvince, "c('Maluku Islands', 'maluku')= 'Maluku'")
gbif_indo$stateProvince <- car::recode(gbif_indo$stateProvince, "c('Raja Ampat', 'Papua Barat')= 'West Papua'")


#NEW TAXONOMY BACKBONE
taxa_bone <- read.csv(
  file = "taxa_bone.csv",
  header = TRUE)
