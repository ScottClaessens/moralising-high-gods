#' Fit coevolve model to data
#'
#' @param data Tibble of D-PLACE data
#' @param tree Posterior set of phylogenetic trees
#' @param region Character. World region(s) to subset to. If \code{NULL}
#'   (default), the dataset is not subsetted by region. Otherwise, the dataset
#'   is subsetted to only include societies in this world region (or multiple
#'   world regions).
#' @param abrahamization Character. Abrahamization level(s) to subset to. If
#'   \code{NULL} (default), the dataset is not subsetted by Abrahamization
#'   level. Otherwise, the dataset is subsetted to include only societies with
#'   this Abrahamization level (or multiple levels).
#' @param geo_control Logical. Whether or not to include the geographic control
#'   over latitude and longitude values. If \code{FALSE} (default), the model is
#'   fitted without the geographic control. If \code{TRUE}, latitude and
#'   longitude values are passed to the model and the geographic control is
#'   included.
#'
#' @returns A coevfit object
#'
fit_coevolve_model <- function(data, tree, region = NULL, abrahamization = NULL,
                               geo_control = FALSE) {

  # if region declared, subset data and tree
  if (!is.null(region)) {
    data <- filter(data, region %in% .env$region)
    tree <- ape::keep.tip.multiPhylo(tree, data$xd_id)
  }

  # if abrahamization level(s) declared, subset data and tree
  if (!is.null(abrahamization)) {
    data <- filter(data, abrahamization %in% .env$abrahamization)
    tree <- ape::keep.tip.multiPhylo(tree, data$xd_id)
  }

  # prepare lon-lat data for geographic control
  if (geo_control) {
    lon_lat <- transmute(data, id = xd_id, longitude, latitude)
  } else {
    lon_lat <- NULL
  }

  # get data list for stan
  stan_data <-
    coevolve::coev_make_standata(
      data = data,
      variables = list(
        moralising_high_gods = "bernoulli_logit",
        political_complexity = "ordered_logistic"
      ),
      id = "xd_id",
      tree = tree,
      lon_lat = lon_lat,
      dist_k = 20,
      estimate_correlated_drift = FALSE
    )

  # get stan code
  stan_code <-
    coevolve::coev_make_stancode(
      data = data,
      variables = list(
        moralising_high_gods = "bernoulli_logit",
        political_complexity = "ordered_logistic"
      ),
      id = "xd_id",
      tree = tree,
      lon_lat = lon_lat,
      dist_k = 20,
      estimate_correlated_drift = FALSE
    )

  # compile model
  model <- stan_model(model_code = stan_code)

  # fit model using rstan
  rstan::sampling(
    object = model,
    data = stan_data,
    pars = c(
      "VCV_tips", "L_VCV_tips", "terminal_drift",
      "z_drift", "dist_v", "yrep", "tdrift"
    ),
    include = FALSE,
    iter = 1000,
    warmup = 500,
    control = list(adapt_delta = 0.95),
    chains = 4,
    cores = 4L,
    seed = 123
  )

}
