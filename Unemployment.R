## Gallup Data Update

#This R File is generated to create custom Vowpal Wabbit input files, used to generate the factor weights and significance

library(data.table)

#setwd("~/Dropbox/2018 - Predicting Employment/cleanedData")
#gallup <- fread("gallup_clean_nocol8.txt")

setwd("~/Box Sync/Data_for_341")
gallup <- fread("gallup_clean_NA_No_D_ccor.txt")
fha <- fread("fha_zipcode_hpi_clean.csv")
eia <- fread("eia_state_all_monthly.csv")

gallup$z_y <- paste(gallup$zip,"_", gallup$year, sep="")
fha$z_y <- paste(fha$zip,"_", fha$year, sep="")
fha <- dplyr::select(fha,dlhpi,z_y)

gallup_new <- dplyr::left_join(gallup,fha, by = c("z_y"))

gallup_new$month_num <- ifelse(gallup_new$month == "JAN",1,ifelse(gallup_new$month == "FEB",2,ifelse(gallup_new$month == "MAR",3,ifelse(gallup_new$month == "APR",4,ifelse(gallup_new$month == "MAY",5,ifelse(gallup_new$month == "JUN",6,ifelse(gallup_new$month == "JUL", 7, ifelse(gallup_new$month == "AUG", 8, ifelse(gallup_new$month == "SEP",9,ifelse(gallup_new$month == "OCT",10,ifelse(gallup_new$month == "NOV",11,12)))))))))))
gallup_new$m_y_st <- paste(gallup_new$month_num,"_", gallup_new$year, "_",gallup_new$st, sep="")
  
eia$m_y_st <- paste(eia$month,"_", eia$year, "_",eia$st, sep="")
eia <- dplyr::select(eia,realgasprice,m_y_st)

gallup_new2 <- dplyr::left_join(gallup_new,eia,by=c("m_y_st"))


file_for_match <- dplyr::select(gallup_new2,state_of_econ,satis_future,lifeladder_now,lifeladder_future,healthprob_days,
                                time_social,age,polviews,nchild,ps_weight,ps_height,ps_bmi,zip,county,met2013,COMB_WEIGHT,
                                intdate,day,month,year,cons_nondur,employed,satis_current,married,worry_food,
                                worry_hcare,healthprob_yes,city_satis,city_safewalk,male,educ,race,st,future_of_econ,city_future,
                                city_safewater,worry_todo,worry_money,worry_productive,purpose,community,physical,financial,social,wellbeing,qtr,lat,long,dlhpi,realgasprice)


file_for_match$time_social <- ifelse(file_for_match$time_social=="None",0,file_for_match$time_social)
file_for_match$time_social <- ifelse(file_for_match$time_social=="(DK)","",file_for_match$time_social)
file_for_match$time_social <- ifelse(file_for_match$time_social=="Less than one hour",0,file_for_match$time_social)
file_for_match$time_social <- as.numeric(file_for_match$time_social)

file_for_match_vowpal_wabbit <- file_for_match




file_for_match_vowpal_wabbit$employed <- ifelse(file_for_match_vowpal_wabbit$employed==0,"-1.0","1.0")
file_for_match_vowpal_wabbit$state_of_econ <- ifelse(file_for_match_vowpal_wabbit$state_of_econ=="","",paste(" |state_of_econ ", gsub("\\s", "",file_for_match_vowpal_wabbit$state_of_econ)," ",sep=""))
file_for_match_vowpal_wabbit$satis_future <- ifelse(file_for_match_vowpal_wabbit$satis_future=="","",paste(" |satis_future ", gsub("\\s", "",file_for_match_vowpal_wabbit$satis_future)," ",sep=""))
file_for_match_vowpal_wabbit$lifeladder_now <- ifelse(file_for_match_vowpal_wabbit$lifeladder_now=="","",paste(" |lifeladder_now ", gsub("\\s", "",file_for_match_vowpal_wabbit$lifeladder_now)," ",sep=""))
file_for_match_vowpal_wabbit$lifeladder_future <- ifelse(file_for_match_vowpal_wabbit$lifeladder_future=="","",paste(" |lifeladder_future ", gsub("\\s", "",file_for_match_vowpal_wabbit$lifeladder_future)," ",sep=""))
file_for_match_vowpal_wabbit$healthprob_days <- ifelse(file_for_match$healthprob_days=="Zero days",0,file_for_match$healthprob_days)
file_for_match_vowpal_wabbit$healthprob_days <- ifelse(file_for_match_vowpal_wabbit$healthprob_days=="N/A","",paste(" | healthprob_days:", file_for_match_vowpal_wabbit$healthprob_days,"",sep=""))
file_for_match_vowpal_wabbit$polviews <- ifelse(file_for_match_vowpal_wabbit$polviews=="","",paste(" |polviews ", gsub("\\s", "",file_for_match_vowpal_wabbit$polviews)," ",sep=""))
file_for_match_vowpal_wabbit$nchild <- ifelse(file_for_match_vowpal_wabbit$nchild=="","",paste(" |nchild ", file_for_match_vowpal_wabbit$nchild," ",sep=""))
file_for_match_vowpal_wabbit$zip <- ifelse(is.na(file_for_match_vowpal_wabbit$zip),"",paste(" |zip ", file_for_match_vowpal_wabbit$zip," ",sep=""))
file_for_match_vowpal_wabbit$lat <- ifelse(is.na(file_for_match_vowpal_wabbit$lat),"",paste(" | lat:", file_for_match_vowpal_wabbit$lat," ",sep=""))
file_for_match_vowpal_wabbit$long <- ifelse(is.na(file_for_match_vowpal_wabbit$long),"",paste(" | long:", file_for_match_vowpal_wabbit$long," ",sep=""))

file_for_match_vowpal_wabbit$county <- ifelse(is.na(file_for_match_vowpal_wabbit$county),"",paste(" |county ", file_for_match_vowpal_wabbit$county," ",sep=""))
file_for_match_vowpal_wabbit$met2013 <- ifelse(is.na(file_for_match_vowpal_wabbit$met2013),"",paste(" |met2013 ", file_for_match_vowpal_wabbit$met2013," ",sep=""))
file_for_match_vowpal_wabbit$intdate <- ifelse(file_for_match_vowpal_wabbit$intdate=="","",paste(" |intdate ", file_for_match_vowpal_wabbit$intdate," ",sep=""))
file_for_match_vowpal_wabbit$day <- ifelse(file_for_match_vowpal_wabbit$day=="","",paste(" |day ", file_for_match_vowpal_wabbit$day," ",sep=""))
file_for_match_vowpal_wabbit$month <- ifelse(file_for_match_vowpal_wabbit$month=="","",paste(" |month ", file_for_match_vowpal_wabbit$month," ",sep=""))
file_for_match_vowpal_wabbit$year <- ifelse(file_for_match_vowpal_wabbit$year=="","",paste(" |year ", file_for_match_vowpal_wabbit$year," ",sep=""))
file_for_match_vowpal_wabbit$future_of_econ <- ifelse(is.na(file_for_match_vowpal_wabbit$future_of_econ),"",paste(" |future_of_econ ", file_for_match_vowpal_wabbit$future_of_econ," ",sep=""))
file_for_match_vowpal_wabbit$city_future <- ifelse(is.na(file_for_match_vowpal_wabbit$city_future),"",paste(" |city_future ", file_for_match_vowpal_wabbit$city_future," ",sep=""))
file_for_match_vowpal_wabbit$city_safewater <- ifelse(is.na(file_for_match_vowpal_wabbit$city_safewater),"",paste(" |city_safewater ", file_for_match_vowpal_wabbit$city_safewater," ",sep=""))

