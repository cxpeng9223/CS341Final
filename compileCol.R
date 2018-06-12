setwd("/Users/yiyangli/Desktop/cs341/data/")
library(data.table)
gallup <- read.csv(file="gallup_all.csv", header=TRUE, sep=",")
#gallup <- fread("gallup_all.csv")
gallup <- gallup[-9]
#factor(gallup$state_of_econ)

file_for_match_vowpal_wabbit <- gallup
file_for_match <- gallup

file_for_match_vowpal_wabbit$educ <- ifelse(file_for_match$educ_coll == 1, "edu_coll", ifelse(file_for_match$educ_hs, "educ_hs", ifelse(file_for_match$educ_nohs == 1, "educ_nohs", ifelse(file_for_match$educ_postgrad==1, "educ_post", ifelse(file_for_match$educ_somecoll==1,"somecoll", ifelse(file_for_match$educ_tech==1,"educ_tech",""))))))
file_for_match_vowpal_wabbit$race <- ifelse(file_for_match$race_asian,"asian",ifelse(file_for_match$race_black,"black",ifelse(file_for_match$race_hisp,"hisp",ifelse(file_for_match$race_white,"white",""))))

write.table(file_for_match_vowpal_wabbit, "/Users/yiyangli/Documents/GitHub/cs341/gallup_all_compileCol.txt", sep=",")
#write.table(mydata, "c:/mydata.txt", sep="\t")