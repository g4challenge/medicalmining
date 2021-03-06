library(rmongodb)
library(plyr) 

host<- ""
db <- ""
username <- ""
password <- ""

mongo <- mongo.create(host=host , db=db , username=username, password=password)

getDocumentList <- function(){
  if(mongo.is.connected(mongo) == TRUE) {
    collection <- "docs"
    namespace <- paste(db, collection, sep=".")
    
    dist <- mongo.distinct(mongo, namespace, "text")
    return(as.list(dist))
  }else{
    print("not connected")
  }
}

#returns list of stopwords
getAllStopwords <- function(){
  if(mongo.is.connected(mongo) == TRUE) {
    collection <- "stopwords"
    namespace <- paste(db, collection, sep=".")
    
    dist <- mongo.distinct(mongo, namespace, "stopword")
    return(as.list(dist))
  }else{
    print("not connected")
  }
}

#write stopword into db
setAdditional <- function(word){
  if(mongo.is.connected(mongo) == TRUE) {
    collection <- "stopwords"
    namespace <- paste(db, collection, sep=".")
    
    one <- mongo.find.one(mongo, namespace,  paste(c('{"stopword":\"', word, "\"}"), sep="", collapse=""))
    if(length(one)==0){
      b <- mongo.bson.from.list(list(stopword=word))
      ok <- mongo.insert(mongo, namespace, b)
    }
  }else{
    print("not connected")
  }
}

setPost <- function(author, text, date){
  if(mongo.is.connected(mongo) == TRUE) {
    collection <- "post"
    namespace <- paste(db, collection, sep=".")
    
    b <- mongo.bson.from.list(list(author=author, text=text, date=date))
    ok <- mongo.insert(mongo, namespace, b)
    
  }else{
    print("not connected")
  }
}

getPosts <- function(){
  if(mongo.is.connected(mongo) == TRUE) {
    collection <- "thread"
    namespace <- paste(db, collection, sep=".")
    #dist <- mongo.distinct(mongo, namespace)
    dist <- mongo.find.all(mongo, namespace, query =  '{"posts.date":{"$exists":1}}',fields = list('posts.text'=1, 'posts.date' = 1, '_id' = 0, 'topic'=1))
    return(dist)
  }else{
    print("not connected")
  }
}

getPostsAsCSV <- function(){
  data <- getPosts()
  topics <- NULL
  dates <- NULL
  sizes <- NULL
  for(topic in data){
    for(post in topic$posts){
      if (!is.na(as.character(strptime(post$date, format="%Y-%m-%d")))){
        topics <- c(topics, topic$topic)
        dates <- c(dates, as.character(strptime(post$date, format="%Y-%m-%d")))
        sizes <- c(sizes, sapply(gregexpr("\\W+", post$text), length) + 1)
      }
    }
  }
  df <- data.frame(dates, topics, sizes)
  names(df) <- c("date", "topic", "size")
  
  return(df)
}

setThread <- function(topic, post){
  if(mongo.is.connected(mongo) == TRUE) {
    collection <- "thread"
    namespace <- paste(db, collection, sep=".")
    
    #subCollection <- mongo.bson.from.list(post)
    #list(author=unlist(lapply(post, function(xl) xl$author)), text=unlist(lapply(post, function(xl) xl$text)), date=unlist(lapply(post, function(xl) xl$date))))
    one <- mongo.find.one(mongo, namespace,  paste(c('{"topic":\"', topic, "\"}"), sep="", collapse=""))
    if(length(one)==0){
      b <- mongo.bson.from.list(list(topic=topic, posts=post))
      ok <- mongo.insert(mongo, namespace, b)
    }
  }else{
    print("not connected")
  }
}