file_for_match_vowpal_wabbit$purpose <- ifelse(file_for_match$purpose=="N/A","",paste(" | purpose: ", file_for_match$purpose," ",sep=""))
file_for_match_vowpal_wabbit$community <- ifelse(file_for_match$community=="N/A","",paste(" | community: ", file_for_match$community," ",sep=""))
file_for_match_vowpal_wabbit$physical <- ifelse(file_for_match$physical=="N/A","",paste(" | physical: ", file_for_match$physical," ",sep=""))
file_for_match_vowpal_wabbit$financial <- ifelse(file_for_match$financial=="N/A","",paste(" | financial: ", file_for_match$financial," ",sep=""))
file_for_match_vowpal_wabbit$social <- ifelse(file_for_match$social=="N/A","",paste(" | social: ", file_for_match$social," ",sep=""))
file_for_match_vowpal_wabbit$wellbeing <- ifelse(file_for_match$wellbeing=="N/A","",paste(" | wellbeing: ", file_for_match$wellbeing," ",sep=""))
file_for_match_vowpal_wabbit$qtr <- ifelse(is.na(file_for_match$qtr),"",paste(" |qtr ", file_for_match$qtr," ",sep=""))



file_for_match_vowpal_wabbit$satis_current <- ifelse(is.na(file_for_match_vowpal_wabbit$satis_current),"",paste(" |satis_current ", file_for_match_vowpal_wabbit$satis_current," ",sep=""))
file_for_match_vowpal_wabbit$married <- ifelse(is.na(file_for_match_vowpal_wabbit$married),"",paste(" |married ", file_for_match_vowpal_wabbit$married," ",sep=""))
file_for_match_vowpal_wabbit$worry_food <- ifelse(is.na(file_for_match_vowpal_wabbit$worry_food),"",paste(" |worry_food ", file_for_match_vowpal_wabbit$worry_food," ",sep=""))
file_for_match_vowpal_wabbit$worry_hcare <- ifelse(is.na(file_for_match_vowpal_wabbit$worry_hcare),"",paste(" |worry_hcare ", file_for_match_vowpal_wabbit$worry_hcare," ",sep=""))
file_for_match_vowpal_wabbit$worry_money <- ifelse(file_for_match_vowpal_wabbit$worry_money=="","",paste(" |worry_money ", gsub("\\s", "",file_for_match_vowpal_wabbit$worry_money)," ",sep=""))
file_for_match_vowpal_wabbit$worry_productive <- ifelse(file_for_match_vowpal_wabbit$worry_productive=="","",paste(" |worry_productive ", gsub("\\s", "",file_for_match_vowpal_wabbit$worry_productive)," ",sep=""))
file_for_match_vowpal_wabbit$worry_todo <- ifelse(file_for_match_vowpal_wabbit$worry_todo=="","",paste(" |worry_todo ", gsub("\\s", "",file_for_match_vowpal_wabbit$worry_todo)," ",sep=""))
file_for_match_vowpal_wabbit$healthprob_yes <- ifelse(is.na(file_for_match_vowpal_wabbit$healthprob_yes),"",paste(" |healthprob_yes ", file_for_match_vowpal_wabbit$healthprob_yes," ",sep=""))
file_for_match_vowpal_wabbit$city_safewalk <- ifelse(is.na(file_for_match_vowpal_wabbit$city_safewalk),"",paste(" |city_safewalk ", file_for_match_vowpal_wabbit$city_safewalk," ",sep=""))
file_for_match_vowpal_wabbit$city_satis <- ifelse(is.na(file_for_match_vowpal_wabbit$city_satis),"",paste(" |city_satis ", file_for_match_vowpal_wabbit$city_satis," ",sep=""))
file_for_match_vowpal_wabbit$male <- ifelse(is.na(file_for_match_vowpal_wabbit$male),"",paste(" |male ", file_for_match_vowpal_wabbit$male," ",sep=""))

file_for_match_vowpal_wabbit$educ <- ifelse(is.na(file_for_match$educ),"",paste(" |educ ", file_for_match_vowpal_wabbit$educ," ",sep=""))
file_for_match_vowpal_wabbit$race <- ifelse(is.na(file_for_match$race),"",paste(" |race ", file_for_match_vowpal_wabbit$race," ",sep=""))


file_for_match_vowpal_wabbit$st <- as.numeric(as.character(file_for_match$st))
file_for_match_vowpal_wabbit$st <- ifelse(is.na(file_for_match_vowpal_wabbit$st),"",paste(" |st ", file_for_match_vowpal_wabbit$st,sep=""))



file_for_match_vowpal_wabbit$time_social <- ifelse(is.na(file_for_match$time_social),"",file_for_match$time_social)
file_for_match_vowpal_wabbit$time_social <- ifelse(file_for_match_vowpal_wabbit$time_social=="","",paste(" | time_social:", file_for_match_vowpal_wabbit$time_social,sep=""))
file_for_match_vowpal_wabbit$age <- as.numeric(as.character(file_for_match$age))
file_for_match_vowpal_wabbit$age <- ifelse(is.na(file_for_match_vowpal_wabbit$age),"",paste(" | age:", file_for_match_vowpal_wabbit$age,sep=""))
file_for_match_vowpal_wabbit$ps_weight <- ifelse(file_for_match$ps_weight=="N/A","",paste(" | ps_weight:", file_for_match$ps_weight,sep=""))
file_for_match_vowpal_wabbit$ps_height <- ifelse(file_for_match$ps_height=="N/A","",paste(" | ps_height:", file_for_match$ps_height,sep=""))
file_for_match_vowpal_wabbit$ps_bmi <- ifelse(file_for_match$ps_bmi=="N/A","",paste(" | ps_bmi:", file_for_match$ps_bmi,sep=""))
file_for_match_vowpal_wabbit$COMB_WEIGHT <- ifelse(file_for_match$COMB_WEIGHT=="N/A","",paste(" | COMB_WEIGHT:", file_for_match$COMB_WEIGHT,sep=""))
file_for_match_vowpal_wabbit$cons_nondur <- ifelse(file_for_match$cons_nondur=="N/A","",paste(" | cons_nondur:", file_for_match$cons_nondur,sep=""))

