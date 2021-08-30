#----------------------------
# Workflow example Scenario 1
# (univariate)
#----------------------------

# Install last version of R2BEAT
#devtools::install_github("barcaroli/R2BEAT)
library(R2BEAT)

## -----------------------------------------------------------
## Sampling frame
load("pop.RData")

## -----------------------------------------------------------
# FIRST VARIABLE : income_hh

## Precision constraints
cv <- as.data.frame(list(DOM=c("DOM1"),
                         CV1=c(0.03)))
cv

## -----------------------------------------------------------
## Prepare inputs for allocation
samp_frame <- pop
samp_frame$one <- 1
id_PSU <- "municipality"  
id_SSU <- "id_ind"        
strata_var <- "stratum"   
# target_vars <- c("income_hh","active","inactive","unemployed")   
target_vars <- c("income_hh") 
deff_var <- "stratum"     
domain_var <- "one"  
delta =  1       # households = survey units
minimum <- 50    # minimum number of SSUs to be interviewed in each selected PSU
f = 0.05         # suggestion for the sampling fraction 
deff_sugg <- 1.5 # suggestion for the deff value
 
inp <- prepareInputToAllocation1(samp_frame,
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

# inp$strata$DOM2 <- NULL
## -----------------------------------------------------------
## Allocation
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
#   iterations PSU_SR PSU NSR PSU Total  SSU
# 1          0      0       0         0 1880
# 2          1      5      28        33 2051
# 3          2      6      30        36 2051

## Simulation
allocat <- alloc$alloc[-nrow(alloc$alloc),]
set.seed(1234)
sample_2st <- StratSel(dataPop = inp$psu_file,
                       idpsu = ~ PSU_ID, 
                       dom= ~ STRATUM, 
                       final_pop = ~ PSU_MOS, 
                       size = ~ PSU_MOS, 
                       PSUsamplestratum = 1, 
                       min_sample = minimum, 
                       min_sample_index = FALSE, 
                       dataAll = allocat,
                       domAll = ~ factor(STRATUM), 
                       f_sample = ~ ALLOC, 
                       planned_min_sample = NULL, 
                       launch = F)
selected_PSU <- sample_2st[[4]]
df=pop
df$one <- 1
PSU_code="municipality"
SSU_code="id_ind"
PSU_sampled=selected_PSU[selected_PSU$Sampled_PSU==1,]
target_vars <- c("income_hh")  
PSU_sampled <- selected_PSU[selected_PSU$PSU_final_sample_unit > 0,]
# Domain level = national
domain_var <- "one"
set.seed(1234)
eval <- eval_2stage(df,
                    PSU_code,
                    SSU_code,
                    domain_var,
                    target_vars,
                    PSU_sampled,
                    nsampl=50, 
                    writeFiles=FALSE,
                    progress=TRUE) 
eval$coeff_var
#      CV1  dom
# 1 0.0262 DOM1

## -----------------------------------------------------------
# SECOND VARIABLE : active

## Precision constraints
cv <- as.data.frame(list(DOM=c("DOM1"),
                         CV1=c(0.03)))
cv

## -----------------------------------------------------------
## Prepare inputs for allocation
samp_frame <- pop
samp_frame$one <- 1
id_PSU <- "municipality"  
id_SSU <- "id_ind"        
strata_var <- "stratum"   
# target_vars <- c("income_hh","active","inactive","unemployed")   
target_vars <- c("active") 
deff_var <- "stratum"     
domain_var <- "one"  
delta =  1       # households = survey units
minimum <- 50    # minimum number of SSUs to be interviewed in each selected PSU
f = 0.05         # suggestion for the sampling fraction 
deff_sugg <- 1.5 # suggestion for the deff value

inp <- prepareInputToAllocation1(samp_frame,
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

# inp$strata$DOM2 <- NULL
## -----------------------------------------------------------
## Allocation
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
# iterations PSU_SR PSU NSR PSU Total SSU
# 1          0      0       0         0 549
# 2          1      0      11        11 609
# 3          2      0      12        12 609
## Simulation
allocat <- alloc$alloc[-nrow(alloc$alloc),]
set.seed(1234)
sample_2st <- StratSel(dataPop = inp$psu_file,
                       idpsu = ~ PSU_ID, 
                       dom= ~ STRATUM, 
                       final_pop = ~ PSU_MOS, 
                       size = ~ PSU_MOS, 
                       PSUsamplestratum = 1, 
                       min_sample = minimum, 
                       min_sample_index = FALSE, 
                       dataAll = allocat,
                       domAll = ~ factor(STRATUM), 
                       f_sample = ~ ALLOC, 
                       planned_min_sample = NULL, 
                       launch = F)
selected_PSU <- sample_2st[[4]]
df=pop
df$one <- 1
PSU_code="municipality"
SSU_code="id_ind"
PSU_sampled=selected_PSU[selected_PSU$Sampled_PSU==1,]
target_vars <- c("active")  
PSU_sampled <- selected_PSU[selected_PSU$PSU_final_sample_unit > 0,]
# Domain level = national
domain_var <- "one"
set.seed(1234)
eval <- eval_2stage(df,
                    PSU_code,
                    SSU_code,
                    domain_var,
                    target_vars,
                    PSU_sampled,
                    nsampl=50, 
                    writeFiles=FALSE,
                    progress=TRUE) 
eval$coeff_var
#      CV1  dom
# 1 0.0235 DOM1

## -----------------------------------------------------------
# THIRD VARIABLE : inactive

## Precision constraints
cv <- as.data.frame(list(DOM=c("DOM1"),
                         CV1=c(0.03)))
cv

## -----------------------------------------------------------
## Prepare inputs for allocation
samp_frame <- pop
samp_frame$one <- 1
id_PSU <- "municipality"  
id_SSU <- "id_ind"        
strata_var <- "stratum"   
# target_vars <- c("income_hh","active","inactive","unemployed")   
target_vars <- c("inactive") 
deff_var <- "stratum"     
domain_var <- "one"  
delta =  1       # households = survey units
minimum <- 50    # minimum number of SSUs to be interviewed in each selected PSU
f = 0.05         # suggestion for the sampling fraction 
deff_sugg <- 1.5 # suggestion for the deff value

inp <- prepareInputToAllocation1(samp_frame,
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

# inp$strata$DOM2 <- NULL
## -----------------------------------------------------------
## Allocation
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
# iterations PSU_SR PSU NSR PSU Total  SSU
# 1          0      0       0         0 3990
# 2          1     12      52        64 4406
# 3          2     12      59        71 4406
## Simulation
allocat <- alloc$alloc[-nrow(alloc$alloc),]
set.seed(1234)
sample_2st <- StratSel(dataPop = inp$psu_file,
                       idpsu = ~ PSU_ID, 
                       dom= ~ STRATUM, 
                       final_pop = ~ PSU_MOS, 
                       size = ~ PSU_MOS, 
                       PSUsamplestratum = 1, 
                       min_sample = minimum, 
                       min_sample_index = FALSE, 
                       dataAll = allocat,
                       domAll = ~ factor(STRATUM), 
                       f_sample = ~ ALLOC, 
                       planned_min_sample = NULL, 
                       launch = F)
selected_PSU <- sample_2st[[4]]
df=pop
df$one <- 1
PSU_code="municipality"
SSU_code="id_ind"
PSU_sampled=selected_PSU[selected_PSU$Sampled_PSU==1,]
target_vars <- c("inactive")  
PSU_sampled <- selected_PSU[selected_PSU$PSU_final_sample_unit > 0,]
# Domain level = national
domain_var <- "one"
set.seed(1234)
eval <- eval_2stage(df,
                    PSU_code,
                    SSU_code,
                    domain_var,
                    target_vars,
                    PSU_sampled,
                    nsampl=50, 
                    writeFiles=FALSE,
                    progress=TRUE) 
eval$coeff_var
#      CV1  dom
# 1 0.0249 DOM1
## -----------------------------------------------------------
# FOURTH VARIABLE : unemployed

## Precision constraints
cv <- as.data.frame(list(DOM=c("DOM1"),
                         CV1=c(0.03)))
cv

## -----------------------------------------------------------
## Prepare inputs for allocation
samp_frame <- pop
samp_frame$one <- 1
id_PSU <- "municipality"  
id_SSU <- "id_ind"        
strata_var <- "stratum"   
# target_vars <- c("income_hh","active","inactive","unemployed")   
target_vars <- c("unemployed") 
deff_var <- "stratum"     
domain_var <- "one"  
delta =  1       # households = survey units
minimum <- 50    # minimum number of SSUs to be interviewed in each selected PSU
f = 0.05         # suggestion for the sampling fraction 
deff_sugg <- 1.5 # suggestion for the deff value

inp <- prepareInputToAllocation1(samp_frame,
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

# inp$strata$DOM2 <- NULL
## -----------------------------------------------------------
## Allocation
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
# iterations PSU_SR PSU NSR PSU Total  SSU
# 1          0      0       0         0 5806
# 2          1     19      68        87 6364
# 3          2     23      72        95 6357

## Simulation
allocat <- alloc$alloc[-nrow(alloc$alloc),]
set.seed(1234)
sample_2st <- StratSel(dataPop = inp$psu_file,
                       idpsu = ~ PSU_ID, 
                       dom= ~ STRATUM, 
                       final_pop = ~ PSU_MOS, 
                       size = ~ PSU_MOS, 
                       PSUsamplestratum = 1, 
                       min_sample = minimum, 
                       min_sample_index = FALSE, 
                       dataAll = allocat,
                       domAll = ~ factor(STRATUM), 
                       f_sample = ~ ALLOC, 
                       planned_min_sample = NULL, 
                       launch = F)
selected_PSU <- sample_2st[[4]]
df=pop
df$one <- 1
PSU_code="municipality"
SSU_code="id_ind"
PSU_sampled=selected_PSU[selected_PSU$Sampled_PSU==1,]
target_vars <- c("unemployed")  
PSU_sampled <- selected_PSU[selected_PSU$PSU_final_sample_unit > 0,]
# Domain level = national
domain_var <- "one"
set.seed(1234)
eval <- eval_2stage(df,
                    PSU_code,
                    SSU_code,
                    domain_var,
                    target_vars,
                    PSU_sampled,
                    nsampl=50, 
                    writeFiles=FALSE,
                    progress=TRUE) 
eval$coeff_var
#      CV1  dom
# 1 0.0299 DOM1
