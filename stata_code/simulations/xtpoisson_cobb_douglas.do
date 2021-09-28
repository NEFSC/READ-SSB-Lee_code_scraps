/* This estimates a log-log regression using 
 A. taking logs and using areg 
 B. taking logs and using xtreg, fe
 C. xtpoisson, fe vce(robust)
 D. poisson with indicators for each cross sectional unit 

The vessel fixed effects are uncorrelated with the RHS variables.
*/


/* dgp of
y_it=q_iE_it^b1X_it^b2*error_it  


lny=beta0+beta1*ln(educ) + beta2*ln(exp)+ error

The q_i indicates that the vessel level q's are constant across the time periods

*/

clear
set seed 55

/* we'll start with a small number of cross sectional units and time periods, just to see if this works */
global cross_sections 350
global years 3


set obs $cross_sections
gen id=_n
/* draw qi */
gen qi=rnormal(1,.5)
replace qi=0
expand $years
bysort id: gen year=_n

/* draw year fixed effect */
gen ut=rnormal(1,.25)
bysort year: replace ut=ut[1]
replace ut=0

expand 365
sort id
bysort id year: gen day=_n
bysort id (year): gen time=_n
order id time
tsset id time

global beta1=1
global beta2=1
/*global beta3=-.002 */
/*poisson estimates the natural log of the constant -- so lets just set this to exp(2) so the beta should be 2 */
global b0=0
global beta0=exp($b0)

/* The error term needs to be mean 0, with some sd...but this will cause some negative error terms */
global meane=0
global sde=.2

gen error=rnormal($meane, $sde)
gen educ=rnormal(0,1)
gen exp=runiform(0,1)
gen exp2=irecode(exp,0.6,1)



gen xb=$b0+$beta1*educ+$beta2*exp2+qi+error+ut
gen sig=sqrt(xb^-2)
gen y=exp(xb)
*gen y=exp(xb)
gen lny=ln(y)

/*****************************************************/
/*****************************************************/
/* END SETUP */
/*****************************************************/
/*****************************************************/

/*Estimator 1: areg, absorbing indicators */
timer on 1
reghdfe lny educ exp2, absorb(id)
est store myhdfeF
timer off 1


timer on 7
/*Estimator 7: ppmlhdfe - not sure why this shows up a slightly different coefficient*/
ppmlhdfe y educ exp2, absorb(id)
est store myppmlF
timer off 7


reghdfe lny educ exp2 if y>.5, absorb(id)
est store myhdfeC

ppmlhdfe y educ exp2, absorb(id)
est store myppmlC


xtpoisson y educ exp2, i(id)