file_for_match_vowpal_wabbit$dlhpi <- ifelse(is.na(file_for_match$dlhpi),"",paste(" | dlhpi:", file_for_match$dlhpi,sep=""))
file_for_match_vowpal_wabbit$realgasprice <- ifelse(is.na(file_for_match$realgasprice),"",paste(" | realgasprice:", file_for_match$realgasprice,sep=""))



new_file <- paste(file_for_match_vowpal_wabbit$employed, file_for_match_vowpal_wabbit$state_of_econ, file_for_match_vowpal_wabbit$satis_future, file_for_match_vowpal_wabbit$lifeladder_now, 
                  file_for_match_vowpal_wabbit$lifeladder_future, file_for_match_vowpal_wabbit$healthprob_days,file_for_match_vowpal_wabbit$polviews,file_for_match_vowpal_wabbit$nchild,
                  file_for_match_vowpal_wabbit$zip, file_for_match_vowpal_wabbit$county, file_for_match_vowpal_wabbit$met2013, file_for_match_vowpal_wabbit$intdate, file_for_match_vowpal_wabbit$day, file_for_match_vowpal_wabbit$month,
                  file_for_match_vowpal_wabbit$year, file_for_match_vowpal_wabbit$future_of_econ,file_for_match_vowpal_wabbit$city_future,file_for_match_vowpal_wabbit$city_safewater,file_for_match_vowpal_wabbit$purpose,file_for_match_vowpal_wabbit$community, 
                  file_for_match_vowpal_wabbit$physical,file_for_match_vowpal_wabbit$financial,file_for_match_vowpal_wabbit$social,file_for_match_vowpal_wabbit$wellbeing,file_for_match_vowpal_wabbit$qtr,
                  file_for_match_vowpal_wabbit$satis_current,file_for_match_vowpal_wabbit$married,file_for_match_vowpal_wabbit$worry_food,file_for_match_vowpal_wabbit$worry_hcare,file_for_match_vowpal_wabbit$worry_money,file_for_match_vowpal_wabbit$worry_productive,
                  file_for_match_vowpal_wabbit$worry_todo,file_for_match_vowpal_wabbit$healthprob_yes,file_for_match_vowpal_wabbit$city_safewalk,file_for_match_vowpal_wabbit$city_satis,file_for_match_vowpal_wabbit$male,
                  file_for_match_vowpal_wabbit$educ,
                  file_for_match_vowpal_wabbit$race,file_for_match_vowpal_wabbit$st,
                  file_for_match_vowpal_wabbit$time_social, file_for_match_vowpal_wabbit$age,file_for_match_vowpal_wabbit$ps_weight,file_for_match_vowpal_wabbit$ps_height,file_for_match_vowpal_wabbit$ps_bmi,file_for_match_vowpal_wabbit$COMB_WEIGHT,file_for_match_vowpal_wabbit$cons_nondur,
                  sep = "")

list = substr(new_file,0,2)
a = which(list=="NA")
new_file = new_file[-a]

setwd("~/Desktop/")

index = seq(1, length(new_file), by = 1)
test_index = sample(index,size = length(index)*.20)
write.table(new_file, file = "file_for_match_vowpal_wabbit_ECON.tsv", row.names=FALSE, col.names=FALSE, quote = FALSE)
write.table(new_file[-test_index], file = "file_for_match_vowpal_wabbit_ECON_train.tsv", row.names=FALSE, col.names=FALSE, quote = FALSE)
write.table(new_file[test_index], file = "file_for_match_vowpal_wabbit_ECON_test.tsv", row.names=FALSE, col.names=FALSE, quote = FALSE)

new_file2 <- paste(file_for_match_vowpal_wabbit$employed, file_for_match_vowpal_wabbit$state_of_econ, file_for_match_vowpal_wabbit$satis_future, file_for_match_vowpal_wabbit$lifeladder_now, 
                  file_for_match_vowpal_wabbit$lifeladder_future, file_for_match_vowpal_wabbit$healthprob_days,file_for_match_vowpal_wabbit$polviews,file_for_match_vowpal_wabbit$nchild,
                  file_for_match_vowpal_wabbit$future_of_econ,file_for_match_vowpal_wabbit$city_future,file_for_match_vowpal_wabbit$city_safewater,file_for_match_vowpal_wabbit$purpose,file_for_match_vowpal_wabbit$community, 
                  file_for_match_vowpal_wabbit$qtr,
                  file_for_match_vowpal_wabbit$satis_current,file_for_match_vowpal_wabbit$married,file_for_match_vowpal_wabbit$worry_food,file_for_match_vowpal_wabbit$worry_hcare,
                  file_for_match_vowpal_wabbit$healthprob_yes,file_for_match_vowpal_wabbit$city_safewalk,file_for_match_vowpal_wabbit$city_satis,file_for_match_vowpal_wabbit$male,
                  file_for_match_vowpal_wabbit$educ_coll,file_for_match_vowpal_wabbit$educ_hs,file_for_match_vowpal_wabbit$educ_nohs,file_for_match_vowpal_wabbit$educ_postgrad,file_for_match_vowpal_wabbit$educ_somecoll,file_for_match_vowpal_wabbit$educ_tech,
                  file_for_match_vowpal_wabbit$race_asian,file_for_match_vowpal_wabbit$race_black,file_for_match_vowpal_wabbit$race_hisp,file_for_match_vowpal_wabbit$race_white,file_for_match_vowpal_wabbit$st,
                  file_for_match_vowpal_wabbit$time_social, file_for_match_vowpal_wabbit$age,file_for_match_vowpal_wabbit$ps_weight,file_for_match_vowpal_wabbit$ps_height,file_for_match_vowpal_wabbit$ps_bmi,file_for_match_vowpal_wabbit$COMB_WEIGHT,file_for_match_vowpal_wabbit$cons_nondur,
                  sep = "")

list = substr(new_file2,0,2)
a = which(list=="NA")
new_file2 = new_file2[-a]

setwd("~/Desktop/")
write.table(new_file2, file = "file_for_match_vowpal_wabbit_ECON2.tsv", row.names=FALSE, col.names=FALSE, quote = FALSE)


new_file3 <- paste(file_for_match_vowpal_wabbit$employed, file_for_match_vowpal_wabbit$state_of_econ, file_for_match_vowpal_wabbit$satis_future, 
                   file_for_match_vowpal_wabbit$lifeladder_now, file_for_match_vowpal_wabbit$lifeladder_future, file_for_match_vowpal_wabbit$healthprob_days, 
                   file_for_match_vowpal_wabbit$time_commute, file_for_match_vowpal_wabbit$time_social, file_for_match_vowpal_wabbit$satis_current, 
                   file_for_match_vowpal_wabbit$married, file_for_match_vowpal_wabbit$worried_food, file_for_match_vowpal_wabbit$worried_healthcare, 
                   file_for_match_vowpal_wabbit$healthprob_yes, file_for_match_vowpal_wabbit$city_safewalk, file_for_match_vowpal_wabbit$city_satis,
                   sep = "")

