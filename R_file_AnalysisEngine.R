#Integrated model

#This R File is to format, optimize, tune and evaluate predictions. Much of this code must be altered depending on the data format
#of the input file, which is does not come in a generalized format.

library(readxl)
library(dplyr)
library(lazyeval)
library(ggplot2)
library(zoo)

# This function was used from stack overflow: (https://stackoverflow.com/questions/1826519/how-to-assign-from-a-function-which-returns-more-than-one-value?utm_medium=organic&utm_source=google_rich_qa&utm_campaign=google_rich_qa)
':=' <- function(lhs, rhs) {
  frame <- parent.frame()
  lhs <- as.list(substitute(lhs))
  if (length(lhs) > 1)
    lhs <- lhs[-1]
  if (length(lhs) == 1) {
    do.call(`=`, list(lhs[[1]], rhs), envir=frame)
    return(invisible(NULL)) 
  }
  if (is.function(rhs) || is(rhs, 'formula'))
    rhs <- list(rhs)
  if (length(lhs) > length(rhs))
    rhs <- c(rhs, rep(list(NULL), length(lhs) - length(rhs)))
  for (i in 1:length(lhs))
    do.call(`=`, list(lhs[[i]], rhs[[i]]), envir=frame)
  return(invisible(NULL)) 
}

#Sim Concept

StLouis_Monthly <- read_csv("~/Downloads/StLouis_Monthly.csv")
Sim_results_10k_June1 <- read_csv("~/Downloads/Sim_results_10k_June1.csv")
a = names(Sim_results_10k_June1)
a[1] = "Date"
names(Sim_results_10k_June1) = a

Sim_results_10k_June1 = dplyr::left_join(Sim_results_10k_June1,select(gallup_daily,date,employed), by = c("Date"= "date"))

#Number_sim_RF <- read_csv("~/Downloads/Number_sim_RF.csv")

sim_data = Sim_results_10k_June1
fed_data = StLouis_Monthly

a = names(Number_sim_RF)
a[1] = "Date"
names(Number_sim_RF) = a

Number_sim_RF =Number_sim_RF[,-5]
Number_sim_RF$Date = format(as.Date(Number_sim_RF$Date,"%m/%d/%Y"), "20%y-%m-%d")

sim_data = dplyr::left_join(sim_data,Number_sim_RF,by=c("Date"))

#Convert date to characters
fed_data$Date = as.character(fed_data$Date)
sim_data$Date = as.character(sim_data$Date)

gallup_daily <- read_csv("~/Dropbox/2018 - Predicting Employment/cleanedData/gallup_daily.csv")
gallup_daily = select(gallup_daily,date,employed)
names(gallup_daily) = c("Date","Gallup Predictions")
sim_data <- dplyr::left_join(sim_data,gallup_daily,by = c("Date"))

## COMMENTED CODE BELOW ARE OLD ANALYSIS ENGINES

