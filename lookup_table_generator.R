# # Lookup Table Generator
# This code compares the original data with the data
# given by kak Didit after she pulled and merged it with GBIF database
# Original: All Occurrences_20043_scientificName clean.xlsx
# Merged: All-Occurrences_20043_23-Juli_merge.csv


library(rio)
convert("All Occurrences_20043_scientificName clean.xlsx", "All Occurrences_20043_scientificName clean.csv")
original_data <- read.csv(
  file = "All Occurrences_20043_scientificName clean.csv",
  header = TRUE)
merged_data <- read.csv(
  file = "All-Occurrences_20043_23-Juli_merge.csv",
  header = TRUE)
head(original_data$scientificName)
head(merged_data$scientificName)

typo <- setdiff(original_data$scientificName, merged_data$scientificName)
correction <- setdiff(merged_data$scientificName, original_data$scientificName)

# lookup_table <- data.frame("typo"=typo, "correction"=correction)

library(writexl)
write_xlsx(x = data.frame("typo"=typo), path = "typos.xlsx", col_names = TRUE)
write_xlsx(x = data.frame("correction"=correction), path = "correction.xlsx", col_names = TRUE)
