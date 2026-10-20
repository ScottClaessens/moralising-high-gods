#' Plot phylogenetic signal and correlation
#'
#' @param signal_draws Posterior draws from the brms phylogenetic signal model
#'
#' @returns A patchwork of ggplot objects
#'
plot_phylogenetic_signal <- function(signal_draws) {

  # calculate phylogenetic signal for political complexity
  phy_var_p <- signal_draws$sd_id1__politicalcomplexity_Intercept^2
  res_var_p <- signal_draws$sd_id2__politicalcomplexity_Intercept^2
  total_var_p <- phy_var_p + res_var_p + ((pi^2) / 3)
  phy_signal_p <- phy_var_p / total_var_p

  # calculate phylogenetic signal for moralising high gods
  phy_var_m <- signal_draws$sd_id1__moralisinghighgods_Intercept^2
  res_var_m <- signal_draws$sd_id2__moralisinghighgods_Intercept^2
  total_var_m <- phy_var_m + res_var_m + ((pi^2) / 3)
  phy_signal_m <- phy_var_m / total_var_m

  # extract phylogenetic correlation
  phy_cor <- signal_draws[[
    "cor_id1__politicalcomplexity_Intercept__moralisinghighgods_Intercept"
  ]]

  # plot phylogenetic signal
  pA <-
    ggplot(
      data = tibble(
        var = rep(c("Political complexity", "Moralising high gods"),
                  each = length(phy_signal_p)),
        signal = c(phy_signal_p, phy_signal_m)
      ),
      mapping = aes(
        x = signal,
        fill = var
      )
    ) +
    tidybayes::stat_halfeye() +
    facet_wrap(var ~ .) +
    scale_fill_manual(values = c("#D55E00", "#0072B2")) +
    labs(
      x = "Phylogenetic signal",
      y = "Density"
    ) +
    guides(fill = "none") +
    xlim(c(0, 1)) +
    theme_classic()

  # plot phylogenetic correlation
  pB <-
    ggplot(
      data = tibble(cor = phy_cor),
      mapping = aes(x = cor)
    ) +
    tidybayes::stat_halfeye() +
    geom_vline(
      xintercept = 0,
      linetype = "dashed"
    ) +
    labs(
      x = "Phylogenetic correlation",
      y = "Density"
    ) +
    xlim(c(-1, 1)) +
    theme_classic()

  # put together
  out <- pA / pB & theme(axis.text = element_text(size = 8))

  # save
  ggsave(
    plot = out,
    file = "plots/signal.pdf",
    height = 5,
    width = 5
  )

  # return
  out

}
