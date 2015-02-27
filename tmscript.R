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
library(elife)
library(SnowballC)
library(stringr)



#Preprocess the text and convert to document-term matrix
dtm.control <- list(
  tolower = T,
  removePunctuation = TRUE,
  removeNumbers = TRUE,
  stopwords = stopwords("de"),
  stemming = T,
  weighting = weightTf
)

corp <- VCorpus(VectorSource(docs.cleared))
dtm <- DocumentTermMatrix(corp, control = dtm.control)
dim(dtm)
dtm <- removeSparseTerms(dtm, 0.99)
dim(dtm)

#### Remove empty documents
rowTotals <- apply(dtm , 1, sum)
dtm.new <- dtm[rowTotals>0, ]

# Fit models and find an optimal number of topics as suggested by Ben Marmick --
# http://stackoverflow.com/questions/21355156/topic-models-cross-validation-with-loglikelihood-or-perplexity/21394092#21394092
harmonicMean <- function(logLikelihoods, precision = 2000L) {
  llMed <- median(logLikelihoods)
  as.double(llMed - log(mean(exp(-mpfr(logLikelihoods,
                                       prec = precision) + llMed))))
}
burnin <- 100
iter <- 100
keep <- 50
ks <- seq(20, 80, by = 1)

ktemp <-20
### Parallel
library(parallel)
# Calculate the number of cores
no_cores <- detectCores() - 1

LDAt <- get("LDA")
# Initiate cluster
cl <- makeCluster(no_cores)
clusterExport(cl, "dtm.new") # Document term matrix
clusterExport(cl, "burnin") # burnin default 1000
clusterExport(cl, "iter") # iter default 1000
clusterExport(cl, "keep") # keep default 50
clusterExport(cl, "LDAt")
models <- parLapply(cl, ks, function(k) LDAt(dtm.new, k, method = "Gibbs", control = list(burnin = burnin, iter = iter, keep = keep)))

stopCluster(cl)

#models <- lapply(ks, function(k) LDA(dtm.new, k, method = "Gibbs", control = list(burnin = burnin, iter = iter, keep = keep)))
logLiks <- lapply(models, function(L)  L@logLiks[-c(1:(burnin/keep))])
hm <- sapply(logLiks, function(h) harmonicMean(h))

##edit by me
k = sapply(models, function(L) sum(length(L@beta) + length(L@gamma)))
AICs = -2*hm + 2*k

plot(ks, hm, type = "l")
opt <- models[which.max(hm)][[1]]

# Extract the 'guts' of the optimal model
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

### Get doc.length
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

# Run the visualization locally using LDAvis
#z <- check.inputs(K=max(topic.id), W=max(token.id), phi, token.frequency, vocab, topic.proportion)
#with(z, runShiny(phi, token.frequency, vocab, topic.proportion))

#library(shiny); runApp(system.file('shiny', 'hover', package='LDAtools'))

json <- createJSON(phi, theta, doc.length, vocab, token.frequency)

#json <- with(z, createJSON(K=max(topic.id), phi, token.frequency, 
#                           vocab, topic.proportion))
serVis(json, out.dir="nurs_lda", open.browser = T)
