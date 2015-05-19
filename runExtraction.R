#### Lukas Huber 
#### 2015
#### Example script how to run an extraction
url <- "board.netdoktor.de"
thematics <- netDoktorScraper(url)
df <- data.frame(matrix(unlist(thematics), nrow=2, byrow=T), stringsAsFactors = F)

## Todo implement control structure and pack it into a function
## Loop over thematics and get Threads
i <- 4
threads <- scrapeThematic(url, df[2,i])
df.threads <- data.frame(matrix(unlist(threads), nrow=2, byrow=T), stringsAsFactors = F)

docs <- getAllDocumentsofThematic(df.threads[,1:10])

for(i in 1:length(df.threads[,1:50])){
  result <- scrapeContent(paste(url,"/" ,df.threads[2,i], sep=""))
  #setSimpleText(title = result$title, author = result$author, text = result$text, date = result$date)
  setThread(result$title, result$posts)
}

# Just get a few documents
#docs <- getAllDocumentsofThematic(df.threads[, 1:50])

# Just test script for single url
#url <- "board.netdoktor.de/beitrag/auf-einem-auge-heller-sehen-wie-kommt-das.249825/"
#scrapeContent(url)

# Clear the wrong added NEXTENTRY as they are not used at the moment
docs.cleared <- lapply(docs, clearNE)
### Augencontent

# Save the file to harddisk should be stored in database
#write.csv(docs.cleared, file="augen2015-2-25.csv", sep="|", fileEncoding="UTF-8")
