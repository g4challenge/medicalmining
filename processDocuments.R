
getDocument <- function(content){
  clearcontent <- content[-1]
  contentTitle <- as.vector(unlist(content[1]))
  ### remove related entries
  clearcontent <- clearcontent[-4]
  ##relatedEntries <- as.vector(unlist(content[5]))
  
  
  #### create Cleansed Content
  dfcontent <- data.frame(matrix(unlist(clearcontent), nrow=3, byrow=T), stringsAsFactors = F)
  #datum <- content$date[[2]]
  #date <- strptime(datum, "%d. %B %Y um %H:%M Uhr")
  
  ### create a Document
  doc <- paste(gsub("[\t\n]", "", x=dfcontent[2,], useBytes = T), sep="", collapse = " NEXTENTRY ")
  return(c(contentTitle, doc))
}


getAllDocumentsofThematic <- function(df.threads){
  doc.list <- list()
  title.list <- list()
  ### Loop over Threads and get Content
  for(j in 1:100){   #length(df.threads)){
    #j <- 4
    content <- scrapeContent(paste(url,"/" ,df.threads[2,j], sep=""))
    doc <- getDocument(content)
    title.list <- list(title.list, list(doc[1]))
    doc.list <- list(doc.list, list(doc[2]))
  }
  return(doc.list)
}

