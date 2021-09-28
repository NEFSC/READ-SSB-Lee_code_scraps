****************************************************
*  Code for Table 3 of Kline and Santos (2011)     *
*  This file produces the nonparametric "pairs"    *
*  bootstrap entries.				   *
****************************************************

version 11.1
set seed 12345

**mata subroutine to compute recentered clustered outer products**
**inputs a matrix S of scores and a cluster summing matrix L**
**outputs clustered outer product matrix**
**note this program assumes a balanced design**
**and proper sort order**
cap mata: mata drop clustOPG()
mata: 
real matrix clustOPG(real matrix S,real matrix L){
real scalar N
real matrix Scent, Scentsum, OPGcent

N=rows(S)
Scent=S - J(N,1,1)*mean(S)
Scentsum=L'*Scent
OPGcent=Scentsum'*Scentsum
return(OPGcent)
}
end


cap prog drop sim_probit
prog def sim_probit, rclass
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

gen v=invnorm(uniform())


gen c=_n	//generate cluster id

expand `m'	//make l obs per cluster

replace x=(x+invnorm(uniform()))/4  //add some within cluster variation in x

gen y=x+D+v/sqrt(2)+invnorm(uniform())/sqrt(2)  //form outcome
replace y=y>0
sort c

**Unrestricted**
probit y x D, cluster(c)
global b=_b[D]
local stdof=sqrt((`m'*`c'-3)/(`m'*`c'-1)) //inverse stata DOF correction
global W=((_b[D]-1)/(_se[D]*`stdof'))^2 //save analytical Wald


**Restricted**
constraint 1 D==1
probit y x D, constraint(1)
predict pr
predict xbr, xb
gen phir=normalden(xbr)
gen er=(y-pr)*phir/(pr*(1-pr)) //quasi-residual
gen wr=phir^2/(pr*(1-pr)) //weights for hessian


**Compute Full Sample LM**
gen one=1
mat accum Hr=one x D [iw=wr], nocons //form hessian

local dfk=(`c'/(`c'-1))
mata: L=I(`c')#J(`m',1,1) //matrix for summing across clusters
mata: Hr=st_matrix("Hr")
mata: Hrinv=invsym(Hr)
mata: er=st_data(.,"er")
mata: n=length(er)
mata: X=st_data(.,("one", "x", "D"))
mata: C=(0\0\1)		//constraint matrix -- third coefficient is restricted
mata: Ar=C'*Hrinv		//form A_n
mata: Sr=colsum(X:*er)	//form sum of scores
mata: OPGrcent=clustOPG(X:*er,L)
mata: Vinvr=invsym(Ar*OPGrcent*`dfk'*Ar') //compute inverse of variance of influence function
mata: T=Ar*Sr'
mata: lm=T'*Vinvr*T	    //compute LM stat
mata: st_numscalar("lm",lm)
global lm=lm	//save lm stat


**Bootstrap**
drop pr xbr phir er wr

mat Ts=J(`r',2,.) //store bootstrap statistics
preserve

forvalues b=1/`r'{
qui{
bsample, cluster(c) idcluster(cnew)

**Compute BS Wald**
probit y x D, cluster(cnew)
local stdof=sqrt((`m'*`c'-3)/(`m'*`c'-1)) //inverse stata DOF correction
mat Ts[`b',1]=((_b[D]-$b)/(_se[D]*`stdof'))^2 //save analytical Wald


**Compute BS LM**
probit y x D, constraint(1)
predict pr
predict xbr, xb
gen phir=normalden(xbr)
gen er=(y-pr)*phir/(pr*(1-pr)) //quasi-residual
gen wr=phir^2/(pr*(1-pr)) //weights for hessian

sort cnew


mat accum Hr=one x D [iw=wr], nocons //form hessian

mata: Hr=st_matrix("Hr")
mata: Hrinv=invsym(Hr)
mata: er=st_data(.,"er")
mata: X=st_data(.,("one", "x", "D"))
mata: Ar=C'*Hrinv		//form A_n
mata: Sr=colsum(X:*er)	//form sum of scores
mata: OPGrcent=clustOPG(X:*er,L)
mata: Vinvr=invsym(Ar*OPGrcent*`dfk'*Ar') //compute inverse of variance of influence function
mata: Tnew=Ar*Sr'-T
mata: lm=Tnew'*Vinvr*Tnew	    //compute LM stat
mata: st_numscalar("lm",lm)
mat Ts[`b',2]=lm
restore, preserve
}
}

svmat Ts

**Return Results**

if $lm!=.{
return scalar anal_lm=$lm>3.84146
}

if $W!=.{
return scalar anal_wald=$W>3.84146
}


gen reject=Ts1>$W
sum reject if Ts1!=.
if r(N)==`r'{
return scalar pairs_wald=r(mean)<.05
}

replace reject=Ts2>$lm
sum reject if Ts1!=.
if r(N)==`r'{
return scalar pairs_lm=r(mean)<.05
}

ereturn clear

end

set more off
log using ./results8/probit8_pairs_`1'_`2'_`3'_`4'.txt, replace text
simul, reps(`4') saving(./results8/probit8_pairs_`1'_`2'_`3'_`4'.dta, replace every(10)): sim_probit, c(`1') m(`2') f(`3')
ci *, bi

