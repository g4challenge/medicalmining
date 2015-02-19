library(RCurl)
library(XML)
netDoktorScraper <- function(url){
  SOURCE <-  getURL(url,encoding="UTF-8") # Specify encoding when dealing with non-latin characters
  PARSED <- htmlParse(SOURCE)
  title <- xpathSApply(PARSED, "//span[contains(@itemprop,'itemListElement')]",xmlValue)
  link <- xpathSApply(PARSED, "//span[contains(@itemprop, 'itemListElement')]/a/@href")
  #time  <- xpathSApply(PARSED, "//time[@itemprop='datePublished']/@datetime")
  #tags <- unique(xpathSApply(PARSED, "//a[@rel='tag']",xmlValue))
  #text <- xpathSApply(PARSED, "//div[@id='article-body-blocks']/p",xmlValue)
  return(list(title=title,
              link=link))
              #time=time,
              #tags=paste(tags,collapse="|")
              #,text=paste(text,collapse="|")))
}



scrapeThematic <- function(url, postfix){
  SOURCE <- getURL(paste(url, "/", postfix, sep=""),encoding="UTF-8") # Specify encoding when dealing with non-latin characters
  PARSED <- htmlParse(SOURCE)
  ## scroll through threads
  nextPage <- xpathSApply(PARSED, "//div[@class='pageNavArrowsRight']/a/@href")
  previous <- NULL
  if(!is.null(nextPage)){previous <- scrapeThematic(url, nextPage[1])}
  
  title <- xpathSApply(PARSED, "//div[@class='title']/a[contains(@itemprop, 'itemListElement')]",xmlValue)
  link <- xpathSApply(PARSED, "//div[@class='title']/a[contains(@itemprop, 'itemListElement')]/@href")
  #print(title)
  return(list(title=c(title, previous$title),
              link=c(link, previous$link)))
}

scrapeContent <- function(url){
  SOURCE <-  getURL(url,encoding="UTF-8") # Specify encoding when dealing with non-latin characters
  PARSED <- htmlParse(SOURCE)
  
  title <- xpathSApply(PARSED, "//div[@class='titleBar']/h1", xmlValue)
  
  author <- xpathSApply(PARSED, "//div[@class='userText']/a", xmlValue)
  entrycount <- length(author)
  ## introduce length control for text date and author
  text <- xpathSApply(PARSED, "//div[@class='messageContent']/article/blockquote", xmlValue)
  textcount <- length(text)
  
  ### Attention order is incorrect
  if(entrycount < textcount){
    author <- c(author, xpathSApply(PARSED, "//div[@class='userText']/span", xmlValue))
    entrycount <- length(author)
  }
  
  date <- xpathSApply(PARSED, "//span[@itemprop='dateCreated']/span[@class='DateTime']/@title")
  
  if(length(date) != entrycount){
    datestring <- xpathSApply(PARSED, "//span[@itemprop='dateCreated']/abbr[@class='DateTime']/@data-datestring")
    timestring <- xpathSApply(PARSED, "//span[@itemprop='dateCreated']/abbr[@class='DateTime']/@data-timestring")
    if(is.null(datestring)) date <- rep(0, entrycount)
    else{
    for(i in 1:(entrycount - length(date))){
      date <- c(date, paste(datestring[i], " um ", timestring[i], " Uhr", sep=""))
    print(datestring[i])
    print(timestring[i])
    }
    #print(date)
    if(length(date)!= entrycount){
      print("error")
    }
  }
  }
  relatedEntries <- xpathSApply(PARSED, "//div[@class='title']/a/@href")
  return(list(title=title,
              author=author,
              text=text,
              date=date,
              relatedEntries=relatedEntries))
}