list = substr(new_file3,0,2)
a = which(list=="NA")
new_file3 = new_file3[-a]

setwd("~/Desktop/")

index = seq(1, length(new_file3), by = 1)
test_index = sample(index,size = length(index)*.20)
write.table(new_file3[-test_index], file = "file_for_match_vowpal_wabbit_ECON3_train.tsv", row.names=FALSE, col.names=FALSE, quote = FALSE)
write.table(new_file3[test_index], file = "file_for_match_vowpal_wabbit_ECON3_test.tsv", row.names=FALSE, col.names=FALSE, quote = FALSE)

####To test the different cleanaed configurations of the file

#File 1 - N/As for no answer

new_file4 <- paste(file_for_match_vowpal_wabbit$employed, file_for_match_vowpal_wabbit$state_of_econ, file_for_match_vowpal_wabbit$satis_future, file_for_match_vowpal_wabbit$lifeladder_now, 
                    file_for_match_vowpal_wabbit$lifeladder_future, file_for_match_vowpal_wabbit$healthprob_days,file_for_match_vowpal_wabbit$polviews,file_for_match_vowpal_wabbit$nchild,
                    file_for_match_vowpal_wabbit$zip, file_for_match_vowpal_wabbit$county, file_for_match_vowpal_wabbit$met2013, file_for_match_vowpal_wabbit$day, file_for_match_vowpal_wabbit$month,
                    file_for_match_vowpal_wabbit$year, file_for_match_vowpal_wabbit$future_of_econ,file_for_match_vowpal_wabbit$city_future,file_for_match_vowpal_wabbit$city_safewater,file_for_match_vowpal_wabbit$purpose,file_for_match_vowpal_wabbit$community, 
                    file_for_match_vowpal_wabbit$physical,file_for_match_vowpal_wabbit$financial,file_for_match_vowpal_wabbit$social,file_for_match_vowpal_wabbit$wellbeing,file_for_match_vowpal_wabbit$qtr,
                    file_for_match_vowpal_wabbit$satis_current,file_for_match_vowpal_wabbit$married,file_for_match_vowpal_wabbit$worry_food,file_for_match_vowpal_wabbit$worry_hcare,file_for_match_vowpal_wabbit$worry_money,file_for_match_vowpal_wabbit$worry_productive,
                    file_for_match_vowpal_wabbit$worry_todo,file_for_match_vowpal_wabbit$healthprob_yes,file_for_match_vowpal_wabbit$city_safewalk,file_for_match_vowpal_wabbit$city_satis,file_for_match_vowpal_wabbit$male,
                    file_for_match_vowpal_wabbit$educ,
                    file_for_match_vowpal_wabbit$race,file_for_match_vowpal_wabbit$st,
                    file_for_match_vowpal_wabbit$time_social, file_for_match_vowpal_wabbit$age,file_for_match_vowpal_wabbit$ps_weight,file_for_match_vowpal_wabbit$ps_height,file_for_match_vowpal_wabbit$ps_bmi,file_for_match_vowpal_wabbit$COMB_WEIGHT,file_for_match_vowpal_wabbit$cons_nondur,
                    sep = "")


setwd("~/Desktop/")

index = seq(1, length(new_file4), by = 1) #must use this same index on all cross comparisons
test_index = sample(index,size = length(index)*.20, seed = 12345)
write.table(new_file4[-test_index], file = "file_for_match_vowpal_wabbit_ECON4_train.tsv", row.names=FALSE, col.names=FALSE, quote = FALSE)
write.table(new_file4[test_index], file = "file_for_match_vowpal_wabbit_ECON4_test.tsv", row.names=FALSE, col.names=FALSE, quote = FALSE)

#File 2 - Updated with values

setwd("~/Box Sync/Data_for_341")
gallup <- fread("gallup_mean_filled_cleaned.txt")

new_file5 <- paste(file_for_match_vowpal_wabbit$employed, file_for_match_vowpal_wabbit$state_of_econ, file_for_match_vowpal_wabbit$satis_future, file_for_match_vowpal_wabbit$lifeladder_now, 
                   file_for_match_vowpal_wabbit$lifeladder_future, file_for_match_vowpal_wabbit$healthprob_days,file_for_match_vowpal_wabbit$polviews,file_for_match_vowpal_wabbit$nchild,
                   file_for_match_vowpal_wabbit$zip, file_for_match_vowpal_wabbit$county, file_for_match_vowpal_wabbit$met2013, file_for_match_vowpal_wabbit$day, file_for_match_vowpal_wabbit$month,
                   file_for_match_vowpal_wabbit$year, file_for_match_vowpal_wabbit$future_of_econ,file_for_match_vowpal_wabbit$city_future,file_for_match_vowpal_wabbit$city_safewater,file_for_match_vowpal_wabbit$purpose,file_for_match_vowpal_wabbit$community, 
                   file_for_match_vowpal_wabbit$physical,file_for_match_vowpal_wabbit$financial,file_for_match_vowpal_wabbit$social,file_for_match_vowpal_wabbit$wellbeing,file_for_match_vowpal_wabbit$qtr,
                   file_for_match_vowpal_wabbit$satis_current,file_for_match_vowpal_wabbit$married,file_for_match_vowpal_wabbit$worry_food,file_for_match_vowpal_wabbit$worry_hcare,file_for_match_vowpal_wabbit$worry_money,file_for_match_vowpal_wabbit$worry_productive,
                   file_for_match_vowpal_wabbit$worry_todo,file_for_match_vowpal_wabbit$healthprob_yes,file_for_match_vowpal_wabbit$city_safewalk,file_for_match_vowpal_wabbit$city_satis,file_for_match_vowpal_wabbit$male,
                   file_for_match_vowpal_wabbit$educ,
                   file_for_match_vowpal_wabbit$race,file_for_match_vowpal_wabbit$st,
                   file_for_match_vowpal_wabbit$time_social, file_for_match_vowpal_wabbit$age,file_for_match_vowpal_wabbit$ps_weight,file_for_match_vowpal_wabbit$ps_height,file_for_match_vowpal_wabbit$ps_bmi,file_for_match_vowpal_wabbit$COMB_WEIGHT,file_for_match_vowpal_wabbit$cons_nondur,
                   sep = "")

setwd("~/Desktop/")
write.table(new_file5[-test_index], file = "file_for_match_vowpal_wabbit_ECON5_train.tsv", row.names=FALSE, col.names=FALSE, quote = FALSE)
write.table(new_file5[test_index], file = "file_for_match_vowpal_wabbit_ECON5_test.tsv", row.names=FALSE, col.names=FALSE, quote = FALSE)


#File 3 - All N/As replaced with 0

setwd("~/Box Sync/Data_for_341") #Use the cleaned with NA dataset
gallup2[gallup2 =="N/A"] <- 0

  

