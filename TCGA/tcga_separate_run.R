#install.packages("PMA")
#BiocManager::install("omicade4")
##write some wrappers for tcga example
#library(devtools)
#require(devtools)
#.libPaths()
#find.package("RGCCA")
#packageVersion("RGCCA")
#install_version("RGCCA", version = "2.1.2", repos = "http://cran.us.r-project.org")
#install_github("LeyingGuan/msCCA")

library(PMA)
library(Rcpp)
library(rifle)
library(parallel)
library(msCCA2)
library(RGCCA)
#packageVersion("RGCCA")
library(parallel)
library(doParallel)
library(doMC)
library(doMPI)
#.libPaths("/gpfs/gibbs/project/guan_leying/lg689/R/4.2")

Rho_func = function(xlist,directions_agg=NULL,directions_list=NULL){
  D = length(xlist)
  n = nrow(xlist[[1]])
  if(is.null(directions_list) | length(directions_list) != D){
    directions_list = list()
    ps = sapply(xlist, ncol)
    pss = c(0,cumsum(ps))
    for(d in 1:D){
      directions_list[[d]] =directions_agg[(pss[d]+1):pss[d+1],,drop = F] 
    }
  }
  ncomp = ncol(directions_list[[1]])
  Z = array(0, dim = c(n, D, ncomp))
  denominators = rep(0, ncomp)
  rhos = rep(0, ncomp)
  Zsum = array(0, dim = c(n, ncomp))
  Zs.agg = array(0, dim = c(n * D, ncomp))
  ps = sapply(xlist, function(z) dim(z)[2])
  pss = c(0, cumsum(ps))
  for (d in 1:length(directions_list)) {
    Z[, d, ] = xlist[[d]] %*% directions_list[[d]]
    ll = (n * (d - 1) + 1):(n * d)
    Zs.agg[ll, ] = Z[, d, ]
  }
  if (ncomp > 1) {
    for (k in 1:(ncomp - 1)) {
      for (k1 in (k + 1):ncomp) {
        Zs.agg[, k1] = lm(Zs.agg[, k1] ~ Zs.agg[, k])$residuals
      }
    }
  }
  for (d in 1:length(directions_list)) {
    ll = (n * (d - 1) + 1):(n * d)
    Z[, d, ] = Zs.agg[ll, ]
  }
  Zsum = apply(Z, c(1, 3), sum)
  a = apply(apply(Z, c(2,3), var),2,sum)
  b = apply(Zsum, 2, var)
  rho = b/a
  return(rho)
}

# sgcca = function(A, C, c1, ncomp, scheme, verbose = F){
#   if(is.null(C)){
#     C = 1 - diag(length(A))
#   }
#   out = rgcca(blocks=A,
#               connection = C,tau = 1,ncomp = ncomp,scheme = scheme,
#               verbose = verbose,scale_block = "inertia",
#               method = "sgcca",sparsity = c1)
#   return(out)
# }
#source("/home/lg689/project/msCCA/algorithm/msCCAfull.R")
#source("/home/lg689/project/msCCA/algorithm/helpers.R")
load("TCGA.normalised.mixDIABLO.RData")
n.core = strtoi(Sys.getenv("SLURM_CPUS_PER_TASK",unset=1))
print(n.core)
lapply(data.train, dim)
lapply(data.test, dim)
xlist1 = data.train[2:4]
xlist2 = data.test[2:4]
yall = c(data.train$subtype, data.test$subtype)
for(d in 1:length(xlist1)){
  xlist1[[d]] = rbind(scale(xlist1[[d]]), scale(xlist2[[d]]))
  xlist1[[d]] = scale(xlist1[[d]])
}
###add noise matrix
inputs = commandArgs(trailingOnly = T)
if(inputs[length(inputs)] != "doparallel"){
  #do mpirun do not keep the args but Rscript does
  inputs = inputs[-1] 
}
print(inputs)
#inputs=c(1, "sgcca", "single")
iseed = as.integer(inputs[1])
method = inputs[2]
multi.core = inputs[3]
print(inputs)
random_seed = 2024+iseed
set.seed(random_seed)
fake_ids1 = sample( 1:nrow(xlist1[[1]]), nrow(xlist1[[1]]))
fake_ids2= sample( 1:nrow(xlist1[[1]]), nrow(xlist1[[1]]))
xlist1[[4]] = xlist1[[1]][fake_ids1,]
xlist1[[5]] = xlist1[[2]][fake_ids2,]
###part I analysis
foldidIA = sample(1:length(yall), ceiling(length(yall)/2))
foldidIB = setdiff(1:length(yall), foldidIA)
xlistA = list()
xlistB = list()
ptotal = 0
for(d in 1:length(xlist1)){
  xlistA[[d]] = scale(xlist1[[d]][foldidIA,])
  xlistB[[d]] = scale(xlist1[[d]][foldidIB,])
  ptotal = ptotal + ncol(xlistA[[1]])
}

ncomp = 10
date = Sys.Date()
nfolds = 10
verbose = F
if(multi.core=="doparallel"){
    cl <- startMPIcluster(verbose = F, logdir = "log")
    print(cl)
    registerDoMPI(cl)
}
if(iseed == 0){
  #run full data
  xlist.tr = xlist1
  xlist.te = NULL
  n = length(yall)
}else{
  #model training nd the training fold
  xlist.tr = xlistA
  xlist.te = xlistB
  n = length(foldidIA)
}
D = length(xlist1)
fitted = list()

