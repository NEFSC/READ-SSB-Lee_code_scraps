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



/* a simple cragg hurdle */

/*********************************************************************/
/*********************************************************************/
/*Stata's churdle linear just does a truncated regression and a probit together 

truncreg fits a regression model of depvar on indepvars from a sample
drawn from a restricted part of the population. Under the normality assumption 
for the whole population, the error terms in the truncated regression model 
have a truncated normal distribution, which is a normal distribution that has been 
scaled upward so that the distribution integrates to one over the restricted range


If you look at the log-likelihood function, the terms for the probit (gammas) and for the truncated part (betas) don't interact with each other. That is, if you 
take a derivative wrt the gammas, the xB terms don't appear. And if you take a derivative of the ll with respect to the betas, the gamma terms dont' appear. So this basically means you can estimate them separately. 
And that's precisely what stata does.  However, the expectations of course depend on both parts.

*/
/*********************************************************************/
/*********************************************************************/











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




























/*********************************************************************/
/*********************************************************************/
/************************Predicted values ***************************/
/*********************************************************************/
/*********************************************************************/

/* probabilities of being positive are the same from the probit, churdle, nehurdle */
/* PROBIT */
est restore prob
predict prob_probit, pr

predict xb_probit, xb
gen IMR=normalden(xb_probit)/normal(xb_probit)


/* CHURDLE*/
est restore ch
predict prob_ch, pr(0,.)

/* NEHURDLE */
est restore nehurdle
predict prob_neh, psel


/* probabilities of being positive*/

summ prob_ch prob_probit prob_neh
assert prob_ch==prob_probit
assert abs(prob_neh-prob_probit)<=1e-6


/* Past the hurdle */


est restore ch

/* Past the hurdle */
predict xb_ch, xb
predict ystar_ch, ystar(0,.)
predict e0dot_ch, e(0,.)

est restore trunc


predict xb_tr, xb
predict ystar_tr, ystar(0,.)
predict e0dot_tr, e(0,.)


est restore nehurdle
predict e0dot_ne, ytrun

predict ycen_ne, ycen

/*linear prediction from churdle and truncreg is the same */
summ xb_ch xb_tr
assert xb_ch-xb_tr<=1e-6

/*linear prediction, conditional on being positive is the same, which follows directly, since the linear prediction is the same and the predicted probabilities are the same */
assert e0dot_ch-e0dot_tr<=1e-6
assert e0dot_ch-e0dot_ne<=1e-6



/* ystar is the "latent" variable.  ystar may be negative. For me, this doesn't have a economic interpretation.  ystar(a,b) the ystar, but confined to the (a,b) interval */

/* note that the ystar from the churdle is *not* the same as the ystar from the truncreg */
summ ystar_ch ystar_tr ycen_ne

/* ystar from the ch is the same a ycen from nehurdle you cannot get truncreg to match it, because? I think this depends on both parts*/


/*********************************************************************/
/*********************************************************************/
/*****************************elasticities ***************************/
/*********************************************************************/
/*********************************************************************/

est restore ch
margins, dydx(distance age) predict(ystar)
est restore nehurdle
margins, dydx(distance age) predict(ycen)



est restore ch
margins, eyex(distance age) predict(ystar)
est restore nehurdle
margins, eyex(distance age) predict(ycen)




est restore ch
margins, dydx(distance age) predict(e(0,.))
est restore nehurdle
margins, dydx(distance age) predict(ytrun)


est restore ch
margins, eyex(distance age) predict(e(0,.))


est restore nehurdle
margins, eyex(distance age) predict(ytrun)







/*elasticities*/





/* also note that ln sigma and sigma are related  as exp(lnsigma)=sigma*/
/* also note that this*/
regress hours age i.smoke distance if hours>0
est store ols

/* is not the same as truncreg */
truncreg hours age i.smoke distance, ll(0)
est table ols trunc, equations(1) b se










/*Stata's churdle exponential does a probit together with a regress lny `xvars'*/

