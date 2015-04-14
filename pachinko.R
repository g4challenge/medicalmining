# Pachinko allocation

# currently structured gibbs lda

pachinko <- function(i, j, v, nrow, ncol, control, ...){
  pachinko.init(...)
  phi=
  theta=
  
  pachinko.estimate()
  for(i in)
    #for all z_i
    for(m)
      for(n)
        #z_i =z[m][n]
    
      compute_phi()
  if(keep)
    inference()
    logliks = logliklihood
    keepiter++
    
  compute_theta()
  
  if(estimate_phi){
    compute_phi()
  }
  
  ## word assign
  for(m) #docs
    for(n) #length
      wordassign[m][n] = get_wordassign(m,n)
  
  
  ############################################################
        
  pachinko.inference()
  
  return(model)
}

PACHINKO_GIBBS.fit <- function(x, k, control= NULL, model = NULL, call, ...){
  
}