#Test.R

#if you are running it on it's own, change all paths
source("../tmscript.R")
load("../data/docs.file")

createJSON <- function(){
  # create dtm
  dtm <-createDTM(
    docs,
    list(
      tolower = TRUE,
      removePunctuation = TRUE,
      removeNumbers = TRUE,
      stopwords = stopwords("de"),
      stemming = TRUE,
      weighting = weightTf
    ), 
    sparsity = 0.99
  )
  
  # create models
  getModels(
    dtm,
    burnin = 1,
    iter = 1,
    keep = 50,
    ks = seq(20, 28, by = 1),
    sel.method = "Gibbs"  
  )
  # select best model and create json
  getBestModel(
    models,
    burnin = 1, 
    keep = 50,
    ks = seq(20, 28, by=1)
  )
  
  json <-getJSON(bestModel)
  
  return(json)
}



# create html
# removien eyes_lda folder is not needed
#unlink("data/eyes_lda", recursive = TRUE, force = FALSE)

#serVis(json, out.dir="data/eyes_lda", open.browser = FALSE)

