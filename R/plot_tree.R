#' Plot maximum clade credibility tree with trait data
#'
#' @param data Tibble of ethnographic data
#' @param mcc_tree Maximum clade credibility tree object of class phylo
#'
#' @returns A ggplot object
#'
plot_tree <- function(data, mcc_tree) {

  # wrangle data
  d <-
    data |>
    transmute(
      var1 = political_complexity,
      var2 = as.factor(moralising_high_gods)
    ) |>
    as.data.frame()
  rownames(d) <- data$xd_id

  # plot tree
  p <-
    ggtree(
      tr = mcc_tree,
      layout = "circular",
      linewidth = 0.15
    )

  # add data for political complexity
  p <-
    gheatmap(
      p = p,
      data = d["var1"],
      offset = -0.5,
      width = 0.05,
      colnames = FALSE,
      color = NA
    ) +
    scale_fill_brewer(
      name = "Political\ncomplexity",
      type = "seq",
      palette = 7,
      na.value = "grey95",
      guide = guide_legend(order = 1)
    ) +
    ggnewscale::new_scale_fill()

  # add data for moralising high gods
  p <-
    gheatmap(
      p = p,
      data = d["var2"],
      offset = 8,
      width = 0.05,
      colnames = FALSE,
      color = NA
    ) +
    scale_fill_manual(
      name = "Moralising\nhigh gods",
      values = c("#BDD7E7", "#08519C"),
      labels = c("Absent", "Present"),
      na.value = "grey95"
    )

  # save
  ggsave(
    filename = "plots/tree.pdf",
    plot = p,
    height = 10,
    width = 10
  )

  # cleanup
  rm(data, mcc_tree, d)

  # return
  p

}
