/* This estimates a log-linear regression using OLS and poisson, robust*/

clear
set seed 55
set obs 5000

/* dgp is ----
straight from the statablog post
 yj = exp(8.5172 + 0.06*educj + 0.1*expj – 0.002*expj2 + error) 
 yj = exp(beta0+ beta1*educj + beta2*expj – beta3*expj2 + error) 

implies that 
lny=beta0+beta1*educ + beta2*exp + beta3*exp^2 + error
 
*/
global beta1=0.06
global beta2=.1
global beta3=-.002
global beta0=8.5172


global meane=0
global sde=1.041

gen error=rnormal($meane, $sde)
gen educ=runiform(1,10)
gen exp=runiform(1,10)


gen xb=$beta0+$beta1*educ+$beta2*exp+$beta3*exp^2+error
gen y=exp(xb)
gen lny=ln(y)

regress lny c.educ c.exp##c.exp 
est store logreg
predict yhat 
replace yhat=exp(yhat)
replace yhat=yhat*exp(e(rmse)^2/2)


poisson y educ c.exp##c.exp, vce(robust) 
est store poireg
est table logreg poireg, equations(1) b se


