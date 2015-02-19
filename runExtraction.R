
url <- "board.netdoktor.de"
thematics <- netDoktorScraper(url)
df <- data.frame(matrix(unlist(thematics), nrow=2, byrow=T), stringsAsFactors = F)

## Loop over thematics and get Threads
i <- 4
threads <- scrapeThematic(url, df[2,i])
df.threads <- data.frame(matrix(unlist(threads), nrow=2, byrow=T), stringsAsFactors = F)

docs <- getAllDocumentsofThematic(df.threads)

docs <- getAllDocumentsofThematic(df.threads[, 1:100])

url <- "board.netdoktor.de/beitrag/auf-einem-auge-heller-sehen-wie-kommt-das.249825/"
scrapeContent(url)