/*
If you look at the log-likelihood function, the terms for the probit (gammas) and for the exponential part (betas) don't interact with each other. That is, if you 
take a derivative wrt the gammas, the xB terms don't appear. And if you take a derivative of the ll with respect to the betas, the gamma terms dont' appear. So this basically means you can estimate them separately. 
And that's precisely what stata does.  However, the expectations of course depend on both parts*/

churdle exponential hours age i.smoke distance, ll(0) select(age i.smoke distance)
est store chexp
gen lny=ln(hours)


regress lny age i.smoke distance if hours>0
est store lnyreg
est table chexp lnyreg prob, equations(1:1:., 2:.:1) b se


poisson hours age i.smoke distance if hours>0, robust
est store poireg

/* coeffs are basically the same */
est table chexp lnyreg poireg prob, equations(1:1:1:., 2:.:.:1) b se

/* exponential */
nehurdle hours age i.smoke distance, trunc exponential select(age i.smoke distance) 
est store nehurdle_exp



/* coeffs are basically the same for churdle, separate lnyreg+probit, and nehurdle. Poisson gives different coefficients for the value equation, but they are similar. */
est table chexp lnyreg poireg prob nehurdle_exp, equations(1:1:1:.:2, 2:.:.:1:1) b se





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




/* these match */
summ e0dot_neexp e0dot_chexp
summ ystar_ne ystar_C

/*this does not */
summ xb_chexp xb_neexp yhat_ols
pause

/*********************************************************************/
/* check that they are the same */
/*********************************************************************/
/*********************************************************************/
/*"linear" predictions */

summ xb_olse xb_chexp
assert abs(xb_olse-xb_chexp)<=1e-6



/* the E[y|x, y>0] */
summ yhat_ols e0dot_chexp
assert abs(yhat_ols-e0dot_chexp)<=1e-3


/* the E[y|x]  This does not match.  */
summ ystar_C ystar_hand
*assert abs(ystar_C-ystar_hand)<=1e-3






/*********************************************************************/
/*********************************************************************/
/**********************elasticities or partial effects  **************/
/*********************************************************************/
/*********************************************************************/

/* The for churdle exponential, if the 
the semi elasticity of E[y|x] is
\gamma_j * IMR + \beta_j

This formula is in the wooldridge powerpoint
*/

est restore chexp
gen semi_dist= _b[hours:distance] + IMR*_b[selection_ll:distance]

/* semi-elasticity, by hand */
summ semi_dist

/* elasticity, by hand */
gen elast_dist= semi_dist*distance


/* semi-elasticity, canned */
margins, eydx(distance)
summ semi_dist
pause

