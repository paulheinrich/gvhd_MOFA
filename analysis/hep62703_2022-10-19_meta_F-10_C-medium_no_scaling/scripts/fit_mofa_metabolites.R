library(here)
library(stringr)
library(reticulate)
library("MOFA2")

here::i_am("analysis/hep62703_2022-10-19_meta_F-10_C-medium_no_scaling/scripts/fit_mofa_metabolites.R")

# Path to python binary with mofapy2 dependency
# This is an absolute path and system dependent!

path_mofapy2_python <- "/home/hep62703/.conda/envs/p107_hp_mofa_mofapy2/bin/python"

# Load input data

views <- c("16S", "ITS", "virome", "metabolites")
input_data <- list()

for (view in views) {
    filename <- paste0("mofa_input_", view, ".csv")
    input_data[[view]] <- as.matrix(read.csv(
        here("data", filename),
        header = TRUE,
        row.names = 1,
        check.names = FALSE
    ))
}

# Load metadata

metadata <- read.csv(
    file = here("metadata/metadata_pat_model_combined.csv"),
    header = TRUE
)

# Create MOFA object with metadata

model <- create_mofa(input_data)
samples_metadata(model) <- metadata

# Modify options

model_opts <- get_default_model_options(model)
model_opts$num_factors <- 10

data_opts <- get_default_data_options(model)

train_opts <- get_default_training_options(model)
train_opts$convergence_mode <- "medium"

# Prepare model

model <- prepare_mofa(
    object = model,
    model_options = model_opts,
    data_options = data_opts,
    training_options = train_opts
)

# Train model

reticulate::use_python(path_mofapy2_python)

model_path <- here(
    "analysis/hep62703_2022-10-19_meta_F-10_C-medium_no_scaling/data/models",
    "model_metabolites_medium_F10.hdf5"
)

model_trained <- run_mofa(
    object = model,
    outfile = NULL,
    use_basilisk = FALSE
)