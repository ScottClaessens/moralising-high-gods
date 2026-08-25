#' Plot standardised cross-selection effects from a fitted model
#'
#' @param fit Fitted model of class coevfit
#' @param prob_inner Inner probability interval for plot
#' @param prob_outer Outer probability interval for plot
#' @param xlim Limits for x-axis of plot
#'
#' @returns A patchwork of ggplot objects
#'
plot_cross_effects <- function(fit, prob_inner = 0.5, prob_outer = 0.95,
                               xlim = c(-5, 5)) {

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

  # collate posterior draws
  draws <-
    tibble(
      direction = rep(
        c("Moralising high gods -> Political complexity",
          "Political complexity -> Moralising high gods"),
        each = length(as.numeric(cross_effect_p_to_m))
      ),
      effect = c(
        as.numeric(cross_effect_m_to_p),
        as.numeric(cross_effect_p_to_m)
      )
    )

  # summarise posterior draws
  summary <-
    draws |>
    group_by(direction) |>
    summarise(
      median      = median(effect),
      lower_inner = quantile(effect, (1 - prob_inner) / 2),
      upper_inner = quantile(effect, (1 + prob_inner) / 2),
      lower_outer = quantile(effect, (1 - prob_outer) / 2),
      upper_outer = quantile(effect, (1 + prob_outer) / 2)
    )

  # plot cross-selection effects
  out <-
    ggplot() +
    tidybayes::stat_slab(
      data = draws,
      mapping = aes(x = effect)
    ) +
    geom_pointrange(
      data = summary,
      aes(
        y = 0,
        x = median,
        xmin = lower_outer,
        xmax = upper_outer
      ),
      size = 0.25
    ) +
    geom_linerange(
      data = summary,
      aes(
        y = 0,
        xmin = lower_inner,
        xmax = upper_inner
      ),
      linewidth = 1
    ) +
    geom_vline(
      xintercept = 0,
      linetype = "dashed"
    ) +
    facet_wrap(direction ~ .) +
    lims(
      x = xlim,
      y = c(0, 1)
    ) +
    xlab("Cross-selection effect (standardised)") +
    theme_classic() +
    theme(
      axis.title.y = element_blank(),
      axis.text.y = element_blank(),
      axis.line.y = element_blank(),
      axis.ticks.y = element_blank(),
      strip.text = element_text(size = 7)
    )

  # save
  ggsave(
    filename = "plots/cross_effects.pdf",
    plot = out,
    width = 5,
    height = 3
  )

  # return
  out

}