new_file6 <- paste(file_for_match_vowpal_wabbit$employed, file_for_match_vowpal_wabbit$state_of_econ, file_for_match_vowpal_wabbit$satis_future, file_for_match_vowpal_wabbit$lifeladder_now, 
                   file_for_match_vowpal_wabbit$lifeladder_future, file_for_match_vowpal_wabbit$healthprob_days,file_for_match_vowpal_wabbit$polviews,file_for_match_vowpal_wabbit$nchild,
                   file_for_match_vowpal_wabbit$zip, file_for_match_vowpal_wabbit$county, file_for_match_vowpal_wabbit$met2013, file_for_match_vowpal_wabbit$day, file_for_match_vowpal_wabbit$month,
                   file_for_match_vowpal_wabbit$year, file_for_match_vowpal_wabbit$future_of_econ,file_for_match_vowpal_wabbit$city_future,file_for_match_vowpal_wabbit$city_safewater,file_for_match_vowpal_wabbit$purpose,file_for_match_vowpal_wabbit$community, 
                   file_for_match_vowpal_wabbit$physical,file_for_match_vowpal_wabbit$financial,file_for_match_vowpal_wabbit$social,file_for_match_vowpal_wabbit$wellbeing,file_for_match_vowpal_wabbit$qtr,
                   file_for_match_vowpal_wabbit$satis_current,file_for_match_vowpal_wabbit$married,file_for_match_vowpal_wabbit$worry_food,file_for_match_vowpal_wabbit$worry_hcare,file_for_match_vowpal_wabbit$worry_money,file_for_match_vowpal_wabbit$worry_productive,
                   file_for_match_vowpal_wabbit$worry_todo,file_for_match_vowpal_wabbit$healthprob_yes,file_for_match_vowpal_wabbit$city_safewalk,file_for_match_vowpal_wabbit$city_satis,file_for_match_vowpal_wabbit$male,
                   file_for_match_vowpal_wabbit$educ,
                   file_for_match_vowpal_wabbit$race,file_for_match_vowpal_wabbit$st,
                   file_for_match_vowpal_wabbit$time_social, file_for_match_vowpal_wabbit$age,file_for_match_vowpal_wabbit$ps_weight,file_for_match_vowpal_wabbit$ps_height,file_for_match_vowpal_wabbit$ps_bmi,file_for_match_vowpal_wabbit$COMB_WEIGHT,file_for_match_vowpal_wabbit$cons_nondur,
                   sep = "")

setwd("~/Desktop/")
write.table(new_file6[-test_index], file = "file_for_match_vowpal_wabbit_ECON6_train.tsv", row.names=FALSE, col.names=FALSE, quote = FALSE)
write.table(new_file5[test_index], file = "file_for_match_vowpal_wabbit_ECON6_test.tsv", row.names=FALSE, col.names=FALSE, quote = FALSE)


### To determine if narrowing age OR reducing 

index_age_withInRange <- which(file_for_match$age >= 20 & file_for_match$age <= 65)
index_age_health_withInRange <- which(file_for_match$age >= 20 & file_for_match$age <= 65 & file_for_match$healthprob_yes == 0)
index_age_health_rDates_withInRange <- which(file_for_match$age >= 20 & file_for_match$age <= 65 & file_for_match$healthprob_yes == 0 & file_for_match$year >= 2014)

  
generate_newfile <- function(input_file) {
  file_for_match_vowpal_wabbit <- input_file
  new_file <- paste(file_for_match_vowpal_wabbit$employed, file_for_match_vowpal_wabbit$state_of_econ, file_for_match_vowpal_wabbit$satis_future, file_for_match_vowpal_wabbit$lifeladder_now, 
                     file_for_match_vowpal_wabbit$lifeladder_future, file_for_match_vowpal_wabbit$healthprob_days,file_for_match_vowpal_wabbit$polviews,file_for_match_vowpal_wabbit$nchild,
                     file_for_match_vowpal_wabbit$zip, file_for_match_vowpal_wabbit$county, file_for_match_vowpal_wabbit$met2013, file_for_match_vowpal_wabbit$day, file_for_match_vowpal_wabbit$month,
                     file_for_match_vowpal_wabbit$year, file_for_match_vowpal_wabbit$future_of_econ,file_for_match_vowpal_wabbit$city_future,file_for_match_vowpal_wabbit$city_safewater,file_for_match_vowpal_wabbit$purpose,file_for_match_vowpal_wabbit$community, 
                     file_for_match_vowpal_wabbit$physical,file_for_match_vowpal_wabbit$financial,file_for_match_vowpal_wabbit$social,file_for_match_vowpal_wabbit$wellbeing,file_for_match_vowpal_wabbit$qtr,
                     file_for_match_vowpal_wabbit$satis_current,file_for_match_vowpal_wabbit$married,file_for_match_vowpal_wabbit$worry_food,file_for_match_vowpal_wabbit$worry_hcare,file_for_match_vowpal_wabbit$worry_money,file_for_match_vowpal_wabbit$worry_productive,
                     file_for_match_vowpal_wabbit$worry_todo,file_for_match_vowpal_wabbit$healthprob_yes,file_for_match_vowpal_wabbit$city_safewalk,file_for_match_vowpal_wabbit$city_satis,file_for_match_vowpal_wabbit$male,
                     file_for_match_vowpal_wabbit$educ,
                     file_for_match_vowpal_wabbit$race,file_for_match_vowpal_wabbit$st,
                     file_for_match_vowpal_wabbit$time_social, file_for_match_vowpal_wabbit$age,file_for_match_vowpal_wabbit$ps_weight,file_for_match_vowpal_wabbit$ps_height,file_for_match_vowpal_wabbit$ps_bmi,file_for_match_vowpal_wabbit$COMB_WEIGHT,file_for_match_vowpal_wabbit$cons_nondur,
                     sep = "")
  return(new_file)
}

new_file7 <- generate_newfile(file_for_match_vowpal_wabbit[index_ageRange,])

setwd("~/Desktop/")
index = seq(1, length(new_file7), by = 1)
test_index = sample(index,size = length(index)*.20)
write.table(new_file7[-test_index], file = "file_for_match_vowpal_wabbit_ECON7_train.tsv", row.names=FALSE, col.names=FALSE, quote = FALSE)
write.table(new_file7[test_index], file = "file_for_match_vowpal_wabbit_ECON7_test.tsv", row.names=FALSE, col.names=FALSE, quote = FALSE)

new_file8 <- generate_newfile(file_for_match_vowpal_wabbit[index_age_health_withInRange,])

setwd("~/Desktop/")
index = seq(1, length(new_file8), by = 1)
test_index = sample(index,size = length(index)*.20)
write.table(new_file8[-test_index], file = "file_for_match_vowpal_wabbit_ECON8_train.tsv", row.names=FALSE, col.names=FALSE, quote = FALSE)
write.table(new_file8[test_index], file = "file_for_match_vowpal_wabbit_ECON8_test.tsv", row.names=FALSE, col.names=FALSE, quote = FALSE)


new_file9 <- generate_newfile(file_for_match_vowpal_wabbit[index_age_health_rDates_withInRange,])


