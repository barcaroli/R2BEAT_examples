#----------------------------
# Workflow example Scenario 2
#----------------------------
# Together with a sampling frame containing the units of the population 
# of reference, also a previous round of the sampling survey to be 
# planned is available

library(R2BEAT)

## -----------------------------------------------------------
## Sampling frame
load("./data/pop.RData")

# -----------------------------------------------------------
## Sample data
load("./data/sample.RData")

## -----------------------------------------------------------
## Precision constraints
cv <- as.data.frame(list(DOM=c("DOM1","DOM2"),
                         CV1=c(0.02,0.03),
                         CV2=c(0.03,0.06),
                         CV3=c(0.03,0.06),
                         CV4=c(0.03,0.06)))
cv

## -----------------------------------------------------------
## Analysis of sampled data

#devtools::install_github("DiegoZardetto/ReGenesees")
library(ReGenesees)

## -----------------------------------------------------------
## Sample design description
sample$stratum_2 <- as.factor(sample$stratum_2)
sample.des <- e.svydesign(sample, 
                          ids= ~ municipality + id_hh, 
                          strata = ~ stratum_2, 
                          weights = ~ weight,
                          self.rep.str = ~ SR,
                          check.data = TRUE)
## -----------------------------------------------------------
## Find and collapse lonely strata
ls <- find.lon.strata(sample.des)
ls
sample.des <- collapse.strata(sample.des)

## -----------------------------------------------------------
## Calibration with known totals
totals <- pop.template(sample.des,
             calmodel = ~ sex : cl_age, 
             partition = ~ region)
totals <- fill.template(pop, totals, mem.frac = 10)
sample.cal <- e.calibrate(sample.des, 
                          totals,
                          calmodel = ~ sex : cl_age, 
                          partition = ~ region,
                          calfun = "logit",
                          bounds = c(0.3, 2.6), 
                          aggregate.stage = 2,
                          force = FALSE)

## -----------------------------------------------------------
## Preparation of inputs for allocation steps
## subset 1: strata, deff, effst, rho

RGdes <- sample.des
RGcal <- sample.cal
strata_vars <- c("stratum")      
target_vars <- c("income_hh",
                 "active",
                 "inactive",
                 "unemployed")   
weight_var <- "weight"
deff_vars <- "stratum"            
id_PSU <- c("municipality")      
id_SSU <- c("id_hh")             
domain_vars <- c("region")       
inp1 <- input_to_beat.2st_1(
        RGdes,       # ReGenesees design object
        RGcal,       # ReGenesees calibrated object
        id_PSU,      # identification variable of PSUs
        id_SSU,      # identification variable of SSUs
        strata_vars, # strata variables
        target_vars, # target variables
        deff_vars,   # deff variables
        domain_vars  # domain variables
      )
## -----------------------------------------------------------
head(inp1$strata)
# stratum STRATUM      N       M1        M2        M3         M4       S1
# 1    1000    1000 196769 23339.70 0.6801679 0.2127596 0.10707247 16543.72
# 2   10000   10000 106057 29340.38 0.7793318 0.2047430 0.01592524 25031.44
# 3   11000   11000 205839 27822.70 0.7814228 0.2029522 0.01562493 26050.40
# 4   12000   12000  57606 23110.90 0.7632522 0.2079530 0.02879485 15405.51
# 5   13000   13000 102801 28185.38 0.7516670 0.2142238 0.03410920 24393.71
# 6   14000   14000  84077 24787.12 0.7537232 0.2131530 0.03312385 17403.58
# S2        S3        S4 COST CENS DOM1   DOM2
# 1 0.4664113 0.4092590 0.3092054    1    0    1 center
# 2 0.4146972 0.4035137 0.1251864    1    0    1  north
# 3 0.4132810 0.4021972 0.1240193    1    0    1  north
# 4 0.4250862 0.4058430 0.1672295    1    0    1  north
# 5 0.4320460 0.4102828 0.1815097    1    0    1  north
# 6 0.4308417 0.4095348 0.1789599    1    0    1  north

## -----------------------------------------------------------
head(inp1$deff)
# stratum STRATUM    DEFF1    DEFF2    DEFF3    DEFF4      b_nar
# 1    1000    1000 1.002141 1.003487 1.018508 0.998091  254.50000
# 2   10000   10000 1.019820 1.029362 1.010320 1.000982  178.83333
# 3   11000   11000 1.128662 1.036882 1.002039 1.115932   52.07500
# 4   12000   12000 3.233942 0.978419 1.202842 0.639357   49.42857
# 5   13000   13000 1.063373 1.056811 1.015756 1.048938 1285.00000
# 6   14000   14000 1.018801 1.003173 1.002272 1.013573  263.50000

