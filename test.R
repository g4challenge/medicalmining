#Test.R
source("tmscript.R")
load("docs.file")
dtm = createDTM(docs)

#print(c("test", as.character(dtm)))    
models <- getModels(dtm)
bestModel <- getBestModel(model)
json <-getJSON(bestModel)
serVis(json, out.dir="eyes_lda", open.browser = F)