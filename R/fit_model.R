#' Fit coevolve model to data
#'
#' @param data Tibble of D-PLACE data
#' @param tree Posterior set of phylogenetic trees
#' @param region World region to subset to. If \code{NULL} (default), the full
#'   global sample is used. Otherwise, the dataset is subsetted to only include
#'   societies in this world region.
#' @param geographic_control Whether or not to include the geographic control
#'   over latitude and longitude values. If \code{FALSE} (default), the model
#'   is fitted without the geographic control. If \code{TRUE}, latitude and
#'   longitude values are passed to the model and the geographic control is
#'   included.
#'
#' @returns A coevfit object
#'
fit_model <- function(data, tree, region = NULL,
                      geographic_control = FALSE) {

  # if region declared, subset data and tree
  if (!is.null(region)) {
    data <- filter(data, region == .env$region)
    tree <- ape::keep.tip.multiPhylo(tree, data$xd_id)
  }

  # prepare lon-lat data for geographic control
  if (geographic_control) {
    lon_lat <- transmute(data, id = xd_id, longitude, latitude)
  } else {
    lon_lat <- NULL
  }

  # fit model
  coevolve::coev_fit(
    data = data,
    variables = list(
      moralising_high_gods = "bernoulli_logit",
      political_complexity = "ordered_logistic"
    ),
    id = "xd_id",
    tree = tree,
    lon_lat = lon_lat,
    dist_k = 20,
    estimate_correlated_drift = FALSE,
    nuts_sampler = "nutpie",
    iter_warmup = 3000,
    iter_sampling = 1500,
    chains = 8,
    cores = 8L,
    seed = 123
  )

}