# combined = dplyr::left_join(fed_data,select(sim_data,X__3,X__5), by = c("DATE" = "X__3")) 
# 
# #Sim data to compress average month, year combinations
# sim_data$monthYear = substr(sim_data$X__3,1,7)
# sim_data_month_year = sim_data %>% group_by(monthYear) %>% summarize(averageMonthYear = mean(X__5, na.rm=TRUE))
# 
# sim_data_month_year$monthYear = as.yearmon(sim_data_month_year$monthYear)+.1
# sim_data_month_year$monthYear = as.Date(sim_data_month_year$monthYear)
# sim_data_month_year$monthYear = substr(sim_data_month_year$monthYear,1,7)
# 
# combined$DATE = substr(combined$DATE,1,7)
# combined = dplyr::left_join(combined,sim_data_month_year, by = c("DATE" = "monthYear")) 
# combined = combined[,-3]
# names(combined) = c("DATE","X__1","X__5")
# combined$DATE = paste0(combined$DATE, "-01", sep="")
# 
# nw.estimator = ksmooth(combined$X__5,combined$X__1,kernel = 'normal',bandwidth = .005)
# 
# #Talk about needing to include weeeknds
# 
# model1 <- lm(X__1 ~ X__5, data = combined)
# plot(combined$X__1, combined$X__5)
# summary(model1)
# 
# combined = combined[-which(is.na(combined$averageMonthYear)),]
# combined$previous_date_adjusted = 1
# for (i in 2:length(combined$DATE)){
#   combined$previous_date_adjusted[i] = combined$X__5[i] - (combined$X__5[i-1] - combined$X__1[i-1])
#   
# }
# 
# plot(combined$X__1, combined$previous_date_adjusted)
# model2 <- lm(X__1 ~ previous_date_adjusted, data = combined)
# summary(model2)
# 
# #Simulation adjustment on previous month's difference
# combined$month_diff = 1
# for (i in 2:length(combined$DATE)){
#   combined$month_diff[i] = (combined$X__5[i-1] - combined$X__1[i-1])
#   
# }
# 
# names(combined) = c("DATE","X__1","avMonYear","month_diff")
# sim_data_new = dplyr::left_join(sim_data,dplyr::select(combined,DATE,avMonYear,month_diff), by = c("X__3" = "DATE"))
# 
# sim_data_new$month_diff[1] = 0
# diff = month_diff[1]
# for (i in 1:length(sim_data_new$X__3)){
#   if (is.na(sim_data_new$month_diff[i]) == TRUE) {
#     sim_data_new$month_diff[i] = diff
#   }
#   else {
#     diff =  sim_data_new$month_diff[i]
#   }
# 
# }
# 
# 
# #Estimate
# sim_data_new$nw_estimates = 0
# for (i in 1:length(sim_data_new$X__3)){
#   sim_data_new$nw_estimates[i] = nw.estimator$y[which.min(abs(nw.estimator$x-sim_data_new$X__5[i]))]
# }
# 
# 
# 
# sim_data_new$multi_month_diff = 0
# multi_month_average = function(num_months, i=1, j = 1, month_av = 0, month_start = 0, hazard_rate = 1){
#   m.new = c()
#   current_month = sim_data_new$month_diff[1]
#   m.new[1] = current_month
#   hazard_weights = c(hazard_rate)
#   for (z in 2:num_months){
#     hazard_weights[z] = (1 - hazard_rate)/num_months*(num_months-z+1)
#   }
#   print(hazard_weights)
#   for (k in 1:length(sim_data_new$X__3)){
#     start_month = sim_data_new$month_diff[k]
#     if (i < num_months){
#       if (current_month != start_month){
#         i = i + 1
#         current_month = sim_data_new$month_diff[k]
#         j = j + 1
#         m.new[j] = current_month
#       }
# 
#     }
#     else {
#       i = 1
#     }
#     if (j >= num_months) {
#       sim_data_new$multi_month_diff[k] = sum(m.new[(j-num_months+1):j]*rev(hazard_weights))
#     }
#   }
#   return(sim_data_new)
# }
# 
# 
# sim_data_new = multi_month_average(3)
# sim_data_new$corrected2 = sim_data_new$X__5-sim_data_new$multi_month_diff
# sim_data_new2 = multi_month_average(5)
# sim_data_new$corrected3 = sim_data_new$X__5-sim_data_new2$multi_month_diff
# sim_data_new3 = multi_month_average(3)
# sim_data_new$corrected4 = sim_data_new$X__5-sim_data_new3$multi_month_diff

## END COMMENTED CODE 


#Re-weight based on previous datas
sim_data$Date = format(as.Date(sim_data$Date,"%m/%d/%Y"), "20%y-%m-%d")
fed_data$Date = format(as.Date(fed_data$Date,"%m/%d/%Y"), "20%y-%m-%d")

sim_data$day = substr(sim_data$Date,9,10)
sim_data$mY = substr(sim_data$Date,1,7)

# This is the objective function we will be minimizing
distance.objective <- function(W,X,Y) {
  #return(sum((rowSums(X*W)/31-Y)^2))
  return(sum((X*W-Y)^2))
}

