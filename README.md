# Publsihed Simulation Reproducibility
Code directory simulations/.
## Synthetic Data Generation
The script simulations_msCCAl1.R and dataGen_nonGaussian.R generate data Gaussian and t-distributed noises respectively. 

-  simulations_msCCAl1.R takes in four input arguments n, s, design, redundency and random seed: Rscript simulations_msCCAl1.R 300 1 identity T 3

- dataGen_nonGaussian.R takes no additional input arguments, with fixed n = 300.

- output file will be saved under /data with specified rds file names.

The author has used bash script to generate data on clusters:

```ruby
bash sim_msCCA_job.sh sim_msCCA_joblist300.txt 300
bash sim_msCCA_job.sh sim_msCCA_joblist1000.txt 1000

# For script tracking reasons for the author: the code below is only relevant to authors for keeping track of her code during paper revision

#dsq --job-file sim_msCCA_joblist300.txt --mem-per-cpu 10g -t 00:25:00 --mail-type ALL
#dsq --job-file failed_msCCA_job_list.txt --mem-per-cpu 10g -t 3:00:00 --mail-type ALL

#sbatch dsq-sim_msCCA_joblist300-2024-09-02.sh
#sbatch dsq-failed_msCCA_job_list-2024-09-11.sh
#sbatch simDataTdistRun.sh
```
##  
## Robustness Examination with t-distributed noise

## Table and Figures
# Published Real Data Reproducibility

# Unpublished Simulation Analyses





