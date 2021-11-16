/* I've we're going to do a hurdle, we need to describe why we're not doing the alternatives to a hurdle model

Poisson and ZIP
Negative binomial and ZI NBreg

Poisson, ZIP, nbreg, and ZINBREG

Tobit. Tobit is nested in churdle linear, so this is easy to dispense with.

	Tobit is a special case of churdle linear.  
	Churdle linear is more flexible because the relative effects of two RHS variables on the participation probabilites can be different from the relative efects of those variables on the "E0 mean"






Exponential
	E[y|x, y>0 ]and E[y|x] formulae are given in Wooldridge, p 537

	
	
wooldridge uses \lambda() for the inverse mills ratio.
	lambda = \phi()\ \Phi() where \phi is the standard normal density function and \Phi is the cumulative normal density function
	
	
	gen IMR2=normalden(xb)/normal(xb)
	
	
	
	https://www.statalist.org/forums/forum/general-stata-discussion/general/1325438-exponentiating-coefficients-in-margins-and-a-couple-other-things
	
	
*/
/* to read
Boucher, J.P.; Santolino, M. Discrete distributions when modeling the disability severity score of motor
victims. Accid. Anal. Prev. 2010, 42, 2041–2049. [CrossRef] [PubMed] 


*/


 


est drop _all
clear
pause on
webuse fitness
/* From Wooldridge: General Things
Consider a binary variable (w=0,1) and a continuous variable y* that is NON-NEGATIVE
we have
y=wy*
We always observe w, but we don't always observe y*: we only observe y* if w=1

Assume w and y* are independent conditional on x variables:

D(y*|w,x)=D(y*|x) (I think this means the distribution of y* conditional on w and x is the same as the distribution of y* conditional only on x)

expected value of y conditional on x and w is:
E[y|x,w] = w*E[ystar|x,w]=wE[ystar|x] as long as the conditional mean of w and ystar are independent.  Pretty sure this is just iterated expectations.


Conditional (on y>0 AND x) expectation of y is
E[y|x,y>0] = E[ystar|x] <--probably i wrote this wrong.

the Unconditional expectation
e[Y|x] = E[w|x]*E[ystar|x] = P[w=1|x]E[ystar|x]

In true sample selection environments, the outcome of the selection variable (w in the current notation) does not logically restrict the
outcome of the response variable. Here, w=0 precludes y >0.

*/


/*
Wooldridge to stata correspondence

1.  Wooldridge's E[y|x]  <---> stata's ystar <--> nehurdle, predict(ycen)


Wooldridge's powerpoint slides
	E[y|x] = \Phi{x\gamma}[xBeta + \sigma * \lambda(XBeta/sigma)]
	

stata's ystar is more general, because it allows for an upper limit and a lower limit.  

2.  Wooldridge's E[Y|x,y>0] <---> stata's e(0,.)  <--> nehurdle, predict(ytrun)

E[Y|x,y>0] = xB = \sigma \lambda(Xb / \sigma)
stata's e(a,b) is more general because it allows for an upper and lower limit.



*/




churdle exponential hours age i.smoke distance, ll(0) select(age i.smoke distance)
est store chexp
gen lny=ln(hours)





churdle linear hours age i.smoke distance, ll(0) select(age i.smoke)
est store ch

truncreg hours age i.smoke distance, ll(0)
mat bout = e(b)
est store trunc

probit hours age i.smoke
mat bsel = e(b)

est store prob
est table ch trunc prob, equations(1:1:., 2:.:1)




/*probit hours age i.smoke distance */


/*Predicted values and elasticities */
/* Predicted values */
/* probabilities of being positive are just the same as in the churdle linear model, so skip that*/

/*********************************************************************/
/*BY HAND


"linear" prediction of the "xb" part from OLS*/
/*********************************************************************/
est restore lnyreg
predict xb_olse, xb
/* smear, this gives us E[y|x, y>0] */
gen yhat_ols=exp(xb_olse) 
replace yhat_ols = yhat_ols*exp(e(rmse)^2/2)


/* the E[y|x] by hand */
gen ystar_hand=yhat_ols*prob_probit






/*********************************************************************/
/*"linear" predictions from churdle*/
/*********************************************************************/
est restore chexp
predict xb_chexp, xb

/*********************************************************************/
/* the E[y|x AND y>0] */
/*********************************************************************/
predict e0dot_chexp, e(0,.)

/*********************************************************************/
/* the E[y|x] */
/*********************************************************************/
predict ystar_C






/*********************************************************************/
/*"linear" predictions from nehurdle, exponential*/
/*********************************************************************/
est restore nehurdle_exp
predict xb_neexp, xbval

