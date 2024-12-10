#!/bin/bash
method_names=("msCCA1cv" "rifle" "SGCTGD")
for iseed in {0..51}; do
    for method_name in ${method_names[@]}; do
        FILE="DR${method_name}_jobs.txt"
        echo "module purge;module load OpenMPI/4.0.5-GCC-10.2.0;module load R/4.2.0-foss-2020b; export R_LIBS=\"/gpfs/gibbs/project/guan_leying/lg689/R/4.2\"; mpirun -np 11 --map-by node R --slave -f tcga_separate_run.R  --args ${iseed} ${method_name} doparallel">> $FILE
    done 
done


method_names=("msCCA1pen" "rgcca" "pma" "sgcca")
for iseed in {0..51}; do
    for method_name in ${method_names[@]}; do
        FILE="DR${method_name}_jobs.txt"
        echo "module load R/4.2.0-foss-2020b; export R_LIBS=\"/gpfs/gibbs/project/guan_leying/lg689/R/4.2\"; Rscript tcga_separate_run.R  --args ${iseed} ${method_name} singleprocess" >> $FILE
    done
done
