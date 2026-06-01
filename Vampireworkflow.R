# Define the list of required packages
packages <- c("tidyverse", "readxl", "sandwich", "tseries", "lubridate", "stargazer", "lmtest")

# Install missing packages
install.packages(setdiff(packages, installed.packages()[,"Package"]))
library(tidyverse)
library(readxl)
library(sandwich)#For Robust SE#
library(tseries)#For Time series objects#
library(lubridate)#For working with dates#
library(stargazer)#For fancy tables#
library(lmtest)#For formal tests with robust SE and time series tests#
#UNADJUSTED#
Vampires <- read_csv("time_series_GB_20040101-0000_20260502-2142.csv")
#Note that British Royal Family topic series is also here but largely to instrument divorces later, because its relative search interest it has an affect on the scale of both vampire and divorce#
plot(Vampires)#Do A Facet of scatter plots#
plot.ts(Vampires)#Do a facet of time series
acf(Vampires[,-1])#Plot autocorelations#
pacf(Vampires[,-1])#Plot  partial autocorelations, to check how many lags we might need 4 lags #
grangervamp <- lm(Divorce~lag(Vampire)+lag(Divorce),data = Vampires) # basic model# 
#Plot residual time series to eyeball stationarity#
plot.ts(resid(grangervamp))
#Check if we missed any lags#
acf(resid(grangervamp))
pacf(resid(grangervamp))
#Add more lags given results#
grangervamp <- lm(Divorce~lag(Vampire)+lag(Divorce)+lag(Vampire,2)+lag(Divorce,2),data = Vampires)
grangervamp <- lm(Divorce~lag(Vampire)+lag(Divorce)+lag(Vampire,2)+lag(Divorce,2),data = Vampires)
plot.ts(resid(grangervamp))
acf(resid(grangervamp))
pacf(resid(grangervamp))
#Add more lags if still correlated#
grangervamp <- lm(Divorce~lag(Vampire)+lag(Divorce)+lag(Vampire,2)+lag(Divorce,2)+lag(Vampire,3)+lag(Divorce,3),data = Vampires)
plot.ts(resid(grangervamp))
acf(resid(grangervamp))
pacf(resid(grangervamp))
#Add more lags as still correlated#
grangervamp <- lm(Divorce~lag(Vampire)+lag(Divorce)+lag(Vampire,2)+lag(Divorce,2)+lag(Vampire,3)+lag(Divorce,3)+lag(Vampire,4)+lag(Divorce,4),data = Vampires)
plot.ts(resid(grangervamp))
acf(resid(grangervamp))
pacf(resid(grangervamp))
bgtest(grangervamp,order = 12)#Optional Breush Godfrey LR(where null model is no residual autocorrelation up to the 12 month) to check if we have enough lags
#Residuals now seem mostly uncorrelated and stationary therefore stick with order 4#
grangervamp <- lm(Divorce~lag(Vampire)+lag(Divorce)+lag(Vampire,2)+lag(Divorce,2)+lag(Vampire,3)+lag(Divorce,3)+lag(Vampire,4)+lag(Divorce,4),data = Vampires)
grangervampnull <- lm(Divorce~lag(Divorce)+lag(Divorce,2)+lag(Divorce,3)+lag(Divorce,4),data = Vampires)
stargazer(grangervampnull,grangervamp,se=list(vcovHAC(grangervampnull),vcovHAC(grangervamp)),type="text")
waldtest(grangervampnull,grangervamp,vcov=vcovHAC)#HAC Robust LR(Wald) test where null is that vampire series doesn't help predict divorce series up to 4th lag#
adf.test(resid(grangervamp))#Formal sanity test for unit root,rejection implies stationary residuals# 
#Alternative Use F test(LR) and BIC if not using Heteroskadasticity and AutoCorrelation adjustment in errors(Risky)#
anova(grangervampnull,grangervamp)
BIC(grangervampnull,grangervamp)
#Adjusted#
vamp_ts <- ts(Vampires$Vampire, frequency = 12)#Prepare both series for seasonal decomposition#
divo_ts <- ts(Vampires$Divorce, frequency = 12)
vamp_stl <- stl(vamp_ts, s.window = "periodic")#use stl and plot results#
divo_stl <- stl(divo_ts, s.window = "periodic")
vamp_adj <- vamp_ts - vamp_stl$time.series[, "seasonal"]#subtract seasonal components from original series#
divo_adj <- divo_ts - divo_stl$time.series[, "seasonal"]
plot(vamp_stl, main = "Vampire Search Decomposition")
plot(divo_stl, main = "Divorce Search Decomposition")
adjusted_data <- data.frame(
  Vampire = as.numeric(vamp_adj),
  Divorce= as.numeric(divo_adj))
plot.ts(adjusted_data)
#Rerun the analysis, Should show the two series as unpredictive of each other#
grangervamp <- lm(Divorce~lag(Vampire)+lag(Divorce)+lag(Vampire,2)+lag(Divorce,2)+lag(Vampire,3)+lag(Divorce,3)+lag(Vampire,4)+lag(Divorce,4),data =adjusted_data)
grangervampnull <- lm(Divorce~lag(Divorce)+lag(Divorce,2)+lag(Divorce,3)+lag(Divorce,4),data = adjusted_data)
stargazer(grangervampnull,grangervamp,se=list(vcovHAC(grangervampnull),vcovHAC(grangervamp)),type="text")
waldtest(grangervampnull,grangervamp,vcov=vcovHAC)
adf.test(resid(grangervamp))
bgtest(grangervamp,order = 12)
#Alternative Use F test(LR) and BIC if not using Heteroskadasticity and AutoCorrelation adjustment in errors(Risky)#
anova(grangervampnull,grangervamp)
BIC(grangervampnull,grangervamp)
#Save Both Adjusted and Unadjusted series for reproducibility#
write.csv(Vampires,file="Vampires")
write.csv(adjusted_data,file="adjusted_data")
#plot both series#
ggplot(Vampires,mapping = aes(x=index(Time),y=Divorce))+geom_line(,colour="blue")+geom_line(aes(x=index(Time),y=Vampire,colour = "red"))+ylab("Divorce/Vampire")+ggtitle("Unadjusted Relative Search Interest")
ggplot(adjusted_data,mapping = aes(y=Divorce,x=index(Divorce)))+geom_line(,colour="blue")+geom_line(aes(y=Vampire,colour = "red",x=index(Vampire)))+ylab("Divorce/Vampire")+ggtitle("Adjusted Relative Search Interest")
