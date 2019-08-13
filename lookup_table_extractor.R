# # Lookup Table Extractor
# This code compares the biodiverskripsi data with the data
# given by kak Didit after she pulled and merged it with GBIF database
# Biodiverskripsi: All Occurrences_19173_4 August.xlsx
# Biodiverskripsi + GBIF: All-Occurrences_20043_23-Juli_merge.csv


library(rio)
original_data <- merged_data
# convert("All Occurrences_19681_6 August.xlsx", "All Occurrences_19681_6 August.csv")
# original_data <- read.csv(
#   file = "All Occurrences_19681_6 August.csv",
#   header = TRUE)
bio_gbif_data <- read.csv(
  file = "All-Occurrences_20043_23-Juli_merge.csv",
  header = TRUE)
head(original_data$scientificName)
head(bio_gbif_data$scientificName)

sn_biodivers <- setdiff(original_data$scientificName, bio_gbif_data$scientificName)
sn_biodivers_gbif <- setdiff(bio_gbif_data$scientificName, original_data$scientificName)
if (length(sn_biodivers_gbif)-length(sn_biodivers) > 0) {
  sn_biodivers <- c(sn_biodivers, rep("", length(sn_biodivers_gbif)-length(sn_biodivers)))
} else {
  sn_biodivers_gbif <- c(sn_biodivers_gbif, rep("", length(sn_biodivers)-length(sn_biodivers_gbif)))
}
diff_table <- data.frame("biodivers"=sn_biodivers, "biodivers+gbif"=sn_biodivers_gbif)

library(writexl)
write_xlsx(x = diff_table, path = "diff_table.xlsx", col_names = TRUE)
