#Huber Lukas

#measure Pachinko speed

executeFitting <- function(dtm){
  pachinkoElement <- pachinko$new()
  pachinkoElement$pachinko(supTop = 5,subTop = 5,alSum = 10,beta = 0.1)
  pachinkoElement$estimate(dtm = dtm,numIterations = 1,optimizeInterval = 2)
  pachinkoElement
}