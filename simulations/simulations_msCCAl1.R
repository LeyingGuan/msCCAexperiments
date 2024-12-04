library(Rcpp)
library(RGCCA)
library(parallel)
library(doParallel)
library(doMPI)
library(msCCA2)


p = 500; nte = 2000; ncomp = 3; alpha = 0; D = 4; ncomp1 = ncomp-1

inputs = commandArgs(trailingOnly = T)
n = as.integer(inputs[1])
s = as.integer(inputs[2])
type = inputs[3]
redundant =  ifelse((inputs[4] == "T")| (inputs[4] == "TRUE"), T, F)
iseed = inputs[5]
res_path = "MainSimulations_revision202409V2/"
data_path = "data/"
eta = 0.025; eta_ratio = 1/sqrt(n);  s_upper = n/2; eps =1/n;  #V2
#eta = 0.01; eta_ratio = 1/sqrt(n); eps =log(p*D)/n; #V1
maxit = 10000; s_upper = n/4;  print_out = 1000; warm_up = 500; penalty.C=2
multi.core = "sequential"
#multi.core = "doparallel"
#cl <- startMPIcluster(verbose = F, logdir = "log")
#print(cl)
#registerDoMPI(cl)
fitted = list(msCCAl1cv = NULL, msCCAl1pen =NULL)
data_file_name=paste0(data_path,"simulation_data_n", n, "_s",s,"_",type,"_redundant",redundant,"_iseed",iseed, ".rds")
dat = readRDS(file = data_file_name)  
res_file_name=paste0(res_path,"msCCAl1_n", n, "_s",s,"_",type,"_redundant",redundant,"_iseed",iseed, ".rds")
print(res_file_name)
foldid = dat[[2]]; dat = dat[[1]]
start_times = matrix(0, ncol = 2, nrow = 1); end_times = matrix(0, ncol =2, nrow = 1)
colnames(start_times) = colnames(end_times) = c("msCCAcv", "msCCApen")
if(!is.na(foldid[1])){
  xlist = dat$X; xlist.te = dat$Xte; xagg = dat$X.agg; xagg.te = dat$Xte.agg
  Zsum.truth = dat$Zsum; Zsum.te.truth = dat$Zsum.te
  U.truth = dat$U; rhos.truth = dat$rhos; Sigma =  dat$Sigma
  start_times[1,1] = Sys.time()
  fitted[[1]] = msCCAl1func(xlist = xlist, ncomp=2, xlist.te =xlist.te, init_method = "soft-thr", foldid = foldid, penalty.C=penalty.C,
                            l1norm_max =sqrt(s_upper), l1norm_min = sqrt(2), eta = eta, eta_ratio = eta_ratio,  eps =  eps, warm_up = warm_up,
                            rho_maxit = maxit, print_out = print_out, step_selection = "cv", seed = iseed, multi.core = multi.core)
  end_times[1,1] = Sys.time()
  print(fitted[[1]]$errors_track_selected)
  
  start_times[1,2] = Sys.time()
  fitted[[2]] =  msCCAl1func(xlist = xlist, ncomp=2, xlist.te =xlist.te, init_method = "soft-thr", foldid = foldid, penalty.C=penalty.C,
                             l1norm_max =sqrt(s_upper), l1norm_min = sqrt(2), eta = eta, eta_ratio = eta_ratio,  eps =  eps, warm_up = warm_up,
                             rho_maxit = maxit, print_out = print_out, step_selection =  "penalized", seed = iseed, multi.core = multi.core)
  end_times[1,2] = Sys.time()
  print(end_times[1,]-start_times[1,])
  colnames(fitted[[1]]$errors_track_selected) = c("beta_L1norm", "selection_obj", "rho")
  colnames(fitted[[2]]$errors_track_selected) = c("beta_L1norm", "selection_obj", "rho")
  print(fitted[[1]]$errors_track_selected)
  print(fitted[[2]]$errors_track_selected)
  #clear data to save space
  fitted[[1]]$fitted_model$X = NULL;  fitted[[1]]$fitted_model$R = NULL; fitted[[1]]$fitted_model$Xagg = NULL; fitted[[1]]$fitted_model$Ragg = NULL
  fitted[[2]]$fitted_model$X = NULL;  fitted[[2]]$fitted_model$R = NULL; fitted[[2]]$fitted_model$Xagg = NULL; fitted[[2]]$fitted_model$Ragg = NULL
  res = list(fitted = fitted, run_time = end_times-start_times)
  saveRDS( res, file = res_file_name)
}



