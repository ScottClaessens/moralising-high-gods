#' Extract standardised cross-selection effects from a fitted model
#'
#' @param fit Fitted model of class coevfit
#' @param region World region(s) to be included in output tibble
#' @param abrahamization Abrahamization level(s) to be included in output tibble
#' @param geo_control Geographic control option to be included in output tibble
#'
#' @returns A tibble
#'
extract_cross_effects <- function(fit, region, abrahamization, geo_control) {

  # get cross-selection effects
  draws <- fit$fit$draws_array
  cross_effect_p_to_m <- as.numeric(draws[, , "A[1,2]"])
  cross_effect_m_to_p <- as.numeric(draws[, , "A[2,1]"])

  # standardise cross-selection effects
  ntips <- length(fit$tree[[1]]$tip.label)
  eta_tips_m <- sapply(1:ntips, \(x) draws[, , paste0("eta[1,", x, ",1]")])
  eta_tips_p <- sapply(1:ntips, \(x) draws[, , paste0("eta[1,", x, ",2]")])
  eta_sd_m <- apply(eta_tips_m, 1, sd)
  eta_sd_p <- apply(eta_tips_p, 1, sd)
  cross_effect_p_to_m <- cross_effect_p_to_m * (eta_sd_p / eta_sd_m)
  cross_effect_m_to_p <- cross_effect_m_to_p * (eta_sd_m / eta_sd_p)

  # return posterior draws
  tibble(
    region = list(region),
    abrahamization = list(abrahamization),
    geo_control = geo_control,
    direction = c(
      "Moralising high gods -> Political complexity",
      "Political complexity -> Moralising high gods"
    ),
    effect = c(
      list(as.numeric(cross_effect_m_to_p)),
      list(as.numeric(cross_effect_p_to_m))
    )
  )

}
