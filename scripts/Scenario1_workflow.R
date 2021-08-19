#----------------------------
# Workflow example Scenario 1
#----------------------------
# Only a sampling frame containing the units of the population 
# of reference is available, no previous round of the sampling survey 

library(R2BEAT)

## -----------------------------------------------------------
## Sampling frame
load("./data/pop.RData")

## -----------------------------------------------------------
## Precision constraints
cv <- as.data.frame(list(DOM=c("DOM1","DOM2"),
                         CV1=c(0.02,0.03),
                         CV2=c(0.03,0.06),
                         CV3=c(0.03,0.06),
                         CV4=c(0.03,0.06)))
cv

## -----------------------------------------------------------
## Sensitivity analysis
deff_sens <- sensitivity(samp_frame=pop,
             errors=cv,
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
             max=2,
             plot=TRUE)
png("Plot_deff.png")
plot.sens(deff_sens,search="deff",min=1,max=2)
dev.off()
deff_min <- sensitivity (samp_frame=pop,
             errors=cv,
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
             max=80,
             plot=TRUE)
png("Plot_min_SSU.png")
plot.sens(deff_min,search="min_SSU",min=30,max=80)
dev.off()
deff_sf <- sensitivity (samp_frame=pop,
             errors=cv,
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
             max=0.10,
             plot=TRUE)
png("Plot_sample_fraction.png")
plot.sens(deff_sf,search="sample_fraction",min=0.01,max=0.10)
dev.off()

## -----------------------------------------------------------
## Prepare inputs for allocation

samp_frame <- pop
samp_frame$one <- 1
id_PSU <- "municipality"  
id_SSU <- "id_ind"        
strata_var <- "stratum"   
target_vars <- c("income_hh","active","inactive","unemployed")   
deff_var <- "stratum"     
domain_var <- "region"  
delta =  1       # households = survey units
minimum <- 50    # minimum number of SSUs to be interviewed in each selected PSU
f = 0.05         # suggestion for the sampling fraction 
deff_sugg <- 1.5 # suggestion for the deff value
 
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

## -----------------------------------------------------------
## Selection of PSUs (I stage)
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
sample_2st[[2]]
#    Domain SRdom nSRdom SRdom+nSRdom SR_PSU_final_sample_unit NSR_PSU_final_sample_unit
# 1    1000     2      0            2                      509                         0
# 2    2000     9      2           11                      525                       132
# 3    3000     0      6            6                        0                       312
# 4    4000     0      1            1                        0                        59
# 5    5000     2      0            2                      305                         0
# 6    6000     3      0            3                      143                         0
# 7    7000     0      2            2                        0                        97
# 8    8000     0      2            2                        0                        99
# 9    9000     1      0            1                     1018                         0
# 10  10000     6      0            6                     1073                         0
# 11  11000    21     19           40                     1028                      1055
# 12  12000     0     14           14                        0                       692
# 13  13000     1      0            1                     1285                         0
# 14  14000     4      0            4                     1054                         0
# 15  15000    28     10           38                     1629                       627
# 16  16000     0     34           34                        0                      1705
# 17  17000     1      0            1                      170                         0
# 18  18000     2      2            4                       84                       137
# 19  19000     0      9            9                        0                       462
# 20  20000     0      5            5                        0                       229
# 21  21000     1      0            1                      160                         0
# 22  22000     3      0            3                      137                         0
# 23  23000     0      5            5                        0                       247
# 24  24000     0      1            1                        0                        47
# 25  Total    84    112          196                     9120                      5900
# 26   Mean                                                380                       246

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

png("allocation.png")
par(mfrow=c(2, 1))
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
        xlab = "strata", ylab = "SSUs",
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
sample <- select_SSU(df=pop,
                   PSU_code="municipality",
                   SSU_code="id_ind",
                   PSU_sampled=selected_PSU,
                   verbose=TRUE)
save(sample,file="./data/sample.RData")

## -----------------------------------------------------------
## Plot of weights distribution

png("weights1.png")
par(mfrow=c(1, 2))
boxplot(sample$weight,col="orange")
title("Weights distribution (total sample)",cex.main=0.7)
boxplot(weight ~ region, data=sample,col="orange")
title("Weights distribution by region",cex.main=0.7)
dev.off()
png("weights2.png")
par(mfrow=c(1, 2))
boxplot(weight ~ province, data=sample,col="orange")
title("Weights distribution by province",cex.main=0.7)
boxplot(weight ~ stratum, data=sample,col="orange")
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
# CV1    CV2    CV3    CV4  dom
# 1 0.009 0.0074 0.0213 0.0292 DOM1
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
# CV1    CV2    CV3    CV4  dom
# 1 0.0094 0.0053 0.0174 0.0566 DOM1
# 2 0.0187 0.0158 0.0398 0.0524 DOM2
# 3 0.0228 0.0240 0.0453 0.0355 DOM3
# > cv
# DOM  CV1  CV2  CV3  CV4
# 1 DOM1 0.02 0.03 0.03 0.03
# 2 DOM2 0.03 0.06 0.06 0.06
# eval$rel_bias

save.image(file="scenario1.RData")

