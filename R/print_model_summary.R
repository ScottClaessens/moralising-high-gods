#' Print summary of fitted model
#'
#' Print summary of fitted model and save the result to a text file
#'
#' @param fit Fitted coevfit model
#' @param region World region(s) to be included in file name
#' @param abrahamization Abrahamization level(s) to be included in file name
#' @param geo_control Geographic control option to be included in file name
#'
#' @returns Nothing, run for printing side-effect
#'
print_model_summary <- function(fit, region, abrahamization, geo_control) {

  # file name
  file_name <-
    paste0(
      "outputs/summary",
      ifelse(!is.null(region), paste0("_", region, collapse = ""), ""),
      ifelse(!is.null(abrahamization),
             paste0("_Abr", paste0(abrahamization, collapse = "")), ""),
      ifelse(geo_control, "_GeoControl", ""),
      ".txt"
    )

  # print model summary
  withr::with_options(
    list(width = 200),
    capture.output(
      suppressWarnings(summary(fit)),
      file = file_name
    )
  )

}