setwd("~/Desktop/")
index = seq(1, length(new_file9), by = 1)
test_index = sample(index,size = length(index)*.20)
write.table(new_file9[-test_index], file = "file_for_match_vowpal_wabbit_ECON9_train.tsv", row.names=FALSE, col.names=FALSE, quote = FALSE)
write.table(new_file9[test_index], file = "file_for_match_vowpal_wabbit_ECON9_test.tsv", row.names=FALSE, col.names=FALSE, quote = FALSE)

#File for sim

new_file10 <- paste(file_for_match_vowpal_wabbit$employed, file_for_match_vowpal_wabbit$state_of_econ, file_for_match_vowpal_wabbit$satis_future, file_for_match_vowpal_wabbit$lifeladder_now, 
                  file_for_match_vowpal_wabbit$lifeladder_future, file_for_match_vowpal_wabbit$healthprob_days,file_for_match_vowpal_wabbit$polviews,file_for_match_vowpal_wabbit$nchild,
                  file_for_match_vowpal_wabbit$zip, file_for_match_vowpal_wabbit$county, file_for_match_vowpal_wabbit$met2013, file_for_match_vowpal_wabbit$intdate, file_for_match_vowpal_wabbit$day, file_for_match_vowpal_wabbit$month,
                  file_for_match_vowpal_wabbit$year, file_for_match_vowpal_wabbit$future_of_econ,file_for_match_vowpal_wabbit$city_future,file_for_match_vowpal_wabbit$city_safewater,file_for_match_vowpal_wabbit$purpose,file_for_match_vowpal_wabbit$community, 
                  file_for_match_vowpal_wabbit$physical,file_for_match_vowpal_wabbit$financial,file_for_match_vowpal_wabbit$social,file_for_match_vowpal_wabbit$wellbeing,file_for_match_vowpal_wabbit$qtr,
                  file_for_match_vowpal_wabbit$satis_current,file_for_match_vowpal_wabbit$married,file_for_match_vowpal_wabbit$worry_food,file_for_match_vowpal_wabbit$worry_hcare,file_for_match_vowpal_wabbit$worry_money,file_for_match_vowpal_wabbit$worry_productive,
                  file_for_match_vowpal_wabbit$worry_todo,file_for_match_vowpal_wabbit$healthprob_yes,file_for_match_vowpal_wabbit$city_safewalk,file_for_match_vowpal_wabbit$city_satis,file_for_match_vowpal_wabbit$male,
                  file_for_match_vowpal_wabbit$educ,file_for_match_vowpal_wabbit$lat,file_for_match_vowpal_wabbit$long,
                  file_for_match_vowpal_wabbit$race,file_for_match_vowpal_wabbit$st,
                  file_for_match_vowpal_wabbit$time_social, file_for_match_vowpal_wabbit$age,file_for_match_vowpal_wabbit$ps_weight,file_for_match_vowpal_wabbit$ps_height,file_for_match_vowpal_wabbit$ps_bmi,file_for_match_vowpal_wabbit$COMB_WEIGHT,file_for_match_vowpal_wabbit$cons_nondur,
                  sep = "")

index = seq(1, length(new_file10), by = 1)
test_index = sample(index,size = length(index)*.20)
write.table(new_file10[-test_index], file = "file_for_match_vowpal_wabbit_ECON10_train.tsv", row.names=FALSE, col.names=FALSE, quote = FALSE)
write.table(new_file10[test_index], file = "file_for_match_vowpal_wabbit_ECON10_test.tsv", row.names=FALSE, col.names=FALSE, quote = FALSE)

file_for_match_vowpal_wabbit_recentyear <- file_for_match_vowpal_wabbit[which(file_for_match_vowpal_wabbit$year == 2010),] 
file_for_match_vowpal_wabbit_recentmonth <- file_for_match_vowpal_wabbit_recentyear[which(file_for_match_vowpal_wabbit_recentyear$month == 'SEP'),]

new_file11 <- paste(file_for_match_vowpal_wabbit_recentyear$employed, file_for_match_vowpal_wabbit_recentyear$state_of_econ, file_for_match_vowpal_wabbit_recentyear$satis_future, 
                    file_for_match_vowpal_wabbit_recentyear$lifeladder_now, file_for_match_vowpal_wabbit_recentyear$lifeladder_future, file_for_match_vowpal_wabbit_recentyear$satis_current, 
                    file_for_match_vowpal_wabbit_recentyear$future_of_econ, file_for_match_vowpal_wabbit_recentyear$lat, file_for_match_vowpal_wabbit_recentyear$long,
                    sep = "")

test_index = sample(index,size = length(index)*.20)
write.table(new_file11[-test_index], file = "file_for_match_vowpal_wabbit_ECON11_train.tsv", row.names=FALSE, col.names=FALSE, quote = FALSE)
write.table(new_file11[test_index], file = "file_for_match_vowpal_wabbit_ECON11_test.tsv", row.names=FALSE, col.names=FALSE, quote = FALSE)
write.table(new_file11, file = "file_for_match_vowpal_wabbit_ECON11_2010.tsv", row.names=FALSE, col.names=FALSE, quote = FALSE)


#file from sim

setwd("~/Box Sync/Data_for_341/Vowpal_wabbit_files")
sim <- fread("sim_out.txt")

file_for_match_vowpal_wabbit <- sim
file_for_match_vowpal_wabbit$employed <- "1.0"
file_for_match_vowpal_wabbit$state_of_econ <- ifelse(sim$V1=="","",paste(" |state_of_econ ", gsub("\\s", "",sim$V1)," ",sep=""))
file_for_match_vowpal_wabbit$satis_future <- ifelse(sim$V2=="","",paste(" |satis_future ", gsub("\\s", "",sim$V2)," ",sep=""))
file_for_match_vowpal_wabbit$lifeladder_now <- ifelse(sim$V3=="","",paste(" |lifeladder_now ", gsub("\\s", "",sim$V3)," ",sep=""))
file_for_match_vowpal_wabbit$lifeladder_future <- ifelse(sim$V4=="","",paste(" |lifeladder_future ", gsub("\\s", "",sim$V4)," ",sep=""))
file_for_match_vowpal_wabbit$satis_current <- ifelse(is.na(sim$V5),"",paste(" |satis_current ", sim$V5," ",sep=""))
file_for_match_vowpal_wabbit$future_of_econ <- ifelse(is.na(sim$V6),"",paste(" |future_of_econ ", sim$V6," ",sep=""))

file_for_match_vowpal_wabbit$lat <- ifelse(is.na(sim$V7),"",paste(" | lat:", sim$V7," ",sep=""))
file_for_match_vowpal_wabbit$long <- ifelse(is.na(sim$V8),"",paste(" | long:", sim$V8," ",sep=""))


