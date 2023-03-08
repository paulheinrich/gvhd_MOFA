library("MOFA2")

load_mofa_tmp_copy <- function(
    file_directory = NA,
    file_name = NA,
    name_tmp_folder = NA
) {
    file_path_source <- file.path(file_directory, file_name)

    if (is.na(name_tmp_folder)) {
        stop("Name for temporary folder not provided")
    }

    tmp_directory <- file.path("/tmp", name_tmp_folder)

    if (!dir.exists(tmp_directory)) {
        dir.create(tmp_directory)
    } else {
        stop("Temporary directory already exists")
    }

    file_path_target <- file.path(tmp_directory, file_name)

    if (file.exists(file_path_source)) {
        file.copy(
            from = file_path_source,
            to = file_path_target
        )
    } else {
        unlink(tmp_directory, recursive = TRUE)
        stop("Source file does not exist")
    }

    mofa_model <- MOFA2::load_model(
        file = file_path_target
    )

    unlink(tmp_directory, recursive = TRUE)

    return(mofa_model)
}