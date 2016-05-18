#tmscriptFacade.R

#if you are running it on it's own, change all paths
#source("../tmscript.R")
load("../data/docs.file")

debug <- T

if(debug == F){
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
models <- getModels(
  dtm,
  burnin = 1,
  iter = 1,
  keep = 50,
  ks = seq(20, 28, by = 1),
  sel.method = "Gibbs"  
)

models <- getCTM(dtm=dtm)

# select best model and create json
bestModel <- getBestModel(
  models,
  burnin = 1, 
  keep = 50,
  ks = seq(20, 28, by=1)
)

## create html
## removien eyes_lda folder is not needed
unlink("../data/eyes_lda", recursive = TRUE, force = FALSE)
json <- getJSON(bestModel)
serVis(json, out.dir="../data/eyes_lda", open.browser = FALSE)

}
