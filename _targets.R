options(tidyverse.quiet = TRUE)
library(targets)
library(tarchetypes)
library(tidyverse)
tar_option_set(
  packages = c("ape", "coevolve", "ggnewscale",
               "ggtree", "phangorn", "tidyverse")
)
tar_source()

# list model types
model_list <-
  tar_map(

    values = tribble(
      ~model, ~region, ~geo_control, ~abrahamic_control, ~log_lik,
      "independent", "Global",   FALSE, FALSE, TRUE,
      "dependent",   "Global",   FALSE, FALSE, TRUE,
      "dependent",   "Global",   TRUE,  FALSE, FALSE,
      "dependent",   "Africa",   FALSE, FALSE, FALSE,
      "dependent",   "Americas", FALSE, FALSE, FALSE,
      "dependent",   "Eurasia",  FALSE, FALSE, FALSE,
      "dependent",   "Sahul",    FALSE, FALSE, FALSE,
      "dependent",   "Global",   FALSE, TRUE,  FALSE
    ),

    # fit model
    tar_target(
      fit,
      fit_model(
        data = data,
        tree = tree_sample,
        model = model,
        region = if (region == "Global") NULL else region,
        geo_control = geo_control,
        abrahamic_control = abrahamic_control,
        log_lik = log_lik
      )
    ),

    # print model summary
    tar_target(
      summary,
      print_model_summary(
        fit,
        paste0(
          "outputs/summary_", model, "_", region,
          ifelse(geo_control, "_withGeoControl", ""),
          ifelse(abrahamic_control, "_withAbrahamicControl", ""),
          ".txt"
        )
      )
    ),

    # extract standardised cross-selection effects
    tar_target(
      effects_std,
      extract_cross_effects(fit, model, region, geo_control, abrahamic_control)
    )

  )

list(

  # get file paths
  tar_target(
    ea_data_file,
    "data/ea_1127_ea033_MHGs/ea_1127_ea033_MHGs.xlsx",
    format = "file"
  ),
  tar_target(
    abrahamization_data_file,
    "data/Abrahamization_09_10_2026/Abrahamization_09_10_2026.xlsx",
    format = "file"
  ),

  # load data
  tar_target(data, load_data(ea_data_file, abrahamization_data_file)),

  # load tree
  tar_target(tree_file, "tree/dplace2.nxs", format = "file"),
  tar_target(tree, load_tree(tree_file)),

  # get mcc tree
  tar_target(mcc_tree, phangorn::mcc(tree)),

  # plot tree
  tar_target(plot_mcc_tree, plot_tree(data, mcc_tree)),

  # get random sample of trees for analysis
  tar_target(tree_sample, tree[sample(1:1000, size = 10)]),

  # loop over model types and combine resulting effects
  model_list,
  tar_combine(effects_std, model_list[["effects_std"]]),

  # plot regional results
  tar_target(plot_regional_effects, plot_regional_results(effects_std))

)
