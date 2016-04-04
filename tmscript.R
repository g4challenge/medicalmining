#### Huber Lukas
#### 2015
#### Script to run Topic Modelling


## Topic Models 
library(shiny)
library(LDAviz)
library(LDAtools)
library(LDAvis)
library(topicmodels)
library(tm)
library(Rmpfr)
library(SnowballC)
library(stringr)
library(RJSONIO)

createDTM <- function(
  docs.cleared,
  dtm.control = list(
    tolower = TRUE,
    removePunctuation = TRUE,
    removeNumbers = TRUE,
    stopwords = stopwords("de"),
    stemming = TRUE,
    weighting = weightTf
  ),
  sparsity = 0.99){
  #Create Corpus from list and get Document Term Matrix
  corp <- VCorpus(VectorSource(docs.cleared))
  dtm <- DocumentTermMatrix(corp, control = dtm.control)
  #dim(dtm)
  dtm <- removeSparseTerms(dtm, sparsity)
  #dim(dtm)
  
  #### Remove empty documents
  rowTotals <- apply(dtm , 1, sum)
  dtm <- dtm[rowTotals>0, ]
  
  return(dtm)
}
# #Preprocess the text and convert to document-term matrix
# dtm.control <- list(
#   tolower = T,
#   removePunctuation = TRUE,
#   removeNumbers = TRUE,
#   stopwords = stopwords("de"),
#   stemming = T,
#   weighting = weightTf
# )


# Fit models and find an optimal number of topics as suggested by Ben Marmick --
# http://stackoverflow.com/questions/21355156/topic-models-cross-validation-with-loglikelihood-or-perplexity/21394092#21394092
harmonicMean <- function(
  logLikelihoods, 
  precision = 2000L
) {
  llMed <- median(logLikelihoods)
  result <- as.double(llMed - log(mean(exp(-mpfr(logLikelihoods,
                                                 prec = precision) + llMed))))
  if(is.na(result)){
    return(0.0)
  }
  return(result)
}

getCTM <- function(dtm,
                   cg=list(iter.max=10,
                           tol=10^-5),
                   em=list(iter.max=10),
                   var=list(iter.max=10),
                   ks=seq(20,28, by=1)){
  library(parallel)
  # Calculate the number of cores
  no_cores <- detectCores()-1
  CTMt <- get("CTM")
  # Initiate cluster
  cl <- makeCluster(no_cores)
  clusterExport(cl, "dtm")
  clusterExport(cl, "cg", envir = environment()) # burnin default 1000
  clusterExport(cl, "em", envir = environment()) # iter default 1000
  clusterExport(cl, "var", envir = environment()) # keep default 50
  clusterExport(cl, "CTMt", envir = environment())
  ctm <- parLapply(cl, ks, function(k) CTMt(dtm, k=ks, control = list(cg=cg, em=em, var=var)))
  stopCluster(cl)
  return(ctm)
}


getLDAModels <- function(
  dtm,
  burnin = 1,
  iter = 1,
  keep = 50,
  ks = seq(20, 28, by = 1),
  sel.method = "Gibbs"
){ 
  ## Parameter checking
  if(sel.method == "VEM") {
  }
  
  
  
  ####### Parallel execution of model fitting
  library(parallel)
  # Calculate the number of cores
  no_cores <- detectCores()-1
  
  LDAt <- get("LDA")
  
  # Initiate cluster
  cl <- makeCluster(no_cores)
  clusterExport(cl, "dtm") # Document term matrix
  clusterExport(cl, "burnin", envir = environment()) # burnin default 1000
  clusterExport(cl, "iter", envir = environment()) # iter default 1000
  clusterExport(cl, "keep", envir = environment()) # keep default 50
  clusterExport(cl, "LDAt", envir = environment())
  if(sel.method == "VEM") {
    models <- parLapply(cl, ks, function(k) LDAt(dtm, k, method= sel.method, control=list(keep = keep, var=var, em=)))
  }
  else{
    models <- parLapply(cl, ks, function(k) LDAt(dtm, k, method = sel.method, control = list(burnin = burnin, iter = iter, keep = keep)))
  }
  stopCluster(cl)
  #### END Parallel execution
  
  return(models)
}

### Select the "best" model
getBestModel <- function(
  models, 
  burnin=1, 
  keep=50,
  ks = seq(20,28, by=1)
){
  logLiks <- lapply(models, function(L)  L@logLiks[-c(1:(burnin/keep))])
  hm <- sapply(logLiks, function(h) harmonicMean(h))
  
  ##edit by me obsolete
  #k = sapply(models, function(L) sum(length(L@beta) + length(L@gamma)))
  #AICs = -2*hm + 2*k
  
  ## plot the harmonic mean
  #TODO show plot
  #plot(ks, hm, type = "l")
  ## select the optimal model
  opt <- models[which.max(hm)][[1]]
  return(opt)
}
# Extract the 'guts' of the optimal model

getJSON <- function(opt){
  doc.id <- opt@wordassignments$i
  token.id <- opt@wordassignments$j
  topic.id <- opt@wordassignments$v
  vocab <- opt@terms
  
  # Get the phi matrix using LDAviz
  dat <- getProbs(token.id, doc.id, topic.id, vocab, K = max(topic.id), sort.topics = "byTerms")
  phi <- (dat$phi.hat)
  theta<- (dat$theta.hat)
  # NOTE TO SELF: these things have to be numeric vectors or else runVis() will break...add a check in check.inputs
  token.frequency <- as.numeric(table(token.id))
  topic.id <- dat$topic.id
  topic.proportion <- as.numeric(table(topic.id)/length(topic.id))
  
  doc.length <- getDocLength(doc.id)
  # Run the visualization locally using LDAvis
  #library(parallel)
  # Calculate the number of cores
  #no_cores <- 8
  
  # Initiate cluster
  #cl <- makeCluster(no_cores)
  
  json <- createJSON(phi, theta, doc.length, vocab, token.frequency)
  #stopCluster(cl)
  return(json)
}

getDocLength <- function(doc.id){
  ### Get doc.length for creating JSON
  lastDoc <- 1
  doc.length <- c()
  count <- 0
  for(i in 1:length(doc.id)){
    if(doc.id[i]==lastDoc){
      count <- count +1
    }
    else{
      doc.length <- c(doc.length, count)
      count <- 0
      lastDoc <- doc.id[i]
    }
    
    if(i==length(doc.id)){  
      doc.length <- c(doc.length,count)
      count <- 0
    }
  }
  return(doc.length)
}

## TODO refactor to serve this in shinydashboard.
#serVis(json, out.dir="eyes_lda", open.browser = T)
