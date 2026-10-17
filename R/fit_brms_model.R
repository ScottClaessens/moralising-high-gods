#' Fit brms model to calculate phylogenetic signal and correlation
#'
#' @param data Tibble of DPLACE data
#' @param tree Treeset multiphylo object
#' @param id Tree ID to use for the model
#'
#' @returns Fitted model brmsfit object
#'
fit_brms_model <- function(data, tree, id) {

  # wrangle data
  data <-
    data |>
    drop_na(political_complexity, moralising_high_gods) |>
    mutate(
      id1 = xd_id,
      id2 = xd_id
    )

  # calculate phylogenetic covariance matrix
  tree <- keep.tip(tree[[id]], tip = data$xd_id)
  phy_cov <- vcv.phylo(tree, corr = TRUE)

  # write formulas
  f1 <- political_complexity ~ 1 + (1 |i| gr(id1, cov = phy_cov)) + (1 |j| id2)
  f2 <- moralising_high_gods ~ 1 + (1 |i| gr(id1, cov = phy_cov)) + (1 |j| id2)

  # set families
  bf1 <- bf(f1, family = cumulative)
  bf2 <- bf(f2, family = bernoulli)

  # fit model
  brm(
    formula = bf1 + bf2 + set_rescor(FALSE),
    data = data,
    data2 = list(phy_cov = phy_cov),
    prior = c(
      prior(normal(0, 1), class = Intercept, resp = politicalcomplexity),
      prior(normal(0, 1), class = Intercept, resp = moralisinghighgods),
      prior(exponential(3), class = sd, resp = politicalcomplexity),
      prior(exponential(3), class = sd, resp = moralisinghighgods),
      prior(lkj(3), class = cor)
    ),
    backend = "cmdstanr",
    chains = 1,
    cores = 1,
    seed = 123
  )

}
