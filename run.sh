#!/usr/bin/env bash

#SBATCH --job-name=moralising-high-gods
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=4
#SBATCH --time=07-00:00:00
#SBATCH --mem=200G
#SBATCH --account=arch039044

module load languages/R/4.5.1
Rscript run.R
