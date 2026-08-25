library(targets)
tar_option_set(packages = c("ape", "coevolve", "tidyverse"))
tar_source()

list(

  # load data
  tar_target(data_file, "data/ea_1127_ea033_MHGs.xlsx", format = "file"),
  tar_target(data, load_data(data_file)),

  # load tree
  tar_target(tree_file, "tree/dplace2.nxs", format = "file"),
  tar_target(tree, load_tree(tree_file)),

  # get random sample of trees for analysis
  tar_target(tree_sample, tree[sample(1:1000, size = 10)]),

  # fit models
  tar_target(fit1, fit_model(data, tree_sample)),

  # plot cross effects
  tar_target(plot_cross_selection, plot_cross_effects(fit1))

)