set.seed(2022)
foldid = sample(rep(1:nfolds, each = ceiling(n/nfolds)), n)
eta = 0.01; eta_ratio = 1/sqrt(nrow(xlist1[[1]])); maxit = 10000; s_upper = n/2; eps =log(ptotal)/n;  seed = 2022; warm_up = 500; 
print_out = 500; penalty.C=2; iter_Pinner=20
norm_varying_ridge = T
start_time =  Sys.time()
if(method=="msCCA1cv"){
  fitted = msCCAl1func(xlist =  xlist.tr, ncomp=ncomp, xlist.te =xlist.te, init_method = "soft-thr", foldid = foldid, penalty.C=penalty.C,
                            l1norm_max =sqrt(s_upper), l1norm_min = sqrt(2), eta = eta, eta_ratio = eta_ratio,  eps =  eps, warm_up = warm_up,
                            rho_maxit = maxit, print_out = print_out, step_selection = "cv", seed = iseed, multi.core = multi.core)
}else if(method == "msCCA1pen"){
  fitted =  msCCAl1func(xlist = xlist.tr, ncomp=ncomp, xlist.te =xlist.te, init_method = "soft-thr", foldid = foldid, penalty.C=penalty.C,
                             l1norm_max =sqrt(s_upper), l1norm_min = sqrt(2), eta = eta, eta_ratio = eta_ratio,  eps =  eps, warm_up = warm_up,
                             rho_maxit = maxit, print_out = print_out, step_selection =  "penalized", seed = iseed, multi.core = multi.core)
  
  
}else if(method=="rifle"){
  fitted$fitted_model  = riffle_sequential(xlist = xlist.tr, ncomp = ncomp, xlist.te = xlist.te, foldid = foldid, maxiter =maxit, eta = eta,
                                                  ss = unique(floor(exp(seq(log(2), log(s_upper), length.out = 20)))),  n.core = NULL, seed = seed, multi.core = multi.core)
  
  fitted$errors_track_selected = fitted$fitted_model$errors_track
  fitted$fitted_model$prev_directions_agg = fitted$fitted_model$betas
}else if(method=="pma"){
  fitted =  PMA_wrapper(xlist.tr,xlist.te,ncomp = ncomp, nperms = 10)
  fitted$fitted_model$prev_directions_agg =fitted$fitted_model$prev_directions[[1]]
  for(d in 2:D){
    fitted$fitted_model$prev_directions_agg = rbind(fitted$fitted_model$prev_directions_agg,fitted$fitted_model$prev_directions[[d]])
  }
  fitted$errors_track_selected = matrix(NA, ncol  = 3, nrow = ncomp)
  if(!is.null(  xlist.te)){
    fitted$errors_track_selected[,3] = fitted$deflated_Zs$rho.te
  }
}else if(method == "sgcca"){
  fitted = sgcca_wrapper(xlist.tr, xlist.te, ncomp = ncomp, foldid = foldid)
  fitted$fitted_model$prev_directions_agg =fitted$fitted_model$prev_directions[[1]]
  for(d in 2:D){
    fitted$fitted_model$prev_directions_agg = rbind(fitted$fitted_model$prev_directions_agg,fitted$fitted_model$prev_directions[[d]])
  }
  fitted$errors_track_selected = matrix(NA, ncol  = 3, nrow = ncomp)
  if(!is.null(  xlist.te)){
    fitted$errors_track_selected[,3] = fitted$deflated_Zs$rho.te
  }
}else if(method == "rgcca"){
  fitted = rgcca_wrapper(xlist.tr, xlist.te,ncomp = ncomp)
  fitted$fitted_model$prev_directions_agg =fitted$fitted_model$prev_directions[[1]]
  for(d in 2:D){
    fitted$fitted_model$prev_directions_agg = rbind(fitted$fitted_model$prev_directions_agg,fitted$fitted_model$prev_directions[[d]])
  }
  fitted$errors_track_selected = matrix(NA, ncol  = 3, nrow = ncomp)
  if(!is.null(  xlist.te)){
    fitted$errors_track_selected[,3] = fitted$deflated_Zs$rho.te
  }
  
}else if (method == "SGCTGD"){
  xagg = xlist.tr[[1]]
  for(d in 2:length(xlist.tr)){
    xagg = cbind(xagg, xlist.tr[[d]])
  }
  fitted=sgcaTGD_wrapper(xlist = xlist.tr, xag=xagg, r = ncomp, foldid = foldid, lambda = 0.1, eta=0.001, 
                         iter_Pinner = iter_Pinner, convergence=1e-3, maxiter=10000, plot = FALSE)
}else{
  stop("unknown method.")
}
end_time=  Sys.time()
fitted$run_time = end_time-start_time
file_name = paste0("outputs/",method,"_tcga_DR_",date,"_iseed", iseed,".rds")
print(fitted$run_time)
print("rhos ")

if(!is.null(xlist.te)){
  dat = list(Xte = xlist.te)
  if(method %in% c("msCCA1cv", "msCCA1pen")){
    fitted$test_rhos_deflated = Rho_func(xlist=xlist.te,directions_list=fitted$fitted_model$prev_directions)
  }else{
    fitted$test_rhos_deflated=Rho_func(xlist=xlist.te,directions_list=fitted$fitted_model$prev_directions,
                         directions_agg =fitted$fitted_model$prev_directions_agg)
    
  }
}
print(fitted$errors_track_selected)
print(fitted$test_rhos_deflated)
saveRDS(fitted, file = file_name)

if(multi.core=="doparallel"){
 closeCluster(cl)
 mpi.quit()
}


sessionInfo()



