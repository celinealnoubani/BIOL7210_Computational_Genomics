#create environment
library(tidyverse)
library(igraph)
library(ape)

#calculate average of mash distance
mashdist_avg = mean(mash_output$V3)
#Calculate average of ANI and add to dataframe
ANI_avg = 1 - mashdist_avg
mash_output$ANI <- 1 - mash_output$V3
#rename column 2 to only the isolate name
mash_output$V2 <- sub(".*/([^/]+)\\.fa$", "\\1", mash_output$V2)
mash_output$V2 <- sub("_.*", "", mash_output$V2)

#create mash results figure
ggplot(data = mash_output, aes(x = V2, y = ANI)) +
  geom_point(color = "purple1") +
  theme(axis.text.x = element_text(angle = 45, hjust = 1)) +
  labs( title = "ANI scores from Mash", x = "Isolate")

#calculate distance matrix for ANI scores  
ani_matrix <- as.matrix(dist(mash_output$ANI))
rownames(ani_matrix) <- mash_output$V2
colnames(ani_matrix) <- mash_output$V2

# Perform hierarchical clustering using the ANI distance matrix
hc <- hclust(as.dist(ani_matrix), method = "average")

#create .nwk tree file to visualize using preferred software (I chose Figtree v1.4.4) 
hc_phylo <- as.phylo(hc)
plot(hc_phylo, show.tip.label = TRUE, cex = 0.6)
write.tree(hc_phylo, file = "ani_tree.nwk")
