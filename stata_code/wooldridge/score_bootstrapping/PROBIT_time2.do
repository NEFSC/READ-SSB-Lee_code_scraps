****************************************************
*  Code for Table 4 of Kline and Santos (2011)     *
*  This file produces the entries labeled: PROBIT  *
****************************************************

version 11.1
clear all
set matsize 10000
set seed 12345
set more off

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



local r=9999
local c=20
local m=20
local f=0
local N=`c'*`m'


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

expand `m'	//make m obs per cluster

replace x=(x+invnorm(uniform()))/4  //add some within cluster variation in x

gen y=x+D+v/sqrt(2)+invnorm(uniform())/sqrt(2)  //form outcome
replace y=y>0
sort c


*****************
***Score Wald2***
*****************


timer on 1

**Unrestricted**
probit y x D, cluster(c)
global b=_b[D]
local stdof=sqrt((`m'*`c'-3)/(`m'*`c'-1)) //inverse stata DOF correction
global W=((_b[D]-1)/(_se[D]*`stdof'))^2 //save analytical Wald

predict pu
predict xbu, xb
gen phiu=normalden(xbu)
gen eu=(y-pu)*phiu/(pu*(1-pu)) //quasi-residual
gen wu=phiu^2/(pu*(1-pu)) //weights for hessian


**Restricted**
constraint 1 D=1
glm y x D, constraint(1) fam(bin) link(probit)
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
mata: X=st_data(.,("one", "x", "D"))
mata: C=(0\0\1)		//constraint matrix -- third coefficient is restricted
mata: Ar=C'*Hrinv		//form A_n


**Prepare influence function wald
mat accum Hu=one x D [iw=wu], nocons //form hessian
mata: Hu=st_matrix("Hu")
mata: Huinv=invsym(Hu)
mata: Au=C'*Huinv



**Bootstrap**
gen u=.
gen ystar=.
gen ernew=.
gen eunew=.
gen pos=.


mat Ts=J(`r',1,.) //store bootstrap statistics

forvalues b=1/`r'{
qui{
by c: replace u=uniform()
by c: replace pos=u[1]<.5  //cluster level rademacher indicator
}

qui replace ernew=(2*pos-1)*er  //weighted residual
qui replace eunew=(2*pos-1)*eu  //weighted residual


*Score bootstrap Wald combining restricted and unrestricted scores -- Rademacher
mata: er=st_data(.,"ernew")
mata: eu=st_data(.,"eunew")
mata: Sr=colsum(X:*er)
mata: OPGucent=clustOPG(X:*eu,L)

mata: wald=Sr*Ar'*invsym(Au*OPGucent*`dfk'*Au')*Ar*Sr'
mata: st_numscalar("wald",wald)
mat Ts[`b',1]=wald	     //save bootstrap Wald


}

svmat Ts

**Return Results**


gen reject=Ts1>$W
sum reject if Ts1!=.
scalar score_rad=r(mean)<.05

timer off 1
timer list 1






*****************
***  Score LM ***
*****************
drop pu-reject
keep in 1/`N'
timer on 2


**Restricted**
constraint 1 D=1
glm y x D, constraint(1) fam(bin) link(probit)
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
mata: X=st_data(.,("one", "x", "D"))
mata: C=(0\0\1)		//constraint matrix -- third coefficient is restricted
mata: Ar=C'*Hrinv		//form A_n
mata: Sr=colsum(X:*er)	//form sum of scores
mata: OPGrcent=clustOPG(X:*er,L)
mata: Vinvr=invsym(Ar*OPGrcent*`dfk'*Ar') //compute inverse of variance of influence function
mata: lm=Sr*Ar'*Vinvr*Ar*Sr'	    //compute LM stat
mata: st_numscalar("lm",lm)
global lm=lm	//save lm stat


**Bootstrap**
gen u=.
gen ystar=.
gen ernew=.
gen eunew=.
gen pos=.


mat Ts=J(`r',1,.) //store bootstrap statistics

forvalues b=1/`r'{
qui{
by c: replace u=uniform()
by c: replace pos=u[1]<.5  //cluster level rademacher indicator
}

qui replace ernew=(2*pos-1)*er  //weighted residual



*Score bootstrap LM -- Rademacher
mata: er=st_data(.,"ernew")
mata: Sr=colsum(X:*er)
mata: OPGrcent=clustOPG(X:*er,L)
mata: lm=Sr*Ar'*invsym(Ar*OPGrcent*`dfk'*Ar')*Ar*Sr'
mata: st_numscalar("lm",lm)
mat Ts[`b',1]=lm	     //save bootstrap LM

}

svmat Ts

**Return Results**


gen reject=Ts1>$lm
sum reject if Ts1!=.
scalar score_rad=r(mean)<.05

timer off 2
timer list 2





****************
***Pairs Wald***
****************

drop pr-reject
keep in 1/`N'
timer on 3

**Unrestricted**
probit y x D, cluster(c)
global b=_b[D]
local stdof=sqrt((`m'*`c'-3)/(`m'*`c'-1)) //inverse stata DOF correction
global W=((_b[D]-1)/(_se[D]*`stdof'))^2 //save analytical Wald


mat Ts=J(`r',1,.) //store bootstrap statistics

**Bootstrap**
preserve
forvalues b=1/`r'{
qui{
bsample, cluster(c) idcluster(cnew)

**Compute BS Wald**
probit y x D, cluster(cnew)
local stdof=sqrt((`m'*`c'-3)/(`m'*`c'-1)) //inverse stata DOF correction
mat Ts[`b',1]=((_b[D]-$b)/(_se[D]*`stdof'))^2 //save analytical Wald
restore, preserve
}
}

svmat Ts
gen reject=Ts1>$W
sum reject if Ts1!=.
scalar pairs_rad=r(mean)<.05

timer off 3
timer list 3

timer list
