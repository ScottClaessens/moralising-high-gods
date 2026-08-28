options(tidyverse.quiet = TRUE)
library(targets)
library(tarchetypes)
library(tidyverse)
tar_option_set(packages = c("ape", "coevolve", "tidyverse"))
tar_source()

# grid over model types
model_grid <-
  tar_map(
    values = expand_grid(
      region = c("Global", "Africa", "Americas", "Eurasia", "Sahul"),
      geographic_control = c(TRUE, FALSE)
    ),
    # fit model
    tar_target(
      fit,
      fit_model(
        data = data,
        tree = tree_sample,
        region = if (region == "Global") NULL else region,
        geographic_control = geographic_control
      )
    ),
    # extract standardised cross-selection effects
    tar_target(
      effects_std,
      extract_cross_effects(fit, region, geographic_control)
    )
  )

list(

  # load data
  tar_target(data_file, "data/ea_1127_ea033_MHGs.xlsx", format = "file"),
  tar_target(data, load_data(data_file)),

  # load tree
  tar_target(tree_file, "tree/dplace2.nxs", format = "file"),
  tar_target(tree, load_tree(tree_file)),

  # get random sample of trees for analysis
  tar_target(tree_sample, tree[sample(1:1000, size = 10)]),

  # loop over model types and combine resulting effects
  model_grid,
  tar_combine(effects_std, model_grid[[2]]),

  # plot results
  tar_target(plot_effects, plot_results(effects_std))

)