new_file12 <- paste(file_for_match_vowpal_wabbit$employed, file_for_match_vowpal_wabbit$state_of_econ, file_for_match_vowpal_wabbit$satis_future, 
                    file_for_match_vowpal_wabbit$lifeladder_now, file_for_match_vowpal_wabbit$lifeladder_future, file_for_match_vowpal_wabbit$satis_current, 
                    file_for_match_vowpal_wabbit$future_of_econ, file_for_match_vowpal_wabbit$lat, file_for_match_vowpal_wabbit$long,
                    sep = "")

write.table(new_file12, file = "file_for_match_vowpal_wabbit_sim.tsv", row.names=FALSE, col.names=FALSE, quote = FALSE)


new_file13 <- paste(file_for_match_vowpal_wabbit$employed, file_for_match_vowpal_wabbit$state_of_econ, file_for_match_vowpal_wabbit$satis_future, file_for_match_vowpal_wabbit$lifeladder_now, 
                  file_for_match_vowpal_wabbit$lifeladder_future, file_for_match_vowpal_wabbit$healthprob_days,file_for_match_vowpal_wabbit$polviews,file_for_match_vowpal_wabbit$nchild,
                  file_for_match_vowpal_wabbit$county, file_for_match_vowpal_wabbit$met2013, file_for_match_vowpal_wabbit$day, file_for_match_vowpal_wabbit$month,
                  file_for_match_vowpal_wabbit$year, file_for_match_vowpal_wabbit$future_of_econ,file_for_match_vowpal_wabbit$city_future,file_for_match_vowpal_wabbit$city_safewater,file_for_match_vowpal_wabbit$purpose,file_for_match_vowpal_wabbit$community, 
                  file_for_match_vowpal_wabbit$physical,file_for_match_vowpal_wabbit$financial,file_for_match_vowpal_wabbit$social,file_for_match_vowpal_wabbit$wellbeing,file_for_match_vowpal_wabbit$qtr,
                  file_for_match_vowpal_wabbit$satis_current,file_for_match_vowpal_wabbit$married,file_for_match_vowpal_wabbit$worry_food,file_for_match_vowpal_wabbit$worry_hcare,file_for_match_vowpal_wabbit$worry_money,file_for_match_vowpal_wabbit$worry_productive,
                  file_for_match_vowpal_wabbit$worry_todo,file_for_match_vowpal_wabbit$healthprob_yes,file_for_match_vowpal_wabbit$city_safewalk,file_for_match_vowpal_wabbit$city_satis,file_for_match_vowpal_wabbit$male,
                  file_for_match_vowpal_wabbit$educ,
                  file_for_match_vowpal_wabbit$race,file_for_match_vowpal_wabbit$st,
                  file_for_match_vowpal_wabbit$time_social, file_for_match_vowpal_wabbit$age,file_for_match_vowpal_wabbit$ps_weight,file_for_match_vowpal_wabbit$ps_height,file_for_match_vowpal_wabbit$ps_bmi,file_for_match_vowpal_wabbit$COMB_WEIGHT,file_for_match_vowpal_wabbit$cons_nondur,
                  file_for_match_vowpal_wabbit$dlhpi, file_for_match_vowpal_wabbit$realgasprice, file_for_match_vowpal_wabbit$lat, file_for_match_vowpal_wabbit$long,
                  sep = "")


index = seq(1, length(new_file13), by = 1)
test_index = sample(index,size = length(index)*.10)
write.table(new_file13[-test_index], file = "file_for_match_vowpal_wabbit_ECON_train.tsv", row.names=FALSE, col.names=FALSE, quote = FALSE)
write.table(new_file13[test_index], file = "file_for_match_vowpal_wabbit_ECON_test.tsv", row.names=FALSE, col.names=FALSE, quote = FALSE)

new_file14 <- paste(file_for_match_vowpal_wabbit$employed, file_for_match_vowpal_wabbit$state_of_econ, file_for_match_vowpal_wabbit$satis_future, file_for_match_vowpal_wabbit$lifeladder_now, 
                    file_for_match_vowpal_wabbit$lifeladder_future, file_for_match_vowpal_wabbit$polviews,file_for_match_vowpal_wabbit$future_of_econ,
                    file_for_match_vowpal_wabbit$city_future,file_for_match_vowpal_wabbit$city_safewater,file_for_match_vowpal_wabbit$purpose,file_for_match_vowpal_wabbit$community, 
                    file_for_match_vowpal_wabbit$physical,file_for_match_vowpal_wabbit$financial,file_for_match_vowpal_wabbit$social,file_for_match_vowpal_wabbit$wellbeing,
                    file_for_match_vowpal_wabbit$satis_current,file_for_match_vowpal_wabbit$worry_food,file_for_match_vowpal_wabbit$worry_hcare,file_for_match_vowpal_wabbit$worry_money,file_for_match_vowpal_wabbit$worry_productive,
                    file_for_match_vowpal_wabbit$worry_todo,file_for_match_vowpal_wabbit$healthprob_yes,file_for_match_vowpal_wabbit$city_safewalk,file_for_match_vowpal_wabbit$city_satis)

write.table(new_file14[-test_index], file = "file_for_match_vowpal_wabbit_ECON_train_sub.tsv", row.names=FALSE, col.names=FALSE, quote = FALSE)
write.table(new_file14[test_index], file = "file_for_match_vowpal_wabbit_ECON_test_sub.tsv", row.names=FALSE, col.names=FALSE, quote = FALSE)

new_file15 <- paste(file_for_match_vowpal_wabbit$employed, file_for_match_vowpal_wabbit$state_of_econ, file_for_match_vowpal_wabbit$satis_future, file_for_match_vowpal_wabbit$lifeladder_now, 
                    file_for_match_vowpal_wabbit$lifeladder_future, file_for_match_vowpal_wabbit$healthprob_days,file_for_match_vowpal_wabbit$polviews,file_for_match_vowpal_wabbit$nchild,
                    file_for_match_vowpal_wabbit$day, file_for_match_vowpal_wabbit$month,
                    file_for_match_vowpal_wabbit$year, file_for_match_vowpal_wabbit$future_of_econ,file_for_match_vowpal_wabbit$city_future,file_for_match_vowpal_wabbit$city_safewater,file_for_match_vowpal_wabbit$purpose,file_for_match_vowpal_wabbit$community, 
                    file_for_match_vowpal_wabbit$physical,file_for_match_vowpal_wabbit$financial,file_for_match_vowpal_wabbit$social,file_for_match_vowpal_wabbit$wellbeing,file_for_match_vowpal_wabbit$qtr,
                    file_for_match_vowpal_wabbit$satis_current,file_for_match_vowpal_wabbit$married,file_for_match_vowpal_wabbit$worry_food,file_for_match_vowpal_wabbit$worry_hcare,file_for_match_vowpal_wabbit$worry_money,file_for_match_vowpal_wabbit$worry_productive,
                    file_for_match_vowpal_wabbit$worry_todo,file_for_match_vowpal_wabbit$healthprob_yes,file_for_match_vowpal_wabbit$city_safewalk,file_for_match_vowpal_wabbit$city_satis,file_for_match_vowpal_wabbit$male,
                    file_for_match_vowpal_wabbit$educ,
                    file_for_match_vowpal_wabbit$race,file_for_match_vowpal_wabbit$st,
                    file_for_match_vowpal_wabbit$time_social, file_for_match_vowpal_wabbit$age,file_for_match_vowpal_wabbit$ps_weight,file_for_match_vowpal_wabbit$ps_height,file_for_match_vowpal_wabbit$ps_bmi,file_for_match_vowpal_wabbit$cons_nondur,
                    file_for_match_vowpal_wabbit$dlhpi, file_for_match_vowpal_wabbit$realgasprice, file_for_match_vowpal_wabbit$lat,file_for_match_vowpal_wabbit$long,
                    sep = "")