/*********************************************************************/
/* the E[y|x AND y>0] */
/*********************************************************************/
predict e0dot_neexp, ytrun

/*********************************************************************/
/* the E[y|x] */
/*********************************************************************/
predict ystar_ne, ycen






/* a little concerned about 














/* truncated normal hurdle model (nehurdle, or churdle linear) 
E[ytrun]=E[e(0,.)]= E[y|x, y>0] = X\beta +  \sigma IMR(xb\sigma)
E[ycen]=E[ystar]= E[y|x] = \normal(x\gamma) * [X\beta + \sigma*IMR(xb\sigma)]
*/




/* lognormal hurdle model (nehurdle, exponential or churdle exponential) 
E[ytrun]=E[e(0,.)]= E[y|x, y>0] = exp(X\beta + \sigma^2/2)
E[ycen]=E[ystar]= E[y|x] = \normal(x\gamma) * exp(X\beta + \sigma^2/2)
*/




/* LL_P0 and lin_log3 are a little harder to compute  look at that stata journal article. */

/* Lognormal hurdle model with logs on the RHS model */

est restore LL_P0




/* Dy/dx */
margins, dydx(q_fy) predict(psel)


/* YTRUN :  For the discrete variables, you can use canned stata. */
margins, dydx(q_fy) predict(ytrun)

/*    for the continuous variables where x_j=ln(z_j)  and we care about dytrun/dz_j, we need to evaluate this:

\beta_j*(exp X\beta + sigma^2/2)* 1/z_j

*/
local exp_sandwich  exp(xb(lnbadj_GDP) + 0.5*(exp(_b[lnsigma:_cons]))^2)

/* price */
margins, expression(_b[lnbadj_GDP:ln_live_priceGDP]* `exp_sandwich'/live_priceGDP  )
/* quota remaining */
margins, expression(_b[lnbadj_GDP:ln_quota_remaining_BOQ]* `exp_sandwich'/quota_remaining_BOQ)
/* WTswt_quota_remaining_BOQ*/
margins, expression(_b[lnbadj_GDP:WTswt_ln_quota_remaining_BOQ]* `exp_sandwich' /WTswt_quota_remaining_BOQ)







/* YCEN :  For the discrete variables, you can use canned stata. */
margins, dydx(q_fy) predict(ycen)


/*    for the continuous variables where x_j=ln(z_j)  it is complicated.  The expression is for the conditional mean is : 

\normal(x\gamma)exp(xbeta + \sigma^2/2)

For things that are in the level equation, but not the selection equation, we just mulitply the ytrun marginal effect by \normmal(xgamma)
for things that are in both, we have to apply the chain rule 
the derivative of the first part is:

\gamma_j*IMR()/z_j*exp(xbeta + sigma^2/2)



*/
local IMR  normalden(xb(selection))/normal(xb(selection))

/* price */
margins, expression(normal(xb(selection))*_b[lnbadj_GDP:ln_live_priceGDP]* `exp_sandwich'/live_priceGDP  )
/* WTswt_quota_remaining_BOQ*/
margins, expression(normal(xb(selection))*_b[lnbadj_GDP:WTswt_ln_quota_remaining_BOQ]* `exp_sandwich' /WTswt_quota_remaining_BOQ)


/* quota remaining  this is not quite right, because I'm not accounting for the quota_remaining in the ln_fraction variable */

margins, expression((_b[selection:ln_quota_remaining_BOQ] + _b[selection:ln_fraction_remaining_BOQ] )*`IMR'/quota_remaining_BOQ*`exp_sandwich' +  normal(xb(selection))*_b[lnbadj_GDP:ln_quota_remaining_BOQ]* `exp_sandwich'/ quota_remaining_BOQ)






/* for the continuous variables that are only in the level equation, this prety easy */



margins, expression(_b[lnbadj_GDP:ln_live_priceGDP]/live_priceGDP  )
margins, expression(_b[lnbadj_GDP:WTswt_ln_quota_remaining_BOQ]/WTswt_quota_remaining_BOQ)








/* elasticities */

/* YTRUN :  For the continuous variables, the coefficients in the levels equations are elasticities of ytrun wrt x */
/* there's no need to do a margins here */
/* YCEN:  For the continuous variables, elasticities are \gamma_j* IMR( x\gamma) + \beta_j */


/* The ycen elasticities are equal to the ytrun elasticities for the variables that are only in the level equation but not in the selection equation */

margins, expression(_b[lnbadj_GDP:ln_quota_remaining_BOQ] + normalden(xb(selection))/normal(xb(selection))*(_b[selection:ln_quota_remaining_BOQ] + _b[selection:ln_fraction_remaining_BOQ]))


expression(exp(predict(xb)))


