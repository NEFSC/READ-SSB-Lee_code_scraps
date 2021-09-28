******************************************************
*  Code for Table 1 of Kline and Santos (2011)       *
*  This file computes Analytical Wald and LM tests   *
*  along with the Score and Wild bootstrapped tests  *
*  Some other results not reported 		     *
*  in the paper are also included.		     *	
******************************************************

version 11.1
set matsize 1000
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


**Monte Carlo program**
cap prog drop sim_ols
prog def sim_ols, rclass
syntax [, c(integer 5) m(integer 50) a(integer 0) f(integer 0) r(integer 199)]
*Notes on syntax: 
*c - # of clusters
*m - # of obs per cluster
*a - controls whether misspecified
*f - controls whether to use mixture regressor
*r - # of bootstrap reps per simulation



**Generate data**
drop _all
set obs `c'  //generate c clusters

gen x=invnorm(uniform()) //covariate

if `f'==1{
	gen mix=uniform()>.1 //contamination probability
	gen D=(mix*invnorm(uniform()) + (1-mix)*(2+3*invnorm(uniform()))) //regressor of interest
}
else{
	gen D=(invnorm(uniform())) //regressor of interest
}

gen v=(1+D+x)*(invttail(6,uniform()))	//cluster effect

gen c=_n	//generate cluster id

expand `m'	//make m obs per cluster

replace x=x+invnorm(uniform())  //add some within cluster variation in x

gen y=x+D+`a'/10*D^2+v+invnorm(uniform())  //form outcome
sort c



**Unrestricted**
reg y x D, cluster(c)
predict xbu, xb
predict eu, resid

