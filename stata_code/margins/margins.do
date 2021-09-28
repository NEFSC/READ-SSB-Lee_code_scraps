/* code to compute marginal effects and elasticities for continuous variables and discrete effects for dummy variables after estimating a probit.


One section is for estimating with levels on the RHS

Another section is for estimating with logs on the RHS. 


See Greene, chapter 21, pages 666-668.  

Definitions:
\Phi is the standard normal distribution; normal() 
\phi is the standard normal density function, normalden()
F() as a function with derivative f()

 In particular, equation 21-6:
P[Y=1|x] = \Phi(x'Beta)

and equations 21-8 to 21-10
E[y|x] = F(x'Beta)
\partialE[y|x] \partial x = f(x'Beta)\beta

and 

\partialE[y|x] \partial x = \phi(x'Beta)\beta

*/

/* load in the data */
clear
sysuse auto
gen adj_rep=rep78<=3




/*estimate the probit in levels */
probit foreign c.weight c.mpg i.adj_rep
est store probit1



/* estimate in logs */

gen lnw=ln(weight)
gen lnmpg=ln(mpg)


probit foreign c.lnw c.lnmpg i.adj_rep
est store probit_logs



/**********************************************************************************************/
/**********************************************************************************************/
/*******************************MARGINAL EFFECTS***********************************************/
/**********************************************************************************************/
/**********************************************************************************************/



est restore probit1 
est replay probit1


/* predict p, xb, and \phi(xb) */
predict p
predict xb, xb
gen nxb=normalden(xb)


/* use 21-10 from Greene, page 668 to compute the marginal effects of weight and mpg on the probability of foreign */
gen marginal_weight=nxb*_b[weight]
gen marginal_mpg=nxb*_b[mpg]




/* use the un-numbered equation from Greene, p668  for the discrete effect 
just predict at (1) and (0) 
*/

gen xb0=_b[weight]*weight+_b[mpg]*mpg+_b[_cons]
gen xb1=_b[weight]*weight+_b[mpg]*mpg+_b[_cons] + 1*_b[1.adj_rep]


/* an alternative way to do this is: */
predict xb0A, xb
replace xb0A=xb0A-adj_rep*_b[1.adj_rep]
gen xb1A=xb0A+1*_b[1.adj_rep]

/*there are some machine precision things going on here, but accurate to 1e-6*/
assert abs(xb0-xb0A)<=1e-6
assert abs(xb1-xb1A)<=1e-6


gen pr0=normal(xb0)
gen pr1=normal(xb1)

gen marginal_effect=pr1-pr0


/* the means from the summation table should match the margins table 
Margins se's are using the delta method.
Summation table just */
summ marginal*
margins, dydx(*)




/**********************************************************************************************/
/**********************************************************************************************/
/******************************* END MARGINAL EFFECTS******************************************/
/**********************************************************************************************/
/**********************************************************************************************/




/**********************************************************************************************/
/**********************************************************************************************/
/*******************************  ELASTICITIES ************************************************/
/**********************************************************************************************/
/**********************************************************************************************/



/* use the elasticity formula */
gen elasticity_weight=marginal_weight*weight/p
gen elasticity_mpg=marginal_mpg*mpg/p

margins, eyex(weight mpg)
summ elasticity*


/**********************************************************************************************/
/**********************************************************************************************/
/******************************* END ELASTICITIES *********************************************/
/**********************************************************************************************/
/**********************************************************************************************/





est restore probit_logs
est replay probit_logs

predict xb2, xb
predict pr2, p


/* example of predict nl, which will be very important later */
/* this is equivalent to
predict pr2, p after the probit*/
predictnl phat=normal(xb())



