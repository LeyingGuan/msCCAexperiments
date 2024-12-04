library(Rcpp)
library(RGCCA)
library(parallel)
library(doParallel)
library(doMPI)
library(msCCA2)
require(MASS)
require(stats)
require(geigen)
require(pracma)

p = 500; nte = 2000; ncomp = 3; D = 4; ncomp1 = ncomp-1; nfolds = NULL
#inputs = c("300", "1", "identity", "T", "1", "20")
inputs = commandArgs(trailingOnly = T)
n = as.integer(inputs[1])
s = as.integer(inputs[2])
type = inputs[3]
redundant =  ifelse(inputs[4] == "T", T, F)
iseed = inputs[5]
iter_Pinner = as.integer(inputs[6])
res_path = "simulations_revision202409/"
data_path = "data/"
multi.core = "sequential"

data_file_name=paste0(data_path,"simulation_data_n", n, "_s",s,"_",type,"_redundant",redundant,"_iseed",iseed, ".rds")
dat = readRDS(file = data_file_name)
res_file_name=paste0(res_path,"sgcaTGD_n", n, "_s",s,"_",type,"_redundant",redundant,"_iseed",iseed,"_Pinner", iter_Pinner, ".rds")
print(res_file_name)

foldid = dat[[2]]; dat = dat[[1]]

start_times = rep(0,1); end_times = rep(0,1)
if(!is.na(foldid[1])){
  r = 2 # this is for the bug with sparseGCA code, should be fixed
  xlist = dat$X; xlist.te = dat$Xte; xagg = dat$X.agg; xagg.te = dat$Xte.agg
  Zsum.truth = dat$Zsum; Zsum.te.truth = dat$Zsum.te
  U.truth = dat$U; rhos.truth = dat$rhos; Sigma =  dat$Sigma
  start_times[1] = Sys.time()
  fitted=sgcaTGD_wrapper(xlist, xagg, r = ncomp1, foldid = foldid, lambda = 0.1, eta=0.001, 
                         iter_Pinner = iter_Pinner, convergence=1e-3, maxiter=10000, plot = FALSE)
  end_times[1] = Sys.time()
  print(end_times[1]-start_times[1])
  #clear data to save space
  res = list(fitted = fitted, run_time = end_times-start_times)
  saveRDS( res, file = res_file_name)
}
