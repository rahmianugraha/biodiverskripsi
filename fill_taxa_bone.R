#install.packages('tidyverse')
#install.packages('stringr')
#install.packages('openxlsx')
library(openxlsx)
library(readxl)
library(stringr)

# Import file
setwd('.')
bio_bone <- read_excel('All-Occurrences_20043_wo_sp.xlsx')

# Remove API because it's format is in JSON
bio_bone <- bio_bone[ , !(names(bio_bone) %in% c('API'))]

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
  file = "All-Occurences_20043_wo_sp_filled.csv",
  quote = FALSE,
  row.names = FALSE,
  na =
)
write.xlsx(read.csv("All-Occurences_20043_wo_sp_filled.csv"), "All-Occurences_20043_wo_sp_filled.xlsx")

