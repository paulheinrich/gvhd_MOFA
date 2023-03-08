library("here")
library("stringr")
library("dplyr")
library("readxl")

here::i_am("metadata/taxonomic_classification/extract_taxonomic_mapping.R")

feature_tables <- list()

feature_tables[["16S"]] <- as.data.frame(read_excel(
    here("metadata/taxonomic_classification/ASV-Table_V1V3.xlsx")
))

feature_tables[["ITS"]] <- as.data.frame(read_excel(
    here("metadata/taxonomic_classification/ASV-Table_ITS.xlsx")
))

taxonomic_mapping <- list()

for (view in names(feature_tables)) {
    taxonomic_mapping[[view]] <- data.frame(
        feature_tables[[view]][[1]],
        "Genus" = feature_tables[[view]][["Genus"]],
        row.names = 1
    )
}

for (view in names(feature_tables)) {
    filename <- paste0("taxonomic_mapping_", view, ".csv")
    write.csv(
        taxonomic_mapping[[view]],
        file = here("metadata/taxonomic_classification", filename),
        row.names = TRUE,
        col.names = TRUE,
        quote = FALSE
    )
}