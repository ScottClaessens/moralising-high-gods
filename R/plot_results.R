#' Plot standardised cross-selection effects from models
#'
#' @param effects_std Tibble of posterior draws for standardised cross-selection
#'   effects
#'
#' @returns A ggplot object
#'
plot_results <- function(effects_std) {

  # get vector of regions
  regions <- c(
    "Global (n = 1127)",
    "Africa (n = 390)",
    "Americas (n = 335)",
    "Eurasia (n = 357)",
    "Sahul (n = 45)"
  )

  # get data for plot
  data <-
    effects_std |>
    mutate(
      region = factor(
        case_when(
          region == "Global"   ~ regions[1],
          region == "Africa"   ~ regions[2],
          region == "Americas" ~ regions[3],
          region == "Eurasia"  ~ regions[4],
          region == "Sahul"    ~ regions[5]
        ),
        levels = regions
      ),
      geographic_control = factor(
        ifelse(
          geographic_control,
          "With geographic control",
          "No geographic control"
        ),
        levels = paste(c("No", "With"), "geographic control")
      )
    ) |>
    unnest(effect)

  # produce plot
  out <-
    ggplot(
      mapping = aes(
        x = effect,
        y = fct_rev(region),
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
    facet_wrap(. ~ geographic_control) +
    labs(
      x = "Cross-selection effect (standardised)",
      y = "World region"
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
    filename = "plots/results.pdf",
    plot = out,
    height = 4,
    width = 5
  )

  # clean up
  rm(effects_std)

  # return
  out

}