margins, expression(_b[hours:distance] + normalden(xb(#2))/normal(xb(#2))*_b[selection_ll:distance])
margins, expression(_b[hours:distance] + normalden(xb(selection_ll))/normal(xb(selection_ll))*_b[selection_ll:distance])


/***************************
MATCH 
**************************/



/* elasticity, canned */
margins, eyex(distance)

summ elast_dist
/***************************
MATCH 
**************************/

/* the conditional elasticity */
/* the semielasticty of E[y|x, y>0] is just \beta_j 
the elasticity of E[y|x, y>0] is therefore \beta_j*X_j */

/* semi-elasticity by hand */
est restore chexp

/* semi-elasticity canned */
margins, eydx(distance) predict(e(0,.))

/* elasticity by hand */
gen elast_distE0=_b[hours:distance]*distance

/* elasticity canned */
margins, eyex(distance) predict(e(0,.))
summ elast_distE0

margins, expression(_b[hours:distance]*distance)





/***************************
MATCH 
**************************/




est restore chexp
margins, dydx(age)

est restore chexp
margins, eyex(age)

est restore nehurdle_exp
margins, dydx(age) predict(ycen)

est restore nehurdle_exp
margins, eyex(age) predict(ycen)



est restore chexp
margins, dydx(age) predict(e(0,.))

margins, eyex(age) predict(e(0,.))

est restore nehurdle_exp
margins, dydx(age) predict(ytrun)
margins, eyex(age) predict(ytrun)


/* WOOLDRIDGE GIVES the formulas if there is a logged RHS variable. */

/* With a log-specification, the elasticity is simply \beta */

/* TEST */
/* If the log-linear and log-log specifications are reasonable, then the elasticity (\beta from the log-log specification) should be similar to the elaisticity from the log-linear specification). 

The log-log spec has an elasticity of 0.0311  and the log-linear spec has an elasticity of 0.0482.  That is pretty similar. 

The "unconditional" elasticity is 

\gamma_j * IMR(x \gamma) + beta_j
*/



gen lndist=ln(distance)
gen lnage=ln(age)


churdle exponential hours lnage i.smoke lndist, ll(0) select(lnage i.smoke lndist)
est store log_log

probit hours lnage i.smoke lndist

predict xb_ll, xb
gen IMR_ll=normalden(xb_ll)/normal(xb_ll)


est restore log_log

gen elast_dist_ll= _b[hours:lndist] + IMR_ll*_b[selection_ll:lndist]

margins, eydx(lndist) predict(ystar)
summ elast_dist_ll


margins, expression(_b[hours:lndist] + normalden(xb(selection_ll))/normal(xb(selection_ll))*_b[selection_ll:lndist])


/************
MATCH  
To compute the elasticity, we use eydx.  nehurdle and churdle are aware of the "ln" on the LHS. 
***********/
nehurdle hours lnage i.smoke lndist, trunc exponential select(lnage i.smoke lndist)

margins, eydx(lndist) predict(ycen)



margins, expression(_b[lnhours:lndist] + normalden(xb(selection))/normal(xb(selection))*_b[selection:lndist])









/* Endogeneity */
/* CF methods are to be appropriate

Ricker-Gilbert2011 AJAE : Dispense with a heckman.  Notes that a Tobit is a subset of a Hurdle model. They call it a double hurdle, but I'm not 100% sure of that.
	Hurdle 1: Participate or not in the fertilizer market (Probit)
	
	Hurdle 2: How much to buy. (Truncated OLS)
	
	Control function for endogeneous continous variables - They use a Tobit for the first stage (Quantity of Subsidized Fertilizer). The residual from the 1st stage goes into the Probit part, but not into the Truncreg part; however, this is an empirical result, it looks like they try it with that residual.
	Unobserved heterogeneity using a Chamberlain-Mundlak (CRE) estimator
	
	They want the "unconditional APE"
	APE is the partial effect computed for all, then averaged over the population
		Bootstrapped. 
		They are a little unclear about what APE they are computing.  But I believe this is the "ystar" version.
	
	They use Burke (2009)'s craggit

	
Verkaart Food policy 2016: Farmers acreage using improved seed
	Unobserved heterogeneity Also use the Chamberlain-Mundlak CRE to avoid the incidental parameters problem
	Unobserved Shocks (endogeneity) - ability to buy seed (tech transfer) is likely correlated with the dependent variable. The argument is not well laid out, but I'm not going to fight it.
	
	
	Cragg's DH linear or exponential?
		In both equations, there are the endogenous, exogenous, CREs, and residuals. 
		"Bootstrap"
	
	They present coefficients, not APE/ marginal effects/elasticities.
	
	Bezu et al 2014
	Also present coefficients -- but less interested in the hurdle itself and more interested in using it to explain changes in other stuff.
	*/
	
/*
1. The market price for quota fits perfectly into the "corner solution" setup described by Wooldridge. This is just Walras law of zero valued excess demand. 

	If all the individual demand functions x(p,w) are continuous, then we have the excess demand function:
	
	z(p)=sum x_i(p,w)-\omega_i
for any price vector p, we must have p*z(p) \equiv 0.

We therefore have --- if prices are non-zero, then we have Q_s=Q_d
if there is excess supply, then the price must be zero.
	
On one hand, I have a big enough n (16/17) and t(40ish). But perhaps I don't because it's 16 x 11.
	The "invidvidual-ness", resets itself every year, because it isn't an actual individual, but a market outcome.
	
	
	
	

*/



