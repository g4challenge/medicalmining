# Pachinko temp

library(R6)

pachinko <- R6Class(classname = "pachinkoModel",
                    public= list(
                      numSuperTopics = 0, # number of topics to be fit
                      numSubTopics = 0,
                      
                      alpha = c(0), #Dirichlet(alpha,alpha,) distribution over supertopics
                      alphaSum = 50,
                      subAlphas = array(),
                      subAlphaSums = c(0),
                      beta=0.001, # Prior on per-topic multinomial distribution over words
                      vBeta=0,
                      
                      #Data 
                      dtm = NULL, #documents
                      numTypes = 0,
                      numTokens = 0,
                      
                      #Gibbs sampling state
                      superTopics = array(), #indexed by document index, sequence index
                      subTopics = array(),
                      
                      #Per-document state variables
                      superSubCounts = array(), # # of words per super,sub
                      superCounts = c(), # # of words per super
                      superWeights = c(), # the component of the Gibbs update that depends on super-topics
                      subWeights = c(), # the component of the Gibbs update that depends on sub-topics
                      superSubWeights = array(), # unnormalized sampling distribution
                      cumulativeSuperWeights = c(), # a cache of the cumulative weight for each super-topic
                      
                      #Per-word type state variables
                      typeSubTopicCounts= array(), # indexed by <feature index, topic index>
                      tokensPerSubTopic= c(), # indexed by <topic index>
                      tokensPerSuperTopic = c(),
                      tokensPerSuperSubTopic = c(),
                      
                      # Histograms for MLE
                      superTopicHistograms = array(),  # histogram of # of words per supertopic in documents
                      #  eg, [17][4] is # of docs with 4 words in sT 17...
                      subTopicHistograms = array(0, dim=c(0,0,0)), #for each supertopic, histogram of # of words per subtopic
                      
                      pachinko = function(supTop, subTop, alSum, beta){
                        self$numSuperTopics = supTop
                        self$numSubTopics= subTop
                        
                        self$alphaSum=alSum
                        self$alpha=rep((self$alphaSum/self$numSuperTopics), supTop)
                        
                        #Initialize the sub-topic alphas to a symmetric dirichlet
                        self$subAlphas <<- array(1.0, dim=c(supTop, subTop))
                        self$subAlphaSums = rep(subTop, supTop)
                        
                        self$beta= beta
                      },
                      
                      estimate = function(dtm, numIterations, optimizeInterval,
                                          showTopicsInterval, outputModelInterval, outputModel, randoms){
                        
                        self$dtm = dtm
                        numDocs = length(unique(dtm$i))
                        self$numTypes = dtm$ncol# size dataalphabet
                        
                        self$superTopics= array(0, dim=c(numDocs, self$numTypes))
                        self$subTopics = array(0, dim=c(numDocs, self$numTypes))
                        
                        self$superSubCounts = array(0, dim=c(self$numSuperTopics, self$numSubTopics))
                        self$superCounts = array(0, dim=c(self$numSuperTopics))
                        self$superWeights = array(0.0, dim=c(self$numSuperTopics))
                        self$subWeights = array(0.0, dim=c(self$numSubTopics))
                        self$superSubWeights = array(0.0, dim=c(self$numSuperTopics, self$numSubTopics))
                        self$cumulativeSuperWeights = array(0.0, dim=c(self$numSuperTopics))
                        
                        self$typeSubTopicCounts = array(0, dim=c(self$numTypes, self$numSubTopics))
                        self$tokensPerSubTopic = array(0, dim=c(self$numSubTopics))
                        self$tokensPerSuperTopic = array(0, dim=c(self$numSuperTopics))
                        self$tokensPerSuperSubTopic = array(0, dim=c(self$numSuperTopics, self$numSubTopics))
                        
                        self$vBeta = self$beta * self$numTypes
                        maxTokens = 0
                        
                        # Initialize with random assignments of tokens to topics
                        # and finish allocating self$topics and self$tokens
                        
                        #for all documents
                        for(di in 1:numDocs){
                          seq = which(as.vector(dtm[di,])>0)
                          seqlen = length(seq)
                          
                          if(seqlen > maxTokens){
                            maxTokens = seqlen
                          }
                          
                          self$numTokens = self$numTokens + seqlen
                          
                          #Randomly assign tokens to topics
                          for(si in 1:seqlen){
                            # Random super-topic
                            superTopic = sample(1:self$numSuperTopics, 1)
                            self$superTopics[di,si] = superTopic
                            self$tokensPerSuperTopic[superTopic] = self$tokensPerSuperTopic[superTopic]+1
                            
                            # Random sub-topic
                            subTopic = sample(1:self$numSubTopics, 1)
                            self$subTopics[di,si] = subTopic
                            
                            # update word-type statistics for sub-topic
                            # document di, token si, index
                            self$typeSubTopicCounts[seq[si],subTopic] <- self$typeSubTopicCounts[seq[si],subTopic] + 1
                            self$tokensPerSubTopic[subTopic] <-  self$tokensPerSubTopic[subTopic] + 1
                            
                            self$tokensPerSuperSubTopic[superTopic, subTopic] = self$tokensPerSuperSubTopic[superTopic, subTopic] + 1
                          }
                        }
                        
                        # create Histograms
                        self$superTopicHistograms = array(0, dim = c(self$numSuperTopics, self$numTypes))
                        self$subTopicHistograms = array(0, dim = c(self$numSuperTopics, self$numSubTopics, self$numTypes))
                        
                        # Start the sampler
                        for(i in 1:numIterations){
                          print(c("iteration", as.character(i)))
                          self$clearHistograms()
                          self$sampleTopicsForAllDocs(random)
                          
                          if(numIterations > 0){
                            #skipped 2 ifs
                            if(optimizeInterval != 0 && (numIterations %% outputModelInterval == 0)){
                              for(superTopic in 1:self$numSuperTopics){
                                self$learnParameters(superTopic)
                                #self$subAlphas[superTopic],
                                #self$subTopicHistograms[superTopic,,],
                                #self$superTopicHistograms[superTopic,])
                                self$subAlphaSums[superTopic]=0.0
                                for(subTopic in 1:self$numSubTopics){
                                  self$subAlphaSums[superTopic] <- self$subAlphaSums[superTopic] + self$subAlphas[superTopic, subTopic]
                                }
                              }
                            }
                          }
                        }
                        # end of constructor
                      },
                      clearHistograms = function(){
                        for(superTopic in 1:self$numSuperTopics){
                          self$superTopicHistograms[superTopic] = rep(0, length(self$superTopicHistograms[superTopic]))
                          for(subTopic in 1:self$numSubTopics){
                            self$subTopicHistograms[superTopic, subTopic, ] = rep(0, length(self$superTopicHistograms[superTopic, subTopic]))
                          }
                        }
                      },
                      learnParameters = function(superTopic){#parameters, observations, observationLengths){
                        #self$subAlphas[superTopic],
                        #self$subTopicHistograms[superTopic,,],
                        #self$superTopicHistograms[superTopic,])
                        
                        
                        parameterSum = sum(self$subAlphas[superTopic])
                        
                        noZeroLimits= rep(-1, length(self$subTopicHistograms[superTopic,,]))
                        
                        #   The histogram arrays go up to the size of the largest document,
                        #		but the non-zero values will almost always cluster in the low end.
                        #		We avoid looping over empty arrays by saving the index of the largest
                        #		non-zero value.
                        
                        for(i in 1:dim(self$subTopicHistograms[superTopic,,])[1]){
                          for(k in 1:dim(self$subTopicHistograms[superTopic,,])[2]){
                            if(self$subTopicHistograms[superTopic,i,k] > 0){
                              noZeroLimits[i] = k
                            }
                          }
                        }
                        
                        for(i in 1:200){
                          #Calculate denominator
                          denominator = 0.0
                          currentDigamma = 0.0
                          #Iterate over the histogram
                          for(i in 1:length(self$subTopicHistograms[superTopic,,])){
                            currentDigamma = currentDigamma + 1/(parameterSum + i - 1)
                            denominator = denominator + as.vector(self$subTopicHistograms[superTopic,,])[i] * currentDigamma
                          }
                        }
                        # Calculate the individual parameters
                        parameterSum = 0
                        
                        for(k in 1:length(self$subAlphas[superTopic,])){
                          # What's the largest non-zero element in the histogram
                          nonZeroLimit = noZeroLimits[k]
                          
                          # If there are no tokens assigned to this super-sub pair
                          # anywhere in the corpus bail
                          
                          if(nonZeroLimit == -1){
                            self$subAlphas[superTopic,k] = 0.000001
                            parameterSum = parameterSum + 0.000001
                            next
                          }
                          oldParametersK = self$subAlphas[superTopic,k]
                          self$subAlphas[superTopic,k] = 0;
                          currentDigamma = 0;
                          
                          for(i in 1:nonZeroLimit){
                            currentDigamma = currentDigamma + 1/(oldParametersK + i - 1)
                            self$subAlphas[superTopic, k] = self$subAlphas[superTopic, k] + self$subTopicHistograms[superTopic,k,i] * currentDigamma
                          }
                          
                          self$subAlphas[superTopic,k] = self$subAlphas[superTopic, k] * oldParametersK / denominator
                          parameterSum = parameterSum + self$subAlphas[superTopic,k]
                        }
                      },
                      # One iteration of Gibbs sampling, across all documents.
                      sampleTopicsForAllDocs = function(random){
                        #Loop over every word in the corpus
                        for(di in 1:self$dtm$nrow){
                          self$sampleTopicsForOneDoc(self$dtm[di,],
                                                     di,
                                                     #self$subTopics[di],
                                                     random)
                        }
                      },
                      sampleTopicsForOneDoc = function(oneDocTokens,
                                                       di, #int index
                                                       #subTopics, #int index
                                                       random){
                        print(c("sample", as.character(di)))
                        for(t in 1:self$numSuperTopics){
                          self$superSubCounts[t,] = rep(0, dim(self$superSubCounts)[2])
                        }
                        self$superCounts = rep(0, length(self$superCounts))
                        
                        seq <- which(as.vector(oneDocTokens)>0)
                        if(length(seq)==0){
                          print("empty")
                          return(self)
                        }
                        
                        #populate topic counts
                        for(si in 1:length(seq)){
                          self$superSubCounts[self$superTopics[di, si], self$subTopics[di, si]] = self$superSubCounts[self$superTopics[di, si], self$subTopics[di, si]] + 1
                          self$superCounts[self$superTopics[di,si]] = self$superCounts[self$superTopics[di, si]] + 1
                        }
                        
                        # iterate over the positions(words) in the document
                        for(si in 1:length(seq)){
                          
                          
                          type = seq[si]
                          superTopic = self$superTopics[di, si]
                          subTopic = self$subTopics[di, si]
                          
                          # Remove this token from all counts
                          self$superSubCounts[superTopic, subTopic] = self$superSubCounts[superTopic, subTopic] - 1
                          self$superCounts[superTopic] = self$superCounts[superTopic] -1
                          self$typeSubTopicCounts[type, subTopic] = self$typeSubTopicCounts[type, subTopic] - 1
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
                          self$cumulativeSuperWeights = rep(0.0, self$numSuperTopics)
                          
                          # The conditional probability of each super-sub pair is proportional
                          #  to an expression with three parts, one that depends only on the 
                          #  super-topic, one that depends only on the sub-topic and the word type,
                          #  and one that depends on the super-sub pair.
                          
                          # Calculate each of the super-only factors first
                          for(superTopic in 1:self$numSuperTopics){
                            self$superWeights[superTopic] = (self$superCounts[superTopic] + self$alpha[superTopic]) /
                              (self$superCounts[superTopic] + self$subAlphaSums[superTopic])
                          }
                          # Next Calculate the sub-only factors
                          
                          for(subTopic in 1:self$numSubTopics){
                            self$subWeights[subTopic] = (self$typeSubTopicCounts[type, subTopic] + self$beta) /
                              (self$tokensPerSubTopic[subTopic] + self$vBeta)
                          }
                          
                          # Finally, put them together
                          cumulativeWeight=0.0
                          for(superTopic in 1:self$numSuperTopics){
                            #currentSuperSubWeights = self$superSubWeights[superTopic,]
                            #currentSuperSubCounts = self$superSubCounts[superTopic,]
                            #currentSubAlpha = self$subAlphas[superTopic,]
                            #currentSuperWeight = self$superWeights[superTopic]
                            
                            for(subTopic in 1:self$numSubTopics){
                              self$superSubWeights[superTopic, subTopic] = 
                                self$superWeights[superTopic] *
                                self$subWeights[subTopic] *
                                (self$superSubCounts[superTopic, subTopic] + self$subAlphas[superTopic, subTopic])
                              cumulativeWeight = cumulativeWeight + self$superSubWeights[superTopic, subTopic]
                            }
                            if(is.na(cumulativeWeight)){
                              print("Error")
                              print(subTopic)
                              print(superTopic)
                              print(type)
                            }
                            self$cumulativeSuperWeights[superTopic] = cumulativeWeight
                          }
                          
                          #Sample a topic assignment from this distribution
                          sample = runif(1, min=0, max=1) *cumulativeWeight #like mallet mean 0.5 var 1/12
                          
                          # Go over the row sums to find the super-topic...
                          superTopic = 1
                          while(sample > self$cumulativeSuperWeights[superTopic]){
                            superTopic = superTopic + 1
                          }
                          # Now read across to find the sub-topic
                          #currentSuperSubWeights = self$superSubWeights[superTopic,]
                          cumulativeWeight = self$cumulativeSuperWeights[superTopic] -
                            self$superSubWeights[superTopic, 1];
                          # Go over each sub-topic until the weight is LESS than
                          #  the sample. Note that we're subtracting weights
                          #  in the same order we added them...
                          subTopic = 1;
                          while(sample < cumulativeWeight){
                            subTopic = subTopic + 1
                            cumulativeWeight = cumulativeWeight - self$superSubWeights[superTopic, subTopic]
                          }
                          
                          # Save the coice into the Gibbs state
                          
                          self$superTopics[di, si] = superTopic
                          self$subTopics[di, si] = subTopic
                          
                          # put the new super/sub topics into the counts
                          self$superSubCounts[superTopic, subTopic] = self$superSubCounts[superTopic, subTopic]+ 1
                          self$superCounts[superTopic] = self$superCounts[superTopic]+1
                          self$typeSubTopicCounts[type, subTopic] = self$typeSubTopicCounts[type, subTopic]+1
                          self$tokensPerSuperTopic[superTopic] = self$tokensPerSuperTopic[superTopic]+1
                          self$tokensPerSubTopic[subTopic] = self$tokensPerSubTopic[subTopic]+1
                          self$tokensPerSuperSubTopic[superTopic, subTopic] = self$tokensPerSuperSubTopic[superTopic, subTopic]+1
                        }
                        # Update the topic count histograms
                        # for dirichlet estimation
                        
                        for(superTopic in 1:self$numSuperTopics){
                          self$superTopicHistograms[superTopic, self$superCounts[superTopic]] = self$superTopicHistograms[superTopic, self$superCounts[superTopic]] +1
                          
                          for(subTopic in 1:self$numSubTopics){
                            self$subTopicHistograms[superTopic, subTopic, self$superSubCounts[superTopic, subTopic]] =
                              self$subTopicHistograms[superTopic, subTopic, self$superSubCounts[superTopic, subTopic]] +1
                          }
                        }
                      },
                      createJSON = function(R=30, 
                                            lambda.step = 0.01, 
                                            plot.opts = list( xlab="PC1",
                                                              ylab="PC2",
                                                              ticks=FALSE)
                      ){
                        dpsub <- dim()
                        dpsup <- dim()
                        dtsub <- dim()
                        dtsup <- dim()
                        
                        if(dpsub[1] != dtsub[2] || dpsub[1] != dtsup[2]) {
                          stop("Number of rows of phi does not match 
                                    number of columns of theta; both should be equal to the number of topics 
                                                                              in the model.")
                        }
                        
                        ###### Export
                        RJSONIO::toJSON(list(mdsDat = mds.df, tinfo = tinfo, 
                                             token.table = token.table, R = R, 
                                             lambda.step = lambda.step,
                                             plot.opts = plot.opts, 
                                             topic.order = o))
                        
                      }
                    ))