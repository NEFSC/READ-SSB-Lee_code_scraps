/*OLS type DGP */
clear
set seed 5454
set obs 1000
global beta 2

gen x=rnormal()
gen e=rnormal()
gen y=2*x+e

regress y x


/* Now X1 is endogenous */


gen x1=x+.5*e
corr x1 e

gen y1=2*x1+e

/*crap!  -- things break*/
regress y1 x1

/* now, we have a variable z that is correlated with x1, but not correlated with e */


gen z2=rnormal()
gen x2=rnormal()+.4*z2+.5*e

gen x3=rnormal()
gen y2=2*x2+e +.5*x3

/* Regress is biased, but IVREGRESS works! */

regress y2 x2 x3
est store biased_ols
ivregress 2sls y2 (x2=z2 ) x3
est store consistent_ivreg
/* first stage */
regress x2 z2 x3
predict errors, resid

regress y2 x2 x3 errors
est store control_function
est table biased_ols consistent_ivreg control_function



/* The control function approach 
skrondal and reabe-hesketh 2004; r-h 2004

Rabe-Hesketh, Sophia, Anders Skrondal, and Andrew Pickles. 2004.
“Generalized multilevel structural equation modeling,” Psychometrika,
69(2), 167–190.
Skrondal, Anders and Sophia Rabe-Hesketh. 2004. Generalized latent
variable modeling: Multilevel, longitudinal, and structural equation
models, Boca Raton, Florida: Chapman and Hall/CRC.
*/


/* AN RC perspective 
sales nested inside days
*/


























