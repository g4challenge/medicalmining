# Classify new document

#return data.frame with topic and token
classifyDoc <- function(doc, phi){
  #naive find max
  doctokens <- createDTM(doc)
  commonTokens <-intersect(doctokens$dimnames$Terms, dtm$dimnames$Terms)
  #should specify the real topic term distribution
  matchMatrix <- phi[,commonTokens]
  Topics <- c()
  for(i in 1:length(commonTokens)){
    Topics <- c(Topics, which.max(matchMatrix[,i]))
  }
  return(data.frame(Topics,commonTokens))
}


#doc <- "Bei der U8 wurde diese Untersuchung vorgenommen und es wurde uns mitgeteilt, dass wir einen Augenarzt mit dem Kind aufsuchen sollen. Beim Sehtest hat er alles gesehen, aber diese Untersuchung hat eine Sehschwäche ergeben. Braucht er nun eine Brille oder wie geht es weiter? Was bedeutet \"Auge abkleben\" und Sehschule, wie muss man sich das vorstellen?
#Mit diesem Verfahren kann man erkennen inwieweit die Augen zusammen spielen, bzw. ob ein Auge weitsichtig ist und das andere beispielsweise kurzsichtig. Abkleben ist, wenn ein Auge sehr dominant ist und das andere dann sozusagen \"nichts\" mehr machen muss. Wenn das starke Auge abgeklebt wird, lernt das andere auch wieder was zu tun.
#"