global b=_b[D]
local stdof=sqrt((`m'*`c'-3)/(`m'*`c'-1)) //inverse stata DOF correction
global W=((_b[D]-1)/(_se[D]*`stdof'))^2 //save analytical Wald


**Restricted**
constraint 1 D=1
cnsreg y x D, cons(1)
predict xbr, xb
predict er, resid


**Compute Full Sample LM/Wald**
gen one=1
mat accum H=one x D, nocons //form hessian

local dfk=(`c'/(`c'-1)) //dof correction
mata: L=I(`c')#J(`m',1,1) //matrix for summing across clusters

mata: H=st_matrix("H")
mata: Hinv=invsym(H)
mata: er=st_data(.,"er")
mata: n=length(er)
mata: X=st_data(.,("one", "x", "D"))
mata: C=(0\0\1)		//constraint matrix -- third coefficient is restricted
mata: A=C'*Hinv		//form A_n
mata: Sr=colsum(X:*er)	//form sum of scores
mata: OPGrcent=clustOPG(X:*er,L)
mata: Vinvr=invsym(A*OPGrcent*`dfk'*A') //compute inverse of variance of influence function
mata: lm=Sr*A'*Vinvr*A*Sr'	    //compute LM stat
mata: st_numscalar("lm",lm)
global lm=lm	//save lm stat



**Bootstrap**
gen u=.
gen ystar=.
gen ernew=.
gen eunew=.
gen pos=.
gen w=.

mat Ts=J(`r',10,.) //store bootstrap statistics


forvalues b=1/`r'{
qui{
by c: replace u=uniform()
by c: replace pos=u[1]<.5  //cluster level rademacher indicator
}

qui replace ernew=(2*pos-1)*er  //weighted residual
qui replace eunew=(2*pos-1)*eu  //weighted residual

*Score bootstrap LM -- Rademacher
mata: er=st_data(.,"ernew")
mata: Sr=colsum(X:*er)
mata: OPGrcent=clustOPG(X:*er,L)
mata: lm=Sr*A'*invsym(A*OPGrcent*`dfk'*A')*A*Sr'
mata: st_numscalar("lm",lm)
mat Ts[`b',1]=lm	     //save bootstrap LM

*Score bootstrap Wald -- Rademacher
mata: eu=st_data(.,"eunew")
mata: Su=colsum(X:*eu)
mata: OPGucent=clustOPG(X:*eu,L)
mata: wald=Su*A'*invsym(A*OPGucent*`dfk'*A')*A*Su'
mata: st_numscalar("wald",wald)
mat Ts[`b',2]=wald	     //save bootstrap Wald

*Score bootstrap Wald combining restricted and unrestricted scores -- Rademacher
mata: wald=Sr*A'*invsym(A*OPGucent*`dfk'*A')*A*Sr'
mata: st_numscalar("wald",wald)
mat Ts[`b',3]=wald	     //save bootstrap Wald

*Wild Wald -- Rademacher
qui replace ystar=xbu+eunew
qui reg ystar x D, cluster(c)
mat Ts[`b',4]=((_b[D]-$b)/(_se[D]*`stdof'))^2  //save bootstrap Wald

*Wild Wald (impose the null) -- Rademacher
qui replace ystar=xbr+ernew
qui reg ystar x D, cluster(c)
mat Ts[`b',5]=((_b[D]-1)/(_se[D]*`stdof'))^2  //save bootstrap Wald



**Mammen weights**
qui by c: replace pos=u[1]<.7236068  //cluster level Mammen indicator
qui replace ernew=-.61803399*pos*er + (1-pos)*(1+.61803399)*er  //weighted residual
qui replace eunew=-.61803399*pos*eu + (1-pos)*(1+.61803399)*eu  //weighted residual


*Score bootstrap LM -- Mammen
mata: er=st_data(.,"ernew")
mata: Sr=colsum(X:*er)
mata: OPGrcent=clustOPG(X:*er,L)
mata: lm=Sr*A'*invsym(A*OPGrcent*`dfk'*A')*A*Sr'
mata: st_numscalar("lm",lm)
mat Ts[`b',6]=lm	     //save bootstrap LM

*Score bootstrap Wald -- Mammen
mata: eu=st_data(.,"eunew")
mata: Su=colsum(X:*eu)
mata: OPGucent=clustOPG(X:*eu,L)
mata: wald=Su*A'*invsym(A*OPGucent*`dfk'*A')*A*Su'
mata: st_numscalar("wald",wald)
mat Ts[`b',7]=wald	     //save bootstrap Wald

*Score bootstrap Wald combining restricted and unrestricted scores -- Rademacher
mata: wald=Sr*A'*invsym(A*OPGucent*`dfk'*A')*A*Sr'
mata: st_numscalar("wald",wald)
mat Ts[`b',8]=wald	     //save bootstrap Wald


*Wild Wald -- Rademacher
qui replace ystar=xbu+eunew
qui reg ystar x D, cluster(c)
mat Ts[`b',9]=((_b[D]-$b)/(_se[D]*`stdof'))^2  //save bootstrap Wald


*Wild Wald (impose the null) -- Mammen
qui replace ystar=xbr+ernew
qui reg ystar x D, cluster(c)
mat Ts[`b',10]=((_b[D]-1)/(_se[D]*`stdof'))^2  //save bootstrap Wald
}

svmat Ts

**Return Results**
return scalar anal_lm=$lm>3.84146
return scalar anal_wald=$W>3.84146


gen reject=Ts1>$lm
sum reject if Ts1!=.
return scalar score_lm_rad=r(mean)<.05

replace reject=Ts1>$W //compare BS LM to Wald
sum reject if Ts1!=.
return scalar score_lmtowald_rad=r(mean)<.05

replace reject=Ts2>$W
sum reject if Ts2!=.
return scalar score_wald_rad=r(mean)<.05

replace reject=Ts3>$W
sum reject if Ts3!=.
return scalar score_hybrid_rad=r(mean)<.05

replace reject=Ts4>$W
sum reject if Ts4!=.
return scalar wild_rad=r(mean)<.05

replace reject=Ts5>$W
sum reject if Ts5!=.
return scalar wild_null_rad=r(mean)<.05

replace reject=Ts6>$lm
sum reject if Ts6!=.
return scalar score_lm_mammen=r(mean)<.05

replace reject=Ts6>$W //compare BS LM to Wald
sum reject if Ts6!=.
return scalar score_lmtowald_mammen=r(mean)<.05

replace reject=Ts7>$W
sum reject if Ts7!=.
return scalar score_wald_mammen=r(mean)<.05

replace reject=Ts8>$W
sum reject if Ts8!=.
return scalar score_hybrid_mammen=r(mean)<.05

replace reject=Ts9>$W
sum reject if Ts9!=.
return scalar wild_wald_mammen=r(mean)<.05

replace reject=Ts10>$W
sum reject if Ts10!=.
return scalar wild_null_mammen=r(mean)<.05


ereturn clear

end


log using ./results8/ols8_`1'_`2'_`3'_`4'_`5'.txt, replace text

simul, reps(`5') saving(./results8/ols8_`1'_`2'_`3'_`4'_`5'.dta, replace every(10)): sim_ols, c(`1') m(`2') a(`3') f(`4')
ci anal* score* wild*, bi

log close
