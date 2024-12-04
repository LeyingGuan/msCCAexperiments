#!/bin/bash

#SBATCH --job-name=msCCAdata
#SBATCH --time=8:00:00
#SBATCH --mem-per-cpu=8G
#SBATCH --mail-type=ALL

module load R/4.2.0-foss-2020b

Rscript dataGen_nonGaussian.R
