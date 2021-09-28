/* Anna found that areg/reghdfe are producing different results than xtpoisson or ppmlhdfe
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
global years 1


set obs $cross_sections
gen id=_n
/* draw qi */
gen qi=rnormal(1,.25)
expand $years
bysort id: gen year=_n

/* draw year fixed effect */
gen ut=rnormal(1,.25)
bysort year: replace ut=ut[1]

expand 365
sort id
bysort id year: gen day=_n
bysort id (year): gen time=_n
order id time
tsset id time

global beta1=0.06
global beta2=.1
/*global beta3=-.002 */
/*poisson estimates the natural log of the constant -- so lets just set this to exp(2) so the beta should be 2 */
global b0=2
global beta0=exp($b0)

/* The error term needs to be mean 1, with some sd...but this will cause some negative error terms */
global meane=1
global sde=.2

gen error=rnormal($meane, $sde)
gen educ=runiform(1,10)
gen exp=runiform(1,10)

gen lned=ln(educ)
gen lnexp=ln(exp)



gen xb=$beta0+$beta1*lned+$beta2*lnexp+error+qi+ut
gen y=$beta0*educ^$beta1*exp^$beta2*error*qi*ut

*gen y=exp(xb)
gen lny=ln(y)

/*****************************************************/
/*****************************************************/
/* END SETUP */
/*****************************************************/
/*****************************************************/

/*Estimator 1: areg, absorbing indicators */
timer on 1
areg lny lned lnexp, absorb(id)
est store myareg
timer off 1

/*
timer on 5
/*Estimator 5: glm, without FEs is the only poisson type estimator that doesn't have thee exact same results.*/
glm y lned lnexp , link(log) family(poisson)
est store mypoiglm
timer off 5
*/

/*Estimator 3: xtPoisson  */
timer on 3
xtpoisson y lned lnexp,fe vce(robust) 
est store myxtpoi
timer off 3

/*
timer on 6
/*Estimator 6: glm, without FEs*/
glm y lned lnexp i.id, link(log) family(poisson)
est store mypoi_glm_id
timer off 6
*/
timer on 7
/*Estimator 7: ppmlhdfe - not sure why this shows up a slightly different coefficient*/
ppmlhdfe y lned lnexp, absorb(id)
est store myppml
timer off 7



