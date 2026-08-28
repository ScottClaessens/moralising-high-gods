#' Load data on moralising high gods and political complexity
#'
#' @param data_file File path to dataset
#'
#' @returns A tibble with 1127 rows and 6 columns
#'
load_data <- function(data_file) {

  readxl::read_xlsx(path = data_file) |>
    transmute(
      xd_id                = society_xd_id_from_EA_1291,
      region               = factor(region_1),
      latitude             = Latitude,
      longitude            = Longitude,
      political_complexity = ordered(EA033),
      moralising_high_gods = as.integer(MHGs)
    )

}
