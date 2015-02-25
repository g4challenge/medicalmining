
getDocument <- function(content){
  if(content =="") return(c("", ""))
  #print(str(content))
  clearcontent <- content[-1]
  contentTitle <- as.vector(unlist(content[1]))
  ### remove related entries
  clearcontent <- clearcontent[-4]
  ##relatedEntries <- as.vector(unlist(content[5]))
  
  
  #### create Cleansed Content
  if(is.null(clearcontent)) return("")
  
  if(is.null(clearcontent$date)){
    clearcontent$date <- rep(0, length(clearcontent$text))
  }
  dfcontent <- tryCatch({
      data.frame(matrix(unlist(clearcontent), nrow=3, byrow=T), stringsAsFactors = F)
                 },
                        error = function(e){
                          print(e)
                          #print(clearcontent)
                         # stop("error")
                        },
                      warning = function(w){
                        #print(w)
                        print(contentTitle)
                        print(clearcontent)
                        data.frame(matrix(unlist(clearcontent), nrow=3, byrow = T), stringsAsFactors = F)
                      }
      )
  #datum <- content$date[[2]]
  #date <- strptime(datum, "%d. %B %Y um %H:%M Uhr")
  #print("test")
  #print(dfcontent)
  ### create a Document
  doc <- paste(gsub("[\t\n]", "", x=dfcontent[2,], useBytes = T), sep="", collapse = " NEXTENTRY ")
  return(c(contentTitle, doc))
}


getAllDocumentsofThematic <- function(df.threads){
  doc.list <- list()
  title.list <- list()
  ### Loop over Threads and get Content
  for(j in 1:length(df.threads)){
    #j <- 4
    content <- scrapeContent(paste(url,"/" ,df.threads[2,j], sep=""))
    doc <- getDocument(content)
    #print(doc)
    title.list <- c(title.list, doc[1])
    doc.list <- c(doc.list, doc[2])
  }
  return(doc.list)
}

clearNE <- function(doc){
  str_replace_all(string = doc, pattern = "NEXTENTRY", replacement = " ")
}
