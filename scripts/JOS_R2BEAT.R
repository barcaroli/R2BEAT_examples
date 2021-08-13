## ----echo=false---------------------------------------------
options(width=85)


## -----------------------------------------------------------
library(R2BEAT)
load("pop.RData")
head(pop[,c(1:9)])


## -----------------------------------------------------------
load("sample.RData")
head(sample)


## ----results=hide-------------------------------------------
devtools::install_github("DiegoZardetto/ReGenesees")
library(ReGenesees)


## -----------------------------------------------------------
sample.des <- e.svydesign(sample, ids= ~ municipality + id_hh, 
                          strata = ~ stratum, weights = ~ weight,
                          self.rep.str = ~ SR,
                          check.data = TRUE)


## -----------------------------------------------------------
ls <- find.lon.strata(sample.des)
ls


## -----------------------------------------------------------
sample.des <- collapse.strata(sample.des)


## -----------------------------------------------------------
totals <- pop.template(sample.des,
             calmodel = ~ sex : cl_age, 
             partition = ~ region)
totals <- fill.template(pop, totals, mem.frac = 10)


## -----------------------------------------------------------
sample.cal <- e.calibrate(sample.des, 
                          totals,
                          calmodel = ~ sex : cl_age, 
                          partition = ~ region,
                          calfun = "logit",
                          bounds = c(0.3, 2.6), 
                          aggregate.stage = 2,
                          force = FALSE)


## -----------------------------------------------------------
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


## -----------------------------------------------------------
head(inp1$deff)


## -----------------------------------------------------------
head(inp1$effst)


## -----------------------------------------------------------
head(inp1$rho)


## -----------------------------------------------------------
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
head(inp2$des_file)


## -----------------------------------------------------------
cv <- as.data.frame(list(DOM=c("DOM1","DOM2"),
                         CV1=c(0.03,0.04),
                         CV2=c(0.06,0.08),
                         CV3=c(0.06,0.08),
                         CV4=c(0.06,0.08)))
cv


## -----------------------------------------------------------
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
set.seed(1234)
allocat <- alloc$alloc[-nrow(alloc$alloc),]
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


## ----echo=false---------------------------------------------
options(width=90)


## -----------------------------------------------------------
sample_2st[[2]]


## ----echo=false---------------------------------------------
options(width=80)


## ----echo=FALSE,results=hide--------------------------------
des <- sample_2st[[2]]
des2 <- NULL
des2$strata <- c(des$Domain[1:24],des$Domain[1:24])
des2$SR <- c(rep("SR",24),rep("nSR",24))
des2$PSU <- as.numeric(c(des$SRdom[1:24],des$nSRdom[1:24]))
des2$SSU <- as.numeric(c(des$SR_PSU_final_sample_unit[1:24],des$NSR_PSU_final_sample_unit[1:24]))
des2 <- as.data.frame(des2)
des2$strata <- as.numeric(des2$strata)
pdf("allocation.pdf")
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
selected_PSU <- sample_2st[[4]]
selected_PSU <- selected_PSU[selected_PSU$PSU_final_sample_unit > 0,]
write.table(sample_2st[[4]],"Selected_PSUs.csv",sep=";",row.names=F,quote=F)
head(selected_PSU)
samp <- select_SSU(df=pop,
                   PSU_code="municipality",
                   SSU_code="id_ind",
                   PSU_sampled=selected_PSU[selected_PSU$Sampled_PSU==1,],
                   verbose=FALSE)


## -----------------------------------------------------------
nrow(samp)
sum(allocat$ALLOC)


## -----------------------------------------------------------
nrow(pop)
sum(samp$weight)


## ----echo=FALSE,results=hide--------------------------------
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


