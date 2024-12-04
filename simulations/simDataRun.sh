#!/bin/bash

#SBATCH --job-name=msCCAdata
#SBATCH --time=18:00:00
#SBATCH --mem-per-cpu=15G
#SBATCH --mail-type=ALL

module load R/4.2.0-foss-2020b

Rscript simulations_dataGen.R
