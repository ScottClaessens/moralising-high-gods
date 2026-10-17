options(tidyverse.quiet = TRUE)
library(crew)
library(targets)
library(tarchetypes)
library(tidyverse)
tar_option_set(
  packages = c("ape", "brms", "coevolve", "ggnewscale",
               "ggtree", "phangorn", "tidyverse"),
  deployment = "main",
  controller = crew_controller_local(workers = 10)
)
tar_source()

# list coevolve model types
model_list <-
  tar_map(

    values = tribble(
      ~region, ~geo_control, ~abrahamic_control,
      "Global",   FALSE, FALSE,
      "Global",   TRUE,  FALSE,
      "Global",   FALSE, TRUE,
      "Africa",   FALSE, FALSE,
      "Americas", FALSE, FALSE,
      "Eurasia",  FALSE, FALSE,
      "Sahul",    FALSE, FALSE
    ),

    # fit coevolve model
    tar_target(
      fit,
      fit_coevolve_model(
        data = data,
        tree = tree[tree_ids],
        region = if (region == "Global") NULL else region,
        geo_control = geo_control,
        abrahamic_control = abrahamic_control
      )
    ),

    # print model summary
    tar_target(
      summary,
      print_model_summary(
        fit,
        paste0(
          "outputs/summary_", region,
          ifelse(geo_control, "_withGeoControl", ""),
          ifelse(abrahamic_control, "_withAbrahamicControl", ""),
          ".txt"
        )
      )
    ),

    # extract standardised cross-selection effects
    tar_target(
      effects_std,
      extract_cross_effects(fit, region, geo_control, abrahamic_control)
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
  tar_target(tree_ids, sample(1:1000, size = 10)),

  # fit brms model to different trees
  tar_target(
    fit_signal,
    fit_brms_model(data, tree, id = tree_ids),
    pattern = map(tree_ids),
    iteration = "list",
    deployment = "worker"
  ),

  # combine brms model draws
  tar_target(signal_draws, bind_rows(lapply(fit_signal, as_draws_df))),

  # loop over coevolve model types and combine resulting effects
  model_list,
  tar_combine(effects_std, model_list[["effects_std"]]),

  # plot regional results
  tar_target(plot_regional_effects, plot_regional_results(effects_std))

)
