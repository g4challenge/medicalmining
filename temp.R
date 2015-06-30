library(streamgraph)
packageVersion("streamgraph")
library(dplyr)
source("memiMongo.R")

df <- read.csv("/Users/lukas/Downloads/tmp/stream2.csv")

df <- getPostsAsCSV()
df2 <- read.csv("test.csv")
df2 <- df2[, -1]
  
write.csv(df, file="test.csv")

  
df2 %>%
  streamgraph("topic", "size", "date") %>%
  sg_axis_x(1, "date", "%Y") %>%
  sg_colors("PuOr")%>%
  sg_legend(show=TRUE, label="Topic: ")
