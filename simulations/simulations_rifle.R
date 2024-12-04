library(Rcpp)
library(RGCCA)
library(parallel)
library(doParallel)
library(doMPI)
library(msCCA2)
library(rifle)


p = 500; nte = 2000; ncomp = 3; D = 4; ncomp1 = ncomp-1; 

inputs = commandArgs(trailingOnly = T)
n = as.integer(inputs[1])
s = as.integer(inputs[2])
type = inputs[3]
redundant =  ifelse(inputs[4] == "T", T, F)
iseed = inputs[5]
res_path = "MainSimulations_revision202409/"
data_path = "data/"
multi.core = "sequential"
alpha = 3; maxit = 10000; 
data_file_name=paste0(data_path,"simulation_data_n", n, "_s",s,"_",type,"_redundant",redundant,"_iseed",iseed, ".rds")
dat = readRDS(file = data_file_name)
res_file_name=paste0(res_path,"rifle_n", n, "_s",s,"_",type,"_redundant",redundant,"_iseed",iseed, ".rds")
print(res_file_name)
foldid = dat[[2]]; dat = dat[[1]]
start_times = rep(0,1); end_times = rep(0,1)
fitted = list()
if(!is.na(foldid[1])){
  xlist = dat$X; xlist.te = dat$Xte; xagg = dat$X.agg; xagg.te = dat$Xte.agg
  Zsum.truth = dat$Zsum; Zsum.te.truth = dat$Zsum.te
  U.truth = dat$U; rhos.truth = dat$rhos; Sigma =  dat$Sigma
  start_times[1] = Sys.time()
  fitted$fitted_model=riffle_sequential(xlist = xlist, ncomp = ncomp1, xlist.te = xlist.te, foldid = foldid, maxiter =maxit, eta = eta,
                                        ss = floor(seq(2^(1/alpha), s_upper^(1/alpha), length.out = 20)^alpha),  n.core = NULL, seed = iseed, multi.core = multi.core)
  fitted$errors_track_selected = fitted$fitted_model$errors_track
  fitted$fitted_model$prev_directions_agg = fitted$fitted_model$betas
  end_times[1] = Sys.time()
  print(end_times[1]-start_times[1])
  #clear data to save space
  res = list(fitted = fitted, run_time = end_times-start_times)
  saveRDS( res, file = res_file_name)
}
