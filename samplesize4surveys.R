library(samplesize4surveys)
help(package="samplesize4surveys")
?ss2s4p
?ss2s4m

load("pop.RData")
PSU <- length(unique(pop$municipality))
pop_strata <- as.numeric(table(pop$stratum))
rho <- read.csv2("rho_scenario1.csv",dec=".")

rho1 <- sum(rho$RHO_NAR1*pop_strata) / sum(pop_strata)
# rho_active <- sum(rho$RHO_NAR2*pop_strata) / sum(pop_strata)
# rho_inactive<- sum(rho$RHO_NAR3*pop_strata) / sum(pop_strata)
# rho_unmployed <- sum(rho$RHO_NAR4pop_strata) / sum(pop_strata)

#------------------
# E = delta : margin of error
# E = CV * z


# First variable (income_hh)
ss2s4m(N = nrow(pop), 
       mu = mean(pop$income_hh), 
       sigma = sd(pop$income_hh),
       # conf = 0.95,
       delta = 0.03 * 1.96, 
       M = PSU, 
       to = 50, 
       rho = rho1)
# 50 1.112746  47 50 2324

# Second variable (active)
ss2s4p(N = nrow(pop), 
       P = as.numeric(table(pop$active))[2]/nrow(pop), 
       # conf = 0.95, 
       delta = 0.03 * 1.96, 
       M = PSU, 
       to = 50, 
       rho = 0.003)
# 50 1.147  14 50 663

# Third variable (inactive)
ss2s4p(N = nrow(pop), 
       P = as.numeric(table(pop$inactive))[2]/nrow(pop), 
       # conf = 0.95, 
       delta = 0.03 * 1.96, 
       M = PSU, 
       to = 50, 
       rho = 0.003)
# 50 1.147  92 50 4570

# Fourth variable (unemployed)
ss2s4p(N = nrow(pop), 
       P = as.numeric(table(pop$unemployed))[2]/nrow(pop), 
       # conf = 0.95, 
       delta = 0.03 * 1.96, 
       M = PSU, 
       to = 50, 
       rho = 0.003)
# 50 1.147 179 50 8929

