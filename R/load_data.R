#' Load data on moralising high gods and political complexity
#'
#' @param ea_data_file File path to Ethnographic Atlas dataset
#' @param abrahamization_data_file File path to Abrahamization dataset
#'
#' @returns A tibble with 1127 rows and 7 columns
#'
load_data <- function(ea_data_file, abrahamization_data_file) {

  # load ethnographic atlas data
  ea_data <-
    readxl::read_xlsx(path = ea_data_file) |>
      transmute(
        xd_id                = society_xd_id_from_EA_1291,
        region               = factor(region_1),
        latitude             = Latitude,
        longitude            = Longitude,
        political_complexity = ordered(EA033),
        moralising_high_gods = as.integer(MHGs)
      )

  # load Abrahamization data
  abrahamization_data <-
    readxl::read_xlsx(path = abrahamization_data_file) |>
    transmute(
      xd_id          = society_xd_id,
      abrahamization = ordered(Abrahamization)
    )

  # return linked dataset
  left_join(ea_data, abrahamization_data, by = "xd_id")

}