## -----------------------------------------------------------
head(inp1$effst)
# stratum STRATUM    EFFST1    EFFST2    EFFST3    EFFST4
# 1    1000    1000 0.9875397 0.8647755 0.7565498 1.0033213
# 2   10000   10000 0.9948599 0.9076545 0.8982699 1.0054137
# 3   11000   11000 0.9765404 0.8136085 0.7835224 0.9925166
# 4   12000   12000 1.0145565 0.9113590 0.9126909 1.0007101
# 5   13000   13000 1.0045911 0.9263170 0.9180502 0.9942647
# 6   14000   14000 1.0016745 0.9471318 0.9375788 0.9967146

## -----------------------------------------------------------
head(inp1$rho)
# STRATUM RHO_AR1       RHO_NAR1 RHO_AR2       RHO_NAR2 RHO_AR3       RHO_NAR3 RHO_AR4
# 1    1000       1 0.000008445759       1  0.00001375542       1 0.000073009862       1
# 2   10000       1 0.000111452671       1  0.00016510965       1 0.000058031865       1
# 3   11000       1 0.002519079785       1  0.00072211454       1 0.000039921684       1
# 4   12000       1 0.046128595870       1 -0.00044562537       1 0.004188477876       1
# 5   13000       1 0.000049355919       1  0.00004424533       1 0.000012271028       1
# 6   14000       1 0.000071622857       1  0.00001208762       1 0.000008655238       1
# RHO_NAR4
# 1 -0.000007530572
# 2  0.000005522024
# 3  0.002269838473
# 4 -0.007446905605
# 5  0.000038113707
# 6  0.000051706667

## -----------------------------------------------------------
## Preparation of inputs for allocation steps
## subset 2: psu_file, des_file

pop$one <- 1
psu <- aggregate(one~municipality+stratum,data=pop,FUN=sum)
psu_id="municipality"        
stratum_var="stratum"         
mos_var="one"                
delta=1                       
minimum <- 50                 
inp2 <- input_to_beat.2st_2(psu,
          psu_id,      # Identifier of the PSU
          stratum_var, # stratum variables
          mos_var,     # Variable to be used as 'measure of size'
          delta,       # Average number of SSUs for each selection unit
          minimum)     # Minimum number of SSUs to be selected in each PSU

head(inp2$psu_file)
# PSU_ID STRATUM PSU_MOS
# 1    309    1000   50845
# 2    330    1000  146162
# 3    292    2000   24794
# 4    293    2000   19609
# 5    300    2000   13897
# 6    304    2000   36195

head(inp2$des_file)
# STRATUM STRAT_MOS DELTA MINIMUM
# 1    1000    197007     1      50
# 2    2000    261456     1      50
# 3    3000    115813     1      50
# 4    4000     17241     1      50
# 5    5000    101067     1      50
# 6    6000     47218     1      50

## -----------------------------------------------------------
## Allocation
alloc <- beat.2st(stratif = inp1$strata, 
                  errors = cv, 
                  des_file = inp2$des_file, 
                  psu_file = inp2$psu_file, 
                  rho = inp1$rho, 
                  deft_start = NULL, 
                  effst = inp1$effst,
                  epsilon1 = 5, 
                  mmdiff_deft = 1,maxi = 15, 
                  epsilon = 10^(-11), 
                  minnumstrat = 2, 
                  maxiter = 200, 
                  maxiter1 = 25)

## -----------------------------------------------------------
## Selection of PSUs (I stage)

allocat <- alloc$alloc[-nrow(alloc$alloc),]
set.seed(1234)
sample_2st <- StratSel(dataPop= inp2$psu_file,
                       idpsu= ~ PSU_ID, 
                       dom= ~ STRATUM, 
                       final_pop= ~ PSU_MOS, 
                       size= ~ PSU_MOS, 
                       PSUsamplestratum= 1, 
                       min_sample= minimum, 
                       min_sample_index= FALSE, 
                       dataAll=allocat,
                       domAll= ~ factor(STRATUM), 
                       f_sample= ~ ALLOC, 
                       planned_min_sample= NULL, 
                       launch= F)
sample_2st[[2]]
#    Domain SRdom nSRdom SRdom+nSRdom SR_PSU_final_sample_unit NSR_PSU_final_sample_unit
# 1    1000     2      0            2                      423                         0
# 2    2000     5      4            9                      288                       235
# 3    3000     0      5            5                        0                       247
# 4    4000     0      1            1                        0                         2
# 5    5000     2      0            2                      281                         0
# 6    6000     1      1            2                       43                        66
# 7    7000     0      1            1                        0                        56
# 8    8000     0      1            1                        0                        35
# 9    9000     1      0            1                      911                         0
# 10  10000     6      0            6                      936                         0
# 11  11000    16     20           36                      761                      1091
# 12  12000     0     11           11                        0                       537
# 13  13000     1      0            1                     1298                         0
# 14  14000     4      0            4                     1049                         0
# 15  15000    28     10           38                     1629                       627
# 16  16000     0     27           27                        0                      1333
# 17  17000     1      0            1                      141                         0
# 18  18000     0      3            3                        0                       134
# 19  19000     0      6            6                        0                       320
# 20  20000     0      3            3                        0                       166
# 21  21000     1      0            1                      130                         0
# 22  22000     1      1            2                       41                        68
# 23  23000     0      3            3                        0                       165
# 24  24000     0      1            1                        0                         2
# 25  Total    69     98          167                     7931                      5084
# 26   Mean                                                330                       212

