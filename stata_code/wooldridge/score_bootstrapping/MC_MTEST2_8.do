*************************************************
* Code for Table 3 of Kline and Santos (2011)   *
* This file computes m-tests of the null of no  *
* within cluster correlation of probit g-resids *
*************************************************

version 11.1
set seed 12345

cap prog drop sim_mtest
prog def sim_mtest, rclass
syntax [, c(integer 5) m(integer 50) f(integer 0) r(integer 199)]
*Notes on syntax: 
*c - # of clusters
*m - # of obs per cluster
*f - controls whether to use mixture regressor
*r - # of bootstrap reps per simulation


**Generate data**
drop _all
set obs `c'  //generate c clusters

gen x=invnorm(uniform()) //covariate
gen mix=uniform()>.1 //contamination probability

if `f'==1{
	gen D=(mix*invnorm(uniform()) + (1-mix)*(2+3*invnorm(uniform())))/4 //regressor of interest
}
else{
	gen D=(invnorm(uniform()))/4 //regressor of interest
}



gen c=_n	//generate cluster id

expand `m'	//make l obs per cluster

replace x=(x+invnorm(uniform()))/4  //add some within cluster variation in x

gen y=x+D+invnorm(uniform())  //form outcome
replace y=y>0



**Run Probit**
probit y x D

predict p
gen e=(y-p)/sqrt(p*(1-p)) //generalized-residual


**Compute Full Sample M-Test**
gen s1=e
gen s2=e*x
gen s3=e*D

egen esum=sum(e), by(c)
gen m=e*(esum-e)/(`m'-1)/`m'

collapse (sum) m s1-s3, by(c) fast //sum to cluster level

*orthogonalize moments
reg m s1-s3, nocons
predict r, resid



hotelling r //this calculates a naive Wald test of jointly zero means
global W=r(T2)


**Bootstrap**
gen u=.
gen pos=.
gen w=.
gen rstar=.

mat Ts=J(`r',2,.) //store bootstrap statistics

forvalues b=1/`r'{

**Rademacher Weights**
qui{
replace u=uniform()
replace pos=u<.5  
replace w=(2*pos-1) //cluster level rademacher weight


replace rstar=w*r


hotelling rstar
mat Ts[`b',1]=r(T2)

**Mammen Weights**
replace pos=u<.7236068  
replace w=-.61803399*pos + (1-pos)*(1+.61803399)  //cluster level Mammen weight


replace rstar=w*r


hotelling rstar
mat Ts[`b',2]=r(T2)
}
}

svmat Ts


**Return Results**

if $W!=.{
return scalar anal=$W>3.84146
}

gen reject=Ts1>$W
sum reject if Ts1!=.
if r(N)==`r'{
return scalar rad=r(mean)<.05
}

replace reject=Ts2>$W
sum reject if Ts2!=.
if r(N)==`r'{
return scalar mammen=r(mean)<.05
}

ereturn clear

end

set more off
log using ./results8/mtest2_8_`1'_`2'_`3'_`4'.txt, replace text
simul, reps(`4') saving(./results8/mtest2_8_`1'_`2'_`3'_`4'.dta, replace every(10)): sim_mtest, c(`1') m(`2') f(`3')
ci anal rad mammen, bi

