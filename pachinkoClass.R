# Pachinko temp

library(R6)

pachinko <- R6Class(classname = "pachinkoModel",
                    public= list(
                      numSuperTopics = 0, # number of topics to be fit
                      numSubTopics = 0,
                      
                      alpha = c(0), #Dirichlet(alpha,alpha,) distribution over supertopics
                      alphaSum = 50,
                      subAlphas = matrix(seq(1, 8), nrow=4, ncol=2),
                      subAlphaSums = c(0),
                      beta=0.001, # Prior on per-topic multinomial distribution over words
                      vBeta=0,
                      
                      #Data 
                      ilist = list(), #documents
                      numTypes = 0,
                      numTokens = 0,
                      
                      #Gibbs sampling state
                      superTopics = matrix(), #indexed by document index, sequence index
                      subTopics = matrix(),
                      
                      #Per-document state variables
                      superSubCounts = matrix(), # # of words per super,sub
                      superCounts = c(), # # of words per super
                      superWeights = c(), # the component of the Gibbs update that depends on super-topics
                      subWeights = c(), # the component of the Gibbs update that depends on sub-topics
                      superSubWeights = matrix(), # unnormalized sampling distribution
                      cumulativeSuperWeights = c(), # a cache of the cumulative weight for each super-topic
                      
                      #Per-word type state variables
                      typeSubTopicCounts= matrix(), # indexed by <feature index, topic index>
                      tokensPerSubTopic= c(), # indexed by <topic index>
                      
                      # Histograms for MLE
                      superTopicHistograms = matrix(),  # histogram of # of words per supertopic in documents
                      #  eg, [17][4] is # of docs with 4 words in sT 17...
                      subTopicHistograms = array(0, dim=c(0,0,0)), #for each supertopic, histogram of # of words per subtopic
                      
                      pachinko = function(supTop, subTop, alSum, beta){
                        self$numSuperTopics = supTop
                        self$numSubTopics= subTop
                        
                        self$alphaSum=alSum
                        self$alpha=rep((self$alphaSum/self$numSuperTopics), supTop)
                        
                        #Initialize the sub-topic alphas to a symmetric dirichlet
                        self$subAlphas = array(1.0, dim=c(supTop, subTop))
                        self$subAlphaSums = rep(subTop, supTop)
                        
                        self$beta= beta
                      },
                      
                      estimate = function(dtm, numIterations, optimizeInterval,
                                          showTopicsInterval, outputModelInterval, outputModel, randoms){
                        
                        numDocs = length(documents)
                        numTypes = 1 # size dataalphabet
                    
                        maxTokens = 0
                        
                        # Initialize with random assignments of tokens to topics
                        # and finish allocating self$topics and self$tokens
                        
                        #for all documents
                        numTokens = length(unique(dtm$j))
                        for(i in 1:length(unique(dtm$i))){
                          seq = which(as.vector(dtm[j,])>0)
                          seqlen = length(seq)
                          
                          #Randomly assign tokens to topics
                          for(j in 1:seqlen){
                            # Random super-topic
                            superTopic = sample(which(as.vector(dtm[i,])>0),1)
                            self$superTopics[i,j] = superTopic
                            self$tokensPerSuperTopic[superTopic] <- self$tokensPerSuperTopic[superTopic]+1
                            
                            # Random sub-topic
                            subTopic = sample(which(as.vector(dtm[i,])>0),1)
                            self$subTopics[i,j] = subTopic
                            
                            # update word-type statistics for sub-topic
                            self$typeSubTopicCounts[seq[j],subTopic] <- self$typeSubTopicCounts[seq[j],subTopic] + 1
                            self$tokensPerSubTopic[subTopic] <-  self$tokensPerSubTopic[subTopic] + 1
                            
                            self$tokensPerSuperSubTopic[superTopic, subTopic] = self$tokensPerSuperSubTopic[superTopic, subTopic] + 1
                          }
                          
                          # create Histograms
                          self$superTopicHistograms = array(0, dim = c(self$numSuperTopics, maxTokens +1))
                          self$subTopicHistograms = array(0, dim = c(self$numSuperTopics, self$numSubTopics, maxTokens + 1))
                          
                          # Start the sampler
                          for(i in 1:numIterations){
                            
                          }
                          
                        }
                        
                      },
                      
                      sampleTopicsForAllDocs <- function(){
                        
                      }
                      ))