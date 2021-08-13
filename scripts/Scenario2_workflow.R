#----------------------------
# Workflow example Scenario 2
#----------------------------
# Only a sampling frame containing the units of the population 
# of reference is available, no previous round of the sampling survey 

## -----------------------------------------------------------
library(R2BEAT)
data(pop)


## -----------------------------------------------------------
head(pop)[10:13]


## ----eval=TRUE---------------------------------------------
sensitivity (samp_frame=pop,
             id_PSU="municipality",
             id_SSU="id_ind",
             strata_var="stratum",
             target_vars=c("income_hh","active","inactive","unemployed"),
             deff_var="stratum",
             domain_var="region",
             minimum=50,
             delta=1,
             f=0.05,
             search=c("deff"),
             min=1,
             max=2)


## ----eval=TRUE---------------------------------------------
sensitivity (samp_frame=pop,
             id_PSU="municipality",
             id_SSU="id_ind",
             strata_var="stratum",
             target_vars=c("income_hh","active","inactive","unemployed"),
             deff_var="stratum",
             domain_var="region",
             delta=1,
             f=0.05,
             deff_sugg=1.5,
             search=c("min_SSU"),
             min=30,
             max=80)


## ----eval=TRUE---------------------------------------------
sensitivity (samp_frame=pop,
             id_PSU="municipality",
             id_SSU="id_ind",
             strata_var="stratum",
             target_vars=c("income_hh","active","inactive","unemployed"),
             deff_var="stratum",
             domain_var="region",
             delta=1,
             minimum=50,
             deff_sugg=1.5,
             search=c("sample_fraction"),
             min=0.01,
             max=0.10)


## -----------------------------------------------------------
samp_frame <- pop
#samp_frame$one <- 1
id_PSU <- "municipality"  
id_SSU <- "id_ind"        
strata_var <- "stratum"   
target_vars <- c("income_hh","active","inactive","unemployed")   # more than one
deff_var <- "stratum"     
domain_var <- "region"  
delta =  1     # households = survey units
minimum <- 50  # minimum number of SSUs to be interviewed in each selected PSU
f = 0.05          # suggestion for the sampling fraction 
deff_sugg <- 1.5  # suggestion for the deff value


## -----------------------------------------------------------
inp <- prepareInputToAllocation(samp_frame,
                                id_PSU,
                                id_SSU,
                                strata_var,
                                target_vars,
                                deff_var,
                                domain_var,
                                minimum,
                                delta,
                                f,
                                deff_sugg)


## -----------------------------------------------------------
alloc <- beat.2st(stratif = inp$strata, 
                  errors = cv, 
                  des_file = inp$des_file, 
                  psu_file = inp$psu_file, 
                  rho = inp$rho, 
                  deft_start = NULL, 
                  effst = inp$effst,
                  epsilon1 = 5, 
                  mmdiff_deft = 1,maxi = 15, 
                  epsilon = 10^(-11), 
                  minnumstrat = 2, 
                  maxiter = 200, 
                  maxiter1 = 25)