# This is the function that is run to initialize the optimization
distance.est <- function(W_init,X,Y) {
  fit <- optim(par=W_init,distance.objective,X=X,Y=Y)
  return(fit)
}

calcWeights <- function(modelOption, sim_data_new = sim_data) {
  sim_data_by_fed = dplyr::select_(sim_data_new,"mY","day",modelOption)
  sim_data_by_fed.spread = tidyr::spread_(sim_data_by_fed,"day",modelOption)
  sim_data_by_fed.spread = sim_data_by_fed.spread %>% mutate_each(funs_(lazyeval::interp(~replace(., is.na(.),0))))
  sim_matrix = data.matrix(sim_data_by_fed.spread[,-1], rownames.force = NA)

  Y = fed_data[,2]
  Y = Y[-1,]

  X = sim_matrix[-124,]
  X = X[-124,]


  W = rep.int(1,31)*.73

  optimized_weights = distance.est(W,X,Y)
  
  
  return(list(optimized_weights, sim_data_by_fed.spread))

}
names(fed_data) = c("Date","Fed")
sim_data = dplyr::left_join(sim_data,fed_data,by=c("Date"))

for (i in 26:28){
  modelOfInterest = i
  models = names(sim_data)
  modelsUpdate = models
  modelsUpdate[modelOfInterest] = "newName"
  names(sim_data) = modelsUpdate
  c(optimized_weights,sim_data_by_fed.spread) := calcWeights(modelOption = modelsUpdate[modelOfInterest])

  adjusted_simData = sim_data_by_fed.spread
  for (i in 1:123){
    adjusted_simData[i,2:32] = sim_data_by_fed.spread[i,2:32]*optimized_weights$par
  }

  names(sim_data) = models
  adjusted_simData = tidyr::gather(adjusted_simData,"Day","weightAdjustedEst",2:32)
  adjusted_simData$Date = paste0(adjusted_simData$mY,"-",adjusted_simData$Day)
  adjusted_simData = dplyr::select(adjusted_simData,Date,weightAdjustedEst)
  names(adjusted_simData) = c("Date", paste0(models[modelOfInterest], "_", "adjusted"))

  sim_data = dplyr::left_join(sim_data,adjusted_simData, by = c("Date"))

  #names(fed_data) = c("Date","Fed")
  #sim_data = dplyr::left_join(sim_data,fed_data,by=c("Date"))
  sim_data[[paste0(models[modelOfInterest], "_", "adjusted2")]] = 0

  fedCurrentDiff = sim_data$Fed[1] - mean(sim_data[[paste0(models[modelOfInterest], "_", "adjusted")]][1:15])
  for (i in 1:length(sim_data[[paste0(models[modelOfInterest], "_", "adjusted")]])) {
    if (is.na(sim_data$Fed[i])==FALSE) {
      fedCurrentDiff = sim_data$Fed[i] - mean(sim_data[[paste0(models[modelOfInterest], "_", "adjusted")]][(i-20):(i-5)])
    }
    sim_data[[paste0(models[modelOfInterest], "_", "adjusted2")]][i] = sim_data[[paste0(models[modelOfInterest], "_", "adjusted")]][i]+fedCurrentDiff
  }
}

#Function to generate error rates
RMSEcalc <- function(Fed, Adjusted2) {
  RMSE = c()
  Fed_only = c()
  Adjusted2_only = c()
  j = 1
  for (i in 2:length(Adjusted2)) {
    if(is.na(Fed[i])==FALSE) {
      if(Adjusted2[i]>0){
        Fed_only[j] = Fed[i]
        Adjusted2_only[j] = Adjusted2[i]
        RMSE[j] = (Fed[i]-Adjusted2[i-1])^2
        j = j +1
      }
    }
  }
  R2 <- 1 - (sum((Fed_only-Adjusted2_only )^2)/sum((Fed_only-mean(Fed_only))^2))
  plot(x = Fed_only, y= Adjusted2_only)
  RMSE_calc <- sqrt(sum(RMSE)/j)
  return(list(R2,RMSE_calc))
}

