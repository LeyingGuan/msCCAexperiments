# Publsihed Simulation Reproducibility
Code directory simulations/.
## Synthetic Data Generation
The script simulations_msCCAl1.R and dataGen_nonGaussian.R generate data Gaussian and t-distributed noises respectively. 

- simulations_dataGen.R for both sample size n = 300 and 1000.

- dataGen_nonGaussian.R takes no additional input arguments, with fixed n = 300.

- output file will be saved under /data with specified rds file names.

- Code below is only relevant to the author for keeping track of her result versions during paper revision.
```ruby

sbatch simDataTdistRun.sh
sbatch simDataTdistRun.sh
```
## Runing main simulations
Individual scripts are created for running msCCAl1 (simulations_msCCAl1.R, tuned using both penalized objective and cross-validation), rifle (simulations_rifle.R, tuned using cross-validation), Sgcca (simulations_sgcca.R, cross-validation), Rgcca (simulations_rgcca.R, "optimal"), PMA (simulations_pma.R, permutation). Each script takes in four arguments (n, s, design, redundency and iteration_number) and load in corresponding Guassian data under /data. Below are examples:
```ruby
Rscript simulations_msCCAl1.R 300 1 identity T 3
```
The saved rds file records both the estimations and run time.

Code below is only relevant to the author for keeping track of her result versions during paper revision:
```ruby
# create job list
bash sim_msCCA_job.sh sim_msCCA_joblist300.txt 300
bash sim_msCCA_job.sh sim_msCCA_joblist1000.txt 1000
bash sim_rifle_job.sh sim_rifle_joblist.txt
bash sim_sgcca_job.sh sim_sgcca_joblist.txt
bash sim_rgcca_job.sh sim_rgcca_joblist.txt
bash sim_pma_job.sh sim_pma_joblist.txt

# create job array for bulk submission
dsq --job-file sim_msCCA_joblist300.txt --mem-per-cpu 10g -t 00:25:00 --mail-type ALL
dsq --job-file sim_msCCA_joblist1000.txt --mem-per-cpu 10g -t 3:00:00 --mail-type ALL
dsq --job-file sim_pma_joblist.txt --mem-per-cpu 6g -t 00:05:00 --mail-type ALL
dsq --job-file sim_rifle_joblist.txt --mem-per-cpu 10g -t 1:50:00 --mail-type ALL
dsq --job-file sim_rgcca_joblist.txt --mem-per-cpu 6g -t 00:05:00 --mail-type ALL
dsq --job-file sim_sgcca_joblist.txt --mem-per-cpu 10g -t 01:00:00 --mail-type ALL

# array job submission
sbatch dsq-sim_msCCA_joblist300-2024-09-02.sh
sbatch dsq-sim_msCCA_joblist1000-2024-09-02.sh
sbatch dsq-sim_pma_joblist-2024-09-02.sh
sbatch dsq-sim_rifle_joblist-2024-08-30.sh
sbatch dsq-sim_rgcca_joblist-2024-08-29.sh
sbatch dsq-sim_sgcca_joblist-2024-09-01.sh
```
## Robustness Examination with t-distributed noise

## Table and Figures
# Published Real Data Reproducibility

# Unpublished Simulation Analyses

## Exploration and comparison using sgcaTGD (cross-validation)
Example of using the sgcaTGD script wrapper:
```ruby
Rscript simulations_sparseGCA.R 1000 5 spiked T 1 1
```
Code below is only relevant to the author for keeping track of her result versions during paper revision:
```ruby
bash sim_sgcaTGD_job.sh sim_sgcaTGD_joblist1.txt 1
bash sim_sgcaTGD_job.sh sim_sgcaTGD_joblist20.txt 20
dsq --job-file sim_sgcaTGD_joblist1.txt  --partition week --mem-per-cpu 6g -t 32:00:00 --mail-type ALL
sbatch dsq-sim_sgcaTGD_joblist1-2024-09-25.sh

dsq --job-file sim_sgcaTGD_joblist20.txt  --partition week  --mem-per-cpu 6g -t 48:00:00 --mail-type ALL
sbatch dsq-sim_sgcaTGD_joblist20-2024-09-25.sh
```




