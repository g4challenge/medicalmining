library(rmongodb)

host <- "127.0.0.1"
db <- "MeMi"

mongo <- mongo.create(host=host , db=db , username="")

getDocumentList <- function(db, host){
  cursor <- mongo.find(mongo, namespace, query)
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