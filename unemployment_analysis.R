#Post hoc unemployment analysis

#This file is to generate USA Map plots of the location bias in Gallup data

library(raster)

setwd("~/Box Sync/Data_for_341/Vowpal_wabbit_files")
results_sim <- fread("predictor_ECON_sim.txt")
results_sim$V1 <- ifelse(results_sim$V1 > 0, 1, 0)


#Actual
df.test = getData("file_for_match_vowpal_wabbit_ECON11.tsv","predictor_ECON11_actual.txt")
df.test$Prediction_b <- ifelse(df.test$Predicted > 0, 1, 0)
df.test$Actual_b <- ifelse(df.test$Actual > 0, 1, 0)


mean(results_sim$V1) # Simulated Employment
mean(df.test$Actual_b) # Actual Employment via Gallup 
mean(df.test$Prediction_b) #Predicted Employment via Gallup 


usa <- map("usa")


gg1 <- ggplot() + geom_polygon(data = usa, aes(x=long, y = lat, group = group)) + 
  coord_fixed(1.3)

map("world", c("hawaii"), boundary = TRUE, col=8, add = TRUE, fill=TRUE )
map("world", c("USA:Alaska"), boundary = TRUE, col='orange', add = TRUE, fill=TRUE )


#Plot 1000 points
g1k <- gallup[200000:201000,]

gg2 <- gg1 + 
  geom_point(data = gallup, aes(x = long, y = lat), color = "yellow", size = 1)

ggsave(plot = gg2, filename = "Full_map.png", width = 10, height = 7)

gg1 + 
  geom_point(data = sim[0:1000,], aes(x = V8, y = V7), color = "yellow", size = 1)