options(tidyverse.quiet = TRUE)
library(crew)
library(crew.cluster)
library(targets)
library(tarchetypes)
library(tidyverse)
tar_option_set(
  packages = c("ape", "brms", "coevolve", "ggnewscale",
               "ggtree", "phangorn", "rstan", "tidyverse"),
  garbage_collection = 1,
  controller = crew_controller_slurm(
    workers = 10,
    options_cluster = crew_options_slurm(
      script_lines = c(
        "#SBATCH --account=arch039044",
        "module load languages/R/4.5.1"
      ),
      memory_gigabytes_required = 50,
      cpus_per_task = 4,
      time_minutes = 2 * 24 * 60
    )
  )
)
tar_source()

# loop over coevolve model types
model_list <-
  tar_map(

    # set up target names and values
    values = tribble(
      ~target_name,   ~region,    ~abrahamization, ~geo_control,
      "Global",       NULL,       NULL,            FALSE,
      "Global_Geo",   NULL,       NULL,            TRUE,
      "Global_Abr01", NULL,       c("0","1"),      FALSE,
      "Global_Abr0",  NULL,       "0",             FALSE,
      "Africa",       "Africa",   NULL,            FALSE,
      "Americas",     "Americas", NULL,            FALSE,
      "Eurasia",      "Eurasia",  NULL,            FALSE,
      "Sahul",        "Sahul",    NULL,            FALSE
    ),
    names = target_name,

    # fit coevolve model
    tar_target(
      fit,
      fit_coevolve_model(
        data = data,
        tree = tree[tree_ids],
        region = region,
        abrahamization = abrahamization,
        geo_control = geo_control
      )
    ),

    # extract standardised cross-selection effects
    tar_target(
      effects_std,
      extract_cross_effects(fit, region, abrahamization, geo_control)
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
  tar_target(tree_ids, sample(1:1000, size = 100)),

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

  # plot phylogenetic signal and correlation
  tar_target(plot_signal, plot_phylogenetic_signal(signal_draws)),

  # loop over coevolve model types and combine resulting effects
  model_list,
  tar_combine(effects_std, model_list[["effects_std"]]),

  # plot regional results
  tar_target(
    plot_regional_effects,
    plot_regional_results(effects_std)
  ),

  # plot abrahamization results
  tar_target(
    plot_abrahamization_effects,
    plot_abrahamization_results(effects_std)
  )

)