/**********************************************************************************************/
/**********************************************************************************************/
/*******************************MARGINAL EFFECTS***********************************************/
/* When we have logs on the RHS, the for a marginal effect is a little more complicated 
(assuming we are interested in the average effect of a change in x on Pr(y=1) and not the average effect 
of a change in ln(x) on Pr(y=1) )

Now,  equation 21-6  from Greene is:

E[y|x] = F(lnx'Beta)

And the partial effect is 

\partialE[y|x] \partial x = f(lnx'Beta)\beta /x


We can't get stata's margins to produce this by hand with margins (see the margins manual, "Expressing derivatives as elasticities" section.  )
*/
/**********************************************************************************************/
/**********************************************************************************************/


/* here is a 1 step way to compute the marginal effect using predictnl*/
/*compute the marginal marginal effect using predictnl*/
predictnl pnl_marginal2_mpg=normalden(xb(#1))*_b[lnmpg]/mpg
predictnl pnl_marginal2_weight=normalden(xb(#1))*_b[lnw]/weight


/* here is another way to do it, using predict xb2, xb */
/* compute the marginal effect "by hand" */
gen marginal2_mpg=normalden(xb2)*_b[lnmpg]/mpg
gen marginal2_weight=normalden(xb2)*_b[lnw]/weight

/*verify these are equivalent */
assert abs(pnl_marginal2_mpg-marginal2_mpg)<=1e-8
assert abs(pnl_marginal2_weight-marginal2_weight)<=1e-8


/* E[Y|X] = \Phi(ZB)

when Z=ln(x), then the marginal effect of x on E[Y|X]= \phi(zb)*b/x.

This isn't one of stata's canned dydx, eyex, dyex, eydx options. So you have to compute it by hand */


/* pass the expressions from pnl into the margins command */

/* compute the marginal effect of a 1 unit increase in mpg or weight on the probabilty of foreign */
/* margins, expression() is nice because it does the delta method for you*/
margins, expression(normalden(xb(#1))*_b[lnmpg]/mpg)
margins, expression(normalden(xb(#1))*_b[lnw]/weight)


/*note, none of these match the previous */
margins, dydx(lnw)
margins, dyex(lnw)
margins, eydx(lnw)
margins, eyex(lnw)

pause


/* perhaps comfortingly, the margins after the linear and log forms match pretty closely*/
summ marginal2_weight marginal_weight
summ marginal2_mpg marginal_mpg
pause

/* the method for computing the discrete effect of adj_rep is exactly the same as before, so I am not going to put it in here */


/**********************************************************************************************/
/**********************************************************************************************/
/******************************* END MARGINAL EFFECTS******************************************/
/**********************************************************************************************/
/**********************************************************************************************/




/**********************************************************************************************/
/**********************************************************************************************/
/*******************************  ELASTICITIES ************************************************/
/**********************************************************************************************/
/**********************************************************************************************/


/*******************************

The Marginal effect is
\partialE[y|x] \partial x = f(lnx'Beta)\beta /x

To get an elasticity, we multiply by (x/y)

The elasticity formula becomes
e  = f(lnx'Beta)\beta /x * (x/y)
   = f(lnx'Beta)\beta /y

   where y is the predicted probabilty
 
*/

/* compute this by hand  */
gen elast_mpg2=normalden(xb2)*_b[lnmpg]/pr2
gen elast_weight2=normalden(xb2)*_b[lnw]/pr2

/* using predictnl syntax   */
predictnl pnl_elast2_mpg=normalden(xb(#1))*_b[lnmpg]/normal(xb(#1))
predictnl pnl_elast2_weight=normalden(xb(#1))*_b[lnw]/normal(xb(#1))

/* this is equivalent to using the eydx shortcut in margins 
(see the margins manual, "Expressing derivatives as elasticities" section.  )
*/

margins, eydx(lnw )
summ elast_weight2 



margins, eydx(lnmpg)
summ elast_mpg2

pause



/* here is code to evaluate the eydx elasticity using margins, expression()*/
margins, expression(normalden(xb(#1))*_b[lnmpg]/normal(xb(#1)))
margins, expression(normalden(xb(#1))*_b[lnw]/normal(xb(#1)))



/* can also refer using the depvar as the equation name*/
