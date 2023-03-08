library(here)
library(stringr)
library("MOFA2")

here::i_am("data/extract_model_input.R")

# Load model

path_existing_models <- here("existing_mofa_models")
path_model <- here(
    path_existing_models,
    "MOFA_model_group-no_nfactors-10_nfactors-10.hdf5"
)

model <- load_model(
    file = path_model
)

views <- views_names(model)
input_data <- list()

for (view in views) {
    input_data[[view]] <- get_data(
        model,
        views = view
    )[[view]][["group1"]]
}

# Load model metadata with metabolite data

metadata <- read.csv(
    file = here("metadata/metadata_pat_model_combined.csv"),
    header = TRUE,
    row.names = "sample"
)

# Get metabolite data

metabolite_data <- t(as.matrix(
    metadata[, grepl("^metab_", colnames(metadata))]
))

metabolite_data <- metabolite_data[, colnames(input_data[[views[1]]])]
input_data[["metabolites"]] <- metabolite_data

# Sanity check

for (view in names(input_data)) {
    print(all.equal(
        colnames(input_data[[views[1]]]), colnames(input_data[[view]])
    ))
}

# Save to csv

for (view in names(input_data)) {
    filename <- paste0("mofa_input_", view, ".csv")

    write.csv(
        x = input_data[[view]],
        file = here("data", filename),
        quote = FALSE,
        row.names = TRUE
    )
}
