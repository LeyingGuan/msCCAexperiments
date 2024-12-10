# Simulation Reproducibility
Code directory simulations/.
## Synthetic Data Generation
The script simulations_msCCAl1.R and dataGen_nonGaussian.R generate data Gaussian and t-distributed noises respectively. 

- simulations_dataGen.R for both sample size n = 300 and 1000.

- dataGen_nonGaussian.R takes no additional input arguments, with fixed n = 300.

- output file will be saved under /data with specified rds file names.

- Code below is only relevant to the author for keeping track of her result versions during paper revision.
```ruby
sbatch simDataTdistRun.sh
```
## Runing main simulations
Individual scripts are created for running msCCAl1 (simulations_msCCAl1.R, tuned using both penalized objective and cross-validation), rifle (simulations_rifle.R, tuned using cross-validation), Sgcca (simulations_sgcca.R, cross-validation), Rgcca (simulations_rgcca.R, "optimal"), PMA (simulations_pma.R, permutation). Each script takes in four arguments (n, s, design, redundency and iteration_number) and load in corresponding Guassian data under /data. Below are examples:
```ruby
Rscript simulations_msCCAl1.R 300 1 identity T 3
```
The saved rds files recording both the estimations and run time, and will be saved under simulations/MainSimulations_revision202409.

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

## Exploration and comparison using sgcaTGD (cross-validation)
Example of using the sgcaTGD script wrapper:
```ruby
Rscript simulations_sparseGCA.R 1000 5 spiked T 1 1
```
The results will be saved under simulations/simulations_revision202409. Compared to simulations_msCCAl1.R, it takes an additional argument being the innerloop number inner_iter used in the convex initialization: inner_iter=1 is used in the rifle's implementation of cvx init, and inner_iter = 20 is used in the SGCTGD's implementation of cvx init.  

Code below is only relevant to the author for keeping track of her result versions during paper revision:
```ruby
bash sim_sgcaTGD_job.sh sim_sgcaTGD_joblist1.txt 1
bash sim_sgcaTGD_job.sh sim_sgcaTGD_joblist20.txt 20
dsq --job-file sim_sgcaTGD_joblist1.txt  --partition week --mem-per-cpu 6g -t 32:00:00 --mail-type ALL
sbatch dsq-sim_sgcaTGD_joblist1-2024-09-25.sh

dsq --job-file sim_sgcaTGD_joblist20.txt  --partition week  --mem-per-cpu 6g -t 48:00:00 --mail-type ALL
sbatch dsq-sim_sgcaTGD_joblist20-2024-09-25.sh
```


## Initialization strategy comparisons
In our experience, even though the  convex initialization has better theoretical guarantees and improved performance when the optimization parameter is well set for convergence, it can be extremely slow, and can sometimes be much slower than running the subsequent decomposition algorithms for large-scale problems. We found that a heuristic initialization used in our paper is often sufficient in practice and can be of magnitude faster. Here, we provide empirical support regarding initialization quality and time costs. The script simulations_initializationEval.R compares different initializations strategies with the same input argument as simulations_msCCAl1.R. Example:
```ruby
Rscript simulations_initializationEval.R 300 1 spiked T 10
```
The results will be saved under simulations/simulations_revision202409. Code below is only relevant to the author for keeping track of her result versions during paper revision:
```ruby
bash initialization_compare_job.sh initialization_compare_job.txt
dsq --job-file initialization_compare_job.txt --mem-per-cpu 10g -t 15:00:00 --mail-type ALL
sbatch dsq-initialization_compare_job-2024-09-24.sh
```
## Robustness Examination with t-distributed noise
To examine the robustness of our proposal, we compare msCCAl1 with rifle with t-distributed data at n=300. The scripts are TDISTsimulations_msCCAl1.R, TDISTsimulations_rifle.R. Example:
```ruby
Rscript TDISTsimulations_msCCAl1.R 300 1 identity T 1
Rscript TDISTsimulations_rifle.R 300 1 identity T 1
```
The results will be saved under simulations/simulations_revision202409. Code below is only relevant to the author for keeping track of her result versions during paper revision:
```ruby
bash TDISTsim_rifle_job.sh TDISTsim_rifle_joblist.txt
bash TDISTsim_msCCA_job.sh TDISTsim_msCCA_joblist.txt

dsq --job-file TDISTsim_msCCA_joblist.txt --mem-per-cpu 10g -t 00:25:00 --mail-type ALL
dsq --job-file TDISTsim_rifle_joblist.txt --mem-per-cpu 10g -t 1:50:00 --mail-type ALL

sbatch dsq-TDISTsim_msCCA_joblist-2024-09-03.sh
sbatch dsq-TDISTsim_rifle_joblist-2024-09-03.sh
```
## Table and Figures
The R markdown file SIM_result_summary.Rmd first save the organized results under simulations/ResSummary_Paper/ with respective names, then, make 

