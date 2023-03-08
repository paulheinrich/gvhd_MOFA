library(here)
library(stringr)
library("MOFA2")

here::i_am("metadata/clean_metadata_model.R")

# Load model

path_existing_models <- here("existing_mofa_models")
path_model <- here(
    path_existing_models,
    "MOFA_model_group-no_nfactors-10_nfactors-10.hdf5"
)

model <- load_model(
    file = path_model
)

metadata <- samples_metadata(model)

# Modify metadata

metadata[["amp_Timepoint"]][metadata[["amp_Timepoint"]] == "Post"] <- "POST"

timepoints <- list()

timepoints[["pre"]] <- c("COND")
timepoints[["allo"]] <- c("0")
timepoints[["post"]] <- c("7", "14", "21", "28", "POST")
timepoints[["idx"]] <- c("IDX")

metadata[["pre_post_allo_SCT"]] <- rep("IDX", nrow(metadata))

for (timepoint in names(timepoints)) {
    metadata[["pre_post_allo_SCT"]][
        metadata[["amp_Timepoint"]] %in% timepoints[[timepoint]]
    ] <- timepoint
}

metadata[["patient"]] <- str_extract(metadata[["sample"]], "[RM]-[A-Z]{2}")
patients_gvhd <- unique(
    metadata[["patient"]][as.numeric(metadata[["GvHD"]]) > 0]
)
metadata[["GvHD_patient"]] <- rep(0, nrow(metadata))
metadata[["GvHD_patient"]][metadata[["patient"]] %in% patients_gvhd] <- 1
colnames(metadata)[colnames(metadata) == "GvHD"] <- "GvHD_sample"

metabolite_col_indices <- c(1:11, 13:17, 19:29, 44)
metabolite_cols <- colnames(metadata)[metabolite_col_indices]
metabolite_cols_new <- tolower(str_replace_all(metabolite_cols, "\\.", "_"))
metabolite_cols_new <- str_replace_all(metabolite_cols_new, "^x", "")
metabolite_cols_new <- paste0("metab_", metabolite_cols_new)

rownames(metadata) <- metadata[["sample"]]

metadata_no_metabolites <- metadata[
    , !(colnames(metadata) %in% metabolite_cols)
]
metadata_metabolites <- metadata[
    , colnames(metadata) %in% metabolite_cols
]
colnames(metadata_metabolites) <- metabolite_cols_new

metadata_cleaned <- merge(
    metadata_no_metabolites,
    metadata_metabolites,
    by.x = "row.names", by.y = "row.names"
)
rownames(metadata_cleaned) <- metadata_cleaned[["Row.names"]]
metadata_cleaned <- metadata_cleaned[
    , !(colnames(metadata_cleaned) %in% "Row.names")
]

all.equal(
    metadata_cleaned[, metabolite_cols_new],
    metadata[, metabolite_cols],
    check.names = FALSE
)

# Write file

write.csv(
    x = metadata_cleaned,
    file = here("metadata/model_metadata_cleaned.csv"),
    quote = FALSE,
    row.names = FALSE
)