write.table(new_file15[-test_index], file = "file_for_match_vowpal_wabbit_ECON_train_lat_long.tsv", row.names=FALSE, col.names=FALSE, quote = FALSE)
write.table(new_file15[test_index], file = "file_for_match_vowpal_wabbit_ECON_test_lat_long.tsv", row.names=FALSE, col.names=FALSE, quote = FALSE)


new_file16 <- paste(file_for_match_vowpal_wabbit$employed, file_for_match_vowpal_wabbit$state_of_econ, file_for_match_vowpal_wabbit$satis_future, file_for_match_vowpal_wabbit$lifeladder_now, 
                    file_for_match_vowpal_wabbit$lifeladder_future, file_for_match_vowpal_wabbit$healthprob_days,file_for_match_vowpal_wabbit$polviews,file_for_match_vowpal_wabbit$nchild,
                    file_for_match_vowpal_wabbit$day, file_for_match_vowpal_wabbit$month,
                    file_for_match_vowpal_wabbit$year, file_for_match_vowpal_wabbit$future_of_econ,file_for_match_vowpal_wabbit$city_future,file_for_match_vowpal_wabbit$city_safewater,file_for_match_vowpal_wabbit$purpose,file_for_match_vowpal_wabbit$community, 
                    file_for_match_vowpal_wabbit$physical,file_for_match_vowpal_wabbit$financial,file_for_match_vowpal_wabbit$social,file_for_match_vowpal_wabbit$wellbeing,file_for_match_vowpal_wabbit$qtr,
                    file_for_match_vowpal_wabbit$satis_current,file_for_match_vowpal_wabbit$married,file_for_match_vowpal_wabbit$worry_food,file_for_match_vowpal_wabbit$worry_hcare,file_for_match_vowpal_wabbit$worry_money,file_for_match_vowpal_wabbit$worry_productive,
                    file_for_match_vowpal_wabbit$worry_todo,file_for_match_vowpal_wabbit$healthprob_yes,file_for_match_vowpal_wabbit$city_safewalk,file_for_match_vowpal_wabbit$city_satis,file_for_match_vowpal_wabbit$male,
                    file_for_match_vowpal_wabbit$educ,
                    file_for_match_vowpal_wabbit$race,file_for_match_vowpal_wabbit$st,
                    file_for_match_vowpal_wabbit$time_social, file_for_match_vowpal_wabbit$age,file_for_match_vowpal_wabbit$ps_weight,file_for_match_vowpal_wabbit$ps_height,file_for_match_vowpal_wabbit$ps_bmi,file_for_match_vowpal_wabbit$cons_nondur,
                    file_for_match_vowpal_wabbit$dlhpi, file_for_match_vowpal_wabbit$realgasprice, file_for_match_vowpal_wabbit$lat,file_for_match_vowpal_wabbit$long,
                    sep = "")


write.table(new_file15[-test_index], file = "file_for_match_vowpal_wabbit_ECON_train_lat_long.tsv", row.names=FALSE, col.names=FALSE, quote = FALSE)
write.table(new_file15[test_index], file = "file_for_match_vowpal_wabbit_ECON_test_lat_long.tsv", row.names=FALSE, col.names=FALSE, quote = FALSE)


new_file17 <- paste(file_for_match_vowpal_wabbit$employed, file_for_match_vowpal_wabbit$state_of_econ, file_for_match_vowpal_wabbit$satis_future, file_for_match_vowpal_wabbit$lifeladder_now, 
                    file_for_match_vowpal_wabbit$lifeladder_future, file_for_match_vowpal_wabbit$healthprob_days,file_for_match_vowpal_wabbit$polviews,file_for_match_vowpal_wabbit$nchild,
                    file_for_match_vowpal_wabbit$county, file_for_match_vowpal_wabbit$met2013, file_for_match_vowpal_wabbit$day, file_for_match_vowpal_wabbit$month,
                    file_for_match_vowpal_wabbit$year, file_for_match_vowpal_wabbit$future_of_econ,file_for_match_vowpal_wabbit$city_future,file_for_match_vowpal_wabbit$city_safewater,file_for_match_vowpal_wabbit$purpose,file_for_match_vowpal_wabbit$community, 
                    file_for_match_vowpal_wabbit$physical,file_for_match_vowpal_wabbit$financial,file_for_match_vowpal_wabbit$social,file_for_match_vowpal_wabbit$wellbeing,file_for_match_vowpal_wabbit$qtr,
                    file_for_match_vowpal_wabbit$satis_current,file_for_match_vowpal_wabbit$married,file_for_match_vowpal_wabbit$worry_food,file_for_match_vowpal_wabbit$worry_hcare,file_for_match_vowpal_wabbit$worry_money,file_for_match_vowpal_wabbit$worry_productive,
                    file_for_match_vowpal_wabbit$worry_todo,file_for_match_vowpal_wabbit$healthprob_yes,file_for_match_vowpal_wabbit$city_safewalk,file_for_match_vowpal_wabbit$city_satis,file_for_match_vowpal_wabbit$male,
                    file_for_match_vowpal_wabbit$educ,
                    file_for_match_vowpal_wabbit$race,file_for_match_vowpal_wabbit$st,
                    file_for_match_vowpal_wabbit$time_social, file_for_match_vowpal_wabbit$age,file_for_match_vowpal_wabbit$ps_weight,file_for_match_vowpal_wabbit$ps_height,file_for_match_vowpal_wabbit$ps_bmi,file_for_match_vowpal_wabbit$COMB_WEIGHT,file_for_match_vowpal_wabbit$cons_nondur,
                    file_for_match_vowpal_wabbit$dlhpi, file_for_match_vowpal_wabbit$realgasprice, file_for_match_vowpal_wabbit$lat, file_for_match_vowpal_wabbit$long, file_for_match_vowpal_wabbit$zip,
                    sep = "")


write.table(new_file17[-test_index], file = "file_for_match_vowpal_wabbit_ECON_train_zip.tsv", row.names=FALSE, col.names=FALSE, quote = FALSE)
write.table(new_file17[test_index], file = "file_for_match_vowpal_wabbit_ECON_test_zip.tsv", row.names=FALSE, col.names=FALSE, quote = FALSE)
