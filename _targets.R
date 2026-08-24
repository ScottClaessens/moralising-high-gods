library(targets)
tar_option_set(packages = c("tidyverse"))
tar_source()

list(
  # load data
  tar_target(data_file, "data/ea_1127_ea033_MHGs.xlsx", format = "file"),
  tar_target(data, load_data(data_file))
)
