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

url <- "board.netdoktor.de"

netDoktorScraper("board.netdoktor.de")

scrapeThematic <- function(url, postfix){
  SOURCE <-  getURL(url,encoding="UTF-8") # Specify encoding when dealing with non-latin characters
  PARSED <- htmlParse(SOURCE)
  ## scroll through threads
  nextPage <- xpathSApply(PARSED, "//div[@class='pageNavArrowsRight']/a/@href")
  previous <- NULL
  if(!is.null(nextPage)){previous <- scrapeThematic(url, postfix + nextPage)}
  
  title <- xpathSApply(PARSED, "//span[contains(@itemprop,'itemListElement')]",xmlValue)
  link <- xpathSApply(PARSED, "//span[contains(@itemprop, 'itemListElement')]/a/@href")
  
  ### call for each thread
  
}

scrapeContent <- function(url){
  SOURCE <-  getURL(url,encoding="UTF-8") # Specify encoding when dealing with non-latin characters
  PARSED <- htmlParse(SOURCE)
  
  title <- xpathSApply(PARSED, "//div[@class='titleBar']/h1")
  
  author <- xpathSApply(PARSED, "//div[@class='userText']/a", xmlValue)
  text <- xpathSApply(PARSED, "//div[@class='messageContent']/article/blockquote", xmlValue)
  date <- xpathSApply(PARSED, "//span[@itemprop='dateCreated']/span[@class='DateTime']/@title")
  relatedEntries <- xpathSApply(PARSED, "//div[@class='title']/a/@href")
  return(list(title=tile,
              author=author,
              text=text,
              date=date,
              relatedEntries=relatedEntries))
}