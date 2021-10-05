/* Code/ Pseudo code to do Vuong's non-nested test. 

References:
1. Vuong 1989
2. Wooldridge's 2010 version of Econometric Analysis of Cross Section and Panel Data.
  Equation 13.76
  
  The numerator is the difference in sum of lnL's, the denominator relies on individual lnL's.

 Wooldridge describes a regression based test:
	1.  Define D=lnL(1)-lnL(2), where lnL(1) and lnL(2) are the log-likelihoods of models 1 and 2
	2.  Regress D on 1 and test whether the constant is equal to zero.  Perhaps use a robust or cluster robust VCE in the auxilliary regression.

	
This stata blog post shows how to get the log-likelihood values
https://blog.stata.com/2011/02/16/positive-log-likelihood-values-happen/
 you *just* evaluate the lnL function at the optimzed values.

3.  Wooldridge shows how to do this in a linear FE context. The objective function for OLS/ xtreg, fe is to minimize the sum of squared residuals. Therefore, all you need to do is predict the residuals and square them. It's not always this easy. 
 https://www.statalist.org/forums/forum/general-stata-discussion/general/1332690-performing-vuong-s-1989-likelihood-ratio-test-for-equivalence-of-explanatory-power-in-nonnested-models
 xtreg y x1 x2 ... xK, fe
predict u1h, e
gen uh1sq = uh1^2
xtreg y z1 ... zM, fe
predict uh2, e
gen uh2sq = uh2^2
gen diff = uh1sq - uh2sq
reg diff, cluster(csid)
 
 
 Note: He also has a nice post on how to compare the logit and probit:
 
 probit y x1 x2 ... xK i.year
predict phat_probit
gen llf_probit = (1 - y)*log(1 - phat_probit) + y*log(phat_probit)
logit y x1 x2 ... xK i.year
predict phat_logit
gen llf_logit = (1 - y)*log(1 - phat_logit) + y*log(phat_logit)
gen diff_llf = llf_probit - llf_logit
reg diff_llf, cluster(csid)

*/


 


est drop _all
clear
pause on
webuse fitness






churdle linear hours age i.smoke distance, ll(0) select(age i.smoke)
est store ch

truncreg hours age i.smoke distance, ll(0)
mat bout = e(b)
est store trunc

probit hours age i.smoke
mat bsel = e(b)

est store prob
est table ch trunc prob, equations(1:1:., 2:.:1)


/* fitting the churdle by hand with mlexp from statacorp */
/* 	zb corresponds to the selection equation 
	xb is the outcome equation */

mat binit = bsel,bout[1,1..5],ln(bout[1,6])

* Set-up for -mlexp-:
local ll 0
local depvar hours
local xb age i.smoke distance _cons
local zb age i.smoke  _cons

* Estimate using -mlexp-:
mlexp ///
((`depvar' ==`ll')*lnnormal(-{zb:`zb'})+(`depvar' >`ll')*lnnormal({zb:}) + ///
(`depvar' > `ll')*(-lnnormal({xb:`xb'}/exp({lnsigma})) +                   ///
                    lnnormalden(`depvar' -{xb:},exp({lnsigma})))),from(binit)
					
est store mlexp				
					
nehurdle hours age i.smoke distance, trunc 

nehurdle hours age i.smoke distance, trunc  select(age i.smoke)
est store nehurdle

/*syntax of craggit is ''backwards'' from the syntax of nehurdle and churdle 
doesn't take factor variables*/
gen smoke1=smoke==1
craggit  hours age smoke1 , second(hours age smoke1 distance) 







/* so here's the code */
/* step 1: estimate the exponential version */

/* step 1A: compute the log-likelihood */
/* placeholder */
gen lnL_exponential=.

/* step 2: estimate the linear version */

/* step 2A: Compute the log-likelihood version */
/* placeholder */

gen lnL_linear=.

/* step 3: Take the difference and then regress on a constant */
gen D=lnL_linear-lnL_exponential

regress D, vce(robust)











