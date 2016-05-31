# Classify new document

#return data.frame with topic and token
classifyDoc <- function(doc, phi){
  #naive find max
  doctokens <- createDTM(doc)
  commonTokens <-intersect(doctokens$dimnames$Terms, dtm$dimnames$Terms)
  #should specify the real topic term distribution
  matchMatrix <- phi[,commonTokens]
  ##Find the topics with the best term distribution for terms in this document
  Topics <- c()
  for(i in 1:length(commonTokens)){
    Topics <- c(Topics, which.max(matchMatrix[,i]))
  }
  return(data.frame(Topics,commonTokens))
}
