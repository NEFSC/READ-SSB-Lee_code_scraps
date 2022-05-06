
	/*
wooldridge uses \lambda() for the inverse mills ratio.
	lambda = \phi()\ \Phi() where \phi is the standard normal density function and \Phi is the cumulative normal density function
	

	
	
	gen IMR2=normalden(xb)/normal(xb)
	
	\Phi --> normal
	\phi --> normalden
	
	*/


        . webuse womenwk
        . replace wage = 0 if missing(wage)
        . global xvars ib0.married children educ age

        . nehurdle wage $xvars, nolog trunc

		
/* doing the margins after nehurdle, by hand */		
		
		/* extract lnsigma and exponentiate */
		local sig exp(_b[lnsigma:_cons])

		/* define xbs and the Inverse mills ratio */
		local xbw xb(wage)
		local xbs `xbw'/`sig'
		local IMR normalden(`xbs')/normal(`xbs')
		
		/* PSEL */
		/* predicted probabilities */
		margins, predict(psel)
		margins,  expression(normal(xb(selection)))
		
		/*marginal effects */
		margins, dydx(_all) predict(psel)
		
		margins,  expression(normalden(xb(selection))*_b[selection:age])
		margins,  expression(normalden(xb(selection))*_b[selection:children])
		margins,  expression(normalden(xb(selection))*_b[selection:education])
		
		preserve
		replace married=0
		margins,  expression(normal(_b[selection:1.married] + _b[selection:children]*children+ _b[selection:education]*education+_b[selection:age]*age +_b[selection:_cons]) - normal(xb(selection)) )  
		restore

		margins, dydx(_all) predict(psel)

		/* ytrun */
		/* E[y|x, y>0] */

		/* all four of these should be identical*/
		margins, predict(ytrun)
		margins, expression(`xbw'+`sig'*normalden(`xbw'/`sig')/normal(`xbw'/`sig'))
		margins, expression(`xbw'+`sig'*normalden(`xbs')/normal(`xbs'))
		margins, expression(`xbw'+`sig'*`IMR')

		margins, dydx(_all) predict(ytrun)

		
		/* dydx ytrun for education */
 		margins, expression (_b[wage:education]*(1-(`IMR')*(`xbs' + `IMR')))
 		margins, expression (_b[wage:children]*(1-(`IMR')*(`xbs' + `IMR')))
 		margins, expression (_b[wage:age]*(1-(`IMR')*(`xbs' + `IMR')))

		
		
		/*for married, predict ytrun at married =0 and then at married==1 */
		/* the first line predicts xbw and then subtracts off the married effect. For rows where married=1, this sets married =0. And for rows where married=0, this does nothing.*/
		local xbat0 `xbw'-_b[wage:1.married]*married
		local xbat1 `xbat0'+_b[wage:1.married]*1

		local pred_at0 `xbat0'+`sig'*normalden(`xbat0'/`sig')/normal(`xbat0'/`sig')
		local pred_at1 `xbat1'+`sig'*normalden(`xbat1'/`sig')/normal(`xbat1'/`sig')

		margins, expression(`pred_at1'-`pred_at0')

		
		
		/*ycen */
		/* E[y|x] */

		margins, predict(ycen)
		margins,  expression(normal(xb(selection))*xb(wage) + `sig'*normalden(`xbs')   )

		margins, dydx(_all) predict(ycen)

		local PS normal(xb(selection))
		local partial_ytrun _b[wage:age]*(1-(`IMR')*(`xbs' + `IMR'))
		local ytrun xb(wage)+`sig'*normalden(xb(wage)/`sig')/normal(xb(wage)/`sig')
		local partial_PS normalden(xb(selection))*_b[selection:age]
		

		margins,  expression( (`partial_PS')*(`ytrun') + (`PS')*(`partial_ytrun') )
		

		local partial_ytrun _b[wage:children]*(1-(`IMR')*(`xbs' + `IMR'))
		local partial_PS normalden(xb(selection))*_b[selection:children]
		
		
		margins,  expression( (`partial_PS')*(`ytrun') + (`PS')*(`partial_ytrun') )

		
		local partial_ytrun _b[wage:education]*(1-(`IMR')*(`xbs' + `IMR'))
		local partial_PS normalden(xb(selection))*_b[selection:education]
		
		margins,  expression( (`partial_PS')*(`ytrun') + (`PS')*(`partial_ytrun') )
		margins, dydx(_all) predict(ycen)

		
		/*for married, predict ycen at married =0 and then at married==1 */

		
nehurdle wage $xvars, exponential
				
margins, predict(ycen)
		
local sig exp(_b[lnsigma:_cons])

	
		/* extract lnsigma and exponentiate */
		local sig exp(_b[lnsigma:_cons])

	
		/* PSEL */
		/* predicted probabilities */
		margins, predict(psel)
		margins,  expression(normal(xb(selection)))

		/*marginal effects */
		margins, dydx(_all) predict(psel)
		
		margins,  expression(normalden(xb(selection))*_b[selection:age])
		margins,  expression(normalden(xb(selection))*_b[selection:children])
		margins,  expression(normalden(xb(selection))*_b[selection:education])
		

			
		/* ytrun */
		/* E[y|x, y>0] */
		margins, predict(ytrun)
		local ytrun exp(xb(lnwage) +`sig'^2/2)
		margins, expression (`ytrun')
		margins, dydx(_all) predict(ytrun)
		
		margins, expression ((`ytrun')*_b[lnwage:children] )
		margins, expression ((`ytrun')*_b[lnwage:age] )
		margins, expression ((`ytrun')*_b[lnwage:education] )


/* ycen */

	margins, predict(ycen)

	local PS normal(xb(selection))
	local ycen `PS'*`ytrun'
	
	margins,  expression(`ycen')


	margins, dydx(_all) predict(ycen)
	local partial_PS normalden(xb(selection))*_b[selection:age]
	local partial_ytrun `ytrun'*_b[lnwage:age]
	
	margins,  expression(`partial_PS'*`ytrun' + `partial_ytrun'*`PS'  )

	local partial_PS normalden(xb(selection))*_b[selection:education]
	local partial_ytrun `ytrun'*_b[lnwage:education]

	margins,  expression(`partial_PS'*`ytrun' + `partial_ytrun'*`PS'  )

	
	local partial_PS normalden(xb(selection))*_b[selection:children]
	local partial_ytrun `ytrun'*_b[lnwage:children]

	margins,  expression(`partial_PS'*`ytrun' + `partial_ytrun'*`PS'  )

	margins, dydx(_all) predict(ycen)

	
	
	/* for discrete vars we plug in the finite approx for the deriviatives [Y|x=1 - Y|x=0] */