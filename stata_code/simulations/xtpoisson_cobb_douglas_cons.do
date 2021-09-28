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
global years 10


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
global beta3=.5 
/*poisson estimates the natural log of the constant -- so lets just set this to exp(2) so the beta should be 2 */
global b0=2
global beta0=exp($b0)

/* The error term needs to be mean 1, with some sd...but this will cause some negative error terms */
global meane=1
global sde=.2

gen error=rnormal($meane, $sde)
gen educ=runiform(1,10)
gen exp=runiform(1,10)

gen dummy=runiform(0,1)
replace dummy=0 if dummy<=.5
replace dummy=1 if dummy>.5

gen lned=ln(educ)
gen lnexp=ln(exp)



*gen xb=$beta0+$beta1*lned+$beta2*lnexp+error+qi+ut+dummy*$beta3



gen y=$beta0*educ^$beta1*exp^$beta2*error*qi*ut
gen dumfx=(exp(dummy)^$beta3)

replace y=y*dumfx
*gen y=exp(xb)
gen lny=ln(y)

/*****************************************************/
/*****************************************************/
/* END SETUP */
/*****************************************************/
/*****************************************************/

/*Estimator 1: areg, absorbing indicators */
timer on 1
areg lny lned lnexp dummy, absorb(id)
est store myareg
timer off 1


/*Estimator 2: xtreg, fe */
timer on 2
xtreg lny lned lnexp dummy, fe
est store myfe
timer off 2


/*Estimator 3: xtPoisson  */
timer on 3
xtpoisson y lned lnexp dummy,fe vce(robust) 
est store myxtpoi
timer off 3



timer on 7
/*Estimator 7: ppmlhdfe - not sure why this shows up a slightly different coefficient*/
ppmlhdfe y lned lnexp dummy, absorb(id)
est store myppml
timer off 7

est table myareg myfe myxtpoi myppml, keep(lned lnexp dummy _cons) equations(1)

 di "True values are: lned= $beta1, lneduc= $beta2, dummy=$beta3 and _cons=$b0 "

