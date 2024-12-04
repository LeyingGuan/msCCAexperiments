library(PMA)
library(RGCCA)
library(PMA)
library(parallel)
library(rifle)
library(msCCA2)

p = 500; nte = 2000; ncomp = 3; D = 4; ncomp1 = ncomp-1; nfolds = NULL

inputs = commandArgs(trailingOnly = T)
n = as.integer(inputs[1])
s = as.integer(inputs[2])
type = inputs[3]
redundant =  ifelse(inputs[4] == "T", T, F)
iseed = inputs[5]
res_path = "MainSimulations_revision202409/"
data_path = "data/"
multi.core = "sequential"
#multi.core = "doparallel"
#cl <- startMPIcluster(verbose = F, logdir = "log")
#print(cl)
#registerDoMPI(cl)

data_file_name=paste0(data_path,"simulation_data_n", n, "_s",s,"_",type,"_redundant",redundant,"_iseed",iseed, ".rds")
dat = readRDS(file = data_file_name)
res_file_name=paste0(res_path,"pma_n", n, "_s",s,"_",type,"_redundant",redundant,"_iseed",iseed, ".rds")
print(res_file_name)

foldid = dat[[2]]; dat = dat[[1]]
start_times = rep(0,1); end_times = rep(0,1)
if(!is.na(foldid[1])){
  xlist = dat$X; xlist.te = dat$Xte; xagg = dat$X.agg; xagg.te = dat$Xte.agg
  Zsum.truth = dat$Zsum; Zsum.te.truth = dat$Zsum.te
  U.truth = dat$U; rhos.truth = dat$rhos; Sigma =  dat$Sigma
  start_times[1] = Sys.time()
  fitted=PMA_wrapper(xlist,xlist.te,ncomp = ncomp1, nperms = 10)
  end_times[1] = Sys.time()
  print(end_times[1]-start_times[1])
  #clear data to save space
  res = list(fitted = fitted, run_time = end_times-start_times)
  saveRDS( res, file = res_file_name)
}