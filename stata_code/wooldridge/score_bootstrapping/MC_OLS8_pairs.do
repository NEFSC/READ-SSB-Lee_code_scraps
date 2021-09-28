****************************************************
*  Code for Table 1 of Kline and Santos (2011)     *
*  This file produces the nonparametric "pairs"    *
*  bootstrap entries.  			   	   *
****************************************************

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
gen mix=uniform()>.1 //contamination probability

if `f'==1{
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


**Unrestricted**
reg y x D, cluster(c)
global b=_b[D]
local stdof=sqrt((`m'*`c'-3)/(`m'*`c'-1)) //inverse stata DOF correction
global W=((_b[D]-1)/(_se[D]*`stdof'))^2 //save analytical Wald



**Restricted**
constraint 1 D=1
cnsreg y x D, cons(1)
predict er, resid

sort c
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
mata: T=A*Sr'
mata: lm=T'*Vinvr*T	    //compute LM stat
mata: st_numscalar("lm",lm)
global lm=lm	//save lm stat



**Bootstrap**
gen ystar=.

mat Ts=J(`r',2,.) //store bootstrap statistics

preserve


forvalues b=1/`r'{
bsample, cluster(c) idcluster(cnew)

**Wald**

reg y x D, cluster(cnew)
mat Ts[`b',1]=((_b[D]-$b)/(_se[D]*`stdof'))^2 //save analytical Wald


**LM**

replace ystar=y-D
reg ystar x
cap drop er
predict er, resid

sort cnew
mat accum H=one x D, nocons //form hessian

mata: H=st_matrix("H")
mata: Hinv=invsym(H)
mata: er=st_data(.,"er")
mata: X=st_data(.,("one", "x", "D"))
mata: A=C'*Hinv		//form A_n
mata: Sr=colsum(X:*er)	//form sum of scores
mata: OPGrcent=clustOPG(X:*er,L)
mata: Vinvr=invsym(A*OPGrcent*`dfk'*A') //compute inverse of variance of influence function
mata: Tnew=A*Sr'-T			//center around full sample stat
mata: lm=Tnew'*Vinvr*Tnew	    //compute LM stat
mata: st_numscalar("lm",lm)
mat Ts[`b',2]=lm
restore, preserve
}

svmat Ts



return scalar anal_wald=$W>3.84146
return scalar anal_lm=$lm>3.84146


gen reject=abs(Ts1)>($W)
sum reject if Ts1!=.
return scalar pairs_wald=r(mean)<.05


replace reject=abs(Ts2)>($lm)
sum reject if Ts2!=.
return scalar pairs_lm=r(mean)<.05


ereturn clear

end


log using ./results8/ols8_pairs_`1'_`2'_`3'_`4'_`5'.txt, replace text

simul, reps(`5') saving(./results8/ols8_pairs_`1'_`2'_`3'_`4'_`5'.dta, replace every(10)): sim_ols, c(`1') m(`2') a(`3') f(`4')

ci anal* pairs*, bi

