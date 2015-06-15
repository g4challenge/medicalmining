#Test.R

#if you are running it on it's own, change all paths
source("../tmscript.R")
load("../data/docs.file")

tmsciptFasade <- function(
  tolower__ = TRUE,
  removePunctuation__ = TRUE,
  removeNumbers__ = TRUE,
  stopwords__ = stopwords("de"),
  stemming__ = TRUE,
  sparsity__ = 0.99,
  burnin__ = 1,
  iter__ = 1,
  keep__ = 50
  ){
  # create dtm
  dtm <- createDTM(
    docs,
    list(
      tolower = tolower__,
      removePunctuation = removePunctuation__,
      removeNumbers = removeNumbers__,
      stopwords = stopwords("de"),
      stemming = stemming__,
      weighting = weightTf
    ), 
    sparsity = 0.99
  )
  
  # create models
  models <- getModels(
    dtm,
    burnin = burnin__,
    iter = iter__,
    keep = keep__,
    ks = seq(20, 28, by = 1),
    sel.method = "Gibbs"  
  )
  
  # select best model and create json
  bestModel <- getBestModel(
    models,
    burnin = burnin__, 
    keep = keep__,
    ks = seq(20, 28, by=1)
  )
  
  ## create html
  ## removien eyes_lda folder is not needed
  unlink("../data/eyes_lda", recursive = TRUE, force = FALSE)
  json <- getJSON(bestModel)
  serVis(json, out.dir="../data/eyes_lda", open.browser = FALSE)
}


tmsciptFasade(
  tolower__ = TRUE,
  removePunctuation__ = TRUE,
  removeNumbers__ = TRUE,
  stopwords__ = stopwords("de"),
  stemming__ = TRUE,
  sparsity__ = 0.99,
  burnin__ = 1,
  iter__ = 1,
  keep__ = 50
)