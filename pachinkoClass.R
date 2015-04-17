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
                            clearHistograms()
                            sampleTopicsForAllDocs(random)
                            
                            if(iterations > 0){
                              #skipped 2 ifs
                              if(optimizeInterval != 0 && (iterations %% outputModelInterval == 0)){
                                for(superTopic in 1:self$numSuperTopics){
                                  learnParameters(self$subAlphas[superTopic],
                                                  self$subTopicHistograms[superTopic],
                                                  self$superTopicHistograms[superTopic])
                                  self$subAlphaSums[superTopic]=0.0
                                  for(subTopic in 1:self$numSubTopics){
                                    self$subAlphaSums[superTopic] <- self$subAlphaSums[superTopic] + self$subAlphas[superTopic, subTopic]
                                  }
                                }
                              }
                            }
                          }
                        }
                        # end of constructor
                      },
                      clearHistograms = function(){
                        for(superTopic in 1:numSuperTopics){
                          self$superTopicHistograms[superTopic] = rep(0, length(self$superTopicHistograms[superTopic]))
                          for(subTopic in 1:numSubTopics){
                            self$subTopicHistograms[superTopic, subTopic] = rep(0, length(self$superTopicHistograms[superTopic, subTopic]))
                          }
                        }
                      },
                      learnParameters = function(parameters, observations, observationLengths){
                        parameterSum = sum(parameters)
                        
                        noZeroLimits= rep(-1, length(observations))
                        
                        #   The histogram arrays go up to the size of the largest document,
                        #		but the non-zero values will almost always cluster in the low end.
                        #		We avoid looping over empty arrays by saving the index of the largest
                        #		non-zero value.

                        for(i in 1:dim(observations)[1]){
                          for(k in 1:dim(observations)[2]){
                            if(observation[i,k] > 0){
                              noZeroLimits[i] = k
                            }
                          }
                        }
                      
                       for(i in 1:200){
                         #Calculate denominator
                         denominator = 0.0
                         currentDigamma = 0.0
                         #Iterate over the histogram
                         for(i in 1:length(observationLengths)){
                           currentDigamma = currentDigamma + 1/(parameterSum + i - 1)
                           denominator = denominator + observationLengths[i] * currentDigamma
                         }
                       }
                       # Calculate the individual parameters
                       parameterSum = 0
                       
                       for(k in 1:length(parameters)){
                         # What's the largest non-zero element in the histogram
                         nonZeroLimit = noZeroLimits[k]
                         
                         # If there are no tokens assigned to this super-sub pair
                         # anywhere in the corpus bail
                         
                         if(nonZeroLimit == -1){
                           parameters[k] = 0.000001
                           parameterSum = parameterSum + 0.000001
                           next
                         }
                         oldParametersK = parameters[k]
                         parameters[k] = 0;
                         currentDigamma = 0;
                         
                         histogram = observations[k]
                         for(i in 1:nonZeroLimit){
                           currentDigamma = currentDigamma + 1/(oldParametersK + i - 1)
                           parameters[k] = parameters[k] + histogram[i] * currentDigamma
                         }
                         
                         parameters[k] = parameters[k] * oldParametersK / denominator
                         parameterSum = parameterSum + parameters[k]
                       }
                      },
                      # One iteration of Gibbs sampling, across all documents.
                      sampleTopicsForAllDocs = function(random){
                        #Loop over every word in the corpus
                        for(di in 1:length(self$superTopics)){
                          sampleTopicsForOneDoc(ilist,
                                                superTopics[di],
                                                subTopics[di],
                                                random)
                        }
                      },
                      sampleTopicsForOneDoc = function(oneDocTokens,
                                                       superTopics,
                                                       subTopics,
                                                       random){
                        for(t in 1:numSuperTopics){
                          self$superSubCounts[t] = rep(0, length(self$superSubCounts))
                        }
                        self$superCounts = rep(0, self$superCounts)
                        
                        #populate topic couns
                        for(si in 1:length(oneDocTokens)){
                          self$superSubCounts[superTopics[si], subTopics[si]] = self$superSubCounts[superTopics[si], subTopics[si]] + 1
                          self$superCounts[superTopics[si]] = self$superCounts[superTopics[si]] + 1
                        }
                        # iterate over the positions(words) in the document
                        for(si in 1:length(oneDocTokens)){
                          type = getIndex(oneDocTokens[si])
                          superTopic = superTopics[si]
                          subTopic = subTopics[si]
                          
                          # Remove this token from all counts
                          self$superSubCounts[superTopic, subTopic] = self$superSubCounts[superTopic, subTopic] - 1
                          self$superCounts[superTopic] = self$superCounts[superTopic] -1
                          self$typeSubTopicCounts[type, subTopics] = self$typeSubTopicCounts[type, subTopics] - 1
                          self$tokensPerSuperTopic[superTopic] = self$tokensPerSuperTopic[superTopic] -1
                          self$tokensPerSubTopic[subTopic] = self$tokensPerSubTopic[subTopic] -1
                          self$tokensPerSuperSubTopic[superTopic, subTopic] = self$tokensPerSuperSubTopic[superTopic, subTopic] - 1
                          
                          # Build a distribution over super-sub topic pairs
                          # for this token
                          
                          # Clear the data structures
                          for(t in 1:self$numSuperTopics){
                            self$superSubWeights[t] = rep(0.0, length(self$superSubWeights[t]))
                          }
                          self$superWeights = rep(0.0, length(self$superWeights))
                          self$subWeights = rep(0.0, length(self$subWeights))
                          self$cumulativeSuperWeights = rep(0.0, self$cumulativeSuperWeights)
                          
                          # The conditional probability of each super-sub pair is proportional
                          #  to an expression with three parts, one that depends only on the 
                          #  super-topic, one that depends only on the sub-topic and the word type,
                          #  and one that depends on the super-sub pair.
                          
                          # Calculate each of the super-only factors first
                          for(superTopic in 1:numSuperTopics){
                            self$superWeights[superTopic] = (self$superCounts[superTopic] + self$alpha[superTopic]) /
                                                            (self$superCounts[superTopic] + self$subAlphaSums[superTopic])
                          }
                          # Next Calculate the sub-only factors
                          
                          for(subTopic in 1:numSubTopics){
                            self$subWeights[subTopic] = (self$typeSubTopicCounts[type, subTopic] + self$beta) /
                                                        (self$tokensPerSubTopic[subTopic] + self$vBeta)
                          }
                          
                          # Finally, put them together
                          cumulativeWeight=0.0
                          for(superTopic in 1:numSuperTopics){
                            currentSuperSubWeights = self$superSupWeights[superTopic]
                            currentSuperSubCounts = self$superSubCounts[superTopic]
                            currentSubAlpha = self$subAlphas[superTopic]
                            currentSuperWeigth = self$superWeights[superTopic]
                            
                            for(subTopic in 1:numSubTopics){
                              currentSuperSubWeights[subTopic] = 
                                  currentSuperWeight *
                                  self$subWeights[subTopic] *
                                  (currentSuperSubCounts[subtopic] + currentSubAlpha[subTopic])
                              cumulativeWeight = cumulativeWeight + currentSuperSubWeights[subTopic]
                            }
                            self$cumulativeSuperWeights[superTopic] = cumulativeWeight
                          }
                          
                          #Sample a topic assignment from this distribution
                          sample = sample(random) *cumulativeWeight #TODO fixx
                          
                          # Go over the row sums to find the super-topic...
                          superTopic = 0
                          while(sample > self$cumulativeSuperWeights[superTopic]){
                            superTopic = superTopic + 1
                          }
                          # Now read across to find the sub-topic
                          currentSuperSubWeights = self$superSubWeights[superTopic]
                          cumulativeWeight = self$cumulativeSuperWeights[superTopic] -
                            currentSuperSubWeights[0];
                          
                          # Go over each sub-topic until the weight is LESS than
                          #  the sample. Note that we're subtracting weights
			                    #  in the same order we added them...
			                    subTopic = 0;
                          while(sample < cumulativeWeight){
                            subTopic = subTopic + 1
                            cumulativeWeight = cumulativeWeight - currentSuperSubWeights[subTopic]
                          }
                          
                          # Save the coice into the Gibbs state
                          
                          superTopics[si] = superTopic
                          subTopic[si] = subTopic
                          
                          # put the new super/sub topics into the counts
			                    self$superSubCounts[superTopic, subTopic] = self$superSubCounts[superTopic, subTopic]+ 1
			                    self$superCounts[superTopic] = self$superCounts[superTopic]+1
			                    self$typeSubTopicCounts[type][subTopic] = self$typeSubTopicCounts[type][subTopic]+1
			                    self$tokensPerSuperTopic[superTopic] = self$tokensPerSuperTopic[superTopic]+1
			                    self$tokensPerSubTopic[subTopic] = self$tokensPerSubTopic[subTopic]+1
			                    self$tokensPerSuperSubTopic[superTopic, subTopic] = self$tokensPerSuperSubTopic[superTopic, subTopic]+1
                        }
                        # Update the topic count histograms
                        # for dirichlet estimation
                        
                        for(superTopic in 1:numSuperTopics){
                          self$superTopicHistograms[superTopic, self$superCounts[superTopic]] = self$superTopicHistograms[superTopic, self$superCounts[superTopic]] +1
                          currentSuperSubCounts = self$superSubCounts[superTopic,]
                          
                          for(subTopic in 1:numSupTopics){
                            self$subTopicHistograms[superTopic, subTopic, currentSuperSubCounts[subTopic]] =
                              self$subTopicHistograms[superTopic, subTopic, currentSuperSubCounts[subTopic]] +1
                          }
                        }
                        
                        
                      
                      
                      
                      
                      }
                      ))