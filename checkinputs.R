check.inputs <- function(K=integer(), W=integer(), phi=matrix(), 
                         term.frequency=integer(),
                         vocab=character(), topic.proportion=numeric()) {
  
  # Start checking the dimension of each object:
  stopifnot(K == dim(phi)[2])
  stopifnot(W == dim(phi)[1])
  stopifnot(W == length(term.frequency))
  stopifnot(W == length(vocab))
  stopifnot(K == length(topic.proportion))
  message("Your inputs look good! Go ahead and runVis() or createJSON().")
  
  # order rows of phi, term.frequency, and vocabulary in decreasing order of 
  # term.frequency:
  term.order <- order(term.frequency, decreasing=TRUE)
  phi <- phi[term.order, ]
  term.frequency <- term.frequency[term.order]
  vocab <- vocab[term.order]
  
  # order columns of phi and topic.proportion in decreasing order of 
  # topic proportion:
  topic.order <- order(topic.proportion, decreasing=TRUE)
  phi <- phi[, topic.order]
  topic.proportion <- topic.proportion[topic.order]
  
  # return a list with the same named elements as the inputs to this function, 
  # except re-ordered as necessary:
  return(list(K=K, W=W, phi=phi, term.frequency=term.frequency, 
              vocab=vocab, topic.proportion=topic.proportion))
}