- Tables 1-6, which summarizes the main quality comparison results and the run time comparisons between msCCAl1 and rifle.

- It generates supplementary Tables in Appendix F for initialization run time quality comparisons using fast initialization and convex initialization.

- It generate the runtime comparison table between SGCTGD and msCCAl1 as well as the comparison between a single-run estimation using SGCTGD to the estimation distributions using msCCAl1.

- Robustness evaluation tables.

# Published Real Data Reproducibility
## Dimension reduction and mCCA factor estimation
The file tcga_separate_run.R constructs the factors (r=10) using different methods and data split.
```ruby
tcga_separate_run.R iseed method multi.core
```
The evaluation of achieved with factor construction learned on the training split and evaluated on the test split (iseed = 1,..., 50). Method takes value from (msCCA1cv, msCCA1pen, rifle, pma, rgcca, sgcca, SGCTGD). multi.core can be "doparallel" for parallel computing in the cluster or others for single-thread process. When iseed = 0, we estimate factor using all data. 

Code below is only relevant to the author for keeping track of her result versions during paper revision:
```ruby
bash create_DRjobs_separate.sh
dsq --job-file DRmsCCA1cv_jobs.txt -n 11 -N 11 --mem-per-cpu 8g -t 6:00:00 --mail-type ALL
dsq --job-file DRmsCCA1pen_jobs.txt --mem-per-cpu 8g -t 3:00:00 --mail-type ALL 
dsq --job-file DRrifle_jobs.txt -n 11 -N 11 --mem-per-cpu 8g -t 23:00:00 --mail-type ALL 
dsq --job-file DRpma_jobs.txt --mem-per-cpu 8g -t 00:30:00 --mail-type ALL 
dsq --job-file DRrgcca_jobs.txt --mem-per-cpu 8g -t 00:30:00 --mail-type ALL
dsq --job-file DRsgcca_jobs.txt --mem-per-cpu 8g -t 4:00:00 --mail-type ALL
dsq --job-file DRSGCTGD_jobs.txt  -n 11 -N 11 --mem-per-cpu 8g -t 2-00:00:00  --mail-type ALL 

sbatch dsq-DRmsCCA1cv_jobs-2024-12-09.sh
sbatch dsq-DRmsCCA1pen_jobs-2024-12-09.sh
sbatch dsq-DRrifle_jobs-2024-12-10.sh
sbatch dsq-DRpma_jobs-2024-12-08.sh
sbatch dsq-DRrgcca_jobs-2024-12-08.sh
sbatch dsq-DRsgcca_jobs-2024-12-09.sh
sbatch dsq-DRSGCTGD_jobs-2024-12-08.sh
```
# System version info
```ruby
sessionInfo()
R version 4.2.0 (2022-04-22)
Platform: x86_64-pc-linux-gnu (64-bit)
Running under: Red Hat Enterprise Linux 8.9 (Ootpa)

Matrix products: default
BLAS/LAPACK: /vast/palmer/apps/avx2/software/OpenBLAS/0.3.12-GCC-10.2.0/lib/libopenblas_haswellp-r0.3.12.so

locale:
 [1] LC_CTYPE=C.UTF-8       LC_NUMERIC=C          
 [3] LC_TIME=C.UTF-8        LC_COLLATE=C.UTF-8    
 [5] LC_MONETARY=C.UTF-8    LC_MESSAGES=C.UTF-8   
 [7] LC_PAPER=C.UTF-8       LC_NAME=C             
 [9] LC_ADDRESS=C           LC_TELEPHONE=C        
[11] LC_MEASUREMENT=C.UTF-8 LC_IDENTIFICATION=C   

attached base packages:
[1] parallel  stats     graphics  grDevices utils     datasets 
[7] methods   base     

other attached packages:
 [1] doMPI_0.2.2       Rmpi_0.6-9.2      doMC_1.3.8       
 [4] doParallel_1.0.17 iterators_1.0.14  foreach_1.5.2    
 [7] RGCCA_2.1.2       msCCA2_1.0        rifle_1.0        
[10] MASS_7.3-57       Rcpp_1.0.13-1     PMA_1.2-4        

loaded via a namespace (and not attached):
 [1] codetools_0.2-18  digest_0.6.37     evaluate_0.15    
 [4] rlang_1.1.4       cli_3.6.3         rstudioapi_0.13  
 [7] rmarkdown_2.28    tools_4.2.0       xfun_0.47        
[10] yaml_2.3.5        fastmap_1.2.0     compiler_4.2.0   
[13] htmltools_0.5.8.1 knitr_1.48  
```



