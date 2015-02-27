Topic Modelling of Medical Discussions
========================================================
author: Lukas Huber
date: March 2nd 2015

Motivation
========================================================
- natural language processing requires complex tools
- vast ammount of written text remains unanalyzed

- online boards share patients view on diseases
- Question: Can you find an structure within threads?
- Question: Is it possible to find new relations between diseases?

Content
========================================================
- Web Scraping
- Terms
- Topic Modeling
- Latent Dirichlet allocation
- Optimization of topics
- Data collection and preprocessing
- 


Web Scraping
========================================================
- Data generated from web content

Terms
========================================================
- A *word* is the basic discrete unit from a *vocabulary* indexed {1,...,V}
- A *document* is a sequence of *N* words $\mathbf{w} = (w_{1},w_{2},...,w_{n})$
- A *corpus* is a collection of *M* documents $\mathbf{D}= (\mathbf{w_{1}},\mathbf{w_{2}},...,\mathbf{w_{m}})$

Topic Modeling
========================================================
![XCKD comic sievert](xckd comic tm.png)
romance (red)
sarcasm (blue)
math (black)
language (green)
***
- statistical mixture model
- each document is a mixture of latent topics
- generative model, based on term frequencies
- bag-of-words models
- extend and build on
 - unigram models (McCallum, Thrun, Mitchell,...)
 - Latent Semantic analysis (Deerwester, Dumais, ...)
 
Latent Dirichlet allocation
========================================================

Optimize number of topics
========================================================

Data collection and preprocessing
========================================================


```r
url <- "board.netdoktor.de"
thematics <- netDoktorScraper(url)
```
Acquire the documents from one thematic

```r
docs <- getAllDocumentsofThematic(df.threads)
docs.cleared <- lapply(docs, clearNE)
```
Get all documents and clear them

Document term-matrice 
========================================================

```r
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
```

Model-generation
========================================================

```r
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
```

Model-fitting
========================================================

```r
logLiks <- lapply(models, function(L)  L@logLiks[-c(1:(burnin/keep))])
hm <- sapply(logLiks, function(h) harmonicMean(h))

plot(ks, hm, type = "l")
```
Model-fitting
===
![Harmonic Mean](20to80topics.png)
Creating the visualisation
===

- phi: 
matrix, with each row containing the distribution over terms for a topic, with as many rows as there are topics in the model, and as many columns as there are terms in the vocabulary. |
- theta: matrix, with each row containing the probability distribution over topics for a document, with as many rows as there are documents in the corpus, and as many columns as there are topics in the model.
- doc.length: integer vector containing the number of tokens in each document of the corpus.
- vocab: character vector of the terms in the vocabulary (in the same order as the columns of phi). Each term must have at least one character.
- term.frequency: integer vector containing the frequency of each term in the vocabulary.
- lambda.step: a value between 0 and 1. Determines the interstep distance in the grid of lambda values over which to iterate when computing relevance. Default is 0.01. Recommended to be between 0.01 and 0.1.
- mds.method: a function that takes phi as an input and outputs a K by 2 data.frame (or matrix). The output approximates the distance between topics. See jsPCA for details on the default method.

Final Product
========================================================




```
processing file: TM Lukas Huber 2015.Rpres
Loading required namespace: servr
serving the directory nurs_lda at http://localhost:4321
Quitting from lines 139-142 (TM Lukas Huber 2015.Rpres) 
Fehler in startServer(host, port, app) : Failed to create server
```
