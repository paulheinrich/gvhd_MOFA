library(here)
library(stringr)

here::i_am("metadata/combine_metadata_model_patients.R")

# Load metadata

metadata_patients <- read.csv(
    file = here("metadata/patient_characteristics_cleaned.csv"),
    header = TRUE
)

metadata_model <- read.csv(
    file = here("metadata/model_metadata_cleaned.csv"),
    header = TRUE
)

colnames(metadata_patients) <- paste0("pat_", colnames(metadata_patients))

sum(!(metadata_model[["patient"]] %in% metadata_patients[["pat_Project_ID"]]))

# Combine metadata

metadata_complete <- merge(
    x = metadata_patients,
    y = metadata_model,
    by.x = "pat_Project_ID",
    by.y = "patient"
)

# Write file

write.csv(
    x = metadata_complete,
    file = here("metadata/metadata_pat_model_combined.csv"),
    quote = FALSE,
    row.names = FALSE
)