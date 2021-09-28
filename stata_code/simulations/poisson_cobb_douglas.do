/* This estimates a log-log regression using OLS and poisson, robust*/

clear
set seed 55
set obs 5000

/* dgp of
y=qE^b1X^b2*error
lny=beta0+beta1*ln(educ) + beta2*ln(exp)+ error
*/

global beta1=0.06
global beta2=.1
/*global beta3=-.002 */
/*poisson estimates the natural log of the constant -- so lets just set this to exp(2) so the beta should be 2 */
global beta0=exp(2)

/* The error term needs to be mean 1, with some sd...but this will cause some negative error terms */
global meane=1
global sde=.2

gen error=rnormal($meane, $sde)
gen educ=runiform(1,10)
gen exp=runiform(1,10)

gen lned=ln(educ)
gen lnexp=ln(exp)



gen xb=$beta0+$beta1*lned+$beta2*lnexp+error
gen y=$beta0*educ^$beta1*exp^$beta2*error

*gen y=exp(xb)
gen lny=ln(y)

regress lny lned lnexp
est store logreg

*predict yhat 
*replace yhat=exp(yhat)
*replace yhat=yhat*exp(e(rmse)^2/2)


poisson y lned lnexp , vce(robust) 
est store poireg
est table logreg poireg, equations(1) b se


