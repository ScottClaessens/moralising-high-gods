#' Load data on moralising high gods and political complexity
#'
#' @param data_file File path to dataset
#'
#' @returns A tibble with 1127 rows and 4 columns
#'
load_data <- function(data_file) {

  readxl::read_xlsx(path = data_file) |>
    transmute(
      xd_id                = society_xd_id,
      political_complexity = ordered(EA033),
      moralising_high_gods = as.integer(MHGs)
    )

}
