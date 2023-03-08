library(here)
library(readxl)
library(stringr)

here::i_am("metadata/clean_metadata_patients.R")

metadata <- as.data.frame(
    read_excel(
        path = here("metadata/Patient Characteristics.xlsx"),
        sheet = 1,
        na = c("N/A", "missing", "?")
    )
)

metadata[["Patient_Age"]] <- as.numeric(
    str_replace(metadata[["Patient_Age"]], ",", ".")
)

relapse_days_approx <- str_detect(metadata[["Relapse_days"]], "~")
relapse_days_approx[is.na(relapse_days_approx)] <- FALSE

metadata[["Relapse_days_only_approx"]] <- as.numeric(relapse_days_approx)

metadata[["Relapse_days"]] <- as.numeric(
    str_replace(metadata[["Relapse_days"]], "~", "")
)

columns_to_rename <- c(
    "1yr_survival_days",
    "1yr_OverallSurvival",
    "2nd AlloTx",
    "1yr_TRM"
)

columns_new_names <- c(
    "survival_1yr_days",
    "survival_1yr_overall",
    "AlloTx_2nd",
    "TRM_1yr"
)

names(columns_new_names) <- columns_to_rename

for (col in names(columns_new_names)) {
    colnames(metadata)[colnames(metadata) == col] <- columns_new_names[col]
}

write.csv(
    x = metadata,
    file = here("metadata/patient_characteristics_cleaned.csv"),
    quote = FALSE,
    row.names = FALSE
)