#ADD GALLUP DATA
gallup_daily = select(gallup_daily,date,employed)
gallup_daily$date = format(as.Date(gallup_daily$date,"%m/%d/%Y"), "20%y-%m-%d")
names(gallup_daily) = c("Date","Gallup Predictions")
sim_data <- dplyr::left_join(sim_data,gallup_daily,by = c("Date"))

c(R2_RF_Norm_10000,RMSE_RF_Norm_10000) := RMSEcalc(sim_data$Fed,sim_data$`Normalized - RF - 10000_adjusted2`)
c(R2_Logit_Norm_10000,RMSE_Logit_Norm_10000) := RMSEcalc(sim_data$Fed,sim_data$`Normalized-Logit - 10000_adjusted2`)
c(R2_Baseline_Norm_10000,RMSE_Baseline_Norm_10000) := RMSEcalc(sim_data$Fed,sim_data$`Baseline - Normalized - 10000_adjusted2`)
c(R2_RF_10000,RMSE_RF_10000) := RMSEcalc(sim_data$Fed,sim_data$`RF - 10000_adjusted2`)
c(R2_Logit_10000, RMSE_Logit_10000) := RMSEcalc(sim_data$Fed,sim_data$`Logit - 10000_adjusted2`)
c(R2_Baseline_10000,RMSE_Baseline_10000) := RMSEcalc(sim_data$Fed,sim_data$`Baseline - 10000_adjusted2`)
c(R2_Gallup,RMSE_Gallup) := RMSEcalc(sim_data$Fed,sim_data$`Gallup Predictions_adjusted2`)
c(R2_RF_1000,RMSE_RF_1000) := RMSEcalc(sim_data$Fed,sim_data$`Normalized - RF - 1000.y_adjusted2`)
c(R2_RF_50000,RMSE_RF_50000) := RMSEcalc(sim_data$Fed,sim_data$`Normalized - RF - 50000.y_adjusted2`)


sim_data$Date = as.Date(sim_data$Date)
fed_data$Date = as.Date(fed_data$Date)
final_plot9 = ggplot() +
  #geom_line(data = sim_data[which(sim_data$`Gallup Predictions_adjusted2`>.3),], aes(x = Date, y=  `Gallup Predictions_adjusted2`,  group = 1), color = 'light blue') +
  geom_line(data = sim_data, aes(x = Date, y=  `Normalized - RF - 1000.y_adjusted2`,  group = 1), color = 'light blue') +
  geom_line(data = sim_data, aes(x = Date, y=  `RF - 10000_adjusted2`,  group = 1), color = 'orange') +
  geom_line(data = sim_data, aes(x = Date, y=  `Normalized - RF - 50000.y_adjusted2`,  group = 1), color = 'blue') +
  geom_line(data = fed_data, aes(x = Date, y = Fed, group = 1), color = 'red',size=1) +
  ylim(0.25,0.95) + 
  ylab("Predictions") +
  ggtitle("Daily Unemployment Predictions") +
  scale_x_date(limits = c(as.Date("2008-01-01"), as.Date("2017-12-31")),breaks = seq(as.Date("2008-01-01"), as.Date("2017-12-31"), "quarter") - c(0,1,1,0), expand=c(0,30)) +
  theme(axis.text.x=element_text(angle=-90, vjust=0.5))
 
  

final_plot9

###Run econ analysis -

gallup_cleaned = fread("gallup_clean_NA_determinant.txt")

econModel <- glm(employed ~ factor(state_of_econ) + factor(satis_future) + factor(lifeladder_now) + factor(lifeladder_future) +
                 healthprob_days + gallup_cleaned$age + gallup_cleaned$nchild + factor(county) + factor(met2013) + 
                   year + factor(male) + factor(educ) + factor(race) + factor(worry_todo) + factor(worry_food) + 
                   factor(worry_hcare) + factor(worry_productive) + factor(worry_money) +
                   daily_indi_vol + daily_indi_SP500 + daily_indi_oil,  data= gallup_cleaned, family = "binomial")
  
summary(econModel)


