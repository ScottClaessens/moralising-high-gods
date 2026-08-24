#' Fit coevolve model to data
#'
#' @param data Tibble of D-PLACE data
#' @param tree Posterior set of phylogenetic trees
#'
#' @returns A coevfit object
#'
fit_model <- function(data, tree) {

  coevolve::coev_fit(
    data = data,
    variables = list(
      moralising_high_gods = "bernoulli_logit",
      political_complexity = "ordered_logistic"
    ),
    id = "xd_id",
    tree = tree,
    nuts_sampler = "nutpie",
    chains = 4,
    cores = 4L,
    seed = 123
  )

}
