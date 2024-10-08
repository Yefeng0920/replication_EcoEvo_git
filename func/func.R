# functions for joint distributions
djoint <- function(x,y,p,m,s) { 
  dmix(y,p,m,s)*dnorm(x-y,mean=0,sd=1)  # conditional on SNR, z ~ N(SNR,1)
}

# functions for the mixture distribution
dmix = function(x,p,m,s){
  drop(p %*% sapply(x, function(x) dnorm(x,mean=m,sd=s)))
}

rmix = function(n,p,m,s){    # sample from a normal mixture
  d=rmultinom(n,1,p)
  rnorm(n,m%*%d,s%*%d)
}

pmix = function(x,p,m,s){ # cumulative distr (vector x)
  drop(p %*% sapply(x, function(x) pnorm(x,mean=m,sd=s)))
}

# Estimate k-component zero-mean normal mixture distribution
# The function accepts weights.
# The function also accepts censoring below c1 and above c2.
# Uses base R function `constrOptim` to run constrained optimization. 
# We define the log likelihood function and set up constraints such
# that the mixture proportions are non-negative and add up to 1, 
# and the component variances are at least 1.
mix = function(z,k=3,c1=0,c2=10^6,weights=1){
  # log likelihood function
  loglik = function(theta,z,k,weights=1){
    p=c(theta[1:(k-1)],1-sum(theta[1:(k-1)]))
    s=theta[k:(2*k-1)]
    m=rep(0,k)
    #lik=dmix(z,p,m=m,s=s)
    lik1=(abs(z) < c1)*(pmix(c1,p,m=m,s=s) - pmix(-c1,p,m=m,s=s))
    lik2=(abs(z) >= c1)*(abs(z) < c2)*dmix(z,p,m=m,s=s)
    lik3=(abs(z) >= c2)*(pmix(-c2,p,m=m,s=s) + 1 - pmix(c2,p,m=m,s=s))
    lik=lik1+lik2+lik3
    return(-sum(weights*log(lik)))   # *minus* the weighted log lik
  }
  # set up constraints for optimization
  # The feasible region is defined by ui %*% par - ci >= 0
  ui=c(rep(-1,(k-1)),rep(0,k))         # (k-1) mixture props sum to < 1
  ui=rbind(ui,cbind(diag(2*k-1)))
  ci=c(-1,rep(0,k-1),rep(1,k))
  
  # set starting value
  theta0=c(rep(1/k,(k-1)),c(1.2,2:k))
  opt=constrOptim(theta=theta0,f=loglik,ui=ui,ci=ci,
                  method = "Nelder-Mead",
                  z=z,weights=weights,k=k,
                  control=list(maxit=10^4))
  
  # collect the results
  p=c(opt$par[1:(k-1)],1-sum(opt$par[1:(k-1)]))  # mixture proportions
  sigma=opt$par[k:(2*k-1)]                       # mixture sds
  m=rep(0,k)                                     # mixture means
  df=data.frame(p=p,m=m,sigma=sigma)
  return(df)
}

# p(SNR | z) when snr ~ dmix(p,m,s)
posterior <- function(z,p,m,s) { 
  s2=s^2
  p=p*dnorm(z,m,sqrt(s2+1))
  p <- p/sum(p)         # conditional mixing probs
  pm <- z*s2/(s2+1) + m/(s2+1) # conditional means
  pv <- s2/(s2+1)          # conditional variances
  ps <- sqrt(pv)            # conditional std devs
  data.frame(p,pm,ps)
}

# probability of replication when snr ~ dmix(p,m,s)
# and we observed a particular z-stat in the original study
# and the replication study is "multiplier" times as large.
replcalc <- function(z,p,m,s,multiplier=1){
  post=posterior(abs(z),p=p,m=m,s=s)
  pp=post$p
  pm=sqrt(multiplier)*post$pm
  ps=sqrt(multiplier)*post$ps
  1 - pmix(1.96,p=pp,m=pm,s=sqrt(ps^2 + 1))
}