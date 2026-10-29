#' Plot standardised cross-selection effects by abrahamization levels
#'
#' @param effects_std Tibble of posterior draws for standardised cross-selection
#'   effects
#'
#' @returns A ggplot object
#'
plot_abrahamization_results <- function(effects_std) {

  # get vector of abrahamization levels
  levels <- c(
    "All societies (n = 1127)",
    "Non-Abrahamized and\nsuperficially Abrahamized\nsocieties only (n = 812)",
    "Non-Abrahamized\nsocieties only (n = 646)"
  )

  # get data for plot
  data <-
    effects_std |>
    rowwise() |>
    filter(!geo_control & is.null(region)) |>
    mutate(
      abrahamization = ifelse(
        is.null(abrahamization), NA, paste0(abrahamization, collapse = "")
      ),
      abrahamization = factor(
        case_when(
          is.na(abrahamization)  ~ levels[1],
          abrahamization == "01" ~ levels[2],
          abrahamization == "0"  ~ levels[3]
        ),
        levels = levels
      )
    ) |>
    unnest(effect)

  # produce plot
  out <-
    ggplot(
      mapping = aes(
        x = effect,
        y = fct_rev(abrahamization),
        fill = direction
      )
    ) +
    geom_vline(
      xintercept = 0,
      linetype = "dotted",
      linewidth = 0.2
    ) +
    tidybayes::stat_slab(
      data = filter(data, direction == unique(data$direction)[1]),
      alpha = 0.3,
      height = 0.5,
      position = position_nudge(y = -0.05),
      side = "bottomright"
    ) +
    tidybayes::stat_slab(
      data = filter(data, direction == unique(data$direction)[2]),
      alpha = 0.3,
      height = 0.5,
      position = position_nudge(y = 0.05)
    ) +
    tidybayes::stat_pointinterval(
      data = data,
      mapping = aes(colour = direction),
      fatten_point = 0.3,
      position = position_dodge(width = 0.25),
      point_colour = "black"
    ) +
    labs(
      x = "Cross-selection effect (standardised)",
      y = "Abrahamization"
    ) +
    xlim(c(-4, 4)) +
    scale_fill_manual(
      values = c("#0072B2", "#D55E00"),
      guide = guide_legend(reverse = TRUE)
    ) +
    scale_colour_manual(
      values = c("#0072B2", "#D55E00"),
      guide = guide_legend(reverse = TRUE)
    ) +
    theme_bw() +
    theme(
      legend.position = "bottom",
      legend.direction = "vertical",
      legend.title = element_blank(),
      panel.grid = element_blank()
    )

  # save plot
  ggsave(
    filename = "plots/abrahamization_results.pdf",
    plot = out,
    height = 4,
    width = 4.5
  )

  # clean up
  rm(effects_std)

  # return
  out

}