## -----------------------------------------------------------
## Plot of allocation (PSUs and SSUs)

des <- sample_2st[[2]]
des2 <- NULL
des2$strata <- c(des$Domain[1:24],des$Domain[1:24])
des2$SR <- c(rep("SR",24),rep("nSR",24))
des2$PSU <- as.numeric(c(des$SRdom[1:24],des$nSRdom[1:24]))
des2$SSU <- as.numeric(c(des$SR_PSU_final_sample_unit[1:24],des$NSR_PSU_final_sample_unit[1:24]))
des2 <- as.data.frame(des2)
des2$strata <- as.numeric(des2$strata)
par(mfrow=c(2, 1))
pdf("allocation.pdf")
barplot(PSU~SR+strata, data=des2,
        main = "PSUs by strata",
        xlab = "strata", ylab = "PSUs",
        col = c("red", "grey"),
        # beside = TRUE,
        las=2,
        cex.names=0.7)
legend("topright", 
       legend = c("Non Self Representative","Self Representative"),cex = 0.7,
       fill = c("red", "grey"))
barplot(SSU~SR+strata, data=des2,
        main = "SSUs by strata",
        xlab = "strata", ylab = "PSUs",
        col = c("red", "grey"),
        # beside = TRUE,
        las=2,
        cex.names=0.7)
legend("topright", 
       legend = c("Non Self Representative","Self Representative"),cex = 0.7,
       fill = c("red", "grey"))
dev.off()


## -----------------------------------------------------------
## Selection of SSUs (II stage)

selected_PSU <- sample_2st[[4]]
selected_PSU <- selected_PSU[selected_PSU$PSU_final_sample_unit > 0,]
write.table(sample_2st[[4]],"Selected_PSUs.csv",sep=";",row.names=F,quote=F)
head(selected_PSU)
set.seed(1234)
samp <- select_SSU(df=pop,
                   PSU_code="municipality",
                   SSU_code="id_ind",
                   PSU_sampled=selected_PSU[selected_PSU$Sampled_PSU==1,],
                   verbose=TRUE)

nrow(samp)
sum(allocat$ALLOC)

nrow(pop)
sum(samp$weight)


## -----------------------------------------------------------
## Plot of weights distribution

pdf ("weights1.pdf", height = 5, width = 7)
par(mfrow=c(1, 2))
boxplot(samp$weight,col="orange")
title("Weights distribution (total sample)",cex.main=0.7)
boxplot(weight ~ region, data=samp,col="orange")
title("Weights distribution by region",cex.main=0.7)
dev.off()
pdf ("weights2.pdf", height = 5, width = 7)
par(mfrow=c(1, 2))
boxplot(weight ~ province, data=samp,col="orange")
title("Weights distribution by province",cex.main=0.7)
boxplot(weight ~ stratum, data=samp,col="orange")
title("Weights distribution by stratum",cex.main=0.7)
dev.off()

## -----------------------------------------------------------
## Precision constraints compliance control (by simulation)

selected_PSU <- sample_2st[[4]]
df=pop
df$one <- 1
PSU_code="municipality"
SSU_code="id_ind"
PSU_sampled=selected_PSU[selected_PSU$Sampled_PSU==1,]
target_vars <- c("income_hh",
                 "active",
                 "inactive",
                 "unemployed")  
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
                    nsampl=100, 
                    writeFiles=TRUE,
                    progress=TRUE) 
eval$coeff_var
#      CV1    CV2    CV3    CV4  dom
# 1 0.0093 0.0095 0.0248 0.0381 DOM1

# Domain level = regional
domain_var <- "region"
set.seed(1234)
eval <- eval_2stage(df,
                    PSU_code,
                    SSU_code,
                    domain_var,
                    target_vars,
                    PSU_sampled,
                    nsampl=100, 
                    writeFiles=TRUE,
                    progress=TRUE) 
eval$coeff_var
#      CV1    CV2    CV3    CV4  dom
# 1 0.0078 0.0048 0.0160 0.0640 DOM1
# 2 0.0209 0.0205 0.0496 0.0805 DOM2
# 3 0.0262 0.0356 0.0599 0.0471 DOM3

save.image(file="scenario2.RData")


