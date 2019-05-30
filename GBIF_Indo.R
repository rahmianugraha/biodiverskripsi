#BIODIVERSKRIPSI TAXONOMY BACKBONE



# HELPER FUNCTIONS
firstup <- function(x) {
  substr(x, 1, 1) <- toupper(substr(x, 1, 1))
  return(x)
}



# IMPORT DATA
library(readxl)
bio_bone <- read_excel('All-Occurrences_20043_wo_sp.xlsx')
#convert("All-Occurrences_20043_wo_sp.xlsx", "All-Occurrences_20043_wo_sp.csv")
#bio_bone <- read.csv(
#file = "All-Occurrences_20043_wo_sp.csv",
#header = TRUE)

# Remove API because it's format is in JSON
bio_bone <- bio_bone[, !(names(bio_bone) %in% c('API'))]

# Check Data
nrow(bio_bone)
sum(is.na(bio_bone_new$GBIF_genus))



# DATA CLEANING

# SCIENTIFICNAME
##
# Abnormal data cases:
# 0. Ada p. and . (dot) di akhir X > cleanup | DONE
# 1. Ada 3 kata, kata ke-3 huruf kecil V > ignore | DONE
# 2. Ada 3 kata, kata ke-3 huruf besar V > hapus author
# 3. Ada angka X > hapus angka, cek taxonnya di skripsi
# 4. Ada tanda kurung di spesies V > ignore | DONE
# 5. Ada tanda kurung di genus X  > fix taxonRank
# 6. Ada titik di tengah X > cek skripsi
# 7. Ada dash di tengah V > ignore | DONE
# 8. Ada dash di akhir V > hapus dashnya | DONE
# 9. Ada L X > hapus L nya
# 10. Ada cf ditengah V > kasih titik setelah cf | DONE
# 11. Ada typos X > cek internet (Harpegnatus, Harbonatus, Calcotropis)
##

# Check for invalid rows
normal.subspecies.rows <- function(value = FALSE) {
  return(grep("^[A-Za-z]+\\s(?!cf)[A-Za-z]+\\s[a-z]+$", bio_bone$scientificName, perl=TRUE, value=value))
}
normal.species.rows <- function(value = FALSE) {
  return(grep("^[A-Za-z]+\\s[A-Za-z]+(?:\\-[a-z]+)?$", bio_bone$scientificName, perl=TRUE, value=value))
}
normal.genus.rows <- function(value = FALSE) {
  return(grep("^[A-Za-z]+$", bio_bone$scientificName, perl=TRUE, value=value))
}
species.rows.with.brackets <- function(value = FALSE) {
  return(grep("^[A-Za-z]+\\s\\([A-Za-z]+\\)\\s[A-Za-z]+$", bio_bone$scientificName, perl=TRUE, value=value))
}
species.rows.with.cfs <- function(value = FALSE) {
  return(grep("^[A-Za-z]+\\scf\\.\\s[a-z]+$", bio_bone$scientificName, perl=TRUE, value=value))
}
check.invalid.scientific.names <- function() {
  # V and "ignore" abnormal cases will be placed here
  na_rows <- which(is.na(bio_bone$scientificName))
  print(paste('NA:', length(na_rows)))
  print(paste('Subspecies:', length(normal.subspecies.rows())))
  print(paste('Species:', length(normal.species.rows()) + length(species.rows.with.brackets()) + length(species.rows.with.cfs())))
  print(paste('Genus:', length(normal.genus.rows())))
  print('INVALID DATA:')
  bio_bone$scientificName[-c(
    na_rows,
    normal.subspecies.rows(),
    normal.species.rows(),
    normal.genus.rows(),
    species.rows.with.brackets(),
    species.rows.with.cfs()
  )]
}
check.invalid.scientific.names() # we know that 113 scientific names are still invalid

# Cleaning 1
# Check for anything ended with p. and . (dot) on scientificName field
grep("^[A-Za-z ]+p\\.$", bio_bone$scientificName, perl=TRUE, value=TRUE)
grep("^[A-Za-z ]+\\.$", bio_bone$scientificName, perl=TRUE, value=TRUE)
# Remove p. and . (dot)
bio_bone$scientificName <- trimws(gsub("^([A-Za-z ]+)p\\.$", '\\1', bio_bone$scientificName))
bio_bone$scientificName <- trimws(gsub("^([A-Za-z ]+)\\.$", '\\1', bio_bone$scientificName))
# Cleaning 2
# TODO: here
# Cleaning 3
# TODO: here
# Cleaning 5
# TODO: here
# Cleaning 6
# TODO: here
# Cleaning 8
bio_bone$scientificName <- trimws(gsub("^([A-Za-z ]+)--$", '\\1', bio_bone$scientificName))
# Cleaning 9
# TODO: here
# Cleaning 10
bio_bone$scientificName <- trimws(gsub("^([A-Za-z]+\\s)cf(\\s[A-Za-z]+)$", '\\1cf.\\2', bio_bone$scientificName))
cf.with.uppercase.species <- function(value = FALSE) {
  return(grep("^[A-Za-z]+\\scf\\.?\\s[A-Z][a-z]+$", bio_bone$scientificName, perl=TRUE, value=value))
}
bio_bone$scientificName[cf.with.uppercase.species()] <- firstup(tolower((cf.with.uppercase.species(TRUE))))
# Cleaning 11
# TODO: here

# TAXONRANK
bio_bone$taxonRank[normal.subspecies.rows()]
bio_bone$taxonRank[normal.subspecies.rows()] <- rep('Subspecies', length(bio_bone$taxonRank[normal.subspecies.rows()]))
bio_bone$taxonRank[normal.species.rows()]
bio_bone$taxonRank[normal.species.rows()] <- rep('Species', length(bio_bone$taxonRank[normal.species.rows()]))
species.rows.with.cfs(TRUE)
bio_bone$taxonRank[species.rows.with.cfs()]
# TODO: FIX CF TAXONRANK

check.invalid.scientific.names() # all scientific names must be cleaned up



# DATA PROCESSING
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
