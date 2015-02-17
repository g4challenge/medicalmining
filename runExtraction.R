
url <- "board.netdoktor.de"

thematics <- netDoktorScraper(url)

df <- data.frame(matrix(unlist(thematics), nrow=2, byrow=T), stringsAsFactors = F)

i <- 4
threads <- scrapeThematic(url, df[2,i])

df2 <- data.frame(matrix(unlist(threads), nrow=2, byrow=T), stringsAsFactors = F)

content <- scrapeContent(paste(url,"/" ,df2[2,4], sep=""))

#### remove title
clearcontent <- content[-1]
contentTitle <- as.vector(unlist(content[1]))
### remove related entries
clearcontent <- clearcontent[-4]
relatedEntries <- as.vector(unlist(content[5]))

#### create Cleansed Content
dfcontent <- data.frame(matrix(unlist(clearcontent), nrow=3, byrow=T), stringsAsFactors = F)
datum <- content$date[[2]]
date <- strptime(datum, "%d. %B %Y um %H:%M Uhr")

### create a Document

doc <- paste(gsub("[\t\n]", "", x=dfcontent[2,], useBytes = T), sep="", collapse = " NEXTENTRY ")
